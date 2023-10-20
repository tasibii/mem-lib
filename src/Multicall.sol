// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract Multicall is Initializable, OwnableUpgradeable {
    using Address for address;
    /// @custom:oz-upgrades-unsafe-allow constructor

    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __Ownable_init_unchained(initialOwner);
    }

    function multicall(address target, bytes[] calldata data) public onlyOwner returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = target.functionCall(data[i]);
        }
        return results;
    }
}

