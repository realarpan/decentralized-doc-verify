import {
  BrowserProvider,
  JsonRpcSigner,
  formatEther,
  parseEther,
  isAddress,
  getAddress,
} from 'ethers';

interface EthereumProvider {
  request: (args: {
    method: string;
    params?: unknown[];
  }) => Promise<unknown>;
}

declare global {
  interface Window {
    ethereum?: EthereumProvider;
  }
}

let provider: BrowserProvider | null = null;
let signer: JsonRpcSigner | null = null;

/**
 * Returns the injected Ethereum provider (MetaMask, Coinbase Wallet, etc.).
 */
const getEthereumProvider = (): EthereumProvider => {
  if (typeof window === 'undefined' || !window.ethereum) {
    throw new Error(
      'No Ethereum wallet detected. Please install MetaMask or another compatible wallet.'
    );
  }

  return window.ethereum;
};

/**
 * Initializes the ethers provider.
 *
 * Does not request wallet access automatically.
 */
export const initializeWeb3 = async (): Promise<boolean> => {
  try {
    const ethereum = getEthereumProvider();

    provider = new BrowserProvider(ethereum);

    // Only obtain the signer if the wallet is already connected.
    const accounts = (await ethereum.request({
      method: 'eth_accounts',
    })) as string[];

    if (accounts.length > 0) {
      signer = await provider.getSigner();
    }

    return true;
  } catch (error) {
    provider = null;
    signer = null;

    console.error('Web3 initialization failed:', error);

    throw new Error(
      `Web3 initialization failed: ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
};

/**
 * Ensures that the provider has been initialized.
 */
const getInitializedProvider = (): BrowserProvider => {
  if (!provider) {
    if (typeof window === 'undefined' || !window.ethereum) {
      throw new Error(
        'No Ethereum wallet detected. Please install MetaMask or another compatible wallet.'
      );
    }

    provider = new BrowserProvider(window.ethereum);
  }

  return provider;
};

/**
 * Connects the user's wallet and returns the selected address.
 */
export const connectWallet = async (): Promise<string> => {
  try {
    const ethereum = getEthereumProvider();

    const accounts = (await ethereum.request({
      method: 'eth_requestAccounts',
    })) as string[];

    if (!accounts.length) {
      throw new Error('No wallet account was returned.');
    }

    const walletProvider = getInitializedProvider();

    signer = await walletProvider.getSigner();

    return getAddress(accounts[0]);
  } catch (error) {
    console.error('Wallet connection failed:', error);

    throw new Error(
      `Wallet connection failed: ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
};

/**
 * Gets the currently connected wallet address.
 *
 * Returns null when no account is connected.
 */
export const getCurrentAccount = async (): Promise<string | null> => {
  try {
    const ethereum = getEthereumProvider();

    const accounts = (await ethereum.request({
      method: 'eth_accounts',
    })) as string[];

    return accounts.length > 0
      ? getAddress(accounts[0])
      : null;
  } catch (error) {
    console.error('Failed to get current account:', error);

    throw new Error(
      `Failed to get current account: ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
};

/**
 * Gets the current EVM chain/network ID.
 *
 * Example:
 * Ethereum Mainnet = 1
 * Polygon = 137
 * Sepolia = 11155111
 */
export const getNetworkId = async (): Promise<bigint> => {
  const walletProvider = getInitializedProvider();
  const network = await walletProvider.getNetwork();

  return network.chainId;
};

/**
 * Gets the native token balance of an address.
 *
 * Returns the balance formatted in ETH/native-token units.
 */
export const getBalance = async (
  address: string
): Promise<string> => {
  if (!isAddress(address)) {
    throw new Error(`Invalid Ethereum address: ${address}`);
  }

  try {
    const walletProvider = getInitializedProvider();
    const balance = await walletProvider.getBalance(address);

    return formatEther(balance);
  } catch (error) {
    console.error(`Failed to get balance for ${address}:`, error);

    throw new Error(
      `Failed to get wallet balance: ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
};

/**
 * Sends a native-token transaction.
 *
 * @param to Recipient address
 * @param value Amount in ETH/native token units
 */
export const sendTransaction = async (
  to: string,
  value: string
) => {
  if (!isAddress(to)) {
    throw new Error(`Invalid recipient address: ${to}`);
  }

  if (!value || Number.isNaN(Number(value)) || Number(value) < 0) {
    throw new Error(`Invalid transaction value: ${value}`);
  }

  try {
    if (!signer) {
      await connectWallet();
    }

    if (!signer) {
      throw new Error('Wallet signer is not available.');
    }

    const transaction = await signer.sendTransaction({
      to: getAddress(to),
      value: parseEther(value),
    });

    console.info(
      `Transaction submitted: ${transaction.hash}`
    );

    const receipt = await transaction.wait();

    if (!receipt) {
      throw new Error(
        `Transaction ${transaction.hash} was not confirmed.`
      );
    }

    return receipt;
  } catch (error) {
    console.error('Transaction failed:', error);

    throw new Error(
      `Transaction failed: ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
};

/**
 * Returns the connected wallet signer.
 *
 * Throws if no wallet is connected.
 */
export const getSigner = (): JsonRpcSigner => {
  if (!signer) {
    throw new Error(
      'Wallet is not connected. Call connectWallet() first.'
    );
  }

  return signer;
};

/**
 * Returns the ethers BrowserProvider.
 */
export const getProvider = (): BrowserProvider => {
  return getInitializedProvider();
};
