import { Lucid, Blockfrost, Network, Data, SpendingValidator } from "@lucid-evolution/lucid";
import dotenv from "dotenv";

// Load environment variables from .env file
dotenv.config();

// Initialize Lucid with Blockfrost
export const initLucid = async () => {
  const blockfrostApiKey = process.env.BLOCKFROST_API_KEY!;
  const networkEnv = process.env.NETWORK_ENV! as Network; // Cast as Network type

  if (!blockfrostApiKey || !networkEnv) {
    throw new Error("Missing Blockfrost API Key or Network Environment in .env");
  }

  const lucid = await Lucid(
    new Blockfrost(`https://cardano-${networkEnv.toLowerCase()}.blockfrost.io/api/v0`, blockfrostApiKey),
    networkEnv // Now correctly typed as "Preprod" or "Mainnet"
  );

  // Use the private key to select a wallet
  const privateKey = process.env.PRIVATE_KEY!;

  if (!privateKey) {
    throw new Error("Missing Private Key");
  }

  lucid.selectWallet.fromPrivateKey(privateKey);

  return lucid;
};
