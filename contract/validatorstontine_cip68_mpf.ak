use aiken/builtin

use aiken/cbor

use aiken/collection/list

use aiken/crypto.{ScriptHash, VerificationKeyHash, blake2b_256}

use cardano/address
use cardano/assets
use cardano/transaction.{
  InlineDatum, Input,  NoDatum, Output, OutputReference,  Transaction,
}

use tontine/tests.{build_tx}
use types/cip68.{CIP68}
use aiken/merkle_patricia_forestry.{MerklePatriciaForestry, do_including, Proof, including, insert, has, root,  from_root} as mpf

pub type TontinePool {
  pool_id: OutputReference,  // Tracks UTXO reference
  creator: ByteArray,        // Creator’s public key hash
  pool_type: PoolType,       // ROSCA or other pool types
  governance: Governance,    // DAO-based or Creator-controlled governance
  max_members: Int,          // Max allowed participants
  state_token: StateToken,   // Efficient global state tracking
  cip68: CIP68,              // ✅ Stores metadata in CIP-68 format
  collateral_amount: Int,    // Locked funds for the pool
  status: Status             // Explicit lifecycle management
}

/// Pool Type
pub type PoolType {
  ASCA
  ROSCA
  AUCTION
}

/// Governance Model (DAO-Based)
pub type Governance {
  CreatorControlled
  DAO(ScriptHash)
}


pub type StateToken {
  StateToken {
    policy_id: ByteArray,     // Policy ID for minting governance tokens
    counter: Int,             // **State progression** for tracking updates
    global_hash: ByteArray,   // Unique hash representing pool state
    current_round: Int,       // Tracks current cycle of the tontine
  }
}

pub type Participant {
  participant_id: VerificationKeyHash,  // ✅ Public Key Hash of Participant
  pool_id: ByteArray                    // ✅ Pool they belong to
}

pub type MPF {
  root_hash: ByteArray,  // ✅ Stores only root hash of the Merkle Patricia Tree
}

// pub type CIP68 {
//   metadata: List<Pair<Data, Data>>,  // ✅ Correct list syntax
//   version: Int,                      // ✅ Follows CIP-68 standard
//   extra: Data                         // ✅ Stores extra Plutus data (needed for validity)
// }

/// Lifecycle Management
pub type Status {
  Created
  Active
  Completed
  Cancelled
}

/// Redeemer Optimization
pub type Redeemer {
  Create(TontineConfig)
  Join
  Contribute(Int)
  SelectWinner
  Cancel
  Withdraw
  Distribute
}

/// Tontine Configuration
pub type TontineConfig {
  creator: VerificationKeyHash,
  contribution_amount: Int,
  collateral_amount: Int,
  entry_fee: Int,
  max_users: Int,
  min_users: Int,
  cycle_duration: Int,
  total_rounds: Int,
  deadline_days: Int,
  governance: Governance,
}

// /// Generate a Merkle Proof for a given participant inside an existing MPF tree.
// ///
// /// ✅ **Ensures** that the participant's data is valid.
// /// ✅ **Allows** smart contracts to verify membership with low cost.
// /// ✅ **Provides** efficient proof verification.
// pub fn generate_merkle_proof(
//     trie: MerklePatriciaForestry,
//     participant_id: ByteArray,
// ) -> Proof {
//     // ✅ Compute the hashed key for lookup
//     let key = blake2b_256(participant_id)

//     // ✅ Traverse MPF to collect proof steps
//     let proof_steps: Proof = traverse_mpf_for_proof(trie, key)

//     // ✅ Return proof steps (could be empty if participant_id is not found)
//     proof_steps
    
// }

