import React, { useState } from 'react';
import { Lucid, Blockfrost, fromText, scriptFromNative, paymentCredentialOf, unixTimeToSlot } from '@lucid-evolution/lucid';
import { mintingPolicyToId } from '@lucid-evolution/utils';

const MintStateToken = () => {
  const [txHash, setTxHash] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const mintAssets = async () => {
    try {
      setIsLoading(true);
      setError(null);

      // Initialize Lucid with Blockfrost API and wallet connection
      const blockfrostApiKey = process.env.NEXT_PUBLIC_BLOCKFROST_KEY_PREPROD;
      const networkEnv = 'Preprod'; // Change to 'Mainnet' if required

      const lucid = await Lucid(
        new Blockfrost(`https://cardano-${networkEnv.toLowerCase()}.blockfrost.io/api/v0`, blockfrostApiKey),
        networkEnv
      );

      // Enable wallet connection
      const api = await window.cardano.nami.enable();
      lucid.selectWallet.fromAPI(api);

      // Get the current address (this will be the minting key)
      const address = await lucid.wallet().address();

      // Create a time-locked minting policy
      const mintingPolicy = scriptFromNative({
        type: 'all',
        scripts: [
          { type: 'sig', keyHash: paymentCredentialOf(address).hash }, // Required signer
          {
            type: 'before', // Time-lock condition
            slot: unixTimeToSlot(lucid.config().network, Date.now() + 1000000), // Slot until which minting is allowed
          },
        ],
      });

      // Derive the Policy ID from the minting policy
      const policyId = mintingPolicyToId(mintingPolicy);
      console.log('Policy ID:', policyId);

      // Define the assets to be minted
      const assetsToMint = {
        [`${policyId}${fromText('StateToken')}`]: 1n, // Mint 1 unit of "StateToken"
      };

      // Build the transaction to mint tokens and send them to the address
      const tx = await lucid
        .newTx()
        .mintAssets(assetsToMint) // Mint the assets
        .pay.ToAddress(address, { [`${policyId}${fromText('StateToken')}`]: 1n }) // Send the token to the address
        .validTo(Date.now() + 900_000) // Set transaction validity
        .attach.MintingPolicy(mintingPolicy) // Attach the minting policy
        .complete();

      console.log('Transaction built');

      // Sign and submit the transaction
      const signedTx = await tx.sign.withWallet().complete();
      const txHash = await signedTx.submit();
      console.log('Transaction submitted. Tx Hash:', txHash);

      setTxHash(txHash);
      setIsLoading(false);
    } catch (err) {
      console.error('Minting failed:', err);
      setError('Minting failed. Please check the console for more details.');
      setIsLoading(false);
    }
  };

  return (
    <div className="mint-state-token">
      <h2>Mint State Token</h2>
      <button onClick={mintAssets} disabled={isLoading}>
        {isLoading ? 'Minting...' : 'Mint State Token'}
      </button>
      {txHash && <p>Transaction Hash: {txHash}</p>}
      {error && <p style={{ color: 'red' }}>{error}</p>}
    </div>
  );
};

export default MintStateToken;
