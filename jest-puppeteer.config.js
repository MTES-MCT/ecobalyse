module.exports = {
  launch: {
    headless: process.env.HEADLESS !== "false",
  },
  browserContext: "default", // Use "incognito" if you want isolated sessions per test
  server: {
    command: 'concurrently "npm run start:parcel" "npm run server:dev"',
    port: 1234,
    launchTimeout: 50000,
    debug: true,
  },
};