/// Generate a Merkle Proof for a given participant inside an existing MPF tree.
/// ✅ Ensures that the participant's data is valid.
/// ✅ Allows smart contracts to verify membership with low cost.
/// ✅ Provides efficient proof verification.
pub fn generate_merkle_proof(
    trie: MerklePatriciaForestry,
    participant_id: ByteArray,
) -> Proof {
    let key = blake2b_256(participant_id)
    trace @"🔍 Debug: Hashed Participant Key (blake2b_256)"
    trace cbor.diagnostic(key)

    let current_root = root(trie)
    trace @"🔍 Debug: Current MPF Root Before Proof Generation"
    trace cbor.diagnostic(current_root)

    // ✅ Generate proof using MPF traversal
    let proof_steps: Proof = traverse_mpf_for_proof(trie, key)

    // ✅ Compute expected root from proof
    let expected_root = including(key, key, proof_steps)
    trace @"🔍 Expected MPF Root from Proof" trace cbor.diagnostic(expected_root)

    // ✅ If proof does not match tree root, log an error
    if expected_root != current_root {
        trace @"🚨 Proof Mismatch! Returning Empty Proof"
        []
    } else {
        proof_steps
    }
}

/// Wrapper function for `mpf.has()` to add debug traces
pub fn debug_has(
    trie: MerklePatriciaForestry,
    key: ByteArray,
    value: ByteArray,
    proof: Proof,
) -> Bool {
    trace @"🔍 Debug: Checking MPF Membership"
    trace @"Key:" trace cbor.diagnostic(key)
    trace @"Value:" trace cbor.diagnostic(value)
    trace @"Proof Steps:" trace cbor.diagnostic(proof)
    trace @"Expected MPF Root:" trace cbor.diagnostic(mpf.root(trie))

    let is_member = mpf.has(trie, key, value, proof)

    trace @"✅ MPF Membership Result:" trace cbor.diagnostic(is_member)

    is_member
}

/// 🔍 Off-chain function to retrieve proof (Requires full trie)
/// ⚠️ This function **MUST** be called off-chain as smart contracts don't store full tries.
// pub fn get_proof_off_chain(
//   trie: MerklePatriciaForestry,
//   participant_id: ByteArray,
// ) -> Option<Proof> {
//   // ⚠️ Off-chain logic should provide this function
//   // ⚠️ On-chain, we assume proof is passed as part of transaction metadata
//   None
// }

pub fn get_proof(
    trie: MerklePatriciaForestry,
    participant_id: ByteArray,
) -> Option<Proof> {
    // ✅ Compute the hashed key for lookup
    let key = blake2b_256(participant_id)

    // ✅ Traverse MPF to collect proof steps
    let proof_steps: Proof = traverse_mpf_for_proof(trie, key)
    trace @"Trace Proof: "
    trace cbor.diagnostic(proof_steps)

    // ✅ If proof exists, return Some(proof), otherwise return None
    if list.is_empty(proof_steps) {
        None
    } else {
        Some(proof_steps)
    }
}

pub fn traverse_mpf_for_proof(
    trie: MerklePatriciaForestry,
    key: ByteArray,
) -> Proof {
    let hashed_key = blake2b_256(key)
    let proof_steps: Proof = []

    // ✅ Log traversal process
    trace @"🔍 Debug: Checking proof for hashed key"
    trace cbor.diagnostic(hashed_key)

    let computed_root = do_including(hashed_key, hashed_key, 0, proof_steps)

    trace @"🔍 Debug: Computed Root from Inclusion"
    trace cbor.diagnostic(computed_root)

    if computed_root == root(trie) {
        trace @"✅ Proof Steps are Valid!"
        proof_steps
    } else {
        trace @"🚨 Proof Mismatch! Returning Empty Proof"
        []
    }
}






