import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          black: '#0A0A0A',      // Primary background (from current site)
          white: '#FFFFFF',       // Primary text
          cyan: {
            DEFAULT: '#00D4FF',   // Primary brand blue (logo)
            light: '#33DDFF',     // Hover states
            dark: '#00A3CC',      // Active states
          },
          blue: {
            DEFAULT: '#3B5A7E',   // Professional blue (Ethos doc)
            light: '#4A6A8F',
          },
          red: '#D5081A',         // Accent/CTA color (current site)
        },
        fusion: {
          gray: {
            100: '#1A1A1A',       // Slightly lighter than black
            200: '#2A2A2A',       // Card backgrounds
            300: '#3A3A3A',       // Borders, dividers
            700: '#888888',       // Muted text
            800: '#CCCCCC',       // Secondary text
          },
        },
        // XP Pillar colors
        integrity: '#3B5A7E',     // Professional blue
        impact: '#00D4FF',        // Vibrant cyan
        innovation: '#D5081A',    // Bold red
      },
      fontFamily: {
        sans: ['var(--font-primary)', 'system-ui', 'sans-serif'],
        display: ['var(--font-display)', 'system-ui', 'sans-serif'],
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-in',
        'slide-up': 'slideUp 0.6s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(20px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
      },
    },
  },
  plugins: [],
}

export default config
