use aiken/builtin.{b_data, constr_data, integer_to_bytearray, list_data}
use aiken/collection/dict.{Dict}
use aiken/collection/list
use aiken/crypto.{VerificationKeyHash}
use aiken/primitive/bytearray
use cardano/assets
use cardano/transaction.{Input, Output, OutputReference, Transaction}

pub type Datum {
  participants: List<VerificationKeyHash>,
  round: Int,
}

pub type TontineRedeemer {
  Contribute
  Redeem { winner_index: Int }
}

pub fn datum_to_data(datum: Datum) -> Data {
  let participant_data = datum.participants |> list.map(b_data)

  let round_data = integer_to_bytearray(True, 0, datum.round)

  constr_data(0, [list_data(participant_data), b_data(round_data)])
}

fn verify_signer(
  participant: VerificationKeyHash,
  signatories: List<VerificationKeyHash>,
) -> Bool {
  list.any(signatories, fn(signer) { signer == participant })
}

fn validate_user_keys(participants: List<VerificationKeyHash>) -> Bool {
  if !list.is_empty(participants) {
    let result =
      list.foldl(
        participants,
        Some(dict.empty),
        fn(key_hash, acc: Option<Dict<VerificationKeyHash, Bool>>) -> Option<
          Dict<VerificationKeyHash, Bool>,
        > {
          let expected_length = 28
          let key_length = bytearray.length(key_hash)

          when acc is {
            None -> None

            Some(acc_dict) ->
              if key_length != expected_length || dict.has_key(
                acc_dict,
                key_hash,
              ) {
                None
              } else {
                Some(dict.insert(acc_dict, key_hash, True))
              }
          }
        },
      )
    result != None
  } else {
    False
  }
}

fn validate_utxo_consistency(
  own_ref: OutputReference,
  self_tx: Transaction,
) -> Bool {
  let relevant_inputs =
    list.filter(self_tx.inputs, fn(input) { input.output_reference == own_ref })

  let total_input_lovelace =
    relevant_inputs
      |> list.foldl(
          0,
          fn(input, acc) { acc + assets.lovelace_of(input.output.value) },
        )

  when list.head(self_tx.outputs) is {
    Some(winner_output) -> {
      let winner_output_lovelace = assets.lovelace_of(winner_output.value)

      if total_input_lovelace == winner_output_lovelace {
        True
      } else {
        trace @"ERROR: Total lovelace mismatch between inputs and output."
        False
      }
    }
    None -> {
      trace @"ERROR: No output found in the transaction."
      False
    }
  }
}

validator tontine {
  spend(
    datum: Option<Datum>,
    redeemer: TontineRedeemer,
    own_ref: OutputReference,
    self: Transaction,
  ) {
    when datum is {
      Some(d) -> {
        let valid_user_keys = validate_user_keys(d.participants)
        let valid_round = d.round >= 0

        if !valid_user_keys {
          trace @"ERROR: Invalid participant key detected."
          False
        } else if !valid_round {
          trace @"ERROR: Round number is invalid."
          False
        } else if !validate_utxo_consistency(own_ref, self) {
          False
        } else {
          when redeemer is {
            Contribute -> {
              trace @"Contribution validated successfully."
              True
            }
            Redeem { winner_index } -> {
              let selected_winner = list.at(d.participants, winner_index)
              when selected_winner is {
                None -> {
                  trace @"ERROR: Invalid winner index."
                  False
                }
                Some(participant) -> {
                  let is_signer =
                    verify_signer(participant, self.extra_signatories)
                  if !is_signer {
                    trace @"ERROR: Missing signature of the winner."
                    False
                  } else {
                    trace @"Winner verified."
                    True
                  }
                }
              }
            }
          }
        }
      }
      None -> fail @"ERROR: Missing Datum."
    }
  }

  else(_) {
    fail @"ERROR: Invalid validator usage."
  }
}
