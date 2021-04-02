// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.2;

interface EACAggregatorProxy {
    function latestAnswer() external view returns (int256);
}

contract OracleProxy {
    EACAggregatorProxy immutable source;

    constructor(address _source) {
        source = EACAggregatorProxy(_source);
    }

    function peek() external view returns (bytes32 wut, bool ok) {
        int256 latestAnswer = source.latestAnswer();
        if (latestAnswer > 0) {
            uint256 answer = uint256(bytes32(latestAnswer));
            return (bytes32(answer * 1e10 / 1100000), true);
        } else {
            return (0, false);
        }
    }
}
