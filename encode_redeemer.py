import cbor2

# Define the redeemer with winner_index = 2
redeemer = {'winner_index': 2}

# Encode the redeemer into CBOR
encoded_redeemer = cbor2.dumps(redeemer)

# Print the CBOR-encoded redeemer
print(encoded_redeemer)
