// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library Uint256ArrayLib {
    function push(uint256[] memory arr, uint256 value) public pure returns (uint256[] memory) {
        assembly {
            // where array is stored in memory (0x80)
            let location := arr
            // length of array is stored at arr (4)
            let length := mload(arr)
            // gets next available memory location
            let nextMemoryLocation := add(add(location, 0x20), mul(length, 0x20))

            let freeMemoryPointer := mload(0x40)
            // advanced msize()
            let newMsize := add(freeMemoryPointer, 0x20)
            // checks if additional varibales in memory
            if iszero(eq(freeMemoryPointer, nextMemoryLocation)) {
                let current
                let previous

                // makes room for _newVal by advacning other memory variables locations by 0x20 (32 bytes)
                for { let i := nextMemoryLocation } lt(i, newMsize) { i := add(i, 0x20) } {
                    current := mload(i)
                    mstore(i, previous)
                    previous := current
                }
            }
            // stores new value to memory
            mstore(nextMemoryLocation, value)
            // increment length by 1
            length := add(length, 1)
            // store new length value
            mstore(location, length)
            // update free memory pointer
            mstore(0x40, newMsize)
        }
        return arr;
    }

    // inserts element into array at index
    function insert(uint256[] memory arr, uint256 newVal, uint256 index) public pure returns (uint256[] memory) {
        assembly {
            // where array is stored in memory (0x80)
            let location := arr
            // length of array is stored at arr (4)
            let length := mload(arr)
            // gets next available memory location
            let nextMemoryLocation := add(add(location, 0x20), mul(length, 0x20))

            let freeMemoryPointer := mload(0x40)
            // advance msize()
            let newMsize := add(freeMemoryPointer, 0x20)

            let targetLocation := add(add(location, 0x20), mul(index, 0x20))

            let current
            let previous

            for { let i := targetLocation } lt(i, newMsize) { i := add(i, 0x20) } {
                current := mload(i)
                mstore(i, previous)
                previous := current
            }
            // stores new value to memory
            mstore(targetLocation, newVal)
            // increment length by 1
            length := add(length, 1)
            // store new length value
            mstore(location, length)
            // update free memory pointer
            mstore(0x40, newMsize)
        }
        return arr;
    }

    // removes element from array at index
    function remove(uint256[] memory arr, uint256 index) public pure returns (uint256[] memory) {
        assembly {
            // where array is stored in memory (0x80)
            let location := arr
            // length of array is stored at arr (4)
            let length := mload(arr)

            let freeMemoryPointer := mload(0x40)

            let targetLocation := add(add(location, 0x20), mul(index, 0x20))

            for { let i := targetLocation } lt(i, freeMemoryPointer) { i := add(i, 0x20) } {
                let nextVal := mload(add(i, 0x20))
                mstore(i, nextVal)
            }
            // decrement length by 1
            length := sub(length, 1)
            // store new length value
            mstore(location, length)
        }
        return arr;
    }

    // removes last element from array
    function pop(uint256[] memory arr) public pure returns (uint256[] memory) {
        assembly {
            // where array is stored in memory (0x80)
            let location := arr
            // length of array is stored at arr (4)
            let length := mload(arr)

            let freeMemoryPointer := mload(0x40)

            let targetLocation := add(add(location, 0x20), mul(length, 0x20))

            for { let i := targetLocation } lt(i, freeMemoryPointer) { i := add(i, 0x20) } {
                let nextVal := mload(add(i, 0x20))
                mstore(i, nextVal)
            }
            // decrement length by 1
            length := sub(length, 1)
            // store new length value
            mstore(location, length)
        }
        return arr;
    }

    function reverse(uint256[] memory arr) public pure returns (uint256[] memory reversed) {
        uint256 length = arr.length;
        reversed = new uint256[](length);
        assembly {
            let forwardIdx := 0x0
            for { let backwardIdx := length } gt(backwardIdx, 0x0) { backwardIdx := sub(backwardIdx, 0x01) } {
                mstore(add(reversed, mul(add(forwardIdx, 0x1), 0x20)), mload(add(arr, mul(backwardIdx, 0x20))))
                forwardIdx := add(forwardIdx, 0x1)
            }
        }
        return reversed;
    }
}
