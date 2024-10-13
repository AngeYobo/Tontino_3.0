import React, { useState } from "react";
import { Lucid, Blockfrost, validatorToAddress, SpendingValidator } from "@lucid-evolution/lucid";

const GenerateContractAddress: React.FC = () => {
  const [contractAddress, setContractAddress] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const generateAddress = async () => {
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

      const validatorScript = "5902540101003232323232323225333002323232323253330073370e900118041baa001132323253323300b3001300c375400c26464a66602060260042a66601a6006601c6ea80104c8c94ccc03cc014c040dd5000899299980819198008009bac3016301730173017301730173017301730173013375401c44a66602a00229404c94ccc04ccdc79bae301800200414a22660060060026030002264a666022600e60246ea800454ccc0454ccc050c8cc004004c8cc004004dd5991800980b1baa3001301637546032602c6ea80108c064c068004894ccc05c00452f5bded8c0264646464a66603066e45220100002153330183371e9101000021003100513301c337606ea4008dd3000998030030019bab3019003375c602e0046036004603200244a66602c002297ae0132333222323300100100322533301c00110031323301e374e6603c6ea4018cc078c06c004cc078c0700052f5c0660060066040004603c0026eb8c054004dd5980b00099801801980d001180c0008a5114a029445288b19299980a0008a60103d87a800013374a90001980a980b000a5eb80dd6180198091baa00d16375c602860226ea800458ccc8c0040048894ccc0500085300103d87a8000132325333013300900313374a90001980b9ba90024bd70099980280280099b8000348004c06000cdd7180b0011bac300130103754602660206ea8014dd6980098081baa009230130011616375a6022002601a6ea8018dc3a40002c601c601e004601a00260126ea800458c02cc030008c028004c028008c020004c010dd50008a4c26cacae6955ceaab9e5573eae815d0aba21"; // Replace with actual CBOR script

      // Define the validator
      const validator: SpendingValidator = {
        type: "PlutusV3",
        script: validatorScript, // The actual compiled Plutus script in CBOR format
      };

        // Get the contract address using Lucid
      const contractAddress = validatorToAddress(
        process.env.NEXT_PUBLIC_NETWORK_ENV === "Preprod" ? "Preprod" : "Mainnet",
        validator
      );
      setContractAddress(contractAddress);
    } catch (err) {
      console.error("Error generating contract address:", err);
      setError("Failed to generate contract address. See console for details.");
    }
  };

  return (
    <div>
      <h2>Generate Contract Address</h2>
      <button className="btn btn-primary" onClick={generateAddress}>
        Generate Address
      </button>

      {contractAddress && (
        <p>
          <strong>Contract Address:</strong> {contractAddress}
        </p>
      )}

      {error && <p style={{ color: "red" }}>{error}</p>}
    </div>
  );
};

export default GenerateContractAddress;
