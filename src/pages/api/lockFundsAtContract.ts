import {
  Blockfrost,
  Lucid,
  SpendingValidator,
  validatorToAddress,
  Data,
} from "@lucid-evolution/lucid";
import { NextApiRequest, NextApiResponse } from "next";
import { Datum } from '../../lib/mySchema';

export default async function handler(
  req: NextApiRequest, 
  res: NextApiResponse
) {
  if (req.method === "POST") {
    try {
      console.log("Request received:", JSON.stringify(req.body, null, 2));

      const { address, usedAddresses, amount, datum, validatorScript, walletApi } = req.body; // Assuming walletApi is passed

      console.log("Received Address:", address);
      console.log("Received Used Addresses:", usedAddresses);
      console.log("Received Amount:", amount);
      console.log("Received Validator Script:", validatorScript);
      console.log("Received Datum:", datum);

      // Validate input
      if (!address) {
        console.error("Address is missing.");
        return res.status(400).json({ error: "Address is required" });
      }
      // if (!walletApi) {
      //   console.error("Wallet API is missing.");
      //   return res.status(400).json({ error: "Wallet API is required" });
      // }

      if (!amount || isNaN(Number(amount))) {
        console.error("Amount is missing or invalid.");
        return res.status(400).json({ error: "Valid amount is required" });
      }

      if (!validatorScript) {
        console.error("Validator script is missing.");
        return res.status(400).json({ error: "Validator script is required" });
      }

      console.log(`Received Address: ${address}`);
      console.log(`Received Address: ${usedAddresses}`);
      console.log(`Received Amount: ${amount}`);
      console.log(`Received Validator Script (CBOR): ${validatorScript}`);
      console.log(`Received Datum: ${JSON.stringify(datum, null, 2)}`);

      // Initialize Lucid
      const lucid = await initializeLucid();
      console.log("Lucid initialized successfully.");
      // Attach the wallet API
      const data = req.body;
      lucid.selectWallet.fromAddress(data.address, []);
     
      // Define the validator
      const validator: SpendingValidator = {
        type: "PlutusV3",
        script: validatorScript, // The actual compiled Plutus script in CBOR format
      };

      const contractAddress = validatorToAddress("Preprod", validator);
      console.log(`Contract Address derived from validator: ${contractAddress}`);

      // Encode the datum using the schema
      const encodedDatum = Data.to(datum, Datum);
      console.log(`Datum: ,encodedDatum}`);
      const amountBigInt = BigInt(amount);

      // Build the transaction to lock funds into the contract
      const tx = await lucid.newTx()
        .pay.ToAddressWithData(contractAddress, { kind: "inline", value: encodedDatum }, { lovelace: amountBigInt })
        .attach.SpendingValidator(validator)
        .complete();

      console.log("Transaction built successfully.");


      // Sign the transaction with wallet API
      const signedTx = await tx.sign.withWallet().complete();
      console.log("Transaction signed successfully.");

      // Submit the transaction
      const txHash = await signedTx.submit();
      console.log(`Transaction submitted successfully. Hash: ${txHash}`);

      res.status(200).json({ txHash });

    } catch (error) {
      if (error instanceof Error) {
        console.error("Transaction failed with error:", error.message);
        res.status(500).json({ error: "Transaction failed", details: error.message });
      } else {
        console.error("Unknown error:", JSON.stringify(error));
        res.status(500).json({ error: "Transaction failed", details: "An unknown error occurred" });
      }
    }
  } else {
    res.setHeader("Allow", ["POST"]);
    res.status(405).end(`Method ${req.method} Not Allowed`);
  }
}

async function initializeLucid() {
  const networkEnv = process.env.NEXT_PUBLIC_NETWORK_ENV;
  const blockfrostInstance = new Blockfrost(
    networkEnv === "Preprod"
      ? process.env.API_URL_PREPROD!
      : process.env.API_URL_MAINNET!,
    networkEnv === "Preprod"
      ? process.env.NEXT_PUBLIC_BLOCKFROST_KEY_PREPROD!
      : process.env.NEXT_PUBLIC_BLOCKFROST_KEY_MAINNET!
  );
  return Lucid(blockfrostInstance, networkEnv === "Preprod" ? "Preprod" : "Mainnet");
}
