// import { VerificationKeyHash } from "@cardano-foundation/cardano-connect-with-wallet-core";
// import { useCardano } from "@cardano-foundation/cardano-connect-with-wallet";
// import { NetworkType } from "@cardano-foundation/cardano-connect-with-wallet-core";
// import {
//   Assets,
//   Emulator,
//   fromUnit,
//   Lucid,
//   UTxO
// } from "@lucid-evolution/lucid";
// import {aggregateTokens, BuyNFTConfig, hexToString, LockNFTConfig, NFTMinterConfig, parseAssetId, Token, WithdrawNFTConfig} from "../pages/api/apitypes";
// import { useEffect, useState } from "react";

// // Define the participant type (VerificationKeyHash as a byte array)
// export type Participant = Uint8Array;

// // Define the datum for the Tontine, which is a list of participants
// export type Datum = {
//   participants: Participant[];
// };

// // New lockTontineFunds function with Uint8Array for participants
// const lockTontineFunds = async (participants: string[], amount: bigint) => {
//   if (isConnected && enabledWallet) {
//     try {
//       const lucid = await Lucid(new Emulator([]), "Preprod");
//       const api = await window.cardano[enabledWallet].enable();
//       lucid.selectWallet.fromAPI(api);

//       // Convert participant strings to Uint8Array (VerificationKeyHash)
//       const participantHashes = participants.map((participant) =>
//         Uint8Array.from(Buffer.from(participant, 'hex')) // Assumes the participant strings are hex-encoded
//       );

//       // Get the validator address from your Tontine smart contract
//       const validatorAddress = lucid.utils.validatorToAddress({
//         script: await fetch("./env").then(res => res.text()),
//       });

//       // Construct the datum according to your smart contract
//       const datum: Datum = {
//         participants: participantHashes,
//       };

//       // Create a UTxO with the specified amount and lock it under the validator
//       const tx = await lucid
//         .newTx()
//         .pay.ToAddress(validatorAddress, { lovelace: amount.toString() }, datum)
//         .complete();

//       const signedTx = await tx.sign.withWallet().complete();
//       const txHash = await signedTx.submit();

//       console.log("Transaction submitted:", txHash);
//     } catch (error) {
//       console.error("Failed to lock funds for Tontine:", error);
//     }
//   }
// };
