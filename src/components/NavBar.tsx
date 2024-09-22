import React from "react";
import WalletConnect from "./WalletConnect";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faDiscord, faGithub } from "@fortawesome/free-brands-svg-icons";

export default function NavBar() {
  return (
    <nav className="bg-white text-gray-800 py-4 shadow-lg">
      <div className="container mx-auto flex justify-between items-center px-6">
        
        {/* Logo or Title */}
        <h1 className="text-3xl font-bold tracking-tight text-gray-900">
          <a href="/" className="hover:text-accent transition duration-200">
            Tontine - PROJECT
          </a>
        </h1>

        {/* Navigation Links */}
        <div className="flex items-center space-x-8">
          <a href="#features" className="text-lg hover:text-accent transition duration-200 text-gray-700">
            Gouvernance
          </a>
          <a href="#documentation" className="text-lg hover:text-accent transition duration-200 text-gray-700">
            Documentation
          </a>
          <a href="#about" className="text-lg hover:text-accent transition duration-200 text-gray-700">
            Compliance
          </a>
        </div>

        {/* Discord & GitHub Icons */}
        <div className="flex items-center space-x-4">
          <a href="https://discord.gg/yourdiscordlink" target="_blank" rel="noopener noreferrer">
            <FontAwesomeIcon icon={faDiscord} className="text-gray-700 hover:text-accent text-xl" />
          </a>
          <a href="https://github.com/docybo/Tontino_3.0" target="_blank" rel="noopener noreferrer">
            <FontAwesomeIcon icon={faGithub} className="text-gray-700 hover:text-accent text-xl" />
          </a>

          {/* Wallet Connect Button */}
          <WalletConnect />
        </div>
      </div>
    </nav>
  );
}
