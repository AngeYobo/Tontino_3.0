"use client";

import { useCardano } from "@cardano-foundation/cardano-connect-with-wallet";
import { NetworkType } from "@cardano-foundation/cardano-connect-with-wallet-core";
import {
  Assets,
  Emulator,
  fromUnit,
  Lucid,
  UTxO
} from "@lucid-evolution/lucid";
import {aggregateTokens, BuyNFTConfig, hexToString, LockNFTConfig, NFTMinterConfig, parseAssetId, Token, WithdrawNFTConfig} from "./../pages/api/apitypes";
import { useEffect, useState } from "react";


type TransactionType = "Delegate" | "Mint" | "Withdraw" | "Lock" | "Buy"

const tokenInfo = fromUnit("b1d54b4cef31e9bc8705f14c2126878f129ccb4547009707af9365a05279616e437573746f6d");
//nft marketplace with diagnostics
const nftMarketPlace = "5903a1010100323232323232322533300232323232325332330083001300937540042646464a664660186002601a6ea801c4c8c94ccc044c0500084c8c8c8c8c8c8c94ccc054c038c058dd500089919191919299980d1807980d9baa001132323232533301e3013301f3754002264a66603e66ebc0280104c8c8c8c8c8c94ccc094c078c098dd51815181580109919191919192999815981218161baa3030303100213232533303030330021323232323253330323375e6e98040dd30050a99981919baf00e008153330323375e604860686ea8048c090c0d0dd50060a99981919b8f00548811cf4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f5000153330320011302b00214a029405280a5014a0a666062604c60646ea930103d87a800013371e0046eb8c0d8c0ccdd5260103d87a800014a26eb4c0d4c0d8008dd7181a000981a0011bae303200116375860620026466002002646600200201644a666062002297adef6c6013232323253330323372291100002153330323371e91010000210031005133036337606ea4008dd3000998030030019bab3033003375c6062004606a004606600244a666060002297ae01323332223233001001003225333036001100313233038374e660706ea4018cc0e0c0d4004cc0e0c0d80052f5c066006006607400460700026eb8c0bc004dd5981800099801801981a00118190008b181780098178011bab302d001302d002302b0013027375400e2c605200260520046eacc09c004c09c008c094004c084dd50018b181198101baa001163300c006005302130220023020001301c3754603e60386ea800458cc020dd6180f0019bad301e4bd7081010000810100001bad301d301e4bd709010000810100001bac301c301d301d001301837540066034602e6ea800458c064c068c068008c060004c050dd518019980b0079980b0069980b19ba548008cc058024cc0594ccc048c01cc04cdd5004098019980b18019980b1ba732330010013758600a602a6ea8c060c054dd500491299980b8008a5eb804cc060c064004cc008008c0680052f5c097ae014c0103d87a80004bd7025eb80c0040048894ccc0580085300103d87a8000132325333015300a00313006330190024bd70099980280280099b8000348004c06800cc060008dd2a4000460280022c6eb4c048004c038dd50039b874800058c03cc040008c038004c028dd50011b874800858c02cc030008c028004c028008c020004c010dd50008a4c26cacae6955ceaab9e5573eae815d0aba201"


