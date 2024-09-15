"use client";
import Main from "@/components/Main";
import Contribute from "@/components/Contribute"; // Your Contribute component
import ReceiveFunds from "@/components/ReceiveFunds"; // Your ReceiveFunds component

export default function Home() {
  return (
    <Main>
      <div>
        <h2>Welcome to Tontino</h2>
        <p>Connect your wallet and start interacting with Tontino.</p>
        <Contribute />
        <ReceiveFunds /> 
      </div>
    </Main>
  );
}
