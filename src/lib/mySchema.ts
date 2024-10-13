import { Data } from "@lucid-evolution/lucid";

// VerificationKeyHash Schema (as a hex-encoded byte array)
export const VerificationKeyHashSchema = Data.Bytes({
  minLength: 28,
  maxLength: 28,
});

// Export the type and schema for VerificationKeyHash
export type VerificationKeyHash = Data.Static<typeof VerificationKeyHashSchema>;
export const VerificationKeyHash = VerificationKeyHashSchema as unknown as VerificationKeyHash;

// Datum Schema: A list of participants represented by their VerificationKeyHashes (hex-encoded byte arrays)
export const DatumSchema = Data.Object({
  participants: Data.Array(VerificationKeyHashSchema), // Use Data.Array to hold byte arrays (hex-encoded hashes)
});

// Export the type and schema for Datum
export type Datum = Data.Static<typeof DatumSchema>;
export const Datum = DatumSchema as unknown as Datum;

// Redeemer Schema: Contains the winner_index (integer)
const RedeemerSchema = Data.Object({
  winner_index: Data.Integer(),
});

// Export the type and schema for Redeemer
export type Redeemer = Data.Static<typeof RedeemerSchema>;
export const Redeemer = RedeemerSchema as unknown as Redeemer;

// OutputReference Schema: Transaction ID and output index
const OutputReferenceSchema = Data.Object({
  transaction_id: Data.Bytes({ minLength: 32, maxLength: 32 }), // Transaction ID is 32 bytes
  output_index: Data.Integer(),
});

// Export the type and schema for OutputReference
export type OutputReference = Data.Static<typeof OutputReferenceSchema>;
export const OutputReference = OutputReferenceSchema as unknown as OutputReference;