const Delegate = async () => {
  const network =
    process.env.NODE_ENV === "development"
      ? NetworkType.TESTNET
      : NetworkType.MAINNET;
  const { isConnected, usedAddresses, enabledWallet } = useCardano({
    limitNetwork: network,
  });

  const getWalletTokens = async (): Promise<Record<string,Token>> => {
    if (isConnected && enabledWallet) {
      try {
        const lucid = await Lucid(new Emulator([]), "Preprod");
        const api = await window.cardano[enabledWallet].enable();
        lucid.selectWallet.fromAPI(api);

        const utxos: UTxO[] = await lucid.wallet().getUtxos();
        const tokens: Token[] = [];

        for (const utxo of utxos) {
          const assets = utxo.assets;
          for (const [assetId, quantity] of Object.entries(assets)) {
            const { policyId, tokenName } = parseAssetId(assetId);
            tokens.push({
              policyId,
              tokenName,
              quantity: BigInt(quantity)
            });
          }
        }
        return aggregateTokens(tokens);
      } catch (error) {
        console.error("Failed to fetch wallet tokens:", error);
        return {};
      }
    }
    return {};
  };

  const [walletTokens, setWalletTokens] = useState<Record<string, Token>>({});

  useEffect(()=>{
    if (isConnected){
      getWalletTokens().then(aggregatedTokens => setWalletTokens(aggregatedTokens));
    }
  },[isConnected]);

  const handleAPI = async (param: TransactionType) => {
    if (isConnected && enabledWallet) {
      try {
        const lucid = await Lucid(new Emulator([]), "Preprod");
        const api = await window.cardano[enabledWallet].enable();
        lucid.selectWallet.fromAPI(api);
        let response;

      if (param === "Mint")
      {
        const body: NFTMinterConfig = {TokenName: "RyanCustom", address: usedAddresses[0]};
        response = await fetch("/api/mint", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          
          body: JSON.stringify(body),
        });
      } else if (param === "Lock") {
        console.log("reached lock");
        const body: LockNFTConfig = {priceOfAsset: (10_000_000n).toString(), policyID: tokenInfo.policyId , TokenName: tokenInfo.assetName! ,marketPlace: nftMarketPlace, sellerAddr: await lucid.wallet().address() };
        response = await fetch("/api/lock", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(body),
        });
      } else if (param === "Withdraw") {
        const body: WithdrawNFTConfig = {marketplace: nftMarketPlace, sellerAddr: await lucid.wallet().address(), pid: tokenInfo.policyId};
        response = await fetch("/api/withdraw", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(body),
        });
      } else if (param === "Buy") {
        const body: BuyNFTConfig = {marketplace: nftMarketPlace, sellerAddr: await lucid.wallet().address(), pid: tokenInfo.policyId };
        response = await fetch("/api/buy", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(body),
        });
      } else {
        const body: NFTMinterConfig = {TokenName: "RyanCustom", address: usedAddresses[0]};
          response = await fetch("/api/mint", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(body),
        });
      }      


        const { tx } = await response.json();
        const signedTx = await lucid.fromTx(tx).sign.withWallet().complete();
        const txh = await signedTx.submit();
        console.log(txh);
      } catch (error) {
        console.log(error);
      }
    }
  };

  return (
    <>
      {isConnected ? (
        <div className="flex flex-row items-start gap-3 sm:gap-6 lg:gap-8 w-full">
          {/* Column for buttons */}
          <div className="flex flex-col items-center w-1/2">
          <h2 className="text-lg font-semibold mb-4">Functions</h2>
            <button className="btn btn-primary mb-4" onClick={() => handleAPI("Mint")}>
              Mint NFT
            </button>
            <button className="btn btn-primary mb-4" onClick={() => handleAPI("Lock")}>
              Lock NFT
            </button>
            <button className="btn btn-primary mb-4" onClick={() => handleAPI("Withdraw")}>
              Withdraw
            </button>
            <button className="btn btn-primary mb-4" onClick={() => handleAPI("Buy")}>
              Buy NFT
            </button>
          </div>
              
                      {/* Column for wallet tokens */}
            <div className="w-1/2">
            <h2 className="text-lg font-semibold mb-4">Tokens</h2>
               {Object.entries(walletTokens).map(([key, token], index) => (
                <div key={index} className="mb-4">
                  <h1 className="flex-grow">
                    <span>{token.tokenName}</span>
                    <span>{"...."}</span>
                    <span>{token.quantity.toString()}</span>
                  </h1>
                </div>
              ))}
            </div>
        </div>
      ) : null}
    </>
  );

};

export default Delegate;