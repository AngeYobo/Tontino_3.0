import type { Config } from "tailwindcss";

const config: Config = {
  // Specify all paths where Tailwind should scan for class names
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",   // Scans all files in the 'pages' folder
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",   // Scans all files in the 'components' folder
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",   // Scans all files in the 'app' folder
  ],

  // Extend the default theme to add custom colors and other styles
  theme: {
    extend: {
      colors: {
        'primary': '#1A202C',    // Custom primary color
        'secondary': '#2D3748',  // Custom secondary color
        'accent': '#4FD1C5',     // Custom accent color
      },
      // You can extend other theme features here, like spacing, fonts, etc.
      spacing: {
        '128': '32rem',    // Custom spacing value (example)
      },
      fontFamily: {
        'sans': ['Inter', 'sans-serif'],   // Custom font family
      },
    },
  },

  // Configure Tailwind's variants (states like hover, focus, etc.)
  variants: {
    extend: {
      backgroundColor: ['active'],    // Example: enable background color on active state
      opacity: ['disabled'],          // Enable opacity utility for disabled state
    },
  },

  // Add any Tailwind plugins here
  plugins: [
    require('@tailwindcss/forms'),     // Example: plugin for better form styling
    require('@tailwindcss/typography'),// Example: plugin for rich typography
    require('@tailwindcss/aspect-ratio')// Example: plugin for aspect ratio utilities
  ],
};

export default config;
