"use client";

import React, { useState } from 'react';

const LendBorrow: React.FC = () => {
  const [actionType, setActionType] = useState<string>("prêter"); // Action par défaut est 'prêter'
  const [amount, setAmount] = useState<number | string>("");
  const [collateral, setCollateral] = useState<number | string>("");

  const handleAction = () => {
    alert("Cette fonctionnalité est en cours de développement. Le prêt et l'emprunt seront bientôt disponibles !");
  };

  return (
    <div className="flex flex-col items-center bg-white shadow-lg rounded-lg p-8 max-w-md mx-auto mt-12">
      <h2 className="text-2xl font-semibold text-gray-900 mb-4">Prêter & Emprunter</h2>
      <p className="text-sm text-gray-600 mb-6">
        Prêtez vos ADA ou empruntez des fonds contre vos parts de Tontine. Une garantie sera utilisée pour sécuriser l'emprunt.
      </p>

      {/* Sélecteur d'action */}
      <div className="w-full mb-4">
        <label htmlFor="actionType" className="block text-sm font-medium text-gray-700">
          Choisir une action
        </label>
        <select
          id="actionType"
          value={actionType}
          onChange={(e) => setActionType(e.target.value)}
          className="mt-1 p-3 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
        >
          <option value="prêter">Prêter</option>
          <option value="emprunter">Emprunter</option>
        </select>
      </div>

      {/* Champ de saisie du montant */}
      <div className="w-full mb-4">
        <label htmlFor="amount" className="block text-sm font-medium text-gray-700">
          Montant en ADA
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

      {/* Champ de saisie de la garantie (Visible uniquement pour l'option Emprunter) */}
      {actionType === "emprunter" && (
        <div className="w-full mb-4">
          <label htmlFor="collateral" className="block text-sm font-medium text-gray-700">
            Garantie en ADA (pour sécuriser le prêt)
          </label>
          <input
            type="number"
            id="collateral"
            placeholder="Entrez la garantie"
            value={collateral}
            onChange={(e) => setCollateral(e.target.value)}
            className="mt-1 p-3 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
          />
        </div>
      )}

      {/* Bouton d'action */}
      <button
        onClick={handleAction}
        className="w-full bg-blue-600 text-white font-semibold py-2 px-4 rounded-md shadow hover:bg-blue-700 transition-all duration-300"
      >
        {actionType === "prêter" ? "Prêter ADA" : "Emprunter ADA"}
      </button>

      {/* Message de fonctionnalité en cours */}
      <div className="mt-6 text-center text-sm text-red-500">
        Cette fonctionnalité est en cours de développement. Non disponible pour le moment.
      </div>
    </div>
  );
};

export default LendBorrow;
