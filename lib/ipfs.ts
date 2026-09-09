import { create, type IPFSHTTPClient } from 'ipfs-http-client';
import type { AddResult } from 'ipfs-http-client';

const IPFS_API_URL =
  process.env.IPFS_API_URL ?? 'http://localhost:5001';

const IPFS_GATEWAY =
  process.env.IPFS_GATEWAY_URL ?? 'https://ipfs.io/ipfs/';

let ipfsClient: IPFSHTTPClient | null = null;

/**
 * Initializes and returns the IPFS client.
 *
 * Uses a singleton instance so we don't create a new client
 * for every operation.
 */
export const initializeIPFS = (): IPFSHTTPClient => {
  if (ipfsClient) {
    return ipfsClient;
  }

  try {
    ipfsClient = create({
      url: IPFS_API_URL,
    });

    return ipfsClient;
  } catch (error) {
    ipfsClient = null;

    console.error('Failed to initialize IPFS client:', error);

    throw new Error(
      `IPFS initialization failed: ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
};

/**
 * Returns the initialized IPFS client.
 *
 * Automatically initializes the client if necessary.
 */
export const getIPFSClient = (): IPFSHTTPClient => {
  return ipfsClient ?? initializeIPFS();
};

/**
 * Uploads a file or buffer to IPFS.
 *
 * @returns The CID/path of the uploaded content.
 */
export const uploadToIPFS = async (
  file: File | Buffer
): Promise<string> => {
  try {
    const client = getIPFSClient();

    const content =
      typeof File !== 'undefined' && file instanceof File
        ? new Uint8Array(await file.arrayBuffer())
        : file;

    const result: AddResult = await client.add(content, {
      progress: (bytes) => {
        console.debug(`IPFS upload progress: ${bytes} bytes`);
      },
    });

    return result.cid.toString();
  } catch (error) {
    console.error('Failed to upload content to IPFS:', error);

    throw new Error(
      `IPFS upload failed: ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
};

/**
 * Retrieves content from IPFS.
 *
 * @returns The content as a Buffer.
 */
export const getFromIPFS = async (
  hash: string
): Promise<Buffer> => {
  if (!hash?.trim()) {
    throw new Error('IPFS hash is required');
  }

  try {
    const client = getIPFSClient();
    const chunks: Buffer[] = [];

    for await (const chunk of client.cat(hash)) {
      chunks.push(Buffer.from(chunk));
    }

    return Buffer.concat(chunks);
  } catch (error) {
    console.error(`Failed to retrieve IPFS content "${hash}":`, error);

    throw new Error(
      `Failed to retrieve IPFS content: ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
};

/**
 * Builds a public IPFS gateway URL for a CID/hash.
 */
export const getIPFSGatewayURL = (hash: string): string => {
  if (!hash?.trim()) {
    throw new Error('IPFS hash is required');
  }

  const gateway = IPFS_GATEWAY.endsWith('/')
    ? IPFS_GATEWAY
    : `${IPFS_GATEWAY}/`;

  return `${gateway}${encodeURIComponent(hash.trim())}`;
};

/**
 * Pins content to the local IPFS node.
 */
export const pinToIPFS = async (
  hash: string
): Promise<void> => {
  if (!hash?.trim()) {
    throw new Error('IPFS hash is required');
  }

  try {
    const client = getIPFSClient();

    await client.pin.add(hash.trim());
  } catch (error) {
    console.error(`Failed to pin IPFS content "${hash}":`, error);

    throw new Error(
      `IPFS pin failed: ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
};

/**
 * Removes a pin from the local IPFS node.
 */
export const unpinFromIPFS = async (
  hash: string
): Promise<void> => {
  if (!hash?.trim()) {
    throw new Error('IPFS hash is required');
  }

  try {
    const client = getIPFSClient();

    await client.pin.rm(hash.trim());
  } catch (error) {
    console.error(`Failed to unpin IPFS content "${hash}":`, error);

    throw new Error(
      `IPFS unpin failed: ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
};
