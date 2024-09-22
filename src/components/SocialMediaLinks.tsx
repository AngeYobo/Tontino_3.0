// src/pages/SocialMediaLinks.tsx

import React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faTwitter, faDiscord, faGithub, faTelegram, faReddit, faMedium } from '@fortawesome/free-brands-svg-icons';

const SocialMediaLinks: React.FC = () => {
  return (
    <div className="mt-4 flex justify-center space-x-6">
      <a href="https://twitter.com/yourprofile" className="text-gray-400 hover:text-white">
        <FontAwesomeIcon icon={faTwitter} className="w-6 h-6" />
      </a>
      <a href="https://discord.com/yourserver" className="text-gray-400 hover:text-white">
        <FontAwesomeIcon icon={faDiscord} className="w-6 h-6" />
      </a>
      <a href="https://github.com/yourprofile" className="text-gray-400 hover:text-white">
        <FontAwesomeIcon icon={faGithub} className="w-6 h-6" />
      </a>
      <a href="https://t.me/yourprofile" className="text-gray-400 hover:text-white">
        <FontAwesomeIcon icon={faTelegram} className="w-6 h-6" />
      </a>
      <a href="https://reddit.com/yourprofile" className="text-gray-400 hover:text-white">
        <FontAwesomeIcon icon={faReddit} className="w-6 h-6" />
      </a>
      <a href="https://medium.com/yourprofile" className="text-gray-400 hover:text-white">
        <FontAwesomeIcon icon={faMedium} className="w-6 h-6" />
      </a>
    </div>
  );
};

export default SocialMediaLinks;