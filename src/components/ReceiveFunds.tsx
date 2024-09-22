"use client";

import { useCardano } from "@cardano-foundation/cardano-connect-with-wallet";
import { NetworkType } from "@cardano-foundation/cardano-connect-with-wallet-core";
import { Lucid, Blockfrost, Data } from "@lucid-evolution/lucid";
import { useState } from "react";

// Function to initialize Lucid with Blockfrost
const initLucid = async () => {
  const blockfrostApiKey = process.env.NEXT_PUBLIC_BLOCKFROST_KEY_PREPROD!;
  const networkEnv = process.env.NEXT_PUBLIC_NETWORK_ENV!;

  const lucid = await Lucid(
    new Blockfrost(`https://cardano-${process.env.NEXT_PUBLIC_NETWORK_ENV!.toLowerCase()}.blockfrost.io/api/v0`, blockfrostApiKey),
    networkEnv as "Preprod" | "Mainnet"
  );

  return lucid;
};

const ReceiveFunds = () => {
  const { isConnected, usedAddresses, enabledWallet } = useCardano({
    limitNetwork: process.env.NODE_ENV === "development" ? NetworkType.TESTNET : NetworkType.MAINNET,
  });

  const [status, setStatus] = useState<string>("");

  const handleReceiveFunds = async () => {
    if (isConnected && enabledWallet) {
      try {
        setStatus("Fetching UTxOs...");

        // Initialize Lucid and select the wallet
        const lucid = await initLucid();
        const api = await window.cardano[enabledWallet].enable();
        lucid.selectWallet.fromAPI(api);

        const contractHash = process.env.NEXT_PUBLIC_CONTRACT_HASH;
        if (!contractHash) {
          throw new Error("Missing contract hash in environment variables");
        }

        // Fetch UTxOs at the contract address
        const allUTxOs = await lucid.utxosAt(contractHash);

        if (allUTxOs.length === 0) {
          throw new Error("No UTxOs found at the contract address");
        }

        // Simplified: Decode the datum from the UTxO to find the correct one
        const ownerUTxO = allUTxOs.find((utxo) => {
          if (utxo.datum) {
            const datum = Data.from(utxo.datum, {
              participants: 'list<bytes>',
            });

            return datum.participants.includes(usedAddresses[0]);
          }
        });

        if (!ownerUTxO) {
          throw new Error("No UTxO found for the winner");
        }

        // Define the redeemer as a proper Data structure
        const redeemer = Data.to(new Map([["winner_index", BigInt(0)]])); // Map format for redeemer

        // Load the spending validator (your Plutus script)
        const compiledContract = process.env.NEXT_PUBLIC_COMPILED_CONTRACT_CBOR;
        if (!compiledContract) {
          throw new Error("Missing compiled contract in environment variables");
        }

        // Create the transaction to collect from the UTxO
        const tx = await lucid
          .newTx()
          .collectFrom([ownerUTxO], redeemer) // Pass the correctly structured redeemer
          .attach.SpendingValidator({
            type: "PlutusV3", // Example, replace with actual type if different
            script: compiledContract, // Attach the validator script
          })
          .addSigner(usedAddresses[0]) // Add the winner's address as the signer
          .complete();

        // Sign the transaction
        const signedTx = await tx.sign.withWallet().complete();

        // Submit the transaction
        const txHash = await signedTx.submit();

        setStatus(`Funds redeemed successfully. Tx Hash: ${txHash}`);
      } catch (error) {
        if (error instanceof Error) {
          setStatus(`Error: ${error.message}`);
        } else {
          setStatus("An unknown error occurred.");
        }
      }
    } else {
      setStatus("Please connect your wallet.");
    }
  };

  return (
    <div className="flex flex-col items-center bg-white shadow-lg rounded-lg p-8 max-w-md mx-auto mt-12">
      <h2 className="text-2xl font-semibold text-gray-900 mb-4">Retrait</h2>
      <p className="text-sm text-gray-600 mb-6">
        Redeem the funds you are eligible for from the Tontine contract on the Cardano blockchain.
      </p>

      {isConnected ? (
        <>
          <button
            className="w-full bg-green-600 text-white font-semibold py-2 px-4 rounded-md shadow hover:bg-green-700 transition-all duration-300"
            onClick={handleReceiveFunds}
            disabled={!!status && status.includes("Fetching")} // Disable button during fetching
          >
            {status.includes("Fetching") ? "Fetching UTxOs..." : "Redeem Funds"}
          </button>

          {/* Status Message */}
          {status && (
            <div className={`mt-4 text-sm ${status.includes("Error") ? "text-red-500" : "text-green-500"}`}>
              {status}
            </div>
          )}
        </>
      ) : (
        <p className="text-sm text-gray-600">Please connect your wallet to redeem funds.</p>
      )}
    </div>
  );
};

export default ReceiveFunds;
