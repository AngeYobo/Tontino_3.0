import { Lucid, Blockfrost, SpendingValidator, validatorToAddress, Data, Constr, getAddressDetails } from "@lucid-evolution/lucid";
import { useCardano } from "@cardano-foundation/cardano-connect-with-wallet";
import { NetworkType } from "@cardano-foundation/cardano-connect-with-wallet-core";
import React, { useState } from "react";
import dynamic from "next/dynamic";

// Helper function to convert a bech32 address to a public key hash (hex string)
const getPublicKeyHashFromAddress = (address: string): string | null => {
  try {
    const details = getAddressDetails(address);
    if (details.paymentCredential && details.paymentCredential.type === "Key") {
      return details.paymentCredential.hash; // Public Key Hash as a hex string
    }
    console.error("Unable to extract payment credential from address:", address);
    return null;
  } catch (error) {
    console.error("Error converting address to public key hash:", error);
    return null;
  }
};

const ReDeem = () => {
  const networkEnv =
    process.env.NEXT_PUBLIC_NETWORK_ENV === "Preprod"
      ? NetworkType.TESTNET
      : NetworkType.MAINNET;

  const { isConnected, enabledWallet } = useCardano({
    limitNetwork: networkEnv,
  });

  const [isLoading, setIsLoading] = useState(false);
  const [txHash, setTxHash] = useState<string | null>(null);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [winnerIndex, setWinnerIndex] = useState<number | string>("");

  const ReDeem = async () => {
    if (!isConnected || !enabledWallet || isNaN(Number(winnerIndex))) {
      setErrorMessage("Invalid input or wallet not connected.");
      return;
    }

    setIsLoading(true);
    setTxHash(null); // Reset the transaction hash
    setErrorMessage(null); // Reset the error message

    try {
      const blockfrostApiKey = process.env.NEXT_PUBLIC_BLOCKFROST_KEY_PREPROD || "";
      const networkEnv = "Preprod"; // Or "Mainnet" depending on your environment

      // Initialize Lucid
      const lucid = await Lucid(
        new Blockfrost(
          `https://cardano-${networkEnv.toLowerCase()}.blockfrost.io/api/v0`,
          blockfrostApiKey
        ),
        networkEnv
      );

      const validatorScript = "5902540101003232323232323225333002323232323253330073370e900118041baa001132323253323300b3001300c375400c26464a66602060260042a66601a6006601c6ea80104c8c94ccc03cc014c040dd5000899299980819198008009bac3016301730173017301730173017301730173013375401c44a66602a00229404c94ccc04ccdc79bae301800200414a22660060060026030002264a666022600e60246ea800454ccc0454ccc050c8cc004004c8cc004004dd5991800980b1baa3001301637546032602c6ea80108c064c068004894ccc05c00452f5bded8c0264646464a66603066e45220100002153330183371e9101000021003100513301c337606ea4008dd3000998030030019bab3019003375c602e0046036004603200244a66602c002297ae0132333222323300100100322533301c00110031323301e374e6603c6ea4018cc078c06c004cc078c0700052f5c0660060066040004603c0026eb8c054004dd5980b00099801801980d001180c0008a5114a029445288b19299980a0008a60103d87a800013374a90001980a980b000a5eb80dd6180198091baa00d16375c602860226ea800458ccc8c0040048894ccc0500085300103d87a8000132325333013300900313374a90001980b9ba90024bd70099980280280099b8000348004c06000cdd7180b0011bac300130103754602660206ea8014dd6980098081baa009230130011616375a6022002601a6ea8018dc3a40002c601c601e004601a00260126ea800458c02cc030008c028004c028008c020004c010dd50008a4c26cacae6955ceaab9e5573eae815d0aba21"; // Your validator script here
      const validator: SpendingValidator = {
        type: "PlutusV3",
        script: validatorScript,
      };

      const contractAddress = validatorToAddress(
        networkEnv === "Preprod" ? "Preprod" : "Mainnet",
        validator
      );
      console.log("Contract Address:", contractAddress);

      const api = await window.cardano[enabledWallet].enable();
      lucid.selectWallet.fromAPI(api);

      const walletAddress = await lucid.wallet().address();
      console.log("Wallet Address: ", walletAddress);

      // Redeemer with winner index
      const redeemer = Data.to(new Constr(0, [BigInt(winnerIndex)]));

      const participants = [
        getPublicKeyHashFromAddress("addr_test1qzxm3w8cr2t0da7r6jh5n0h4c49mur07xkjq3l2wu6xhguu0x7zxuq8e6wnvmx67tmkpr7de0guxez98c2knvpmnwmnq4ws9qt"),
        getPublicKeyHashFromAddress("addr_test1qzqj3u3u407gl4jnaujm6w78awnes4rk5pq6extz67ey0urymfwmlan75sp4fm5e5tnfdhzz7lnvq06qkdj7kec5ntds7azxt0"),
      ]
        .filter((participant): participant is string => participant !== null) // Public key hash as hex string
        .map((participant) => Data.to(participant)); // Convert hex string to Data

      const allUTxOs = await lucid.utxosAt(contractAddress);
      const ownerUTxO = allUTxOs.find((utxo) => {
        const datum = utxo.datum ? Data.from(utxo.datum) : null;
        if (datum && datum instanceof Constr) {
          // Extract participants from the datum fields and print for debugging
          console.log("Datum fields: ", datum.fields);

          const datumParticipants = datum.fields[0]; // Adjust depending on the structure
          
          // Check if it's an array and contains participants
          if (Array.isArray(datumParticipants)) {
            return datumParticipants.some((dp) => {
              const participantHex = dp instanceof Uint8Array ? Buffer.from(dp).toString("hex") : null;
              return participantHex && participants.includes(Data.to(participantHex));
            });
          }
        }
        return false;
      });

      if (!ownerUTxO) {
        throw new Error("No matching UTXO found for the winning participant.");
      }

      const tx = await lucid
        .newTx()
        .collectFrom([ownerUTxO], redeemer)
        .pay.ToAddress(walletAddress, { lovelace: BigInt(2000000) }) // Pays 2 ADA to the winner's wallet
        .attach.SpendingValidator(validator)
        .complete();

      const signedTx = await tx.sign.withWallet().complete();
      const txHash = await signedTx.submit();
      setTxHash(txHash);
    } catch (error: unknown) {
      if (error instanceof Error) {
        setErrorMessage(error.message);
        console.error("Error redeeming funds:", error.message);
      } else if (typeof error === "object" && error !== null) {
        const errorObject = JSON.stringify(error, Object.getOwnPropertyNames(error));
        setErrorMessage(errorObject);
        console.error("Error redeeming funds:", errorObject);
      } else {
        setErrorMessage("An unknown error occurred.");
        console.error("Unknown error redeeming funds:", error);
      }
    } finally {
      setIsLoading(false); // Stop processing after transaction completes
    }
  };

  return (
    <div className="w-full max-w-md mx-auto p-6 bg-white rounded shadow-lg mt-10">
      <h2 className="text-2xl font-semibold mb-6 text-center">Redeem Tontine Winnings</h2>
      <div className="mb-4">
        <input
          type="number"
          placeholder="Winner Index"
          value={winnerIndex}
          onChange={(e) => setWinnerIndex(e.target.value)}
          className="w-full p-3 border border-gray-300 rounded focus:outline-none focus:ring focus:border-blue-300"
        />
      </div>
      <div className="mb-4">
        <button
          className={`w-full p-3 text-white font-semibold rounded ${isLoading ? "bg-gray-500 cursor-not-allowed" : "bg-blue-500 hover:bg-blue-600"}`}
          onClick={ReDeem}
          disabled={isLoading}
        >
          {isLoading ? "Processing..." : "Redeem"}
        </button>
      </div>
      {txHash && (
        <p className="text-green-500 text-center mt-2">
          Transaction submitted! Check it on{" "}
          <a
            href={`https://preprod.cardanoscan.io/transaction/${txHash}`}
            target="_blank"
            rel="noopener noreferrer"
            className="text-blue-500 underline"
          >
            Cardano Explorer
          </a>
          .
        </p>
      )}
      {errorMessage && (
        <p className="text-red-500 text-center mt-2">
          Error: {errorMessage}
        </p>
      )}
    </div>
  );
};

export default dynamic(() => Promise.resolve(ReDeem), { ssr: false });
