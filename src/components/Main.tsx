"use client";
import React from "react";
import NavBar from "./NavBar";
import Footer from "./Footer";
import { useCardano } from "@cardano-foundation/cardano-connect-with-wallet";
// import HeroSection from "./HeroSection";
// import FeaturesSection from "./FeaturesSection"; 
//import JoinCommunitySection from "./JoinCommunitySection"; 
//import TontineTypesSection from "./TontineTypesSection"



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
        {/* Display Contribute.tsx (children) only if the wallet is connected */}
        {isConnected ? (
          <div>
            {children} {/* Only render the DApp functionality when connected */}
          </div>

        ) : (
          // If the wallet is NOT connected, show the landing page
          <>
            {/* <HeroSection />
            <TontineTypesSection/>
            <FeaturesSection />
            <JoinCommunitySection /> */}
           
          </>
        )}
      </main>
      <Footer />
    </div>
  );
}
