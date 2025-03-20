// use aiken/builtin
// use aiken/cbor
// use aiken/collection/dict
// use aiken/collection/list
// use aiken/collection/pairs
// use aiken/crypto.{ScriptHash, VerificationKeyHash}
// use aiken/merkle_patricia_forestry.{
//   MerklePatriciaForestry,  Proof, from_root, has,
//   insert, root,
// }
// use aiken/option
// use aiken/primitive/bytearray
// use cardano/address.{Address, Script}
// use cardano/assets.{PolicyId}
// use cardano/transaction.{
//   InlineDatum, Input, NoDatum, Output, OutputReference, Transaction,
// }
// use cardano/tx
// use tontine/tests.{build_tx}
// use types/cip68.{CIP68}

// // Core Structure
// pub type TontinePool {
//   pool_id: OutputReference,
//   creator: ByteArray,
//   pool_type: PoolType,
//   governance: Governance,
//   max_members: Int,
//   state_token: StateToken,
//   cip68: CIP68,
//   collateral_amount: Int,
//   status: Status,
// }

// // ✅ Explicit lifecycle management

// // Participant Tracking
// pub type Participant {
//   participant_id: VerificationKeyHash,
//   pool_id: ByteArray,
//   cip68: CIP68,
// }

// // Rounds & State Tracking
// pub type Round {
//   round_number: Int,
//   cip68: CIP68,
// }

// // Efficient Global State Tracking
// pub type StateToken {
//   StateToken {
//     policy_id: ByteArray,
//     counter: Int,
//     global_hash: ByteArray,
//     current_round: Int,
//   }
// }

// // Merkle Patricia Forest for On-Chain Data Compression
// pub type MPF {
//   root_hash: ByteArray,
//   key_value_pairs: List<Pair<ByteArray, ParticipantData>>,
// }

// pub type ParticipantData {
//   contribution: Int,
//   payouts: Int,
// }

// // Pool Type
// pub type PoolType {
//   ASCA
//   ROSCA
//   AUCTION
// }

// // Governance Model (DAO-Based)
// pub type Governance {
//   CreatorControlled
//   DAO(ScriptHash)
// }


// // Tontine Configuration
// pub type TontineConfig {
//   creator: VerificationKeyHash,
//   contribution_amount: Int,
//   collateral_amount: Int,
//   entry_fee: Int,
//   max_users: Int,
//   min_users: Int,
//   cycle_duration: Int,
//   total_rounds: Int,
//   deadline_days: Int,
//   governance: Governance,
// }

// // Lifecycle Management
// pub type Status {
//   Created
//   Active
//   Completed
//   Cancelled
// }

// // Redeemer Optimization
// pub type Redeemer {
//   Create(TontineConfig)
//   Join
//   Contribute(Int)
//   SelectWinner
//   Cancel
//   Withdraw
//   Distribute
// }

// // pub type CIP68 {
// //   metadata: Pairs<Data, Data>,
// //   version: Int,
// //   // extra
// // }

// // The generic CIP68 metadatum type as defined in the CIP at
// // https:// // cips.cardano.org// cips// cip68// .
// // Return the version of the metadata.
// // // // 
// // ```aiken
// // metadatum |> cip68.version
// // ```
// pub fn version(metadata: CIP68) -> Int {
//   metadata.version
// }

// // Attempt to find a data structure by a key inside the cip68 metadatum. If
// // nothing is found then return `None`.
// // // // 
// // ```aiken
// // cip68.get(metadatum, some_key)
// // ```

// pub fn get(cip68: CIP68, key: Data) -> Option<Data> {
//   do_get(cip68.metadata, key)
// }

// pub fn do_get(cip68: Pairs<Data, Data>, key: Data) -> Option<Data> {
//   when cip68 is {
//     [] -> None
//     [d, ..ds] ->
//       if builtin.fst_pair(d) == key {
//         Some(builtin.snd_pair(d))
//       } else {
//         do_get(ds, key)
//       }
//   }
// }

// ///**Tontine Validator for Minting & Spending**
// validator tontine_validator(
//   tontine_ref: OutputReference,
//   config: TontineConfig,
// ) {
//   ///**Minting Tontine State Token**
//   mint(redeemer: Redeemer, policy_id: PolicyId, transaction: Transaction) {
//     let Transaction { inputs, mint, extra_signatories, .. } = transaction
//     when redeemer is {
//       Create(config) -> {
//         // Check that a known reference UTxO is present.
//         expect Some(_input) =
//           list.find(inputs, fn(input) { input.output_reference == tontine_ref })
//         // Extract minted tokens.
//         expect [Pair(state_token_name, amount)] =
//           mint |> assets.tokens(policy_id) |> dict.to_pairs()
//         expect amount == 1
//         // Must mint exactly one state token.
//         // **Extra Check:** Verify the token name is as expected.
//         let expected_token_name = "CIP68PoolNFT"
//         expect state_token_name == expected_token_name
//         // (Optional) If the pool datum carries CIP68 metadata that is constructed off‑chain,
//         // you could also validate it here. (Typically, the metadata is updated in spending transactions.)
//         // let metadata_valid =
//         //   validate_cip68_metadata(
//         //     datum.cip68,
//         //     config.creator,
//         //     extra_signatories,
//         //   )
//         // expect metadata_valid == True
//         // Enforce governance rules.
//         let governance_valid =
//           when config.governance is {
//             CreatorControlled -> list.has(extra_signatories, config.creator)
//             DAO(dao_script_hash) -> list.has(extra_signatories, dao_script_hash)
//           }
//         governance_valid?
//       }
//       _ -> fail @"Invalid redeemer for minting"
//     }
//   }

//   ///**Spending (Joining, Contributing, Withdrawing, etc.)**
//   spend(
//     datum_opt: Option<TontinePool>,
//     redeemer: Redeemer,
//     own_ref: OutputReference,
//     transaction: Transaction,
//   ) {
//     let Transaction { inputs, outputs, extra_signatories, .. } = transaction
//     // ✅ Ensure the datum exists and trace it for debugging
//     expect Some(datum) = datum_opt
//     trace @"Debug: Extracted datum"
//     trace cbor.diagnostic(datum)
//     // ✅ Find the own input (the UTxO being spent)
//     expect Some(own_input) =
//       list.find(inputs, fn(input) { input.output_reference == own_ref })
//     // ✅ Extract the inline datum and convert it to TontinePool
//     expect InlineDatum(stored_datum) = own_input.output.datum
//     expect stored_tontine: TontinePool = stored_datum
//     // ✅ Define stored_tontine first!
//     // ✅ Extract and validate policy_id *after* stored_tontine exists
//     expect Script(policy_id) = own_input.output.address.payment_credential
//     expect policy_id == stored_tontine.state_token.policy_id
//     // ✅ Validate CIP68 metadata (ensuring metadata is well-formed)
//     let metadata_valid =
//       validate_cip68_metadata(
//         stored_tontine.cip68,
//         config.creator,
//         extra_signatories,
//       )
//     expect metadata_valid == True

//     // ✅ Ensure the updated pool datum is included in outputs
//     let datum_updated =
//       list.any(
//         outputs,
//         fn(output) { output.datum == InlineDatum(stored_tontine) },
//       )
//     expect datum_updated == True
//     // ✅ Process redeemers
//     when redeemer is {
//       Join -> handle_join(stored_tontine, transaction)
//       Contribute(amount) ->
//         handle_contribute(stored_tontine, amount, transaction)
//       SelectWinner ->
//         when stored_tontine.governance is {
//           DAO(dao_policy) ->
//             verify_dao_approval(transaction, dao_policy) && handle_select_winner(
//               stored_tontine,
//               transaction,
//             )
//           _ -> fail @"Only the DAO can select winners"
//         }
//       Withdraw -> handle_withdraw(stored_tontine, transaction)
//       Cancel ->
//         when stored_tontine.governance is {
//           DAO(dao_policy) ->
//             verify_dao_approval(transaction, dao_policy) && handle_cancel(
//               stored_tontine,
//               transaction,
//             )
//           _ -> fail @"Only the DAO can cancel"
//         }
//       Distribute ->
//         when stored_tontine.governance is {
//           DAO(dao_policy) ->
//             verify_dao_approval(transaction, dao_policy) && handle_distribute(
//               stored_tontine,
//               transaction,
//             )
//           _ -> fail @"Only the DAO can distribute funds"
//         }
//       _ -> fail @"Invalid redeemer for spending"
//     }
//   }

//   else(_) {
//     fail @"Unsupported purpose"
//   }
// }


// /// Validate CIP68 metadata for required fields and version.
// pub fn validate_cip68_metadata(
//   metadata: CIP68,
//   _issuer: VerificationKeyHash,
//   extra_signatories: List<VerificationKeyHash>,
// ) -> Bool {
//   // Step 1: Define Required Fields
//   let required_fields =
//     [
//       builtin.b_data("name"),
//       builtin.b_data("image"),
//       builtin.b_data("author"),
//       builtin.b_data("tontine_id"),
//       builtin.b_data("start_date"),
//       builtin.b_data("end_date"),
//     ]

//   // Step 2: Validate All Required Fields Exist
//   let fields_valid =
//     list.all(
//       required_fields,
//       fn(key) {
//         let field_value = cip68.get(metadata, key)
//         // Validate the retrieved data
//         builtin.choose_data(field_value, True, True, True, True, True)
//       },
//     )
//   // False 
//   // Step 3: Validate Metadata Version
//   let version_valid = cip68.version(metadata) == 1
//   // Step 4: Validate Author and Signature
//   let author_valid = match_author_signature(metadata, extra_signatories)
//   // Step 5: Validate Tontine-Specific Metadata
//   let tontine_id_valid =
//     builtin.choose_data(
//       cip68.get(metadata, builtin.b_data("tontine_id")),
//       False,
//       False,
//       False,
//       False,
//       bytearray.length(
//         builtin.un_b_data(cip68.get(metadata, builtin.b_data("tontine_id"))),
//       ) > 0,
//     )
//   // Default case: If the data doesn't match any pattern, treat it as invalid
//   // False
//   let date_valid = and {
//       validate_date(metadata, builtin.b_data("start_date")),
//       validate_date(metadata, builtin.b_data("end_date")),
//     }
//   // Step 6: Validate Optional Extra Data
//   let extra_data_valid =
//     builtin.choose_data(
//       cip68.get(metadata, builtin.b_data("extra_data")),
//       False,
//       False,
//       True,
//       False,
//       False,
//     )
//   // True Default case: Valid if `extra_data` is missing
//   // Combine All Checks
//   fields_valid && version_valid && author_valid && tontine_id_valid && date_valid && extra_data_valid
// }

