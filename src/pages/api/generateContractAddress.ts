import { Lucid, Blockfrost, validatorToAddress , SpendingValidator} from "@lucid-evolution/lucid";

async function generateContractAddress() {
  // Initialize Lucid with Blockfrost API
  const blockfrostApiKey = process.env.NEXT_PUBLIC_BLOCKFROST_KEY_PREPROD;
  const networkEnv = "Preprod"; // Or "Mainnet"

  const lucid = await Lucid(
    new Blockfrost(
      `https://cardano-${networkEnv.toLowerCase()}.blockfrost.io/api/v0`,
      blockfrostApiKey
    ),
    networkEnv
  );

  // Updated validator script after recompiling
  const validatorScript = "your_new_cbor_script_here"; // Replace with the CBOR of the newly recompiled validator script

  // Define the validator
  const validator: SpendingValidator = {
    type: "PlutusV3",
    script: validatorScript, // The actual compiled Plutus script in CBOR format
  };

  // Get the contract address using Lucid
  const contractAddress = validatorToAddress(
    process.env.NEXT_PUBLIC_NETWORK_ENV === "Preprod" ? "Preprod" : "Mainnet",
    validator
  );

  console.log("New Contract Address:", contractAddress);

  return contractAddress;
}

// Call the function to generate the contract address
generateContractAddress().catch((err) => console.error("Error generating contract address:", err));
