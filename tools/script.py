import numpy as np

class BloomFilterScript:
    def __init__(self, size_bits=131072):
        # Size in bits must match the GPU bitmask configuration
        self.size_bits = size_bits
        self.size_words = size_bits // 32
        # Initialize 32-bit word array (equivalent to threadgroup seen buffer)
        self.bit_array = np.zeros(self.size_words, dtype=np.uint32)

    def add_key(self, key: int):
        """Simulates adding a key to the Bloom filter bitset."""
        hash_val = (key * 0x9E3779B1) & 0xFFFFFFFF
        bit_index = hash_val % self.size_bits
        
        word_idx = bit_index >> 5           # Equivalent to bit_index / 32
        bit_mask = 1 << (bit_index & 31)    # Equivalent to bit_index % 32
        
        self.bit_array[word_idx] |= bit_mask

    def save_to_file(self, filename="script.bf"):
        """Serializes the bit array into a compact .bf binary file."""
        with open(filename, "wb") as f:
            f.write(self.bit_array.tobytes())
        print(f"Successfully saved Bloom filter to {filename} ({self.bit_array.nbytes} bytes)")

    def load_from_file(self, filename="script.bf"):
        """Loads a .bf binary file to be mapped directly to a GPU buffer."""
        with open(filename, "rb") as f:
            data = f.read()
        self.bit_array = np.frombuffer(data, dtype=np.uint32)
        print(f"Loaded {filename} into memory. Ready for GPU buffer binding.")

# --- Execution Example ---
if __name__ == "__main__":
    # Initialize a 128k-bit filter
    bf = BloomFilterScript(size_bits=131072)
    
    # Add some sample keys/nodes
    bf.add_key(42)
    bf.add_key(1034)
    bf.add_key(9999)
    
    # Export as script.bf
    bf.save_to_file("script.bf")
