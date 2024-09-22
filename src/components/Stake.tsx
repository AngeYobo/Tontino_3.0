"use client";

import React, { useState } from 'react';

const Stake: React.FC = () => {
  const [amount, setAmount] = useState<number | string>("");
  const [duration, setDuration] = useState<string>("30"); // Durée par défaut : 30 jours

  const handleStake = () => {
    alert("Cette fonctionnalité est en cours de développement. Le mécanisme de staking sera bientôt disponible !");
  };

  return (
    <div className="flex flex-col items-center bg-white shadow-lg rounded-lg p-8 max-w-md mx-auto mt-12">
      <h2 className="text-2xl font-semibold text-gray-900 mb-4">Mécanisme de Staking</h2>
      <p className="text-sm text-gray-600 mb-6">Stakez vos ADA ou jetons pour gagner des récompenses dans le pool Tontine.</p>

      {/* Champ de saisie du montant */}
      <div className="w-full mb-4">
        <label htmlFor="amount" className="block text-sm font-medium text-gray-700">
          Montant à staker
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

      {/* Sélecteur de durée */}
      <div className="w-full mb-6">
        <label htmlFor="duration" className="block text-sm font-medium text-gray-700">
          Durée de staking (jours)
        </label>
        <select
          id="duration"
          value={duration}
          onChange={(e) => setDuration(e.target.value)}
          className="mt-1 p-3 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
        >
          <option value="30">30 jours</option>
          <option value="60">60 jours</option>
          <option value="90">90 jours</option>
        </select>
      </div>

      {/* Bouton d'action */}
      <button
        onClick={handleStake}
        className="w-full bg-blue-600 text-white font-semibold py-2 px-4 rounded-md shadow hover:bg-blue-700 transition-all duration-300"
      >
        Staker Maintenant
      </button>

      {/* Message en cours de développement */}
      <div className="mt-6 text-center text-sm text-red-500">
        Cette fonctionnalité est en cours de développement. Non disponible pour le moment.
      </div>
    </div>
  );
};

export default Stake;