// /// Validate the author field and its signature.
// fn match_author_signature(
//   metadata: CIP68,
//   extra_signatories: List<VerificationKeyHash>,
// ) -> Bool {
//   let author_data = cip68.get(metadata, builtin.b_data("author"))

//   builtin.choose_data(
//     author_data,
//     False,
//     False,
//     False,
//     False,
//     check_signed_by_author(extra_signatories, author_data |> builtin.un_b_data),
//   )
//   // Default case: Treat as invalid - use False here ??
// }


// //////False

// /// Validate a date field in the metadata.
// fn validate_date(metadata: CIP68, key: Data) -> Bool {
//   let field_value = cip68.get(metadata, key)

//   builtin.choose_data(field_value, False, False, False, True, False)
//   // Default case: If it doesn't match any of the above, treat it as invalid
// }

// /// Reusable function to verify author signature
// pub fn check_signed_by_author(
//   extra_signatories: List<VerificationKeyHash>,
//   author_input: ByteArray,
// ) -> Bool {
//   tx.verify_signature(extra_signatories, author_input)
// }

// ///**Verify DAO Approval**
// pub fn verify_dao_approval(
//   transaction: Transaction,
//   dao_policy: PolicyId,
// ) -> Bool {
//   // ✅ Ensure at least one DAO member has signed
//   let has_dao_signatory =
//     list.any(
//       transaction.extra_signatories,
//       fn(signatory) {
//         // ✅ Check if this `signatory` holds a governance token from `dao_policy`
//         let has_token = list.has(assets.policies(transaction.mint), dao_policy)

//         // ✅ Ensure this signatory has actually signed the transaction
//         has_token && list.has(transaction.extra_signatories, signatory)
//       },
//     )

//   has_dao_signatory
//   // ✅ Must be `True` for DAO approval
// }

// ///**Update Tontine State Token**
// pub fn update_tontine_state(
//   datum: TontinePool,
//   updated_state_token: StateToken,
//   transaction: Transaction,
// ) -> Bool {
//   let Transaction { extra_signatories, outputs, .. } = transaction

//   // ✅ Check Governance Rules
//   let governance_valid =
//     when datum.governance is {
//       CreatorControlled -> {
//         let creator_valid = list.has(extra_signatories, datum.creator)

//         creator_valid
//       }
//       DAO(dao_script_hash) -> {
//         let dao_valid = list.has(extra_signatories, dao_script_hash)

//         dao_valid
//       }
//     }

//   // ✅ Construct Updated Datum
//   let updated_datum =
//     TontinePool {
//       pool_id: datum.pool_id,
//       creator: datum.creator,
//       pool_type: datum.pool_type,
//       governance: datum.governance,
//       max_members: datum.max_members,
//       state_token: updated_state_token,
//       cip68: datum.cip68,
//       collateral_amount: datum.collateral_amount,
//       status: datum.status,
//     }

//   // ✅ Ensure the updated datum is included in the outputs
//   let datum_is_correct =
//     list.any(
//       outputs,
//       fn(output: Output) -> Bool {
//         let matches = output.datum == InlineDatum(updated_datum)

//         matches
//       },
//     )

//   let final_result = governance_valid && datum_is_correct

//   final_result
// }
 

// pub fn handle_join(datum: TontinePool, transaction: Transaction) -> Bool {
//   let Transaction { inputs, outputs, extra_signatories, .. } = transaction

//   // ✅ Ensure the pool is active using STT current_round
//   let is_active = datum.state_token.current_round > 0
//   trace @"Debug: is_active?"
//   trace cbor.diagnostic(is_active)

//   // ✅ Ensure the participant has signed the transaction
//   trace @"Debug: Checking participant signature"
//   trace cbor.diagnostic(extra_signatories)

//   let participant =
//     list.find(
//       extra_signatories,
//       fn(signatory) { list.has(extra_signatories, signatory) },
//     )

//   expect Some(participant_id) = participant

//   // ✅ Check if CIP-68 metadata exists
//   trace @"Debug: Initial CIP-68 metadata"
//   trace cbor.diagnostic(datum.cip68.metadata)

//   let already_joined =
//     list.any(
//       datum.cip68.metadata,
//       fn(entry) { builtin.fst_pair(entry) == builtin.b_data(participant_id) },
//     )

//   trace @"Debug: already_joined?"
//   trace cbor.diagnostic(already_joined)

//   // ✅ Ensure participant count doesn't exceed max_members
//   let participant_count = list.length(datum.cip68.metadata)
//   let can_join = participant_count < datum.max_members

//   trace @"Debug: Can Join?"
//   trace cbor.diagnostic(can_join)

//   // ✅ Ensure participant collateral is locked in transaction inputs
//   let has_collateral =
//     list.any(
//       inputs,
//       fn(input) {
//         let lovelace = assets.lovelace_of(input.output.value)
//         lovelace >= datum.collateral_amount
//       },
//     )

//   trace @"Debug: Has Collateral?"
//   trace cbor.diagnostic(has_collateral)

//   // ✅ Construct updated CIP-68 metadata with the new participant
//   let updated_metadata =
//     CIP68(
//       list.concat(
//         datum.cip68.metadata,
//         [Pair(builtin.b_data(participant_id), builtin.b_data(participant_id))],
//       ),
//       datum.cip68.version + 1,
//     )

//   trace @"Debug: Updated CIP-68 metadata"
//   trace cbor.diagnostic(updated_metadata)

//   // ✅ Define `updated_datum` before using it
//   let updated_datum =
//     TontinePool {
//       pool_id: datum.pool_id,
//       creator: datum.creator,
//       pool_type: datum.pool_type,
//       governance: datum.governance,
//       max_members: datum.max_members,
//       state_token: datum.state_token,
//       cip68: updated_metadata,
//       collateral_amount: datum.collateral_amount,
//       status: datum.status,
//     }

//   trace @"Debug: Updated Pool Datum"
//   trace cbor.diagnostic(updated_datum)

//   // ✅ Ensure updated metadata appears in the transaction outputs
//   let metadata_updated =
//     list.any(outputs, fn(output) { output.datum == InlineDatum(updated_datum) })

//   // ✅ Now defined
//   trace @"Debug: Metadata Updated?"
//   trace cbor.diagnostic(metadata_updated)

//   let final_result =
//     is_active && !already_joined && can_join && has_collateral && metadata_updated

//   trace @"Debug: Final result"
//   trace cbor.diagnostic(final_result)

//   final_result
// }


// /// Insert a key-value pair in an ordered list, updating value if key exists
// pub fn insert_with_by_ascending_key(
//   self: List<Pair<ByteArray, Int>>,
//   key: ByteArray,
//   value: Int,
//   compare: fn(ByteArray, ByteArray) -> Ordering,
//   with: fn(Int, Int) -> Int,
// ) -> List<Pair<ByteArray, Int>> {
//   when self is {
//     [] -> [Pair(key, value)]
//     [Pair(k, v), ..rest] ->
//       when compare(key, k) is {
//         Less -> [Pair(key, value), ..self]
//         // Insert before the current element
//         Equal -> [Pair(k, with(v, value)), ..rest]
//         // Update value
//         Greater ->
//           [
//             Pair(k, v),
//             ..insert_with_by_ascending_key(rest, key, value, compare, with)
//           ]
//       }
//   }
// }

// ///**Helper Function: Find Valid Contribution UTxO**
// pub fn find_contribution_utxo(
//   inputs: List<Input>,
//   participant_id: VerificationKeyHash,
// ) -> Option<OutputReference> {
//   list.find(
//     inputs,
//     fn(input) {
//       let input_lovelace = assets.lovelace_of(input.output.value)
//       let is_valid_amount = input_lovelace > 0
//       let input_signer = input.output_reference.transaction_id

//       // ✅ Check if participant is the owner of this UTxO
//       let belongs_to_participant =
//         input.output.address == address.from_verification_key(participant_id)

//       trace @"🔍 Checking UTxO Signer: "
//       trace cbor.diagnostic(input.output_reference.transaction_id)
//       trace @"🔍 Checking Lovelace: "
//       trace cbor.diagnostic(input_lovelace)
//       trace @"🔍 Valid Amount? "
//       trace cbor.diagnostic(is_valid_amount)
//       trace @"🔍 Belongs to Participant? "
//       trace cbor.diagnostic(belongs_to_participant)
//       // ✅ Now ensures the UTxO belongs to `participant_id`
//       is_valid_amount && belongs_to_participant
//     },
//   )
//     |> option.map(fn(input) { input.output_reference })
//   //Extract the UTxO reference if found
// }

// ///**Main Contribution Validator**
// pub fn handle_contribute(
//   datum: TontinePool,
//   amount: Int,
//   transaction: Transaction,
// ) -> Bool {
//   let Transaction { inputs, outputs, extra_signatories, .. } = transaction

//   // ✅ Ensure pool is active
//   let is_active = datum.state_token.counter > 0
//   trace @"🔍 is_active?: "
//   trace cbor.diagnostic(is_active?)

//   // ✅ Identify the contributor
//   let maybe_participant = list.head(extra_signatories)
//   expect Some(participant_id) = maybe_participant
//   trace @"🔍 participant_id: "
//   trace cbor.diagnostic(participant_id)

//   // ✅ Find Contribution UTxO for this participant
//   let maybe_contribution_utxo = find_contribution_utxo(inputs, participant_id)
//   expect Some(contribution_utxo) = maybe_contribution_utxo
//   trace @"🔍 Contribution UTxO: "
//   trace cbor.diagnostic(contribution_utxo)

//   // ✅ Extract UTxO transaction ID as ByteArray
//   let contribution_utxo_key = builtin.b_data(contribution_utxo.transaction_id)
//   trace @"🔍 contribution_utxo_key (ByteArray): "
//   trace cbor.diagnostic(contribution_utxo_key)

//   // ✅ Ensure contributor hasn't already used this UTxO
//   let replay_protection =
//     list.find(
//       datum.cip68.metadata,
//       fn(entry) { builtin.fst_pair(entry) == contribution_utxo_key },
//     )

//   let is_utxo_used =
//     when replay_protection is {
//       Some(_) -> True
//       None -> False
//     }
//   trace @"🔍 Checking UTxO Replay Protection: "
//   trace cbor.diagnostic(is_utxo_used?)

