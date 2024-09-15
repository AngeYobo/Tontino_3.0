"use client";

import React, { useState } from "react";
import { useCardano } from "@cardano-foundation/cardano-connect-with-wallet";
import { NetworkType } from "@cardano-foundation/cardano-connect-with-wallet-core";
import { Lucid, Blockfrost } from "@lucid-evolution/lucid";

const Contribute = () => {
  // Properly map NETWORK_ENV to NetworkType
  const networkEnv = process.env.NETWORK_ENV === "Preprod" ? NetworkType.TESTNET : NetworkType.MAINNET;

  const { isConnected, usedAddresses, enabledWallet } = useCardano({
    limitNetwork: networkEnv,
  });

  const [amount, setAmount] = useState<number | string>("");

  const handleContribute = async () => {
    if (isConnected && enabledWallet) {
      try {
        const lucid = await Lucid(
          new Blockfrost(
            `https://cardano-${process.env.NETWORK_ENV!.toLowerCase()}.blockfrost.io/api/v0`,
            process.env.BLOCKFROST_API_KEY!
          ),
          networkEnv
        );

        const api = await window.cardano[enabledWallet].enable();
        lucid.selectWallet.fromAPI(api);

        const tx = await lucid
          .newTx()
          .pay.ToAddress("cf251272284aa24b71fe9387a8a5c91b9a271c615a50d59c562f40d9", { lovelace: BigInt(amount) }) 
          .complete();

        const signedTx = await tx.sign.withWallet().complete();
        const txHash = await signedTx.submit();
        console.log("Transaction hash:", txHash);
      } catch (error) {
        console.error("Error contributing funds:", error);
      }
    }
  };

  return (
    <div className="flex flex-col items-center gap-3 sm:gap-6 lg:gap-8">
      <h2 className="text-2xl">Contribute to Tontine</h2>
      <input
        type="number"
        placeholder="Amount in Lovelace"
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
        className="input input-bordered"
      />
      <button className="btn btn-outline" onClick={handleContribute}>
        Contribute
      </button>
    </div>
  );
};

export default Contribute;
