import React from "react";
import { Bar } from "react-chartjs-2";
import { Chart as ChartJS, CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend } from 'chart.js';

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend);

// Define three dummy datasets for different graphs
const investmentData = {
  labels: ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin"],
  datasets: [
    {
      label: "ADA",
      data: [1000, 1500, 2000, 4000, 3200, 4500],
      backgroundColor: "rgba(54, 162, 235, 0.7)", // Blue
      borderColor: "rgba(54, 162, 235, 1)",
      borderWidth: 1,
      hoverBackgroundColor: "rgba(54, 162, 235, 0.9)",
      hoverBorderColor: "rgba(54, 162, 235, 1)",
      barPercentage: 0.7,
      borderRadius: 10,
    },
  ],
};

const stakingData = {
  labels: ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin"],
  datasets: [
    {
      label: "ADA",
      data: [800, 1200, 2500, 3200, 2800, 3800],
      backgroundColor: "rgba(75, 192, 192, 0.7)", // Green
      borderColor: "rgba(75, 192, 192, 1)",
      borderWidth: 1,
      hoverBackgroundColor: "rgba(75, 192, 192, 0.9)",
      hoverBorderColor: "rgba(75, 192, 192, 1)",
      barPercentage: 0.7,
      borderRadius: 10,
    },
  ],
};

const farmingData = {
  labels: ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin"],
  datasets: [
    {
      label: "ADA",
      data: [700, 1000, 3000, 4500, 1500, 3200],
      backgroundColor: "rgba(153, 102, 255, 0.7)", // Violet
      borderColor: "rgba(153, 102, 255, 1)",
      borderWidth: 1,
      hoverBackgroundColor: "rgba(153, 102, 255, 0.9)",
      hoverBorderColor: "rgba(153, 102, 255, 1)",
      barPercentage: 0.7,
      borderRadius: 10,
    },
  ],
};

const options = {
  responsive: true,
  plugins: {
    legend: {
      display: false,
    },
    title: {
      display: true,
      text: "Graphique des Investissements", // French title
      color: "white",
    },
  },
  scales: {
    x: {
      grid: {
        display: false,
      },
    },
    y: {
      grid: {
        color: "rgba(255, 255, 255, 0.1)",
      },
    },
  },
};

// Modify GraphPlaceholder to accept a title and data prop
const GraphPlaceholder = ({ title, data }: { title: string; data: any }) => {
  const chartOptions = { ...options, plugins: { ...options.plugins, title: { ...options.plugins.title, text: title } } };

  return (
    <div className="p-8 bg-gray-800 rounded-lg shadow-lg flex flex-col items-center" style={{ width: '400px', height: '300px' }}>
      <div className="w-full h-60">
        <Bar data={data} options={chartOptions} />
      </div>
    </div>
  );
};

const InvestmentGraphSection = () => {
  return (
    <section className="mt-8 text-center">
      <h2 className="text-2xl font-semibold text-center mb-4"></h2>
      <div className="flex justify-center gap-4">
        <GraphPlaceholder title="Investissement Total" data={investmentData} />
        <GraphPlaceholder title="Performance du Staking" data={stakingData} />
        <GraphPlaceholder title="Revenus de Yield Farming" data={farmingData} />
      </div>
    </section>
  );
};

export default InvestmentGraphSection;
