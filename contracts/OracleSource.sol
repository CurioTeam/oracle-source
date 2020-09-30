pragma solidity ^0.7.2;

interface EACAggregatorProxy {
    function latestAnswer() external view returns (int256);
}

contract OracleSource {
    EACAggregatorProxy immutable source;
    
    constructor(address _source) {
        source = EACAggregatorProxy(_source);
    }
    
    function pick() external view returns (bytes32 wut, bool ok) {
        int256 latestAnswer = source.latestAnswer();
        if (latestAnswer > 0) {
            return (bytes32(latestAnswer), true);
        } else {
            return (0, false);
        }
    }
}
