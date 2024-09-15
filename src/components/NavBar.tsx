// src/components/NavBar.tsx
import React from "react";
import WalletConnect from "./WalletConnect";

export default function NavBar() {
  return (
    <nav className="navbar">
      <div className="container">
        <h1>Tontine DApp</h1>
        <WalletConnect />
      </div>
    </nav>
  );
}
