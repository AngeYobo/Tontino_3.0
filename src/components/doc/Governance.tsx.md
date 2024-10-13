"use client";

import React, { useState } from 'react';

const Governance: React.FC = () => {
  const [selectedProposal, setSelectedProposal] = useState<string | null>(null);
  const [isVoting, setIsVoting] = useState<boolean>(false);
  const [voteSubmitted, setVoteSubmitted] = useState<boolean>(false);

  const handleVote = () => {
    if (!selectedProposal) {
      alert("Please select a proposal to vote.");
      return;
    }
    
    setIsVoting(true);
    setTimeout(() => {
      setIsVoting(false);
      setVoteSubmitted(true);
      alert("This feature is under work. Voting will be available soon!");
    }, 2000); // Simulating a network request
  };

  const proposals = [
    { id: "1", title: "Increase Staking Rewards" },
    { id: "2", title: "Lower Borrowing Rates" },
    { id: "3", title: "Add New Tontine Features" },
  ];

  return (
    <div className="flex flex-col items-center bg-white shadow-lg rounded-lg p-8 max-w-md mx-auto mt-12">
      <h2 className="text-2xl font-semibold text-gray-900 mb-4">Governance Voting</h2>
      <p className="text-sm text-gray-600 mb-6">
        Participate in the governance of Tontine by voting on proposals that impact the platform's future.
      </p>

      {/* Proposals List */}
      <div className="w-full mb-6">
        <h3 className="text-lg font-medium text-gray-700 mb-3">Current Proposals:</h3>
        <ul className="space-y-3">
          {proposals.map((proposal) => (
            <li key={proposal.id}>
              <label className="flex items-center space-x-3">
                <input
                  type="radio"
                  name="proposal"
                  value={proposal.id}
                  onChange={() => setSelectedProposal(proposal.id)}
                  className="form-radio h-4 w-4 text-blue-600 transition duration-150 ease-in-out"
                />
                <span className="text-gray-700">{proposal.title}</span>
              </label>
            </li>
          ))}
        </ul>
      </div>

      {/* Vote Button */}
      <button
        onClick={handleVote}
        disabled={isVoting}
        className="w-full bg-green-600 text-white font-semibold py-2 px-4 rounded-md shadow hover:bg-green-700 transition-all duration-300"
      >
        {isVoting ? "Enrégistrement ..." : "Vote"}
      </button>

      {/* Vote Submitted Message */}
      {voteSubmitted && (
        <div className="mt-6 text-center text-sm text-green-500">
          Vote submitted successfully!<br />
          This feature is currently under work.
        </div>
      )}
    </div>
  );
};

export default Governance;
