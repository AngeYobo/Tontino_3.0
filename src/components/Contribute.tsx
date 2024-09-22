"use client";

import React, { useState } from "react";
import { useCardano } from "@cardano-foundation/cardano-connect-with-wallet";
import { NetworkType } from "@cardano-foundation/cardano-connect-with-wallet-core";


const Contribute: React.FC = () => {
  const networkEnv =
    process.env.NEXT_PUBLIC_NETWORK_ENV === "Preprod"
      ? NetworkType.TESTNET
      : NetworkType.MAINNET;

  const { isConnected } = useCardano({
    limitNetwork: networkEnv,
  });

  const [amount, setAmount] = useState<string>(""); // State for holding amount input
  const [isLoading, setIsLoading] = useState(false); // State for loading status
  const [transactionHash, setTransactionHash] = useState<string>(""); // State to store transaction hash

  const handleContribute = async () => {
    if (!amount || isNaN(Number(amount))) {
      alert("Please enter a valid amount.");
      return;
    }
    
    setIsLoading(true);
    // Add your logic to handle the transaction here
    // For example, the transaction hash is set below as an example.
    setTimeout(() => {
      setTransactionHash("0xExampleTxHash123456789");
      setIsLoading(false);
    }, 2000);
  };

  return (
    <div className="flex flex-col items-center bg-white shadow-lg rounded-lg p-8 max-w-md mx-auto mt-12 transition-all duration-300 hover:shadow-xl">
      <h2 className="text-2xl font-semibold text-gray-900 mb-4">Contribuer</h2>
      <p className="text-sm text-gray-600 mb-6">
        Verrouillez vos fonds dans le contrat Tontine pour participer. Vos fonds seront sécurisés sur la blockchain Cardano.
      </p>
  
      {/* Champ de saisie du montant */}
      <div className="w-full mb-6">
        <label htmlFor="amount" className="block text-sm font-medium text-gray-700">
          Montant en Lovelace
        </label>
        <input
          type="number"
          id="amount"
          placeholder="Entrez le montant"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          className="mt-1 p-3 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
        />
      </div>
  
      {/* Bouton d'action */}
      <button
        onClick={handleContribute}
        disabled={isLoading}
        className={`w-full bg-blue-600 text-white font-semibold py-2 px-4 rounded-md shadow ${isLoading ? 'opacity-50' : 'hover:bg-blue-700'} transition-all duration-300`}
      >
        {isLoading ? "Traitement en cours..." : "Contribuer"}
      </button>
  
      {/* Hash de la transaction */}
      {transactionHash && (
        <div className="mt-6 text-center text-sm text-green-500">
          Contribution réussie !<br />
          Hash de transaction : <a href={`https://explorer.cardano.org/en/transaction?id=${transactionHash}`} target="_blank" rel="noopener noreferrer" className="text-blue-600 underline">{transactionHash}</a>
        </div>
      )}
    </div>
  );
  
};

export default Contribute;
