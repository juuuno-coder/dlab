module.exports = {
  content: [
    "./app/views/**/*.html.erb",
    "./app/helpers/**/*.rb",
    "./app/assets/stylesheets/**/*.css",
    "./app/javascript/**/*.js",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: "#1E40AF",
          dark: "#1E3A8A",
        },
        accent: "#3B82F6",
      },
      fontFamily: {
        sans: ["Inter", "sans-serif"],
        serif: ["Noto Serif KR", "serif"],
        cinzel: ["Cinzel", "serif"],
      },
    },
  },
  plugins: [],
};
