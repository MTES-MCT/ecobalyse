require("dotenv").config();
const fs = require("fs");
const crypto = require("crypto");

// Secret key for encrypting and decrypting things
// If you need to generate a first secret key: crypto.createHash("sha512").digest("hex").substring(0, 32)
// Then store the result in an ENCRYPTION_KEY env var and never expose it publicly!
const { ENCRYPTION_KEY } = process.env;

function encrypt(text, secret_key = ENCRYPTION_KEY) {
  validateSecretKey(secret_key);
  validateNotAlreadyEncrypted(text);
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv("aes-256-cbc", Buffer.from(secret_key), iv);
  return {
    iv: iv.toString("hex"),
    encrypted: Buffer.concat([cipher.update(text), cipher.final()]).toString("hex"),
  };
}

function decrypt({ encrypted, iv }, secret_key = ENCRYPTION_KEY) {
  validateSecretKey(secret_key);
  const decipher = crypto.createDecipheriv(
    "aes-256-cbc",
    Buffer.from(secret_key),
    Buffer.from(iv, "hex"),
  );
  return Buffer.concat([
    decipher.update(Buffer.from(encrypted, "hex")),
    decipher.final(),
  ]).toString();
}

function encryptFile(path, secret_key = ENCRYPTION_KEY) {
  const contents = fs.readFileSync(path).toString("utf-8");
  const encryptedContents = encrypt(contents, secret_key);
  fs.writeFileSync(path, JSON.stringify(encryptedContents));
}

function decryptFile(path, secret_key = ENCRYPTION_KEY) {
  const encryptedContents = fs.readFileSync(path).toString("utf-8");
  fs.writeFileSync(path, decrypt(JSON.parse(encryptedContents), secret_key));
}

function validateNotAlreadyEncrypted(contents) {
  try {
    // Attempting at deciphering provided text should raise an expected Error
    decrypt(JSON.parse(contents));
  } catch (err) {
    return;
  }
  // If no error has been raised, we're likely to face already encypted text
  throw new Error("Contents are already encrypted.");
}

function validateSecretKey(key) {
  if (String(key).length !== 32) {
    throw new Error("Invalid secret key provided, which must be 32c length.");
  }
}

function demo() {
  const textToEncrypt = "Lorem ipsum dolor sit amet, consectetur adipiscing elit.";
  console.log("Texte à chiffrer:", textToEncrypt);
  const encrypted = encrypt(textToEncrypt);
  console.log("Données chiffrées:", encrypted);
  console.log("Données déchiffrées:", decrypt(encrypted));
}

function demoFile() {
  const path = `${__dirname}/../public/data/textile/processes_impacts.json`;
  encryptFile(path);
  decryptFile(path);
}

module.exports = {
  decrypt,
  decryptFile,
  demo,
  demoFile,
  encrypt,
  encryptFile,
};
