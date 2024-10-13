import React from 'react';
import Image from 'next/image';

const HeroSection = () => {
  return (
    <section className="relative bg-white text-black py-24">
      <div className="container mx-auto flex flex-col lg:flex-row items-center justify-start text-left">
        
        {/* Left Section - Text */}
        <div className="lg:w-1/2 flex flex-col justify-center lg:pr-10">
          <h1 className="text-6xl font-bold mb-6 leading-tight">
            Réinventer l'épargne collective grâce à la puissance de la décentralisation
          </h1>
          <p className="text-1xl font-light mb-6 leading-relaxed">
            Tontine Dapp est une plateforme décentralisée sur Cardano qui transforme les stratégies traditionnelles d'épargne et d'investissement en utilisant les innovations DeFi.
          </p>
          <button className="px-6 py-2 bg-black text-white rounded-full text-lg hover:bg-gray-900 transition-all duration-300">
            Rejoindre Maintenant
          </button>
        </div>

        {/* Right Section - Image */}
        <div className="relative lg:w-1/2 mt-10 lg:mt-0 flex justify-center">
          <Image
            src="/assets/Comm.jpg" // Mettre à jour le chemin de l'image
            alt="Hero Section Image"
            width={600}
            height={600}
            className="block"
          />
        </div>
      </div>
    </section>
  );
};

export default HeroSection;
