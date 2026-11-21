import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { crc32 } from 'node:zlib';

const pngSignature = Buffer.from('89504e470d0a1a0a', 'hex');
const maxBytes = 1024 * 1024;
const maxDimension = 1024;

function validatePng(bytes: Buffer): void {
  if (bytes.length > maxBytes) {
    throw new Error('entry.png exceeds the 1 MiB limit');
  }
  if (!bytes.subarray(0, pngSignature.length).equals(pngSignature)) {
    throw new Error('entry.png has an invalid PNG signature');
  }
  if (bytes.length < 33 || bytes.readUInt32BE(8) !== 13 ||
      bytes.toString('ascii', 12, 16) !== 'IHDR') {
    throw new Error('entry.png is missing a complete IHDR chunk');
  }

  const width = bytes.readUInt32BE(16);
  const height = bytes.readUInt32BE(20);
  if (width < 1 || height < 1 || width > maxDimension || height > maxDimension) {
    throw new Error('entry.png dimensions must be between 1 and 1024 pixels');
  }

  let hasImageData = false;
  for (let offset = pngSignature.length; offset + 12 <= bytes.length;) {
    const length = bytes.readUInt32BE(offset);
    const dataEnd = offset + 8 + length;
    const chunkEnd = dataEnd + 4;
    if (chunkEnd > bytes.length) {
      throw new Error('entry.png contains a truncated PNG chunk');
    }

    const type = bytes.toString('latin1', offset + 4, offset + 8);
    if (type === 'IHDR' && offset !== pngSignature.length) {
      throw new Error('entry.png contains a duplicate IHDR chunk');
    }
    if (crc32(bytes.subarray(offset + 4, dataEnd)) !== bytes.readUInt32BE(dataEnd)) {
      throw new Error('entry.png contains a PNG chunk with an invalid checksum');
    }
    if (type === 'IDAT' && length > 0) hasImageData = true;
    if (type === 'IEND') {
      if (length !== 0 || chunkEnd !== bytes.length || !hasImageData) {
        throw new Error('entry.png is missing image data or a valid final IEND chunk');
      }
      return;
    }
    offset = chunkEnd;
  }
  throw new Error('entry.png is missing image data or a valid final IEND chunk');
}

const output = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';
const bytes = readFileSync(new URL('./entry.png', import.meta.url));
validatePng(bytes);
mkdirSync(output, { recursive: true });
writeFileSync(join(output, 'entry.png'), bytes);
