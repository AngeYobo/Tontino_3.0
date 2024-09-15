"use client";

import { useCardano } from "@cardano-foundation/cardano-connect-with-wallet";
import { NetworkType } from "@cardano-foundation/cardano-connect-with-wallet-core";
import { Lucid, Blockfrost, Data } from "@lucid-evolution/lucid";
import { useState } from "react";

// Function to initialize Lucid with Blockfrost
const initLucid = async () => {
  const blockfrostApiKey = process.env.BLOCKFROST_API_KEY!;
  const networkEnv = process.env.NEXT_PUBLIC_NETWORK_ENV!;

  if (!blockfrostApiKey || !networkEnv) {
    throw new Error("Missing Blockfrost API Key or Network Environment in .env");
  }

  const lucid = await Lucid(
    new Blockfrost(`https://cardano-${networkEnv.toLowerCase()}.blockfrost.io/api/v0`, blockfrostApiKey),
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
        const lucid = await initLucid();
        const api = await window.cardano[enabledWallet].enable();
        lucid.selectWallet.fromAPI(api);

        // Fetch transaction details from the server
        const response = await fetch("/api/redeem", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ address: usedAddresses[0] }),
        });

        const { tx } = await response.json();

        // Sign and submit the transaction
        const signedTx = await lucid.fromTx(tx).sign.withWallet().complete();
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
    <div className="flex flex-col items-center gap-3 sm:gap-6 lg:gap-8">
      {isConnected ? (
        <>
          <button className="btn btn-primary" onClick={handleReceiveFunds}>
            Redeem Tontine Funds
          </button>
          {status && <p>{status}</p>}
        </>
      ) : (
        <p>Please connect your wallet to redeem funds.</p>
      )}
    </div>
  );
};

export default ReceiveFunds;
