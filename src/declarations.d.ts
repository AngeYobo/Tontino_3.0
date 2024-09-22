"use client";

// Declaring the Cardano connect modules without types
declare module "@cardano-foundation/cardano-connect-with-wallet";
declare module "@cardano-foundation/cardano-connect-with-wallet-core";
declare module "cardano-multiplatform-lib";
declare module '@fortawesome/free-solid-svg-icons';
declare module '@fortawesome/react-fontawesome';
declare module "@emurgo/cardano-multiplatform-lib-browser"

// Extend the global Window interface to declare the 'cardano' object
interface Cardano {
  name: string;
  icon: string;
  enable: () => Promise<any>;
  // Add more properties and methods as needed
}

declare global {
  interface Window {
    cardano?: {
      [key: string]: Cardano; // Supports multiple wallet providers like Nami, Eternl, etc.
    };
  }
}
