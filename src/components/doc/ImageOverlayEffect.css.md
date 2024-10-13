/* Effet de rotation pour la première image */
.image-rotate {
    animation: rotateAnimation 5s infinite linear;
  }
  
  /* Effet de déplacement pour la deuxième image */
  .image-move {
    animation: moveAnimation 6s infinite ease-in-out;
  }
  
  /* Effet de redimensionnement pour la troisième image */
  .image-scale {
    animation: scaleAnimation 8s infinite ease-in-out;
  }
  
  /* Animation de rotation */
  @keyframes rotateAnimation {
    0% {
      transform: rotate(0deg);
    }
    100% {
      transform: rotate(360deg);
    }
  }
  
  /* Animation de mouvement (translation) */
  @keyframes moveAnimation {
    0% {
      transform: translateX(0px) translateY(0px);
    }
    50% {
      transform: translateX(20px) translateY(20px);
    }
    100% {
      transform: translateX(0px) translateY(0px);
    }
  }
  
  /* Animation de mise à l'échelle */
  @keyframes scaleAnimation {
    0% {
      transform: scale(1);
    }
    50% {
      transform: scale(1.1);
    }
    100% {
      transform: scale(1);
    }
  }
  