//   // ✅ Check if participant already contributed
//   let maybe_previous_contribution =
//     list.find(
//       datum.cip68.metadata,
//       fn(entry) { builtin.fst_pair(entry) == builtin.b_data(participant_id) },
//     )

//   let already_joined =
//     when maybe_previous_contribution is {
//       Some(_) -> True
//       None -> False
//     }
//   trace @"🔍 already_joined?: "
//   trace cbor.diagnostic(already_joined?)

//   // ✅ Extract previous contribution
//   let previous_contribution =
//     when maybe_previous_contribution is {
//       Some(entry) -> builtin.un_i_data(builtin.snd_pair(entry))
//       None -> 0
//     }
//   trace @"🔍 previous_contribution: "
//   trace cbor.diagnostic(previous_contribution)

//   // ✅ Calculate new total contribution
//   let new_contribution = previous_contribution + amount
//   trace @"🔍 new_contribution: "
//   trace cbor.diagnostic(new_contribution)

//   // ✅ Ensure contribution is included in transaction inputs
//   let has_contribution =
//     list.any(
//       inputs,
//       fn(input) {
//         let input_lovelace = assets.lovelace_of(input.output.value)
//         let is_valid_utxo =
//           input.output_reference.transaction_id == contribution_utxo.transaction_id
//         trace @"🔍 Valid UTxO?"
//         trace cbor.diagnostic(is_valid_utxo)
//         trace @"🔍 Input Lovelace?"
//         trace cbor.diagnostic(input_lovelace)
//         is_valid_utxo && input_lovelace >= amount
//       },
//     )?
//   trace @"🔍 has_contribution?: "
//   trace cbor.diagnostic(has_contribution)

//   let participant_count = datum.cip68.version
//   let can_join = participant_count < datum.max_members
//   trace @"🔍 participant_count: "
//   trace cbor.diagnostic(participant_count)
//   trace @"🔍 can_join?: "
//   trace cbor.diagnostic(can_join?)

//   // ✅ Convert metadata to a list of (ByteArray, Int)
//   let metadata_entries_converted =
//     list.map(
//       datum.cip68.metadata,
//       fn(entry) {
//         Pair(
//           builtin.un_b_data(entry.1st),
//           // Convert key from Data to ByteArray
//           builtin.un_i_data(entry.2nd),
//         )
//       },
//     )

//   // Convert value from Data to Int
//   // ✅ Insert participant contribution
//   let raw_metadata_entries =
//     insert_with_by_ascending_key(
//       metadata_entries_converted,
//       participant_id,
//       new_contribution,
//       bytearray.compare,
//       fn(old, new) { old + new },
//     )

//   // ✅ Add UTxO reference for replay protection
//   let metadata_with_utxo =
//     insert_with_by_ascending_key(
//       raw_metadata_entries,
//       builtin.un_b_data(contribution_utxo_key),
//       1,
//       bytearray.compare,
//       fn(old, _new) { old },
//     )

//   // ✅ Sort metadata entries by ByteArray key for consistency
//   let sorted_metadata_entries =
//     list.sort(metadata_with_utxo, fn(a, b) { bytearray.compare(a.1st, b.1st) })

//   // ✅ Convert sorted entries back to Data format
//   let updated_metadata_entries =
//     list.map(
//       sorted_metadata_entries,
//       fn(entry) { Pair(builtin.b_data(entry.1st), builtin.i_data(entry.2nd)) },
//     )

//   // Ensure proper conversion
//   let participant_count_increment =
//     if already_joined {
//       0
//     } else {
//       1
//     }
//   let updated_metadata =
//     CIP68(
//       updated_metadata_entries,
//       datum.cip68.version + participant_count_increment,
//     )
//   trace @"🔍 updated_metadata: "
//   trace cbor.diagnostic(updated_metadata)

//   // ✅ Ensure at least one output contains the updated metadata
//   let metadata_updated =
//     list.any(
//       outputs,
//       fn(output) {
//         when output.datum is {
//           InlineDatum(stored_datum) -> {
//             expect TontinePool { cip68: stored_metadata, .. } = stored_datum

//             // ✅ Extract metadata list from stored datum
//             let stored_metadata_entries = stored_metadata.metadata

//             // ✅ Sort stored metadata before comparison
//             let stored_metadata_sorted =
//               list.sort(
//                 stored_metadata_entries,
//                 // Ensure we're sorting the list of Pair<Data, Data>
//                 fn(a, b) {
//                   bytearray.compare(
//                     builtin.un_b_data(builtin.fst_pair(a)),
//                     builtin.un_b_data(builtin.fst_pair(b)),
//                   )
//                 },
//               )

//             // ✅ Check if updated metadata matches the stored metadata
//             let is_match = stored_metadata_sorted == updated_metadata_entries
//             trace @"🔍 stored_metadata: "
//             trace cbor.diagnostic(stored_metadata_sorted)
//             trace @"🔍 is_match?: "
//             trace cbor.diagnostic(is_match?)
//             is_match?
//           }
//           _ -> False
//         }
//       },
//     )?
//   trace @"🔍 metadata_updated?: "
//   trace cbor.diagnostic(metadata_updated)

//   // ✅ Final validation
//   let final_result =
//     is_active && has_contribution && metadata_updated && can_join && !is_utxo_used
//   trace @"🔍 final_result: "
//   trace cbor.diagnostic(final_result?)

//   final_result
// }

// /// Comparator function for Data values that hold ByteArray
// pub fn compare_data_as_bytearray(left: Data, right: Data) -> Ordering {
//   let left_ba = builtin.un_b_data(left)
//   let right_ba = builtin.un_b_data(right)
//   bytearray.compare(left_ba, right_ba)
 
// }


// pub fn handle_select_winner(
//   datum: TontinePool,
//   transaction: Transaction,
// ) -> Bool {
//   let Transaction { inputs, outputs, extra_signatories, .. } = transaction

//   // ✅ Ensure the pool is active using STT current_round
//   let is_active = datum.state_token.current_round > 0
//   trace @"Debug: is_active?"
//   trace cbor.diagnostic(is_active)

//   // ✅ Ensure the winner selection is authorized
//   let is_authorized =
//     when datum.governance is {
//       CreatorControlled -> list.has(extra_signatories, datum.creator)
//       DAO(dao_script_hash) -> list.has(extra_signatories, dao_script_hash)
//     }
//   trace @"Debug: is_authorized?"
//   trace cbor.diagnostic(is_authorized)

//   // ✅ Extract the current round from metadata
//   let current_round = datum.cip68.version
//   trace @"Debug: current_round"
//   trace cbor.diagnostic(current_round)

//   // ✅ Identify the winner based on pool type
//   let winner_data =
//     when datum.pool_type is {
//       ROSCA -> {
//         let participant_keys = pairs.keys(datum.cip68.metadata)
//         trace @"Debug: participant_keys"
//         trace cbor.diagnostic(participant_keys)

//         if list.length(participant_keys) > 0 {
//           let index =
//             builtin.mod_integer(current_round, list.length(participant_keys))
//           trace @"Debug: selected_index"
//           trace cbor.diagnostic(index)

//           let winner = list.at(participant_keys, index)
//           trace @"Debug: selected_winner"
//           trace cbor.diagnostic(winner)

//           winner
//         } else {
//           None
//         }
//       }
//       AUCTION -> {
//         let highest_bidder =
//           list.foldl(
//             datum.cip68.metadata,
//             None,
//             fn(entry, highest) {
//               let participant_id = builtin.fst_pair(entry)
//               let bid_amount = builtin.snd_pair(entry) |> builtin.un_i_data()

//               when highest is {
//                 None -> Some(Pair(participant_id, bid_amount))
//                 Some(Pair(_current_winner, current_highest)) ->
//                   if bid_amount > current_highest {
//                     Some(Pair(participant_id, bid_amount))
//                   } else {
//                     highest
//                   }
//               }
//             },
//           )
//         when highest_bidder is {
//           Some(Pair(winner, _)) -> Some(winner)
//           None -> None
//         }
//       }
//       _ -> None
//     }

//   trace @"Debug: winner_data"
//   trace cbor.diagnostic(winner_data)

//   // Ensure winner_data is present.
//   expect Some(winner_data) = winner_data
//   let winner_id = builtin.un_b_data(winner_data)
//   trace @"Debug: winner_id"
//   trace cbor.diagnostic(winner_id)

//   // ✅ Verify the winner's contribution is in the transaction
//   let has_contributed =
//     list.any(
//       inputs,
//       fn(input) {
//         let participant_id_data = builtin.b_data(winner_id)
//         let input_value = assets.lovelace_of(input.output.value)

//         let is_in_metadata =
//           pairs.has_key(datum.cip68.metadata, participant_id_data)

//         let has_funds = input_value > 0

//         // Ensure they have contributed something
//         trace @"Debug: Contribution Check - ID in Metadata?"
//         trace cbor.diagnostic(is_in_metadata)

//         trace @"Debug: Contribution Check - Lovelace Amount"
//         trace cbor.diagnostic(input_value)

//         is_in_metadata && has_funds
//       },
//     )
//   // ✅ Step 3: Compute updated metadata BEFORE using it
//   let cleaned_metadata =
//     pairs.delete_first(datum.cip68.metadata, builtin.b_data(winner_id))

//   // Remove old contribution entry
//   trace @"Debug: Confirmed Winner ID"
//   trace cbor.diagnostic(winner_id)

//   let updated_metadata_entries =
//     pairs.repsert_by_ascending_key(
//       cleaned_metadata,
//       builtin.b_data(winner_id),
//       builtin.b_data("Winner"),
//       compare_data_as_bytearray,
//     )

//   let updated_metadata = CIP68(updated_metadata_entries, current_round + 1)

//   // ✅ Increment version
//   trace @"Debug: updated_metadata"
//   trace cbor.diagnostic(updated_metadata)

//   // ✅ Ensure updated metadata is included in outputs
//   let metadata_updated =
//     list.any(
//       outputs,
//       fn(output) {
//         trace @"Debug: Checking Output Datum"
//         trace cbor.diagnostic(output.datum)
//         when output.datum is {
//           InlineDatum(stored_datum) -> {
//             // ✅ Extract only CIP-68 metadata for comparison
//             expect TontinePool { cip68: stored_metadata, .. } = stored_datum