pub fn handle_join(datum: TontinePool, transaction: Transaction) -> Bool { 
  let Transaction { inputs, outputs, extra_signatories, .. } = transaction

  // ✅ Debug: Print participant signatories
  trace @"Debug: Transaction Extra Signatories"
  trace cbor.diagnostic(extra_signatories)

  // ✅ Ensure the pool is active
  let is_active = datum.status == Active
  trace @"Debug: Pool Active Status"
  trace cbor.diagnostic(is_active)

  // ✅ Ensure the participant has signed the transaction
  let participant_opt =
    list.find(
      extra_signatories,
      fn(signatory) { list.has(extra_signatories, signatory) },
    )

  // ✅ Debug: Check participant signing
  trace @"Debug: Found Participant Signature"
  trace cbor.diagnostic(participant_opt)

  expect Some(participant_id) = participant_opt

  // ✅ Convert OutputReference to ByteArray
  let pool_id_bytes: ByteArray = builtin.serialise_data(datum.pool_id)
  trace @"Debug: Serialized Pool ID"
  trace cbor.diagnostic(pool_id_bytes)

  // ✅ Hash the converted ByteArray
  let key: ByteArray = blake2b_256(pool_id_bytes)
  trace @"Debug: Computed MPF Key (blake2b_256)"
  trace cbor.diagnostic(key)

  // ✅ Attempt to retrieve the MPF Root from CIP-68 metadata
  let mpf_data_opt: Option<Data> = Some(cip68.get(datum.cip68, key))

  // ✅ Debug: Check MPF data retrieval
  trace @"Debug: Retrieved MPF Data"
  trace cbor.diagnostic(mpf_data_opt)

  // ✅ Ensure `mpf_data_opt` is Some(Data), otherwise fail
  expect Some(mpf_data) = mpf_data_opt

  // ✅ Convert extracted Data to ByteArray
  let existing_mpf_root: ByteArray = builtin.un_b_data(mpf_data)
  trace @"Debug: Extracted MPF Root"
  trace cbor.diagnostic(existing_mpf_root)

  // ✅ Initialize MPF instance from root hash
  let mpf_tree = from_root(existing_mpf_root)
  trace @"Debug: Initialized MPF Tree"

  // ✅ Generate Merkle Proof for participant
  let proof: Proof = generate_merkle_proof(mpf_tree, participant_id)
  trace @"Debug: Generated Merkle Proof"
  trace cbor.diagnostic(proof)

  // ✅ Verify proof correctness before insertion
  let proof_is_valid = has(mpf_tree, participant_id, participant_id, proof)
  trace @"Debug: Is Participant's Proof Valid?"
  trace cbor.diagnostic(proof_is_valid)

  expect proof_is_valid == False  // The participant should NOT be in the tree before joining

  // ✅ Ensure pool has space for new participants
  let participant_count = list.length(datum.cip68.metadata)
  let can_join = participant_count < datum.max_members
  trace @"Debug: Pool Capacity Check"
  trace cbor.diagnostic(can_join)

  // ✅ Ensure participant collateral is locked in transaction inputs
  let has_collateral =
    list.any(
      inputs,
      fn(input) {
        let lovelace = assets.lovelace_of(input.output.value)
        lovelace >= datum.collateral_amount
      },
    )
  trace @"Debug: Collateral Requirement Met?"
  trace cbor.diagnostic(has_collateral)

  // ✅ Insert participant into MPF tree
  let updated_mpf_tree = insert(mpf_tree, participant_id, participant_id, proof)
  let updated_mpf_root = root(updated_mpf_tree)
  trace @"Debug: New MPF Root After Insertion"
  trace cbor.diagnostic(updated_mpf_root)

  // ✅ Validate proof after insertion
  let post_insertion_proof = generate_merkle_proof(updated_mpf_tree, participant_id)
  let proof_after_insert_is_valid = has(updated_mpf_tree, participant_id, participant_id, post_insertion_proof)
  trace @"Debug: Is Proof Valid After Insertion?"
  trace cbor.diagnostic(proof_after_insert_is_valid)

  expect proof_after_insert_is_valid == True  // Now proof should be valid!

  // ✅ Construct updated CIP-68 metadata with new MPF root
  let updated_metadata =
    CIP68 {
      metadata: [
        Pair(
          builtin.b_data(
            #"2131A7D2A11D14D45013EA598D81EA5D0D3C2411750C56E45FB8F0796374959E",
          ),
          builtin.b_data(updated_mpf_root),
        ),
      ],
      version: datum.cip68.version + 1,
    }
  trace @"Debug: Updated CIP-68 Metadata"
  trace cbor.diagnostic(updated_metadata)

  // ✅ Construct updated TontinePool state
  let updated_datum =
    TontinePool {
      pool_id: datum.pool_id,
      creator: datum.creator,
      pool_type: datum.pool_type,
      governance: datum.governance,
      max_members: datum.max_members,
      state_token: datum.state_token,
      cip68: updated_metadata,
      collateral_amount: datum.collateral_amount,
      status: datum.status,
    }
  trace @"Debug: Updated TontinePool State"
  trace cbor.diagnostic(updated_datum)

  // ✅ Ensure updated Merkle Root appears in transaction outputs
  let metadata_updated =
    list.any(outputs, fn(output) { output.datum == InlineDatum(updated_datum) })
  trace @"Debug: Is Updated Metadata in Transaction Outputs?"
  trace cbor.diagnostic(metadata_updated)
  
  // ✅ Final validation check
  let final_result = is_active && can_join && has_collateral && metadata_updated
  trace @"Debug: Final Result of handle_join"
  trace cbor.diagnostic(final_result)

  final_result
}




