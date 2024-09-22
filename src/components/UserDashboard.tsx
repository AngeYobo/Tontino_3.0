import React from 'react';

const Dashboard = () => {
  return (
    <section className="py-16" style={{ background: "linear-gradient(135deg, #e0e0f7, #ffffff)" }}>
      <div className="container mx-auto">
        <div className="grid grid-cols-4 gap-6 text-center">
          <div className="p-8 bg-white rounded-lg shadow-xl transform transition duration-500 hover:scale-105">
            <h3 className="text-lg font-semibold text-gray-700">Total Investment</h3>
            <p className="text-3xl font-bold text-gray-900">1000 ADA</p>
          </div>
          <div className="p-8 bg-white rounded-lg shadow-xl transform transition duration-500 hover:scale-105">
            <h3 className="text-lg font-semibold text-gray-700">Staked Amount</h3>
            <p className="text-3xl font-bold text-gray-900">500 ADA</p>
          </div>
          <div className="p-8 bg-white rounded-lg shadow-xl transform transition duration-500 hover:scale-105">
            <h3 className="text-lg font-semibold text-gray-700">Rewards Earned</h3>
            <p className="text-3xl font-bold text-gray-900">50 ADA</p>
          </div>
          <div className="p-8 bg-white rounded-lg shadow-xl transform transition duration-500 hover:scale-105">
            <h3 className="text-lg font-semibold text-gray-700">Voting Power</h3>
            <p className="text-3xl font-bold text-gray-900">5%</p>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Dashboard;
