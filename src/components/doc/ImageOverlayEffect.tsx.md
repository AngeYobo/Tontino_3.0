import React from 'react';
import './ImageOverlayEffect.css'; // Importer le fichier CSS pour les animations

const ImageOverlayEffect = () => {
  return (
    <div className="relative w-96 h-96">
      {/* Première image */}
      <img
        src="/assets/roasca_image4.webp"
        alt="First Layer"
        className="absolute top-0 left-0 w-full h-full image-rotate"
      />

      {/* Deuxième image */}
      <img
        src="/assets/roasca_image5.webp"
        alt="Second Layer"
        className="absolute top-0 left-0 w-full h-full opacity-80 image-move"
      />

      {/* Troisième image */}
      <img
        src="/assets/Comm.webp"
        alt="Third Layer"
        className="absolute top-0 left-0 w-full h-full opacity-60 image-scale"
      />
    </div>
  );
};

export default ImageOverlayEffect;
