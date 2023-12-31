// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library MemoryLib {
    //** UINT256 */
    function push(uint256[] memory arr, uint256 value) public pure returns (uint256[] memory) {
        assembly {
            // where array is stored in memory (0x80)
            let location := arr
            // length of array is stored at arr
            let length := mload(arr)
            // gets next available memory location
            let nextMemoryLocation := add(add(location, 0x20), mul(length, 0x20))

            let freeMemoryPointer := mload(0x40)
            // advanced msize()
            let newMsize := add(freeMemoryPointer, 0x20)
            // checks if additional variables in memory
            if iszero(eq(freeMemoryPointer, nextMemoryLocation)) {
                let current
                let previous

                // creates space for a value by advancing the memory locations of other variables by 0x20 (32 bytes)
                for { let i := nextMemoryLocation } lt(i, newMsize) { i := add(i, 0x20) } {
                    current := mload(i)
                    mstore(i, previous)
                    previous := current
                }
            }
            // stores new value to memory
            mstore(nextMemoryLocation, value)
            // increment length by 1
            length := add(length, 0x1)
            // store new length value
            mstore(location, length)
            // update free memory pointer
            mstore(0x40, newMsize)
        }
        return arr;
    }

    // inserts element into array at index
    function insert(uint256[] memory arr, uint256 value, uint256 index) public pure returns (uint256[] memory) {
        assembly {
            // where array is stored in memory (0x80)
            let location := arr
            // length of array is stored at arr
            let length := mload(arr)
            // gets next available memory location
            let nextMemoryLocation := add(add(location, 0x20), mul(length, 0x20))

            let freeMemoryPointer := mload(0x40)
            // advance msize()
            let newMsize := add(freeMemoryPointer, 0x20)

            let targetLocation := add(add(location, 0x20), mul(index, 0x20))

            let current
            let previous

            // creates space for a value by advancing the memory locations of other variables by 0x20 (32 bytes)
            for { let i := targetLocation } lt(i, newMsize) { i := add(i, 0x20) } {
                current := mload(i)
                mstore(i, previous)
                previous := current
            }
            // stores new value to memory
            mstore(targetLocation, value)
            // increment length by 1
            length := add(length, 0x1)
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
            // length of array is stored at arr
            let length := mload(arr)

            let freeMemoryPointer := mload(0x40)

            let targetLocation := add(add(location, 0x20), mul(index, 0x20))

            for { let i := targetLocation } lt(i, freeMemoryPointer) { i := add(i, 0x20) } {
                let nextVal := mload(add(i, 0x20))
                mstore(i, nextVal)
            }
            // decrement length by 1
            length := sub(length, 0x1)
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
            // length of array is stored at arr
            let length := mload(arr)

            let freeMemoryPointer := mload(0x40)

            let targetLocation := add(add(location, 0x20), mul(length, 0x20))

            for { let i := targetLocation } lt(i, freeMemoryPointer) { i := add(i, 0x20) } {
                let nextVal := mload(add(i, 0x20))
                mstore(i, nextVal)
            }
            // decrement length by 1
            length := sub(length, 0x1)
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
            for { let backwardIdx := length } gt(backwardIdx, 0x0) { backwardIdx := sub(backwardIdx, 0x1) } {
                mstore(add(reversed, mul(add(forwardIdx, 0x1), 0x20)), mload(add(arr, mul(backwardIdx, 0x20))))
                forwardIdx := add(forwardIdx, 0x1)
            }
        }
        return reversed;
    }

    function concat(uint256[] memory from, uint256[] memory dest) public pure returns (uint256[] memory concated) {
        uint256 length = from.length + dest.length;
        concated = new uint256[](length);
        assembly {
            for { let i := 0 } lt(i, mload(from)) { i := add(i, 0x1) } {
                mstore(add(concated, mul(add(i, 0x1), 0x20)), mload(add(from, mul(add(i, 0x1), 0x20))))
            }
            for { let i := 0 } lt(i, mload(dest)) { i := add(i, 0x1) } {
                mstore(
                    add(concated, mul(add(add(i, mload(from)), 0x1), 0x20)), mload(add(dest, mul(add(i, 0x1), 0x20)))
                )
            }
        }
        return concated;
    }

    function include(uint256[] memory arr, uint256 value) public pure returns (bool included) {
        assembly {
            for { let i := 0 } lt(i, mload(arr)) { i := add(i, 0x1) } {
                included := eq(value, mload(add(arr, mul(add(i, 0x1), 0x20))))
                if iszero(iszero(included)) { break }
            }
        }
    }

    function getIdx(uint256[] memory arr, uint256 value) public pure returns (uint256 index) {
        assembly {
            index := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            for { let i := 0 } lt(i, mload(arr)) { i := add(i, 0x1) } {
                if eq(value, mload(add(arr, mul(add(i, 0x1), 0x20)))) {
                    index := i
                    break
                }
            }
        }
    }

    function bubbleSort(uint256[] memory arr) public pure {
        unchecked {
            uint256 len = arr.length;
            bool swapped;

            for (uint256 i = 0; i < len - 1; i++) {
                swapped = false;

                for (uint256 j = 0; j < len - i - 1; j++) {
                    if (arr[j] > arr[j + 1]) {
                        (arr[j], arr[j + 1]) = (arr[j + 1], arr[j]);
                        swapped = true;
                    }
                }

                if (!swapped) {
                    break;
                }
            }
        }
    }

    function insertionSort(uint256[] memory arr) public pure {
        unchecked {
            uint256 len = arr.length;

            for (uint256 i = 1; i < len; i++) {
                uint256 j = i;
                uint256 currentValue = arr[i];

                while (j > 0 && arr[j - 1] > currentValue) {
                    arr[j] = arr[j - 1];
                    j--;
                }

                arr[j] = currentValue;
            }
        }
    }

    function shellSort(uint256[] memory arr) internal pure {
        unchecked {
            uint256 len = arr.length;
            uint256 sublistcount = len / 2;

            while (sublistcount > 0) {
                for (uint256 start = 0; start < sublistcount; start++) {
                    for (uint256 i = start + sublistcount; i < len; i += sublistcount) {
                        uint256 currentValue = arr[i];
                        int256 position = int256(i);

                        while (
                            position >= int256(sublistcount)
                                && arr[uint256(position - int256(sublistcount))] > currentValue
                        ) {
                            arr[uint256(position)] = arr[uint256(position - int256(sublistcount))];
                            position -= int256(sublistcount);
                        }
                        arr[uint256(position)] = currentValue;
                    }
                }
                sublistcount /= 2;
            }
        }
    }

    function quickSort(uint256[] memory arr, int256 left, int256 right) public pure {
        unchecked {
            int256 i = left;
            int256 j = right;
            if (i == j) return;
            uint256 pivot = arr[uint256(left + (right - left) / 2)];

            while (i <= j) {
                while (arr[uint256(i)] < pivot) {
                    i++;
                }
                while (arr[uint256(j)] > pivot) {
                    j--;
                }
                if (i <= j) {
                    (arr[uint256(i)], arr[uint256(j)]) = (arr[uint256(j)], arr[uint256(i)]);
                    i++;
                    j--;
                }
            }
            if (left < j) {
                quickSort(arr, left, j);
            }
            if (i < right) {
                quickSort(arr, i, right);
            }
        }
    }

    //** BYTES32 */
    // allows user to push value to memory array
    function push(bytes32[] memory arr, bytes32 value) public pure returns (bytes32[] memory) {
        assembly {
            // where array is stored in memory (0x80)
            let location := arr
            // length of array is stored at arr
            let length := mload(arr)
            // gets next available memory location
            let nextMemoryLocation := add(add(location, 0x20), mul(length, 0x20))

            let freeMemoryPointer := mload(0x40)
            // advanced msize()
            let newMsize := add(freeMemoryPointer, 0x20)
            // checks if additional variables in memory
            if iszero(eq(freeMemoryPointer, nextMemoryLocation)) {
                let current
                let previous

                // creates space for a value by advancing the memory locations of other variables by 0x20 (32 bytes)
                for { let i := nextMemoryLocation } lt(i, newMsize) { i := add(i, 0x20) } {
                    current := mload(i)
                    mstore(i, previous)
                    previous := current
                }
            }
            // stores new value to memory
            mstore(nextMemoryLocation, value)
            // increment length by 1
            length := add(length, 0x1)
            // store new length value
            mstore(location, length)
            // update free memory pointer
            mstore(0x40, newMsize)
        }
        return arr;
    }

    // inserts element into array at index
    function insert(bytes32[] memory arr, bytes32 value, uint256 index) public pure returns (bytes32[] memory) {
        assembly {
            // where array is stored in memory (0x80)
            let location := arr
            // length of array is stored at arr
            let length := mload(arr)
            // gets next available memory location
            let nextMemoryLocation := add(add(location, 0x20), mul(length, 0x20))

            let freeMemoryPointer := mload(0x40)
            // advance msize()
            let newMsize := add(freeMemoryPointer, 0x20)

            let targetLocation := add(add(location, 0x20), mul(index, 0x20))

            let current
            let previous

            // creates space for a value by advancing the memory locations of other variables by 0x20 (32 bytes)
            for { let i := targetLocation } lt(i, newMsize) { i := add(i, 0x20) } {
                current := mload(i)
                mstore(i, previous)
                previous := current
            }
            // stores new value to memory
            mstore(targetLocation, value)
            // increment length by 1
            length := add(length, 0x1)
            // store new length value
            mstore(location, length)
            // update free memory pointer
            mstore(0x40, newMsize)
        }
        return arr;
    }

    // removes element from array at index
    function remove(bytes32[] memory arr, uint256 index) public pure returns (bytes32[] memory) {
        assembly {
            // where array is stored in memory (0x80)
            let location := arr
            // length of array is stored at arr
            let length := mload(arr)

            let freeMemoryPointer := mload(0x40)

            let targetLocation := add(add(location, 0x20), mul(index, 0x20))

            for { let i := targetLocation } lt(i, freeMemoryPointer) { i := add(i, 0x20) } {
                let nextVal := mload(add(i, 0x20))
                mstore(i, nextVal)
            }
            // decrement length by 1
            length := sub(length, 0x1)
            // store new length value
            mstore(location, length)
        }
        return arr;
    }

    // removes last element from array
    function pop(bytes32[] memory arr) public pure returns (bytes32[] memory) {
        assembly {
            // where array is stored in memory (0x80)
            let location := arr
            // length of array is stored at arr
            let length := mload(arr)

            let freeMemoryPointer := mload(0x40)

            let targetLocation := add(add(location, 0x20), mul(length, 0x20))

            for { let i := targetLocation } lt(i, freeMemoryPointer) { i := add(i, 0x20) } {
                let nextVal := mload(add(i, 0x20))
                mstore(i, nextVal)
            }
            // decrement length by 1
            length := sub(length, 0x1)
            // store new length value
            mstore(location, length)
        }
        return arr;
    }

    function reverse(bytes32[] memory arr) public pure returns (bytes32[] memory reversed) {
        uint256 length = arr.length;
        reversed = new bytes32[](length);
        assembly {
            let forwardIdx := 0x0
            for { let backwardIdx := length } gt(backwardIdx, 0x0) { backwardIdx := sub(backwardIdx, 0x1) } {
                mstore(add(reversed, mul(add(forwardIdx, 0x1), 0x20)), mload(add(arr, mul(backwardIdx, 0x20))))
                forwardIdx := add(forwardIdx, 0x1)
            }
        }
        return reversed;
    }

    function concat(bytes32[] memory from, bytes32[] memory dest) public pure returns (bytes32[] memory concated) {
        uint256 length = from.length + dest.length;
        concated = new bytes32[](length);
        assembly {
            for { let i := 0 } lt(i, mload(from)) { i := add(i, 0x1) } {
                mstore(add(concated, mul(add(i, 0x1), 0x20)), mload(add(from, mul(add(i, 0x1), 0x20))))
            }
            for { let i := 0 } lt(i, mload(dest)) { i := add(i, 0x1) } {
                mstore(
                    add(concated, mul(add(add(i, mload(from)), 0x1), 0x20)), mload(add(dest, mul(add(i, 0x1), 0x20)))
                )
            }
        }
        return concated;
    }

    function include(bytes32[] memory arr, bytes32 value) public pure returns (bool included) {
        assembly {
            for { let i := 0 } lt(i, mload(arr)) { i := add(i, 0x1) } {
                included := eq(value, mload(add(arr, mul(add(i, 0x1), 0x20))))
                if iszero(iszero(included)) { break }
            }
        }
    }

    function getIdx(bytes32[] memory arr, bytes32 value) public pure returns (uint256 index) {
        assembly {
            index := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            for { let i := 0 } lt(i, mload(arr)) { i := add(i, 0x1) } {
                if eq(value, mload(add(arr, mul(add(i, 0x1), 0x20)))) {
                    index := i
                    break
                }
            }
        }
    }

    //** ADDRESS */
    // TODO: Address, Bytes, String
}
