/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'finly': {
          bg: '#F8FAFC',
          card: '#FFFFFF',
          text: '#1E293B',
          textSecondary: '#64748B',
          primary: '#4F46E5',
          secondary: '#F1F5F9',
          income: '#22C55E',
          expense: '#EF4444',
          balance: '#3B82F6',
          dropzone: '#EEF2FF',
          dropzoneBorder: '#C7D2FE',
        }
      }
    },
  },
  plugins: [],
}
