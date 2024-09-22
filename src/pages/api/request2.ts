// import { Blockfrost, Lucid, Data, SpendingValidator } from "@lucid-evolution/lucid";
// import { NextApiRequest, NextApiResponse } from "next";

// // Helper function to derive an address from the validator
// function deriveAddressFromValidator(lucid: any, validator: SpendingValidator) {
//   return lucid.utils.validatorToAddress(validator); // Use LucidEvolution's utils to derive the address
// }

// export default async function handler(req: NextApiRequest, res: NextApiResponse) {
//   if (req.method === "POST") {
//     try {
//       // Initialize Lucid with Blockfrost for either preprod or mainnet
//       const initLucid = async () => {
//         if (process.env.NODE_ENV === "development") {
//           const b = new Blockfrost(
//             process.env.API_URL_PREPROD!,
//             process.env.NEXT_PUBLIC_BLOCKFROST_API_KEY!
//           );
//           return await Lucid(b, "Preprod");
//         } else {
//           const b = new Blockfrost(
//             process.env.API_URL_MAINNET!,
//             process.env.BLOCKFROST_KEY_MAINNET!
//           );
//           return await Lucid(b, "Mainnet");
//         }
//       };

//       const lucid = await initLucid();
//       const data = req.body;

//       // Define the spending validator for the Tontine contract
//       const validator: SpendingValidator = {
//         type: "PlutusV2",
//         script: process.env.COMPILED_CONTRACT_CBOR!, // Replace with actual CBOR of your contract
//       };

//       // Derive the contract address from the validator
//       const contractAddress = deriveAddressFromValidator(lucid, validator);

      
//       // Construct a datum for the participants
//       const participants: string[] = data.participants;
//       const encodedParticipants = participants.map((pkh) => Data.Bytes(hexToBytes(pkh)));

//       // Ensure the correct usage of the encoded participants in your datum schema or object
//       const datum = Data.to({
//         participants: encodedParticipants,
//         });

//       // Build the transaction to lock funds at the contract address
//       const tx = await lucid
//         .newTx()
//         .pay.ToAddressWithData(contractAddress, { kind: "inline", value: datum }, { lovelace: BigInt(data.amount) }) // Lock ADA in the contract
//         .complete();

//       // Return the transaction in CBOR format to the client
//       res.status(200).json({ tx: tx.toCBOR() });
//     } catch (error) {
//       res.status(500).json({ error: "Transaction failed", details: (error as Error).message });
//     }
//   } else {
//     // Handle unsupported HTTP methods
//     res.setHeader("Allow", ["POST"]);
//     res.status(405).end(`Method ${req.method} Not Allowed`);
//   }
// }

// // Helper function to convert hex to bytes
// function hexToBytes(hex: string): Uint8Array {
//   if (hex.length % 2 !== 0) {
//     throw new Error("Hex string must have an even number of characters");
//   }

//   const bytes = new Uint8Array(hex.length / 2);
//   for (let i = 0; i < hex.length; i += 2) {
//     bytes[i / 2] = parseInt(hex.substr(i, 2), 16);
//   }
//   return bytes;
// }

// // Helper to parse big integers from JSON
// export const parse = (json: string) =>
//   JSON.parse(json, (key, value) =>
//     typeof value === "string" && /^\d+n$/.test(value)
//       ? BigInt(value.slice(0, -1))
//       : value
//   );
