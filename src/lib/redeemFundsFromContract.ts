import { Lucid, Blockfrost, Data, SpendingValidator, Network } from "@lucid-evolution/lucid";
import dotenv from "dotenv";

// Load environment variables from .env file
dotenv.config();

// Map environment variable string to Lucid's Network type
const mapEnvToNetwork = (env: string): Network => {
  if (env === "Preprod") return "Preprod";
  if (env === "Mainnet") return "Mainnet";
  throw new Error(`Invalid NETWORK_ENV value: ${env}`);
};

// Initialize Lucid with Blockfrost
export const initLucid = async () => {
  const blockfrostApiKey = process.env.BLOCKFROST_KEY_PREPROD!;
  const networkEnv = process.env.NETWORK_ENV!; 
  
  if (!blockfrostApiKey || !networkEnv) {
    throw new Error("Missing Blockfrost API Key or Network Environment in .env");
  }

  const network: Network = mapEnvToNetwork(networkEnv); // Map string to Network type

  const lucid = await Lucid(
    new Blockfrost(`https://cardano-${networkEnv.toLowerCase()}.blockfrost.io/api/v0`, blockfrostApiKey),
    network // Use the correct Network type
  );

  // Use the private key to select a wallet
  const privateKey = process.env.PRIVATE_KEY!;
  
  if (!privateKey) {
    throw new Error("Missing Private Key in .env");
  }

  lucid.selectWallet.fromPrivateKey(privateKey);

  return lucid;
};