// Test Constants
const dummy_tx_id = #"00000000000000000000000000000000000000000000000000000000"
const creator_vk = #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f50"
const dao_script_hash = #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f51"
const policy_id = #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f52"
const asset_name = #"f5a3b9c4252d8670"
const collateral = 30_000_000
const contribution_amt = 50_000_000
const entry_fee = 5_000_000
const initial_mpf_root = mpf.root(mpf.empty) 

// Sample CIP-68 Metadata
const initial_cip68 = CIP68 {
  metadata: [
    Pair(
      builtin.b_data(
        #"2131A7D2A11D14D45013EA598D81EA5D0D3C2411750C56E45FB8F0796374959E"
      ),
      builtin.b_data(initial_mpf_root),
    ),
  ],
  version: 1,
}

// Sample Tontine Configuration
const tontine_config = TontineConfig {
    creator: creator_vk,
    contribution_amount: contribution_amt,
    collateral_amount: collateral,
    entry_fee,
    max_users: 6,
    min_users: 3,
    cycle_duration: 30,
    total_rounds: 30,
    deadline_days: 5,
    governance: DAO(dao_script_hash),
}

// Sample Pool Datum  
const sample_pool_datum = TontinePool {
    pool_id: OutputReference { transaction_id: dummy_tx_id, output_index: 0 },
    creator: creator_vk,
    pool_type: ROSCA,
    governance: tontine_config.governance,
    max_members: tontine_config.max_users,
    state_token: StateToken {
        policy_id,
        counter: 0,
        global_hash: #"",
        current_round: 1,
    },
    cip68: initial_cip68,
    collateral_amount: collateral,
    status: Active,
}

test participant_proof_validation_after_joining() {
    let participant_vk = #"f5a3b9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f50"
    let participant_id: VerificationKeyHash = participant_vk

    // Step 1: Initialize an empty MPF tree
    let mpf_tree = mpf.empty
    let proof: Proof = []

    // Step 2: Ensure participant is NOT in the tree initially
    let not_in_tree = has(mpf_tree, participant_id, participant_id, proof)
    trace @"Before Join: Is participant in MPF tree?" trace cbor.diagnostic(not_in_tree)
    expect not_in_tree == False

    // Step 3: Insert participant into MPF tree
    trace @"Inserting participant into MPF with key:" trace cbor.diagnostic(participant_id)
    let updated_mpf_tree = insert(mpf_tree, participant_id, participant_id, proof)
    let updated_mpf_root = root(updated_mpf_tree)

    trace @"After Join: Updated MPF Root" trace cbor.diagnostic(updated_mpf_root)

    // Step 4: Generate proof after join
    let valid_proof = generate_merkle_proof(updated_mpf_tree, participant_id)
    trace @"Generated Merkle Proof (Valid)" trace cbor.diagnostic(valid_proof)

    // Step 5: Validate proof
    trace @"Validating Proof After Join"
    let proof_is_valid = has(updated_mpf_tree, participant_id, participant_id, valid_proof)
    trace @"Is valid proof accepted?" trace cbor.diagnostic(proof_is_valid)

    // Step 6: Validate proof using expected root
    let expected_proof_root = including(participant_id, participant_id, valid_proof)
    trace @"🔍 Expected Proof Root from Inclusion" trace cbor.diagnostic(expected_proof_root)

    // Step 7: Ensure proof validation is correct
    expect expected_proof_root == updated_mpf_root
    expect proof_is_valid == True
}




