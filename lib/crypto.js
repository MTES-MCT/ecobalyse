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

function encryptFile(sourcePath, destinationPath, secret_key = ENCRYPTION_KEY) {
  const contents = fs.readFileSync(sourcePath).toString("utf-8");
  const encryptedContents = encrypt(contents, secret_key);
  fs.writeFileSync(destinationPath, JSON.stringify(encryptedContents));
}

function decryptFile(sourcePath, destinationPath, secret_key = ENCRYPTION_KEY) {
  const encryptedContents = fs.readFileSync(sourcePath).toString("utf-8");
  fs.writeFileSync(destinationPath, decrypt(JSON.parse(encryptedContents), secret_key));
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

function sha1(str) {
  return crypto.createHash("sha1").update(str).digest("hex");
}

module.exports = {
  decrypt,
  decryptFile,
  encrypt,
  encryptFile,
  sha1,
};
