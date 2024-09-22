"use client";
import React, { useEffect } from "react";
import { useCardano } from "@cardano-foundation/cardano-connect-with-wallet";
import { NetworkType } from "@cardano-foundation/cardano-connect-with-wallet-core";
import Image from "next/image";

declare global {
  interface Window {
    my_modal: any;
  }
}

type WalletModalProps = {
  onClose: () => void;
};

const WalletModal: React.FC<WalletModalProps> = ({ onClose }) => {
  const network =
    process.env.NEXT_PUBLIC_NETWORK_ENV === "Preprod"
      ? NetworkType.TESTNET
      : NetworkType.MAINNET;

  const { isConnected, connect, disconnect, installedExtensions } = useCardano({
    limitNetwork: network,
  });

  // Automatically close modal when wallet is connected
  useEffect(() => {
    if (isConnected) {
      window.my_modal.close();
    }
  }, [isConnected]);

  return (
    <div>
      {/* Connect/Disconnect Button */}
      {!isConnected ? (
        <button
          className="btn btn-primary py-2 px-6 rounded-full hover:bg-blue-600 transition"
          onClick={() => window.my_modal.showModal()}
        >
          CONNECT WALLET
        </button>
      ) : (
        <button
          className="btn btn-red py-2 px-6 rounded-full hover:bg-red-600 transition"
          onClick={disconnect}
        >
          DISCONNECT WALLET
        </button>
      )}

      {/* Modal for wallet selection */}
      <dialog id="my_modal" className="modal modal-open bg-white rounded-lg shadow-lg p-8">
        <form method="dialog" className="modal-box w-80 bg-gray-100 rounded-lg shadow-lg">
          <h2 className="text-lg font-bold mb-4">Connect Your Wallet</h2>
          <div className="flex flex-col gap-4">
            {installedExtensions.map((provider: string) => (
              <div
                key={provider}
                className="flex justify-between items-center border p-3 rounded-lg bg-white hover:shadow-md cursor-pointer"
                onClick={() => connect(provider)}
              >
                <span className="text-lg font-semibold">{provider.toUpperCase()}</span>
                <Image
                  src={window.cardano[provider].icon}
                  alt={provider}
                  width={32}
                  height={32}
                  className="rounded-full"
                />
              </div>
            ))}
          </div>

          <div className="mt-6 text-center">
            <button className="btn btn-secondary" onClick={onClose}>
              Close
            </button>
          </div>
        </form>
      </dialog>
    </div>
  );
};

export default WalletModal;
