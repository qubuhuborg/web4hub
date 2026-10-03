#!/usr/bin/env python3
"""
script.bf - Advanced High-Performance Bloom Filter & Bitmask Manager
Upgraded with double-hashing (multiple hash functions), structured headers,
fill-ratio monitoring, and filter merging capabilities.
"""

import numpy as np
import os
import struct

MAGIC_HEADER = b"BFIL"  # Bloom Filter Identifier
VERSION = 1

class ScriptBF:
    def __init__(self, size_bits: int = 131072, num_hashes: int = 3):
        """
        Initializes the upgraded Bloom Filter bitmask array.
        :param size_bits: Total number of bits in the filter (aligned to 32-bit words).
        :param num_hashes: Number of hash functions to use per key (default: 3).
        """
        if size_bits % 32 != 0:
            size_bits = ((size_bits + 31) // 32) * 32
            
        self.size_bits = size_bits
        self.size_words = size_bits // 32
        self.num_hashes = num_hashes
        self.bit_array = np.zeros(self.size_words, dtype=np.uint32)

    def _get_hash_pair(self, key: int) -> tuple:
        """Generates two independent hash values for double hashing."""
        h1 = (key * 0x9E3779B1) & 0xFFFFFFFF
        h2 = (key * 0x85EBCA77 + 0xC2B2AE35) & 0xFFFFFFFF
        return h1, h2

    def _get_bit_indices(self, key: int) -> list:
        """Computes k bit positions using Kirsch-Mitzenmacher double hashing."""
        h1, h2 = self._get_hash_pair(key)
        indices = []
        for i in range(self.num_hashes):
            combined = (h1 + i * h2) % self.size_bits
            indices.append(combined)
        return indices

    def add(self, key: int) -> None:
        """Adds a key or node index to the filter across all hash lanes."""
        for bit_index in self._get_bit_indices(key):
            word_idx = bit_index >> 5           # Bit index / 32
            bit_mask = 1 << (bit_index & 31)    # Bit index % 32
            self.bit_array[word_idx] |= bit_mask

    def contains(self, key: int) -> bool:
        """Tests if a key exists. Returns False if definitely missing, True if likely present."""
        for bit_index in self._get_bit_indices(key):
            word_idx = bit_index >> 5
            bit_mask = 1 << (bit_index & 31)
            if (self.bit_array[word_idx] & bit_mask) == 0:
                return False
        return True

    def fill_ratio(self) -> float:
        """Calculates the percentage of set bits (saturation level)."""
        # Count total set bits across all 32-bit words
        set_bits = sum(bin(word).count('1') for word in self.bit_array)
        return set_bits / self.size_bits

    def merge(self, other: 'ScriptBF') -> None:
        """Performs a bitwise OR merge with another Bloom filter of equal size."""
        if self.size_bits != other.size_bits:
            raise ValueError("Cannot merge filters with differing bit sizes.")
        self.bit_array |= other.bit_array

    def save(self, filepath: str = "script.bf") -> None:
        """Serializes the filter with a structured header and bit array."""
        header = struct.pack("<4sIIII", MAGIC_HEADER, VERSION, self.size_bits, self.num_hashes, self.size_words)
        with open(filepath, "wb") as f:
            f.write(header)
            f.write(self.bit_array.tobytes())
        print(f"[script.bf] Saved structured filter ({self.bit_array.nbytes} bytes data) to {filepath}")

    def load(self, filepath: str = "script.bf") -> None:
        """Loads and validates a structured .bf file from disk."""
        if not os.path.exists(filepath):
            raise FileNotFoundError(f"Target file {filepath} not found.")
            
        header_size = struct.calcsize("<4sIIII")
        with open(filepath, "rb") as f:
            header_data = f.read(header_size)
            magic, version, size_bits, num_hashes, size_words = struct.unpack("<4sIIII", header_data)
            
            if magic != MAGIC_HEADER:
                raise ValueError("Invalid file format: Missing BFIL magic header.")
                
            self.size_bits = size_bits
            self.num_hashes = num_hashes
            self.size_words = size_words
            
            data = f.read()
            self.bit_array = np.frombuffer(data, dtype=np.uint32)
            
        print(f"[script.bf] Successfully loaded {filepath} (Bits: {self.size_bits}, Hashes: {self.num_hashes})")

    def get_gpu_buffer_pointer(self):
        """Returns the raw memory pointer for binding directly to Metal/GPU buffers."""
        return self.bit_array.ctypes.data

# --- Execution & Verification ---
if __name__ == "__main__":
    # Initialize with 256k bits and 4 hash functions
    bf = ScriptBF(size_bits=262144, num_hashes=4)
    
    # Add items
    sample_nodes = [1042, 5821, 99993, 12, 42]
    for node in sample_nodes:
        bf.add(node)
        
    # Check saturation
    print(f"Filter Fill Ratio: {bf.fill_ratio() * 100:.2f}%")
    
    # Save to disk
    bf.save("script.bf")
    
    # Test loading back
    loaded_bf = ScriptBF()
    loaded_bf.load("script.bf")
    
    print(f"Contains node 42? {loaded_bf.contains(42)}")     # True
    print(f"Contains node 888? {loaded_bf.contains(888)}")   # False
