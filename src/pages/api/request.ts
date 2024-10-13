import { Blockfrost, Lucid } from "@lucid-evolution/lucid";
import { NextApiRequest, NextApiResponse } from "next";

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method === "POST") {
    try {
      const initLucid = () => {
        const networkEnv = process.env.NEXT_PUBLIC_NETWORK_ENV;

        if (networkEnv === "Preprod") {
          const blockfrostInstance = new Blockfrost(
            process.env.API_URL_PREPROD!,
            process.env.NEXT_PUBLIC_BLOCKFROST_KEY_PREPROD!
          );
          return Lucid(blockfrostInstance, "Preprod");
        } else if (networkEnv === "Mainnet") {
          const blockfrostInstance = new Blockfrost(
            process.env.API_URL_MAINNET!,
            process.env.NEXT_PUBLIC_BLOCKFROST_KEY_MAINNET!
          );
          return Lucid(blockfrostInstance, "Mainnet");
        } else {
          throw new Error(`Unsupported network environment: ${networkEnv}`);
        }
      };
  
      const lucid = await initLucid();
      const data = req.body;

      // Ensure the necessary address is provided
      if (!data.address) {
        res.status(400).json({ error: "Address is required" });
        return;
      }

      // Selecting wallet by address (ensure UTxOs are fetched properly)
      await lucid.selectWallet.fromAddress(data.address, []);

      // Build your custom transaction here
      const tx = await lucid.newTx()
        .pay.ToAddress(data.address, { lovelace: BigInt(1000000n) })  // Example: paying 1 ADA to the address
        .complete();

      // Sign and submit the transaction
      const signedTx = await tx.sign.withWallet().complete();
      const txHash = await signedTx.submit();

      // Return the transaction hash
      res.status(200).json({ txHash });
    } catch (error) {
      if (error instanceof Error) {
        // Safely access error.message
        res.status(500).json({ error: "Transaction failed", details: error.message });
      } else {
        res.status(500).json({ error: "Transaction failed", details: "Unknown error occurred" });
      }
    }
  } else {
    // Handle unsupported HTTP methods
    res.setHeader("Allow", ["POST"]);
    res.status(405).end(`Method ${req.method} Not Allowed`);
  }
}

export const parse = (json: string) =>
  JSON.parse(json, (key, value) =>
    typeof value === "string" && /^\d+n$/.test(value)
      ? BigInt(value.slice(0, -1))
      : value
  );
