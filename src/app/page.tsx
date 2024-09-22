"use client";

import Main from "@/components/Main";
import Contribute from "@/components/Contribute";
import ReceiveFunds from "@/components/ReceiveFunds";
import Governance from "@/components/Governance";
import LendBorrow from "@/components/LendBorrow";
import Stake from "@/components/Stake";
import YieldFarm from "@/components/YieldFarm";
import UserDashboard from "@/components/UserDashboard";
import GraphPlaceholder from "@/components/GraphPlaceholder";

export default function Home() {
  return (
    <Main>
      {/* Dashboard Header Section */}
      <UserDashboard />
      {/* Grid Layout for DeFi Features */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-10 mt-12 px-4">
        {/* Left Column: Contribute & Governance */}
        <div className="space-y-10">
          <Contribute />
          <Governance />
        </div>

        {/* Middle Column: Lending/Borrowing & Staking */}
        <div className="space-y-10">
          <LendBorrow />
          <Stake />
        </div>

        {/* Right Column: Yield Farming & Funds Redeem */}
        <div className="space-y-10">
          <YieldFarm />
          <ReceiveFunds />
        </div>
      </div>
    </Main>
  );
}
