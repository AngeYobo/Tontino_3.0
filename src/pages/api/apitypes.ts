
// Define the participant type (VerificationKeyHash as a string)
export type Participant = string;

// Define the datum for the Tontine, which is a list of participants
export type Datum = {
  participants: Participant[];
};

// Define the redeemer for the Tontine, which specifies the winner index
export type Redeemer = {
  winner_index: number;  
};

