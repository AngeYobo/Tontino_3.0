/** @type {import('next').NextConfig} */
const nextConfig = {
  webpack: (config: import('webpack').Configuration) => {
    // Enable WebAssembly
    config.experiments = {
      ...config.experiments,
      asyncWebAssembly: true,
    };

    return config;
  },
};

export default nextConfig;