//             trace @"Debug: Extracted CIP-68 metadata"
//             trace cbor.diagnostic(stored_metadata)

//             let is_match = stored_metadata == updated_metadata
//             trace @"Debug: Metadata Matches?"
//             trace cbor.diagnostic(is_match)

//             is_match
//           }
//           _ -> False
//         }
//       },
//     )
//   trace @"Debug: metadata_updated?"
//   trace cbor.diagnostic(metadata_updated)

//   let final_result =
//     is_active && has_contributed && metadata_updated && is_authorized
//   trace @"Debug: final_result"
//   trace cbor.diagnostic(final_result)

//   final_result
// }



// pub fn handle_withdraw(datum: TontinePool, transaction: Transaction) -> Bool {
//   let Transaction { inputs, outputs, extra_signatories, .. } = transaction

//   // ✅ Step 1: Check if the pool is active
//   let is_active = datum.state_token.counter > 0
//   trace @"Debug: is_active?"
//   trace cbor.diagnostic(is_active)

//   // ✅ Step 2: Ensure participant signature
//   trace @"Debug: Checking participant signature"
//   trace cbor.diagnostic(extra_signatories)

//   let participant =
//     list.find(
//       extra_signatories,
//       fn(signatory) {
//         pairs.has_key(datum.cip68.metadata, builtin.b_data(signatory))
//       },
//     )
//   expect Some(participant_id) = participant
//   trace @"Debug: participant_id"
//   trace cbor.diagnostic(participant_id)

//   // ✅ Step 3: Ensure participant has winnings recorded
//   let withdrawal_data =
//     pairs.get_first(datum.cip68.metadata, builtin.b_data(participant_id))
//   expect Some(winnings_data) = withdrawal_data
//   let winnings = builtin.un_i_data(winnings_data)
//   trace @"Debug: winnings amount"
//   trace cbor.diagnostic(winnings)

//   // ✅ Step 4: Ensure the winnings are present in inputs
//   let winnings_in_inputs =
//     list.any(
//       inputs,
//       fn(input) {
//         let input_lovelace = assets.lovelace_of(input.output.value)
//         trace @"Debug: Input lovelace amount"
//         trace cbor.diagnostic(input_lovelace)

//         input_lovelace >= winnings
//       },
//     )
//   trace @"Debug: winnings_in_inputs?"
//   trace cbor.diagnostic(winnings_in_inputs)

//   // ✅ Step 5: Ensure the participant can withdraw
//   let can_withdraw = winnings > 0
//   trace @"Debug: can_withdraw?"
//   trace cbor.diagnostic(can_withdraw)

//   // ✅ Step 6: Ensure the correct output is included
//   let has_correct_output =
//     list.any(
//       outputs,
//       fn(output) {
//         let participant_address = address.from_verification_key(participant_id)
//         let output_lovelace = assets.lovelace_of(output.value)

//         trace @"Debug: Checking Output Address"
//         trace cbor.diagnostic(output.address)
//         trace @"Debug: Expected Participant Address"
//         trace cbor.diagnostic(participant_address)
//         trace @"Debug: Output Lovelace Amount"
//         trace cbor.diagnostic(output_lovelace)

//         output.address == participant_address && output_lovelace == winnings
//       },
//     )
//   trace @"Debug: has_correct_output?"
//   trace cbor.diagnostic(has_correct_output)

//   // ✅ Step 7: Remove participant's winnings from metadata
//   let updated_metadata =
//     CIP68(
//       pairs.delete_first(datum.cip68.metadata, builtin.b_data(participant_id)),
//       datum.cip68.version,
//     )
//   trace @"Debug: updated_metadata"
//   trace cbor.diagnostic(updated_metadata)

//   // ✅ Step 8: Ensure updated metadata appears in outputs
//   let metadata_updated =
//     list.any(
//       outputs,
//       fn(output) {
//         trace @"Debug: Checking Output Datum"
//         trace cbor.diagnostic(output.datum)

//         when output.datum is {
//           InlineDatum(stored_datum) -> {
//             // ✅ Extract only the CIP-68 metadata for comparison
//             expect TontinePool { cip68: stored_metadata, .. } = stored_datum
//             trace @"Debug: Extracted CIP-68 metadata"
//             trace cbor.diagnostic(stored_metadata)

//             let is_match = stored_metadata == updated_metadata
//             trace @"Debug: Metadata Matches?"
//             trace cbor.diagnostic(is_match)

//             is_match
//           }
//           _ -> False
//         }
//       },
//     )
//   trace @"Debug: metadata_updated?"
//   trace cbor.diagnostic(metadata_updated)

//   // ✅ Step 9: Final validation
//   let final_result =
//     is_active && can_withdraw && has_correct_output && metadata_updated && winnings_in_inputs
//   trace @"Debug: Final validation result"
//   trace cbor.diagnostic(final_result)
//   expect final_result == True

//   final_result
// }

// /// **Main Cancel Validator with Enhanced Security**
// pub fn handle_cancel(datum: TontinePool, transaction: Transaction) -> Bool {
//   let Transaction { inputs, outputs, extra_signatories, .. } = transaction

//   // ✅ Step 1: Ensure the correct Tontine UTXO is being spent.
//   let tontine_utxo_present =
//     list.any(inputs, fn(input) { input.output_reference == datum.pool_id })

//   trace @"🔍 tontine_utxo_present?: "
//   trace cbor.diagnostic(tontine_utxo_present)

//   // ✅ Step 2: Ensure only DAO can cancel.
//   let is_authorized =
//     when datum.governance is {
//       DAO(dao_script_hash) -> list.has(extra_signatories, dao_script_hash)
//       _ -> False
//     }

//   trace @"🔍 DAO authorized?: "
//   trace cbor.diagnostic(is_authorized)

//   // ✅ Step 3: Prevent Double Cancellation
//   when datum.collateral_amount == 0 is {
//     True -> {
//       trace @"❌ ERROR: Pool already canceled!"
//       trace cbor.diagnostic(False)
//       False
//     }
//     False -> {
//       let expected_total_refund =
//         list.foldl(
//           datum.cip68.metadata,
//           0,
//           fn(entry, acc) { acc + builtin.un_i_data(builtin.snd_pair(entry)) },
//         )

//       trace @"🔍 Expected total refund: "
//       trace cbor.diagnostic(expected_total_refund)

//       let actual_total_refund =
//         list.foldl(
//           outputs,
//           0,
//           fn(output, acc) { acc + assets.lovelace_of(output.value) },
//         )

//       trace @"🔍 Actual total refund: "
//       trace cbor.diagnostic(actual_total_refund)

//       let refunds_match = expected_total_refund == actual_total_refund
//       trace @"🔍 Refunds match?: "
//       trace cbor.diagnostic(refunds_match)

//       when !refunds_match is {
//         True -> {
//           trace @"❌ ERROR: Refunds do not match!"
//           trace cbor.diagnostic(False)
//           False
//         }
//         False -> {
//           let refunds_processed =
//             list.all(
//               datum.cip68.metadata,
//               fn(entry) {
//                 let participant_id = builtin.fst_pair(entry)
//                 let refund_amount = builtin.un_i_data(builtin.snd_pair(entry))

//                 let refund_addr =
//                   address.from_verification_key(
//                     builtin.un_b_data(participant_id),
//                   )

//                 let refund_found =
//                   list.any(
//                     outputs,
//                     fn(output) {
//                       let is_correct_address = output.address == refund_addr
//                       let is_correct_amount =
//                         assets.lovelace_of(output.value) == refund_amount
//                       let is_valid_refund =
//                         is_correct_address && is_correct_amount
//                       trace @"🔍 Checking refund for: "
//                       trace cbor.diagnostic(refund_addr)
//                       trace @"🔍 Expected refund: "
//                       trace cbor.diagnostic(refund_amount)
//                       trace @"🔍 Refund found?: "
//                       trace cbor.diagnostic(is_valid_refund)
//                       is_valid_refund
//                     },
//                   )?

//                 refund_found?
//               },
//             )?

//           trace @"🔍 All refunds processed?: "
//           trace cbor.diagnostic(refunds_processed)
//           // ✅ Construct Updated Datum
//           let updated_datum =
//             TontinePool {
//               pool_id: datum.pool_id,
//               creator: datum.creator,
//               pool_type: datum.pool_type,
//               governance: datum.governance,
//               max_members: datum.max_members,
//               state_token: StateToken {
//                 policy_id: datum.state_token.policy_id,
//                 counter: datum.state_token.counter + 1,
//                 // ✅ Ensure state progression
//                 global_hash: datum.state_token.global_hash,
//                 current_round: datum.state_token.current_round,
//               },
//               cip68: CIP68 {
//                 metadata: datum.cip68.metadata,
//                 version: datum.cip68.version,
//               },
//               collateral_amount: 0,
//               // ✅ Mark as Cancelled
//               status: Cancelled,
//             }

//           // ✅ Explicitly update status
//           // ✅ Serialize the updated datum
//           let serialized_updated_datum = builtin.serialise_data(updated_datum)

//           // ✅ Verify that the updated datum appears in outputs
//           let is_status_updated =
//             list.any(
//               outputs,
//               fn(output) {
//                 when output.datum is {
//                   InlineDatum(stored_datum) -> {
//                     let serialized_stored_datum =
//                       builtin.serialise_data(stored_datum)
//                     let is_match =
//                       serialized_stored_datum == serialized_updated_datum
//                     trace @"🔍 Checking updated datum: "
//                     trace cbor.diagnostic(serialized_updated_datum)
//                     trace @"🔍 Stored datum in output: "
//                     trace cbor.diagnostic(serialized_stored_datum)
//                     trace @"🔍 Is match?: "
//                     trace cbor.diagnostic(is_match)
//                     is_match
//                   }
//                   _ -> False
//                 }
//               },
//             )?

//           trace @"🔍 Pool status updated?: "
//           trace cbor.diagnostic(is_status_updated?)

//           // ✅ Final validation check
//           let final_result =
//             is_authorized && refunds_processed && is_status_updated && tontine_utxo_present && refunds_match
//           trace @"// ✅ Final cancel result: "
//           trace cbor.diagnostic(final_result)
//           final_result?
//         }
//       }
//     }
//   }
// }

// pub fn handle_distribute(datum: TontinePool, transaction: Transaction) -> Bool {
//   let Transaction { inputs, outputs, extra_signatories, .. } = transaction

