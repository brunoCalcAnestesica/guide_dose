import type { Config } from 'tailwindcss'

export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#eff6ff',
          100: '#dbeafe',
          200: '#bfdbfe',
          300: '#93c5fd',
          400: '#60a5fa',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
          800: '#1e40af',
          900: '#1e3a8a',
          950: '#172554',
        },
        // Paleta Guide Dose (app_colors.dart: primary #1A2848)
        guide: {
          50: '#E8EAEF',
          100: '#D1D6E0',
          200: '#A3ADC1',
          300: '#7584A2',
          400: '#475B83',
          500: '#1A2848',
          600: '#15203A',
          700: '#10182B',
          800: '#0B101D',
          900: '#06080E',
          950: '#030407',
        },
        // Superfícies e contornos (Guide Dose)
        surface: {
          DEFAULT: '#FFFFFF',
          variant: '#F5F5F5',
        },
        outline: '#E0E0E0',
      },
    },
  },
  plugins: [],
} satisfies Config
