#include <metal_stdlib>
using namespace metal;

struct MemoryConfig {
    uint capacity;     // Total slots in the hash table
    uint key_dim;      // Dimension/size of the keys
};

// Concurrent Hash Map Insertion for AI Memory
kernel void store_memory_keys(
    constant MemoryConfig& config [[buffer(0)]],
    device const uint* incoming_keys [[buffer(1)]],
    device atomic_uint* hash_table_keys [[buffer(2)]],
    device uint* hash_table_values [[buffer(3)]],
    uint gid [[thread_position_in_grid]]
) {
    if (gid >= config.capacity) return;

    uint key = incoming_keys[gid];
    uint slot = (key * 0x9E3779B1u) & (config.capacity - 1u);

    // Linear probing with atomic compare-and-swap
    while (true) {
        uint expected = 0xFFFFFFFFu; // Empty sentinel
        if (atomic_compare_exchange_weak_explicit(
            &hash_table_keys[slot], 
            &expected, 
            key, 
            memory_order_relaxed, 
            memory_order_relaxed
        )) {
            // Successfully claimed slot, store associated value/index
            hash_table_values[slot] = gid;
            break;
        }
        // If slot already contains this key, update and exit
        if (expected == key) {
            hash_table_values[slot] = gid;
            break;
        }
        // Otherwise, probe next slot
        slot = (slot + 1u) & (config.capacity - 1u);
    }
}