//   // ✅ Ensure only DAO or creator can distribute rewards
//   let is_authorized =
//     when datum.governance is {
//       CreatorControlled -> list.has(extra_signatories, datum.creator)
//       DAO(dao_script_hash) -> list.has(extra_signatories, dao_script_hash)
//     }
//   // ✅ If not authorized, return immediately to avoid extra computation
//   when is_authorized is {
//     False -> {
//       trace @"🚨 Unauthorized distribution attempt!"
//       trace cbor.diagnostic(False)
//       False
//     }
//     True -> {
//       trace @"// ✅ Authorized distribution"
//       trace cbor.diagnostic(True)

//       // ✅ Extract participant contributions from CIP-68 metadata
//       let participants =
//         list.map(datum.cip68.metadata, fn(entry) { builtin.fst_pair(entry) })

//       // ✅ Ensure the total amount to distribute is in inputs
//       let total_rewards =
//         list.foldl(
//           datum.cip68.metadata,
//           0,
//           fn(entry, acc) {
//             let amount = builtin.un_i_data(builtin.snd_pair(entry))
//             acc + amount
//           },
//         )

//       trace @"🔍 Total rewards to distribute: "
//       trace cbor.diagnostic(total_rewards)

//       let rewards_available =
//         list.any(
//           inputs,
//           fn(input) {
//             let input_lovelace = assets.lovelace_of(input.output.value)
//             trace @"🔍 Checking input Lovelace: "
//             trace cbor.diagnostic(input_lovelace)
//             input_lovelace >= total_rewards
//           },
//         )?

//       trace @"🔍 Rewards available? "
//       trace cbor.diagnostic(rewards_available)

//       // ✅ Ensure every participant receives a reward
//       let rewards_distributed =
//         list.all(
//           participants,
//           fn(participant_data) {
//             let participant_id = builtin.un_b_data(participant_data)

//             list.any(
//               outputs,
//               fn(output) {
//                 when output.datum is {
//                   InlineDatum(stored_datum) -> {
//                     expect TontinePool { cip68: stored_metadata, .. } =
//                       stored_datum

//                     // ✅ Extract metadata entries (Pairs<Data, Data>)
//                     let stored_metadata_entries = stored_metadata.metadata

//                     // ✅ Ensure participant is in stored metadata
//                     list.any(
//                       stored_metadata_entries,
//                       fn(entry) {
//                         let stored_participant_id =
//                           builtin.un_b_data(builtin.fst_pair(entry))
//                         let is_correct_recipient =
//                           stored_participant_id == participant_id
//                         trace @"🔍 Checking recipient: "
//                         trace cbor.diagnostic(is_correct_recipient)
//                         is_correct_recipient
//                       },
//                     )?
//                   }
//                   _ -> False
//                 }
//               },
//             )?
//           },
//         )?

//       trace @"🔍 All rewards distributed? "
//       trace cbor.diagnostic(rewards_distributed)

//       // ✅ Ensure the tontine pool is marked as completed
//       let updated_datum =
//         TontinePool {
//           pool_id: datum.pool_id,
//           creator: datum.creator,
//           pool_type: datum.pool_type,
//           governance: datum.governance,
//           max_members: datum.max_members,
//           state_token: datum.state_token,
//           cip68: datum.cip68,
//           collateral_amount: datum.collateral_amount,
//           status: datum.status,
//         }

//       let is_status_updated =
//         list.any(
//           outputs,
//           fn(output) { output.datum == InlineDatum(updated_datum) },
//         )?

//       trace @"🔍 Pool status updated? "
//       trace cbor.diagnostic(is_status_updated)

//       // ✅ Final validation check
//       let final_result =
//         rewards_distributed && is_status_updated && rewards_available
//       trace @"// ✅ Final distribution result: "
//       trace cbor.diagnostic(final_result)

//       final_result
//     }
//   }
// }




// /// TESTS

// // Test Constants
// const dummy_tx_id = #"00000000000000000000000000000000000000000000000000000000"

// const creator_vk = #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f50"

// const dao_script_hash =
//   #"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"

// const policy_id = #"cccccccccccccccccccccccccccccccccccccccccccccccccccccccc"

// const collateral = 10_000_000

// const contribution_amt = 50_000_000

// const entry_fee = 5_000_000

// ///  Sample CIP-68 Metadata
// const initial_cip68 = CIP68 { metadata: builtin.new_pairs(), version: 1 }

// ///  Sample Tontine Configuration
// const tontine_config =
//   TontineConfig {
//     creator: creator_vk,
//     contribution_amount: contribution_amt,
//     collateral_amount: collateral,
//     entry_fee,
//     max_users: 6,
//     min_users: 3,
//     cycle_duration: 30,
//     total_rounds: 6,
//     deadline_days: 5,
//     governance: DAO(dao_script_hash),
//   }

// ///  Sample Pool Datum  
// const sample_pool_datum =
//   TontinePool {
//     pool_id: OutputReference { transaction_id: dummy_tx_id, output_index: 0 },
//     creator: creator_vk,
//     pool_type: ROSCA,
//     governance: tontine_config.governance,
//     max_members: tontine_config.max_users,
//     state_token: StateToken {
//       policy_id,
//       counter: 0,
//       global_hash: #"dddddddddddddddddddddddddddddddddddddddddddddddddddddddd",
//       current_round: 1,
//     },
//     cip68: initial_cip68,
//     collateral_amount: collateral,
//     status: Active
//   }

// ///  --- TEST CASES ---

// // ✅ 1. Test: Tontine Creation (DAO Governance)
// test create_tontine_with_dao_succeeds() {
//   let tontine_ref =
//     OutputReference { transaction_id: dummy_tx_id, output_index: 0 }
//   let mint_value = assets.from_asset(policy_id, "CIP68PoolNFT", 1)

//   let inputs =
//     [
//       Input {
//         output_reference: tontine_ref,
//         output: Output {
//           address: address.from_verification_key(dao_script_hash),
//           value: assets.from_lovelace(0),
//           datum: InlineDatum(sample_pool_datum),
//           reference_script: None,
//         },
//       },
//     ]

//   let transaction =
//     build_tx(
//       Some(inputs),
//       None,
//       Some([]),
//       Some(mint_value),
//       None,
//       Some([]),
//       None,
//       Some([dao_script_hash]),
//       None,
//       None,
//       None
//     )

//   let result =
//     tontine_validator.mint(
//       tontine_ref,
//       tontine_config,
//       Create(tontine_config),
//       policy_id,
//       transaction,
//     )
//   expect result == True
// }

// test participant_can_join() {
//   // ✅ Step 1: Setup an Active tontine pool
//   let pool_id = sample_pool_datum.pool_id
//   let participant_vk =
//     #"00000000000000000000000000000000000000000000000000000003"

//   // ✅ Step 2: Create initial CIP-68 metadata (empty, no participants yet)
//   let initial_metadata = CIP68 { metadata: [], version: 1 }

//   // ✅ Step 3: Initialize the tontine pool datum
//   let datum =
//     TontinePool {
//       pool_id,
//       creator: sample_pool_datum.creator,
//       pool_type: sample_pool_datum.pool_type,
//       governance: sample_pool_datum.governance,
//       max_members: sample_pool_datum.max_members,
//       state_token: sample_pool_datum.state_token,
//       cip68: initial_metadata,
//       collateral_amount: sample_pool_datum.collateral_amount,
//       status: sample_pool_datum.status,
//     }

//   // ✅ Step 4: Create an input representing the tontine UTxO
//   let input =
//     Input {
//       output_reference: pool_id,
//       output: Output {
//         address: address.from_verification_key(sample_pool_datum.creator),
//         value: assets.from_lovelace(datum.collateral_amount),
//         datum: InlineDatum(datum),
//         reference_script: None,
//       },
//     }

//   // ✅ Step 5: Expected CIP-68 metadata after the participant joins
//   trace @"Debug: Before Join - Initial CIP-68 metadata"
//   trace cbor.diagnostic(datum.cip68)
//   let updated_metadata =
//     CIP68 {
//       metadata: list.concat(
//         datum.cip68.metadata,
//         [Pair(builtin.b_data(participant_vk), builtin.b_data(participant_vk))],
//       ),
//       // ✅ New participant entry
//       version: datum.cip68.version + 1,
//     }

//   trace @"Debug: After Join - Updated CIP-68 metadata"
//   trace cbor.diagnostic(updated_metadata)
//   // ✅ Step 6: Expected updated pool datum
//   let updated_datum =
//     TontinePool {
//       pool_id: datum.pool_id,
//       creator: datum.creator,
//       pool_type: datum.pool_type,
//       governance: datum.governance,
//       max_members: datum.max_members,
//       state_token: datum.state_token,
//       cip68: updated_metadata,
//       collateral_amount: datum.collateral_amount,
//       status: datum.status,
//     }

//   trace @"Debug: Expected Updated Datum"
//   trace cbor.diagnostic(updated_datum)
//   // ✅ Step 7: Expected output containing the updated pool state
//   let output =
//     Output {
//       address: address.from_verification_key(sample_pool_datum.creator),
//       value: assets.from_lovelace(datum.collateral_amount),
//       datum: InlineDatum(updated_datum),
//       // ✅ Ensure updated datum is included
//       reference_script: None,
//     }

//   // ✅ Step 8: Create the transaction for participant joining
//   let transaction =
//     build_tx(
//       Some([input]),
//       // ✅ Input: Tontine pool UTxO
//       None,
//       Some([output]),
//       // ✅ Output: Updated tontine UTxO with new participant
//       Some(assets.zero),
//       None,
//       Some([]),
//       None,
//       Some([participant_vk]),
//       // ✅ Signed by the joining participant
//       None,
//       None,
//       None,
//     )
//   trace @"Debug: Actual Transaction Outputs"
//   trace cbor.diagnostic(transaction.outputs)
//   // ✅ Step 9: Validate that the participant can join
//   let result = handle_join(datum, transaction)
//   // ✅ Step 10: Expect success
//   expect result == True
// }


// // // ✅ 3. Test: Duplicate Participant Cannot Join
// // test participant_cannot_join_twice() {
// //   let pool_id = sample_pool_datum.pool_id
// //   let participant_vk =
// //     #"00000000000000000000000000000000000000000000000000000003"

