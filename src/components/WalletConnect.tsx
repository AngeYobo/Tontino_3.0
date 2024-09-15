"use client";

import React, { useEffect, useState } from "react";
import { useCardano } from "@cardano-foundation/cardano-connect-with-wallet";
import { NetworkType } from "@cardano-foundation/cardano-connect-with-wallet-core";
import WalletModal from "./WalletModal";

const WalletConnect = () => {
  const network =
    process.env.NODE_ENV === "development"
      ? NetworkType.TESTNET
      : NetworkType.MAINNET;

  const { isConnected, usedAddresses, disconnect, accountBalance } = useCardano({
    limitNetwork: network,
  });

  const [showModal, setShowModal] = useState(false); // Manage modal visibility

  const formatAddress = (address: string | undefined) => {
    if (!address) return "Unknown Address";
    return `${address.slice(0, 6)}...${address.slice(-4)}`;
  };

  const formatBalance = (balance: number | string) => {
    // Convert balance to string and multiply by 1,000,000 to avoid decimals
    const balanceInLovelace = Math.floor(Number(balance) * 1_000_000); 
    const ada = BigInt(balanceInLovelace) / BigInt(1_000_000); // Convert to BigInt
    return `${ada.toString()} ADA`;
  };
  

  useEffect(() => {
    if (typeof window !== "undefined") {
      // Access window or other browser-specific APIs here
    }
  }, []); // This will only run on the client

  return (
    <div className="flex items-center gap-3 sm:gap-6 lg:gap-8">
      {isConnected ? (
        <div className="flex items-center gap-3 sm:gap-6 lg:gap-8">
          <h1>{formatAddress(usedAddresses?.[0])}</h1>
          <h1>{formatBalance(accountBalance || "0")}</h1>
          <button
            className="btn btn-square btn-outline"
            onClick={() => {
              disconnect();
            }}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              className="h-6 w-6"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth="2"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </button>
        </div>
      ) : (
        <button className="btn btn-primary" onClick={() => setShowModal(true)}>
          Connect Wallet
        </button>
      )}

      {/* Modal for wallet connection */}
      {showModal && (
        <WalletModal onClose={() => setShowModal(false)} />
      )}
    </div>
  );
};

export default WalletConnect;
