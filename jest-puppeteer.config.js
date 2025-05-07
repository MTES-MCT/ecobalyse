module.exports = {
  launch: {
    headless: process.env.HEADLESS !== "false",
  },
  browserContext: "default", // Use "incognito" if you want isolated sessions per test
  server: {
    command: "npm run start:parcel",
    port: 1234,
    launchTimeout: 10000,
    debug: true,
  },
};