// //   let metadata =
// //     CIP68 {
// //       metadata: [
// //         Pair(builtin.b_data(participant_vk), builtin.b_data(participant_vk)),
// //       ],
// //       version: 1,
// //     }
// //   let datum =
// //     TontinePool {
// //       pool_id: sample_pool_datum.pool_id,
// //       creator: sample_pool_datum.creator,
// //       pool_type: sample_pool_datum.pool_type,
// //       governance: sample_pool_datum.governance,
// //       max_members: sample_pool_datum.max_members,
// //       state_token: sample_pool_datum.state_token,
// //       cip68: metadata,
// //       collateral_amount: sample_pool_datum.collateral_amount,
// //       status: sample_pool_datum.status
// //     }

// //   let input =
// //     Input {
// //       output_reference: pool_id,
// //       output: Output {
// //         address: address.from_verification_key(participant_vk),
// //         value: assets.from_lovelace(collateral),
// //         datum: InlineDatum(datum),
// //         reference_script: None,
// //       },
// //     }

// //   let transaction =
// //     build_tx(
// //       Some([input]),
// //       None,
// //       Some([]),
// //       Some(assets.zero),
// //       None,
// //       Some([]),
// //       None,
// //       Some([participant_vk]),
// //       None,
// //       None,
// //       None
// //     )

// //   let result = handle_join(datum, transaction)
// //   expect result == False
// // }

// // /// Comparator function for Data values that hold ByteArray
// // pub fn compare_data_as_bytearray(left: Data, right: Data) -> Ordering {
// //   let left_ba = builtin.un_b_data(left)
// //   // Convert Data to ByteArray
// //   let right_ba = builtin.un_b_data(right)
// //   bytearray.compare(left_ba, right_ba)
// //   // Compare the ByteArrays
// // }

// // test contribute_succeeds() {
// //   // ✅ Step 1: Setup the TontinePool datum with one existing participant
// //   let creator_id = #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f50"
// //   let participant_1_id = #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f51" // Existing
// //   let participant_2_id = #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f52" // New contributor

// //   let pool_id = OutputReference {
// //     transaction_id: #"0000000000000000000000000000000000000000000000000000000000000000",
// //     output_index: 0
// //   }

// //   // ✅ Step 2: Define a Unique Contribution UTxO
// //   let contribution_utxo = OutputReference {
// //     transaction_id: #"2222222222222222222222222222222222222222222222222222222222222222",
// //     output_index: 1
// //   }

// //   let initial_metadata = CIP68 {
// //     metadata: [
// //       Pair(builtin.b_data(participant_1_id), builtin.i_data(150_000)) // Existing participant
// //     ],
// //     version: 1 // Version represents participant count
// //   }

// //   let state_token =
// //     StateToken {
// //       policy_id: sample_pool_datum.state_token.policy_id,
// //       counter: 1,  // ✅ Active pool
// //       global_hash: sample_pool_datum.state_token.global_hash,
// //       current_round: 1,
// //     }

// //   let datum = TontinePool {
// //     pool_id: pool_id,
// //     creator: creator_id,
// //     pool_type: ROSCA,
// //     governance: CreatorControlled,
// //     max_members: 6,
// //     state_token: state_token,
// //     cip68: initial_metadata,
// //     collateral_amount: 1_000_000,
// //     status: Active
// //   }

// //   // ✅ Step 3: Define the contribution amount and update metadata
// //   let contribution_amount = 2_000_000

// //   /// ✅ Convert `transaction_id` to `ByteArray`
// // let contribution_utxo_key = contribution_utxo.transaction_id

// // trace @"🔍 contribution_utxo_key (ByteArray): " trace cbor.diagnostic(contribution_utxo_key)

// // let updated_metadata_entries = [
// //    Pair(builtin.b_data(participant_1_id), builtin.i_data(150_000)),  // Keep previous contribution
// //    Pair(builtin.b_data(participant_2_id), builtin.i_data(contribution_amount)), // New contributor
// //    Pair(builtin.b_data(contribution_utxo_key), builtin.i_data(1)) // ✅ Corrected storage format
// // ]

// // trace @"pdated_metadata_entries"

// //   let updated_metadata = CIP68(updated_metadata_entries, datum.cip68.version + 1)
// //   let updated_datum = TontinePool { ..datum, cip68: updated_metadata }

// //   // ✅ Step 4: Build the transaction
// //   let participant_2_address = address.from_verification_key(participant_2_id)
// //   let creator_address = address.from_verification_key(creator_id)

// //   let transaction = build_tx(
// //     // Inputs (Contribution UTxO and Pool UTxO)
// //     Some([
// //       Input {
// //         output_reference: pool_id,
// //         output: Output {
// //           address: creator_address,
// //           value: assets.from_lovelace(1_000_000),
// //           datum: InlineDatum(datum),
// //           reference_script: None
// //         }
// //       },
// //       Input {
// //         output_reference: contribution_utxo, // ✅ Correctly use contribution_utxo
// //         output: Output {
// //           address: participant_2_address,
// //           value: assets.from_lovelace(contribution_amount),
// //           datum: NoDatum,
// //           reference_script: None
// //         }
// //       }
// //     ]),
// //     // Reference inputs (none needed)
// //     None,
// //     // Outputs (Updated Tontine state)
// //     Some([
// //       Output {
// //         address: creator_address,
// //         value: assets.from_lovelace(1_000_000 + contribution_amount),
// //         datum: InlineDatum(updated_datum),
// //         reference_script: None
// //       }
// //     ]),
// //     // Minting (None)
// //     None,
// //     // Certificates (None)
// //     None,
// //     // Withdrawals (None)
// //     None,
// //     // Validity range (None)
// //     None,
// //     // Extra Signatories (Only participant_2)
// //     Some([participant_2_id]),
// //     // Redeemers (None)
// //     None,
// //     // Datums (None)
// //     None,
// //     Some(2_000_000) // ✅ Transaction Fee (2 ADA)
// //   )

// //   // ✅ Debugging Traces
// //   trace @"🔍 Checking Active Pool" trace cbor.diagnostic(datum.state_token.counter)
// //   trace @"🔍 Checking Contribution Amount" trace cbor.diagnostic(contribution_amount)
// //   trace @"🔍 Checking Participant 2 Address" trace cbor.diagnostic(participant_2_address)
// //   trace @"🔍 Checking UTxO Protection" trace cbor.diagnostic(contribution_utxo.transaction_id)
// //   trace @"🔍 Checking UTxO Key (Fixed)" trace cbor.diagnostic(contribution_utxo_key)

// //   // ✅ Step 5: Run the validator
// //   let result = handle_contribute(datum, contribution_amount, transaction)

// //   // ✅ Step 6: Assertions
// //   expect result == True
// // }




// // test select_winner_rosca_succeeds() {
// //   // ✅ Step 1: Setup a ROSCA-based tontine with participants.
// //   let pool_id = sample_pool_datum.pool_id

// //   let state_token =
// //     StateToken {
// //       policy_id: sample_pool_datum.state_token.policy_id,
// //       counter: 1,
// //       // ✅ This is fine
// //       global_hash: sample_pool_datum.state_token.global_hash,
// //       current_round: 1,
// //     }

// //   // 🔥 Ensure this is > 0
// //   // Create CIP-68 metadata using insert_by_ascending_key
// //   let metadata =
// //     []
// //       |> pairs.repsert_by_ascending_key(
// //           key: builtin.b_data(
// //             #"00000000000000000000000000000000000000000000000000000001",
// //           ),
// //           value: builtin.i_data(1_000_000),
// //           compare: compare_data_as_bytearray,
// //         ) // ✅ Use the custom comparator
      
// //     |> pairs.insert_by_ascending_key(
// //           key: builtin.b_data(
// //             #"00000000000000000000000000000000000000000000000000000002",
// //           ),
// //           value: builtin.i_data(1_000_000),
// //           compare: compare_data_as_bytearray,
// //         )

// //   // ✅ Use the custom comparator
// //   let cip68_metadata = CIP68 { metadata, version: 1 }

// //   // ✅ Step 2: Create the initial pool datum
// //   let datum =
// //     TontinePool {
// //       pool_id,
// //       creator: sample_pool_datum.creator,
// //       pool_type: ROSCA,
// //       governance: sample_pool_datum.governance,
// //       max_members: sample_pool_datum.max_members,
// //       state_token: sample_pool_datum.state_token,
// //       cip68: cip68_metadata,
// //       collateral_amount: sample_pool_datum.collateral_amount,
// //       status: sample_pool_datum.status
// //     }

// //   // trace @"Debug: Initial Pool Datum"
// //   // trace cbor.diagnostic(datum)

// //   // ✅ Step 3: Compute updated metadata BEFORE using it
// //   let cleaned_metadata =
// //     pairs.delete_first(
// //       datum.cip68.metadata,
// //       builtin.b_data(
// //         #"00000000000000000000000000000000000000000000000000000002",
// //       ),
// //     )

// //   // Remove old contribution
// //   let updated_metadata =
// //     CIP68(
// //       pairs.repsert_by_ascending_key(
// //         cleaned_metadata,
// //         builtin.b_data(
// //           #"00000000000000000000000000000000000000000000000000000002",
// //         ),
// //         builtin.b_data("Winner"),
// //         compare_data_as_bytearray,
// //       ),
// //       datum.cip68.version + 1,
// //     )

// //   // ✅ Increment version
// //   // trace @"Debug: Updated Metadata"
// //   // trace cbor.diagnostic(updated_metadata)

// //   // ✅ Step 4: Construct updated pool datum using updated_metadata
// //   let updated_datum =
// //     TontinePool {
// //       pool_id: datum.pool_id,
// //       creator: datum.creator,
// //       pool_type: datum.pool_type,
// //       governance: datum.governance,
// //       max_members: datum.max_members,
// //       state_token,
// //       cip68: updated_metadata,
// //       collateral_amount: datum.collateral_amount,
// //       status: datum.status
// //     }

// //   // trace @"Debug: Updated Pool Datum"
// //   // trace cbor.diagnostic(updated_datum)

// //   // ✅ Step 5: Create the transaction for winner selection
// //   let transaction =
// //     build_tx(
// //       Some(
// //         [
// //           Input {
// //             output_reference: pool_id,
// //             output: Output {
// //               address: address.from_verification_key(dao_script_hash),
// //               value: assets.from_lovelace(1_000_000),
// //               datum: InlineDatum(datum),
// //               reference_script: None,
// //             },
// //           },
// //         ],
// //       ),
// //       None,
// //       Some(
// //         [
// //           Output {
// //             address: address.from_verification_key(dao_script_hash),
// //             value: assets.from_lovelace(1_000_000),
// //             datum: InlineDatum(updated_datum),
// //             // ✅ Ensure correct datum
// //             reference_script: None,
// //           },
// //         ],
// //       ),
// //       None,
// //       None,
// //       None,
// //       None,
// //       Some([dao_script_hash]),
// //       None,
// //       None,
// //       None
// //     )

