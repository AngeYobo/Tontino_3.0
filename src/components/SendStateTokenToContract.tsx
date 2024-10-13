import React, { useState } from "react";
import { Lucid, Blockfrost, fromText } from "@lucid-evolution/lucid";

const SendStateTokenToContract: React.FC = () => {
  const [txHash, setTxHash] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const sendStateToken = async () => {
    try {
      const blockfrostApiKey = process.env.NEXT_PUBLIC_BLOCKFROST_KEY_PREPROD || "";
      const networkEnv = "Preprod"; // Or "Mainnet"

      // Initialize Lucid
      const lucid = await Lucid(
        new Blockfrost(
          `https://cardano-${networkEnv.toLowerCase()}.blockfrost.io/api/v0`,
          blockfrostApiKey
        ),
        networkEnv
      );

      // Enable the wallet connection (Nami for instance)
      const api = await window.cardano.nami.enable();
      lucid.selectWallet.fromAPI(api);

      // Define the contract address
      const contractAddress = "addr_test1wrsdp3ulp0u5nqkmskuylgve7ejvh46nh5tklknxk7yrqfc3g550g";

      // Define the Policy ID and the asset name for the state token
      const policyId = "928705753d7448b627cc204b0c196838440f143f103f4a32432e855e";  // Replace with the actual policy ID of your state token
      const stateTokenName = fromText("StateToken");  // Name of the state token

      // Define the assets to send
      const assetsToSend = {
        lovelace: BigInt(2_000_000),  // Sending 2 ADA (2,000,000 Lovelace)
        [`${policyId}${stateTokenName}`]: 1n,  // Sending 1 unit of the state token
      };

      // Build the transaction
      const tx = await lucid
        .newTx()
        .pay.ToAddress(contractAddress, assetsToSend)  // Send ADA and state token to the contract
        .complete();

      // Sign and submit the transaction
      const signedTx = await tx.sign.withWallet().complete();
      const txHash = await signedTx.submit();

      console.log("Transaction submitted. Tx Hash:", txHash);
      setTxHash(txHash);
    } catch (err) {
      console.error("Error sending state token:", err);
      setError("Failed to send state token. See console for details.");
    }
  };

  return (
    <div>
      <h2>Send State Token and ADA to Contract</h2>
      <button className="btn btn-primary" onClick={sendStateToken}>
        Send to Contract
      </button>

      {txHash && (
        <p>
          <strong>Transaction Hash:</strong> {txHash}
        </p>
      )}

      {error && <p style={{ color: "red" }}>{error}</p>}
    </div>
  );
};

export default SendStateTokenToContract;