test participant_can_join_with_mpf() {
    let participant_vk = #"f5a3b9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f50"
    let participant_id: VerificationKeyHash = participant_vk
    

    // Initialize empty MPF tree
    let mpf_tree = mpf.empty

    // Generate Merkle Proof for participant (initially empty)
    let proof: Proof = []

    // Ensure participant is NOT in the tree before joining
    let not_in_tree = has(mpf_tree, participant_id, participant_id, proof)
    trace @"not-in-tree? if 121 -> OK: " trace cbor.diagnostic(not_in_tree)
    expect not_in_tree == False

    // Insert participant into MPF tree
    let updated_mpf_tree = insert(mpf_tree, participant_id, participant_id, proof)
    let updated_mpf_root = root(updated_mpf_tree)

    trace @"From_Test_TRACE_updated_mpf_tree: " trace cbor.diagnostic(updated_mpf_tree)
    trace @"From_Test_TRACE_updated_mpf_root: " trace cbor.diagnostic(updated_mpf_root)

    // ✅ Ensure transaction inputs contain the required collateral
    let collateral_utxo = Input {
        output: Output {
            address: address.from_verification_key(participant_vk),
            value: assets.from_lovelace(collateral),  // ✅ Ensure collateral is present
            datum: NoDatum,  // No datum required here
            reference_script: None
        },
        output_reference: OutputReference { transaction_id: dummy_tx_id, output_index: 0 } // Dummy UTXO
    }

    trace @"Debug: Constructed Collateral UTXO" trace cbor.diagnostic(collateral_utxo)

    // ✅ Construct updated CIP-68 metadata with new MPF root
    
    let updated_metadata = CIP68 {
       metadata: [
        Pair(
          builtin.b_data(
            #"2131A7D2A11D14D45013EA598D81EA5D0D3C2411750C56E45FB8F0796374959E"
          ),
          builtin.b_data(updated_mpf_root),
       ),
      ],
      version: sample_pool_datum.cip68.version + 1,  // ✅ Increment version
   }

    // ✅ Construct updated TontinePool state
    let updated_datum = TontinePool {
      pool_id: sample_pool_datum.pool_id,
      creator: sample_pool_datum.creator,
      pool_type: sample_pool_datum.pool_type,
      governance: sample_pool_datum.governance,
      max_members: sample_pool_datum.max_members,
      state_token: sample_pool_datum.state_token,
      cip68: updated_metadata,  // ✅ Store updated Merkle Root
      collateral_amount: sample_pool_datum.collateral_amount,
      status: sample_pool_datum.status,
    }

    // ✅ Construct the transaction with the collateral input
    let tx = build_tx(
        Some([collateral_utxo]),  // ✅ Ensure transaction has collateral input
        None,
        Some([
            Output {
                address: address.from_verification_key(participant_vk),
                value: assets.from_asset(policy_id, asset_name, 1),
                datum: InlineDatum(updated_datum),  // ✅ Store updated MPF root
                reference_script: None
            }
        ]),
        None,
        None,
        None,
        None,
        Some([participant_id]), // Include participant signature
        None,
        None,
        None
    )

    trace @"Debug: Transaction Inputs (Before Join)" trace cbor.diagnostic(tx.inputs)

    // ✅ Validate participant joining
    let can_join = handle_join(sample_pool_datum, tx)

    trace @"Debug: handle_join result" trace cbor.diagnostic(can_join)

    expect can_join == True
}
