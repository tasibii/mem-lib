// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import { Test, console2 } from "forge-std/Test.sol";
import { Uint256ArrayLib } from "src/Uint256ArrayLib.sol";

contract Uint256ArrayLibTest is Test {
    uint256 nonce = 0;
    uint256[] public expect;

    function setUpData() public returns (uint256[] memory) {
        uint256 length = _rand();
        uint256[] memory data = new uint256[](length);
        for (uint256 i; i < length;) {
            data[i] = _rand();

            unchecked {
                ++i;
            }
        }
        return data;
    }

    function testPush() public {
        uint256 pushValue = _rand();
        uint256[] memory arr = setUpData();
        _assignStorage(arr, 1, pushValue);

        uint256[] memory newArr = Uint256ArrayLib.push(arr, pushValue);

        assertEq(newArr.length, expect.length);
        assertEq(newArr, expect);
    }

    function testPop() public {
        uint256[] memory arr = setUpData();
        _assignStorage(arr, 2, 0);

        uint256[] memory newArr = Uint256ArrayLib.pop(arr);

        assertEq(newArr.length, expect.length);
        assertEq(newArr, expect);
    }

    function testInsert() public {
        uint256[] memory arr = setUpData();
        uint256[] memory newArr = Uint256ArrayLib.insert(arr, 1_000_000_000, 3);

        assertEq(newArr.length, arr.length + 1);
        assertEq(newArr[3], 1_000_000_000);
    }

    function testRemove() public {
        uint256[] memory arr = setUpData();
        _assignStorage(arr, 3, 3);

        uint256[] memory newArr = Uint256ArrayLib.remove(arr, 3);

        assertEq(newArr.length, arr.length - 1);
        // delete in solid is set to 0
        assertEq(expect[3], 0);
    }

    function testReverse() public {
        uint256[] memory arr = setUpData();
        uint256[] memory newArr = Uint256ArrayLib.reverse(arr);

        assertEq(newArr.length, arr.length);
    }

    function _assignStorage(uint256[] memory arr, uint8 option, uint256 value) internal {
        uint256 length = arr.length;

        for (uint256 i = 0; i < length;) {
            expect.push(arr[i]);
            unchecked {
                ++i;
            }
        }

        if (option == 1) {
            expect.push(value);
        } else if (option == 2) {
            expect.pop();
        } else if (option == 3) {
            delete expect[value];
        }
    }

    function _rand() internal returns (uint256) {
        nonce += 1;
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 100;
    }
}
