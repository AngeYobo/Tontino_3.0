import React from 'react';
import { FaShieldAlt, FaChartLine, FaRobot } from 'react-icons/fa';

const FeaturesSection = () => {
  return (
    <section className="py-20 bg-gray-100 text-gray-800">
      <div className="container mx-auto text-center">
        <h2 className="text-4xl font-bold mb-12">Pourquoi Choisir Tontino 3.0 ?</h2>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-8">
          
          {/* Security Feature */}
          <div className="feature-box p-8 bg-white shadow-lg rounded-lg">
            <FaShieldAlt className="text-4xl text-green-500 mb-4 mx-auto" />
            <h3 className="text-2xl font-semibold mb-4">Sécurité grâce à la décentralisation</h3>
            <p>Toutes les transactions sont enregistrées sur la blockchain Cardano, garantissant transparence et sécurité.</p>
          </div>

          {/* Maximized Returns Feature */}
          <div className="feature-box p-8 bg-white shadow-lg rounded-lg">
            <FaChartLine className="text-4xl text-green-500 mb-4 mx-auto" />
            <h3 className="text-2xl font-semibold mb-4">Rendements Maximisés</h3>
            <p>Les contributions sont investies dans des stratégies de yield farming et de staking pour générer des rendements élevés.</p>
          </div>

          {/* Automated Processes Feature */}
          <div className="feature-box p-8 bg-white shadow-lg rounded-lg">
            <FaRobot className="text-4xl text-green-500 mb-4 mx-auto" />
            <h3 className="text-2xl font-semibold mb-4">Processus Automatisés</h3>
            <p>Les smart contracts gèrent tout, des contributions aux distributions, réduisant les erreurs humaines.</p>
          </div>
        </div>
      </div>
    </section>
  );
};

export default FeaturesSection;
