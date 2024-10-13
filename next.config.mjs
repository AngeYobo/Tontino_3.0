/** @type {import('next').NextConfig} */
const nextConfig = {
  webpack: (config) => {
    // Enable WebAssembly
    config.experiments = { 
      asyncWebAssembly: true,
      topLevelAwait: true,
      layers: true
    }

    return config;
  },
};

export default nextConfig;