// //   // trace @"Debug: Transaction Outputs"
// //   // trace cbor.diagnostic(transaction.outputs)

// //   // ✅ Step 6: Validate winner selection
// //   let result = handle_select_winner(datum, transaction)

// //   // trace @"Debug: Final Validation Result"
// //   // trace cbor.diagnostic(result)

// //   // ✅ Step 7: Expect success
// //   expect result == True
// // }

// // test select_winner_auction_succeeds() {
// //   // Step 1: Setup an Auction-based tontine with contributions.
// //   let pool_id = sample_pool_datum.pool_id
// //   let participant_1 =
// //     Pair(
// //       builtin.b_data(
// //         #"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
// //       ),
// //       builtin.i_data(150_000),
// //     )
// //   let participant_2 =
// //     Pair(
// //       builtin.b_data(
// //         #"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
// //       ),
// //       builtin.i_data(300_000),
// //     )

// //   // ✅ Initial CIP-68 Metadata
// //   let metadata = CIP68 { metadata: [participant_1, participant_2], version: 1 }

// //   // trace @"Debug: Initial Metadata"
// //   // trace cbor.diagnostic(metadata)

// //   // ✅ Initial Pool Datum
// //   let datum =
// //     TontinePool {
// //       pool_id,
// //       creator: sample_pool_datum.creator,
// //       pool_type: AUCTION,
// //       governance: sample_pool_datum.governance,
// //       max_members: sample_pool_datum.max_members,
// //       state_token: sample_pool_datum.state_token,
// //       cip68: metadata,
// //       collateral_amount: sample_pool_datum.collateral_amount,
// //       status: sample_pool_datum.status
// //     }

// //   // trace @"Debug: Initial Pool Datum"
// //   // trace cbor.diagnostic(datum)

// //   // ✅ Identify the highest bidder (winner)
// //   let highest_bidder =
// //     when pairs.get_first(metadata.metadata, builtin.b_data(#"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb")) is {
// //       Some(_) -> #"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
// //       None -> #""
// //     }

// //   // trace @"Debug: Winner ID"
// //   // trace cbor.diagnostic(highest_bidder)

// //   // ✅ Updated metadata after selecting winner
// //   let cleaned_metadata = pairs.delete_first(metadata.metadata, builtin.b_data(highest_bidder))

// //   let updated_metadata =
// //     CIP68(
// //       pairs.repsert_by_ascending_key(
// //         cleaned_metadata,
// //         builtin.b_data(highest_bidder),
// //         builtin.b_data("Winner"),
// //         compare_data_as_bytearray,
// //       ),
// //       metadata.version + 1,
// //     )

// //   // trace @"Debug: Updated Metadata"
// //   // trace cbor.diagnostic(updated_metadata)

// //   // ✅ Updated Pool Datum after selecting winner
// //   let updated_datum =
// //     TontinePool {
// //       pool_id: datum.pool_id,
// //       creator: datum.creator,
// //       pool_type: datum.pool_type,
// //       governance: datum.governance,
// //       max_members: datum.max_members,
// //       state_token: datum.state_token,
// //       cip68: updated_metadata,
// //       collateral_amount: datum.collateral_amount,
// //       status: sample_pool_datum.status
// //     }

// //   // trace @"Debug: Updated Pool Datum"
// //   // trace cbor.diagnostic(updated_datum)

// //   // ✅ Step 2: Create the transaction that triggers winner selection.
// //   let transaction =
// //     build_tx(
// //       Some(
// //         [
// //           Input {
// //             output_reference: pool_id,
// //             output: Output {
// //               address: address.from_verification_key(dao_script_hash),
// //               value: assets.from_lovelace(1_000_000),
// //               datum: InlineDatum(datum),
// //               reference_script: None,
// //             },
// //           },
// //         ],
// //       ),
// //       None,
// //       Some([
// //         Output {
// //           address: address.from_verification_key(dao_script_hash),
// //           value: assets.from_lovelace(1_000_000),
// //           datum: InlineDatum(updated_datum), // ✅ Include updated datum in outputs
// //           reference_script: None,
// //         },
// //       ]),
// //       None,
// //       None,
// //       None,
// //       None,
// //       Some([dao_script_hash]),
// //       None,
// //       None,
// //       None
// //     )

// //   // trace @"Debug: Transaction Outputs"
// //   // trace cbor.diagnostic(transaction.outputs)

// //   // ✅ Step 3: Run the validator to check winner selection.
// //   let result = handle_select_winner(datum, transaction)

// //   // trace @"Debug: Final Validation Result"
// //   // trace cbor.diagnostic(result)

// //   // ✅ Step 4: Validate success
// //   expect result == True
// // }



// // test select_winner_fails_if_unauthorized() {
// //   // Step 1: Setup a tontine with governance
// //   let pool_id = sample_pool_datum.pool_id
// //   let participant_1 =
// //     Pair(
// //       builtin.b_data(
// //         #"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
// //       ),
// //       builtin.i_data(200_000),
// //     )
// //   let metadata = CIP68 { metadata: [participant_1], version: 1 }

// //   // Update the datum
// //   let datum =
// //     TontinePool {
// //       pool_id,
// //       creator: sample_pool_datum.creator,
// //       pool_type: ROSCA,
// //       governance: DAO(dao_script_hash),
// //       // DAO required for winner selection
// //       max_members: sample_pool_datum.max_members,
// //       state_token: sample_pool_datum.state_token,
// //       cip68: metadata,
// //       collateral_amount: sample_pool_datum.collateral_amount,
// //       status: sample_pool_datum.status
// //     }

// //   // Step 2: Create the transaction without DAO signature.
// //   let transaction =
// //     build_tx(
// //       Some(
// //         [
// //           Input {
// //             output_reference: pool_id,
// //             output: Output {
// //               address: address.from_verification_key(dao_script_hash),
// //               value: assets.from_lovelace(1_000_000),
// //               datum: InlineDatum(datum),
// //               reference_script: None,
// //             },
// //           },
// //         ],
// //       ),
// //       None,
// //       Some([]),
// //       Some(assets.zero),
// //       None,
// //       Some([]),
// //       None,
// //       Some([#"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f50"]),
// //       // Unauthorized signer
// //       None,
// //       None,
// //       None
      
// //     )

// //   // Step 3: Run the validator to check failure case.
// //   let result = handle_select_winner(datum, transaction)

// //   // Step 4: Expect failure
// //   expect result == False
// // }

// // // ✅ 5. Test: Withdrawals
// // test withdraw_succeeds() {
// //   // Step 1: Setup the TontinePool datum with a participant and winnings
// //   let participant_id = #"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
// //   let winnings = 100_000
// //   let initial_metadata = CIP68 {
// //     metadata: [Pair(builtin.b_data(participant_id), builtin.i_data(winnings))],
// //     version: 1
// //   }
// //   let pool_id = sample_pool_datum.pool_id
// //   let state_token =
// //     StateToken {
// //       policy_id: sample_pool_datum.state_token.policy_id,
// //       counter: 1,
// //       // ✅ This is fine
// //       global_hash: sample_pool_datum.state_token.global_hash,
// //       current_round: 1,
// //     }

// //   let datum = TontinePool {
// //     pool_id: pool_id,
// //     creator: #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f50", // Sample creator
// //     pool_type: ROSCA, // Or AUCTION, depending on your use case
// //     governance: CreatorControlled,
// //     max_members: 6,
// //     state_token: state_token, // Active pool
// //     cip68: initial_metadata,
// //     collateral_amount: 1_000_000,
// //     status: Completed
// //   }

// //   // trace @"Debug: Initial Pool Datum"
// //   // trace cbor.diagnostic(datum)
  
// //   // Step 2: Compute the updated metadata (remove participant's winnings)
// //   let updated_metadata = CIP68 {
// //     metadata: pairs.delete_first(initial_metadata.metadata, builtin.b_data(participant_id)),
// //     version: initial_metadata.version // No increment needed per your code
// //   }
// //   let updated_datum = TontinePool { ..datum, cip68: updated_metadata }

// //   // Step 3: Build the transaction
// //   let participant_address = address.from_verification_key(participant_id)
// //   let transaction = build_tx(
// //   Some([  // ✅ This is the correct place for inputs
// //     Input {
// //       output_reference: pool_id,
// //       output: Output {
// //         address: address.from_verification_key(datum.creator),
// //         value: assets.from_lovelace(1_000_000), // Pool funds
// //         datum: InlineDatum(datum),
// //         reference_script: None
// //       }
// //     }
// //   ]),
// //   None,  // ❌ This was previously where outputs were incorrectly placed
// //   Some([  // ✅ Outputs should be here
// //     Output {
// //       address: participant_address,
// //       value: assets.from_lovelace(winnings),
// //       datum: InlineDatum(datum),
// //       reference_script: None
// //     },
// //     Output {
// //       address: address.from_verification_key(datum.creator),
// //       value: assets.from_lovelace(900_000), // Remaining pool funds
// //       datum: InlineDatum(updated_datum),
// //       reference_script: None
// //     }
// //   ]),
// //   Some(assets.zero), // Minted assets (none)
// //   None, // Fee
// //   Some([]), // Reference inputs
// //   None, // Validity range
// //   Some([participant_id]), // Signatures: participant signs
// //   None, // Redeemers
// //   None,  // Datums
// //   None
// // )

// //   // trace @"Debug: Transaction Inputs"
// //   // trace cbor.diagnostic(transaction.inputs)
// //   // trace @"Debug: Transaction Outputs"
// //   // trace cbor.diagnostic(transaction.outputs)

// //   // Step 4: Run the validator
// //   let result = handle_withdraw(datum, transaction)

// //   // trace @"Debug: Final Validation Result"
// //   // trace cbor.diagnostic(result)

// //   // Step 5: Assert success
// //   expect result == True
// // }

// // test test_cancel_by_dao_succeeds() { 
// //   // ✅ Step 1: Setup Initial Conditions
// //   let dao_script_hash = #"00000000000000000000000000000000000000000000000000000000"
// //   let creator_id = #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f50"
// //   let participant_1_id = #"00000000000000000000000000000000000000000000000000000001"
// //   let participant_2_id = #"00000000000000000000000000000000000000000000000000000002"

