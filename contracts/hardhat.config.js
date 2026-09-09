require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const {
  SEPOLIA_RPC_URL,
  MUMBAI_RPC_URL,
  PRIVATE_KEY,
} = process.env;

/**
 * Returns the configured deployer account.
 *
 * Keeping this in one place makes it easier to validate
 * configuration and avoid accidentally passing an empty key.
 */
const accounts = PRIVATE_KEY ? [PRIVATE_KEY] : [];

module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },

  networks: {
    // Local Hardhat network
    hardhat: {
      chainId: 1337,
    },

    // Ethereum Sepolia testnet
    sepolia: {
      url: SEPOLIA_RPC_URL || "",
      accounts,
      chainId: 11155111,
    },

    // Polygon Mumbai testnet
    //
    // Note: Mumbai has been deprecated by Polygon.
    // Prefer Amoy for new deployments.
    mumbai: {
      url: MUMBAI_RPC_URL || "",
      accounts,
      chainId: 80001,
    },
  },

  paths: {
    sources: "./contracts",
    tests: "./tests",
    cache: "./cache",
    artifacts: "./artifacts",
  },

  mocha: {
    timeout: 40000,
  },
};
