"use client";
import React from "react";
import NavBar from "./NavBar";
import Footer from "./Footer";
import { useCardano } from "@cardano-foundation/cardano-connect-with-wallet";

type MainProps = {
  children: React.ReactNode;
};

export default function Main({ children }: MainProps) {
  const { isConnected } = useCardano({
    limitNetwork: process.env.NODE_ENV === "development" ? "testnet" : "mainnet",
  });

  return (
    <div>
      <NavBar />
      <main>
        {isConnected ? (
          children // DApp functionality if connected
        ) : (
          <p>Please connect your wallet to access the DApp functionality.</p> // Message if not connected
        )}
      </main>
      <Footer />
    </div>
  );
}