// //   // ✅ Step 2: Setup Participants' Contributions
// //   let participant_1_contribution = 1_500_000
// //   let participant_2_contribution = 2_000_000
// //   let total_contribution = participant_1_contribution + participant_2_contribution

// //   let metadata = [
// //     Pair(builtin.b_data(participant_1_id), builtin.i_data(participant_1_contribution)),
// //     Pair(builtin.b_data(participant_2_id), builtin.i_data(participant_2_contribution))
// //   ]

// //   let tontine_datum = TontinePool {
// //     pool_id: OutputReference {
// //       transaction_id: #"0000000000000000000000000000000000000000000000000000000000000000",
// //       output_index: 0
// //     },
// //     creator: creator_id,
// //     pool_type: ROSCA,
// //     governance: DAO(dao_script_hash), // ✅ DAO must authorize the cancellation
// //     max_members: 10,
// //     state_token: StateToken {
// //       policy_id: #"f4c90000000000000000000000000000000000000000000000000000",
// //       counter: 1,
// //       global_hash: #"f4c90000000000000000000000000000000000000000000000000000",
// //       current_round: 1
// //     },
// //     cip68: CIP68 { metadata, version: 1 },
// //     collateral_amount: total_contribution,
// //     status: Active // ✅ Initial state should be Active
// //   }

// //   // ✅ Step 3: Construct Transaction Refund Outputs
// //   let refund_output_1 = Output {
// //     address: address.from_verification_key(participant_1_id),
// //     value: assets.from_lovelace(participant_1_contribution),
// //     datum: NoDatum,
// //     reference_script: None
// //   }

// //   let refund_output_2 = Output {
// //     address: address.from_verification_key(participant_2_id),
// //     value: assets.from_lovelace(participant_2_contribution),
// //     datum: NoDatum,
// //     reference_script: None
// //   }

// //   // ✅ Step 4: Define Updated Pool Datum (Explicitly Updating Fields)
// //   let updated_datum = TontinePool {
// //     pool_id: tontine_datum.pool_id,
// //     creator: tontine_datum.creator,
// //     pool_type: tontine_datum.pool_type,
// //     governance: tontine_datum.governance,
// //     max_members: tontine_datum.max_members,
// //     state_token: StateToken {
// //         policy_id: tontine_datum.state_token.policy_id,
// //         counter: tontine_datum.state_token.counter + 1,  // ✅ Ensure state progression
// //         global_hash: tontine_datum.state_token.global_hash,
// //         current_round: tontine_datum.state_token.current_round
// //     },
// //     cip68: CIP68 {
// //         metadata: tontine_datum.cip68.metadata,
// //         version: tontine_datum.cip68.version
// //     },
// //     collateral_amount: 0, // ✅ Set collateral to 0 since it's being cancelled
// //     status: Cancelled // ✅ Explicitly update status
// //   }

// //   // ✅ Step 5: Serialize & Hash Updated Datum
// //   let serialized_updated_datum = builtin.serialise_data(builtin.constr_data(0, [
// //     builtin.constr_data(0, [
// //       builtin.b_data(updated_datum.pool_id.transaction_id),
// //       builtin.i_data(updated_datum.pool_id.output_index)
// //     ]),
// //     builtin.b_data(updated_datum.creator),
// //     when updated_datum.governance is {
// //         DAO(dao_script_hash) -> builtin.constr_data(0, [builtin.b_data(dao_script_hash)])
// //         CreatorControlled -> builtin.constr_data(1, [])
// //     },
// //     builtin.i_data(updated_datum.max_members),
// //     builtin.constr_data(0, [
// //         builtin.b_data(updated_datum.state_token.policy_id),
// //         builtin.i_data(updated_datum.state_token.counter),  // ✅ Proper state progression
// //         builtin.b_data(updated_datum.state_token.global_hash),
// //         builtin.i_data(updated_datum.state_token.current_round)
// //     ]),
// //     builtin.map_data(
// //         list.map(updated_datum.cip68.metadata, fn(entry) {
// //             Pair(
// //                 builtin.b_data(builtin.un_b_data(builtin.fst_pair(entry))),
// //                 builtin.i_data(builtin.un_i_data(builtin.snd_pair(entry)))
// //             )
// //         })
// //     ),
// //     builtin.i_data(0),  // ✅ Ensure collateral_amount is updated
// //     builtin.constr_data(2, [])  // ✅ **Status -> Cancelled** (0 = Active, 1 = Completed, 2 = Cancelled)
// //   ]))  

// //   let updated_datum_hash = crypto.blake2b_256(serialized_updated_datum)

// //   // ✅ Step 6: Create Transaction Output with Updated Datum
// //   let tontine_output = Output {
// //     address: address.from_script(dao_script_hash),
// //     value: assets.from_lovelace(0),
// //     datum: InlineDatum(updated_datum),  // ✅ Ensure it's an **InlineDatum**
// //     reference_script: None
// //   }

// //   // ✅ Step 7: Define Transaction Inputs
// //   let tontine_utxo = Input {
// //     output_reference: tontine_datum.pool_id,
// //     output: Output {
// //       address: address.from_script(dao_script_hash),
// //       value: assets.from_lovelace(total_contribution),
// //       datum: InlineDatum(tontine_datum), // ✅ Ensure original datum is inline
// //       reference_script: None
// //     }
// //   }

// //   // ✅ Step 8: Build Transaction
// //   let cancel_tx = build_tx(
// //     Some([tontine_utxo]),
// //     None,
// //     Some([refund_output_1, refund_output_2, tontine_output]),
// //     None,
// //     None,
// //     None,
// //     None,
// //     Some([dao_script_hash]), // ✅ DAO must sign the transaction
// //     None,
// //     Some(dict.from_pairs([
// //       Pair(updated_datum_hash, builtin.constr_data(0, [builtin.b_data(serialized_updated_datum)]))
// //     ])),
// //     Some(2_000_000) // ✅ Transaction Fee
// //   )

// //   // ✅ Step 9: Validate Execution
// //   let result = handle_cancel(tontine_datum, cancel_tx)

// //   // ✅ Debugging Traces
// //   trace @"🔍 Checking updated datum: " trace cbor.diagnostic(updated_datum)  
// //   trace @"🔍 Updated Datum Hash: " trace cbor.diagnostic(updated_datum_hash)
// //   trace @"🔍 Checking stored datum in output: " trace cbor.diagnostic(tontine_output.datum)
// //   trace @"🔍 Final cancel result: " trace cbor.diagnostic(result)

// //   // ✅ Step 10: Assertions
// //   expect result == True
// // }

// // test distribute_succeeds() {
// //   // ✅ Step 1: Setup the TontinePool datum
// //   let creator_id = #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f50"
// //   let participant_1_id = #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f51"
// //   let participant_2_id = #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f52"

// //   let pool_id = OutputReference {
// //     transaction_id: #"0000000000000000000000000000000000000000000000000000000000000000",
// //     output_index: 0
// //   }

// //   let initial_metadata = CIP68 {
// //     metadata: [
// //       Pair(builtin.b_data(participant_1_id), builtin.i_data(1_500_000)),
// //       Pair(builtin.b_data(participant_2_id), builtin.i_data(2_000_000))
// //     ],
// //     version: 2 // Total participants
// //   }

// //   let state_token =
// //     StateToken {
// //       policy_id: sample_pool_datum.state_token.policy_id,
// //       counter: 1,
// //       global_hash: sample_pool_datum.state_token.global_hash,
// //       current_round: 1
// //     }

// //   let datum = TontinePool {
// //     pool_id: pool_id,
// //     creator: creator_id,
// //     pool_type: ROSCA,
// //     governance: CreatorControlled,
// //     max_members: 6,
// //     state_token: state_token,
// //     cip68: initial_metadata,
// //     collateral_amount: 3_500_000,
// //     status: Completed
// //   }

// //   // ✅ Step 2: Define the total rewards to distribute
// //   let total_rewards = 3_500_000

// //   // ✅ Step 3: Construct inputs (Ensure pool has enough funds)
// //   let pool_utxo = OutputReference {
// //     transaction_id: #"1111111111111111111111111111111111111111111111111111111111111111",
// //     output_index: 0
// //   }

// //   let input_pool = Input {
// //     output_reference: pool_utxo,
// //     output: Output {
// //       address: address.from_verification_key(creator_id),
// //       value: assets.from_lovelace(total_rewards),
// //       datum: InlineDatum(datum),
// //       reference_script: None
// //     }
// //   }

// //   // ✅ Step 4: Construct expected outputs (Ensure participants receive correct rewards)
// //   let output_participant_1 = Output {
// //     address: address.from_verification_key(participant_1_id),
// //     value: assets.from_lovelace(1_500_000),
// //     datum: NoDatum,
// //     reference_script: None
// //   }

// //   let output_participant_2 = Output {
// //     address: address.from_verification_key(participant_2_id),
// //     value: assets.from_lovelace(2_000_000),
// //     datum: NoDatum,
// //     reference_script: None
// //   }

// //   let updated_datum = TontinePool { ..datum }
  

// //   let output_pool = Output {
// //     address: address.from_verification_key(creator_id),
// //     value: assets.from_lovelace(0), // Pool should be empty after distribution
// //     datum: InlineDatum(updated_datum),
// //     reference_script: None
// //   }

// //   // ✅ Step 5: Build transaction with authorized creator signature
// //   let transaction = build_tx(
// //     Some([input_pool]),
// //     None,
// //     Some([output_participant_1, output_participant_2, output_pool]),
// //     None,
// //     None,
// //     None,
// //     None,
// //     Some([creator_id]), // ✅ Creator must sign the transaction
// //     None,
// //     None,
// //     Some(2_000_000)
// //   )

// //   // ✅ Debugging traces
// //   trace @"🔍 Checking total_rewards: " trace cbor.diagnostic(total_rewards)
// //   trace @"🔍 Checking creator_id: " trace cbor.diagnostic(creator_id)
// //   trace @"🔍 Checking participant_1_id: " trace cbor.diagnostic(participant_1_id)
// //   trace @"🔍 Checking participant_2_id: " trace cbor.diagnostic(participant_2_id)

// //   // ✅ Step 6: Run the validator
// //   let result = handle_distribute(datum, transaction)

// //   // ✅ Step 7: Assertions
// //   expect result == True
// // }

