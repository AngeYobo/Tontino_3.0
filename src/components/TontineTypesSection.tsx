import React from 'react';
import { FaCoins, FaRecycle, FaCogs, FaHandsHelping } from 'react-icons/fa'; // Importing Icons

const TontineTypesSection = () => {
  return (
    <section className="py-20 bg-white text-gray-800">
      <div className="container mx-auto text-center">
        <h2 className="text-4xl font-bold mb-12">Explorez les modèles de Tontine</h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
          
          {/* Accumulation Tontine */}
          <div className="tontine-box p-8 bg-gray-100 shadow-lg rounded-lg">
            <FaCoins className="text-4xl text-green-600 mb-4 mx-auto" /> {/* Icon */}
            <h3 className="text-2xl font-semibold mb-4">Tontine d'Accumulation (ASCA)</h3>
            <p>Contribuez à un fonds commun qui est prêté ou investi pour générer des rendements.</p>
          </div>
          
          {/* Rotative Tontine */}
          <div className="tontine-box p-8 bg-gray-100 shadow-lg rounded-lg">
            <FaRecycle className="text-4xl text-blue-600 mb-4 mx-auto" /> {/* Icon */}
            <h3 className="text-2xl font-semibold mb-4">Tontine Rotative (ROSCA)</h3>
            <p>Les contributions sont redistribuées aux participants de manière rotative.</p>
          </div>
          
          {/* Variable Share Tontine */}
          <div className="tontine-box p-8 bg-gray-100 shadow-lg rounded-lg">
            <FaCogs className="text-4xl text-purple-600 mb-4 mx-auto" /> {/* Icon */}
            <h3 className="text-2xl font-semibold mb-4">Tontine à Parts Variables</h3>
            <p>Niveaux de contribution flexibles avec gestion automatisée via des contrats intelligents.</p>
          </div>
          
          {/* Solidarity Tontine */}
          <div className="tontine-box p-8 bg-gray-100 shadow-lg rounded-lg">
            <FaHandsHelping className="text-4xl text-red-600 mb-4 mx-auto" /> {/* Icon */}
            <h3 className="text-2xl font-semibold mb-4">Tontine de Solidarité</h3>
            <p>Une partie des fonds est utilisée pour aider les membres en difficulté financière.</p>
          </div>

        </div>
      </div>
    </section>
  );
};

export default TontineTypesSection;
