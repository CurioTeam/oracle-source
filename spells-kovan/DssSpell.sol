// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.5.12;

interface DSPauseAbstract {
    function setOwner(address) external;
    function setAuthority(address) external;
    function setDelay(uint256) external;
    function plans(bytes32) external view returns (bool);
    function proxy() external view returns (address);
    function delay() external view returns (uint256);
    function plot(address, bytes32, bytes calldata, uint256) external;
    function drop(address, bytes32, bytes calldata, uint256) external;
    function exec(address, bytes32, bytes calldata, uint256) external returns (bytes memory);
}

interface SpotAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function ilks(bytes32) external view returns (address, uint256);
    function vat() external view returns (address);
    function par() external view returns (uint256);
    function live() external view returns (uint256);
    function file(bytes32, bytes32, address) external;
    function file(bytes32, uint256) external;
    function file(bytes32, bytes32, uint256) external;
    function poke(bytes32) external;
    function cage() external;
}

contract SpellAction {
    // KOVAN ADDRESSES
    address constant PIP_MANA        = 0x54D2c91277Bb11Ecfd914C235cC6Ab5914c96204;
    address constant MCD_SPOT        = 0x8B9656AfBAC4528160673852Ae4656FdabB2246f;

    function execute() external {

        /************************************/
        /*** CT1 COLLATERAL PRICE SOURCE CHANGE ***/
        /************************************/
        // Set ilk bytes32 variable
        bytes32 ilk = "MANA-A";

        // Set the COMP PIP in the Spotter
        SpotAbstract(MCD_SPOT).file(ilk, "pip", PIP_MANA);

        // Update CT1 spot value in Vat
        SpotAbstract(MCD_SPOT).poke(ilk);
    }
}

contract DssSpell {
    DSPauseAbstract public pause =
    DSPauseAbstract(0x9700b2171c517Bd772546372D53D66F2Ff937003);
    address         public action;
    bytes32         public tag;
    uint256         public eta;
    bytes           public sig;
    uint256         public expiration;
    bool            public done;

    string constant public description = "Use custom oracle for CT1";

    constructor() public {
        sig = abi.encodeWithSignature("execute()");
        action = address(new SpellAction());
        bytes32 _tag;
        address _action = action;
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
        expiration = now + 30 days;
    }

    function schedule() public {
        require(now <= expiration, "This contract has expired");
        require(eta == 0, "This spell has already been scheduled");
        eta = now + DSPauseAbstract(pause).delay();
        pause.plot(action, tag, sig, eta);
    }

    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}

interface Vote {
    function vote(address[] calldata yays) external;
    function lift(address a) external;
    function lock(uint256 _amount) external;
}