/*
 * Curio StableCoin System
 *
 * Copyright ©️ 2021 Curio AG (Company Number FL-0002.594.728-9)
 * Incorporated and registered in Liechtenstein.
 *
 * Copyright ©️ 2021 Curio Capital AG (Company Number CHE-211.446.654)
 * Incorporated and registered in Zug, Switzerland.
 */
// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

// local imports
// import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

// github imports
import "https://github.com/smartcontractkit/chainlink/evm-contracts/src/v0.6/ChainlinkClient.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.3/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.3/contracts/token/ERC20/SafeERC20.sol";

/** 
 *  Ferrari F12 TDF price oracle
 */
contract ChainlinkPriceOracle is Ownable, ChainlinkClient {
    using SafeERC20 for IERC20;

    string public constant ORACLE_NAME = "Ferrari F12 TDF price oracle";

    address public oracle;
    bytes32 public jobId;
    uint256 public fee;

    struct PriceData {
        uint128 latestPrice;
        uint32 priceUpdateTime; // timestamp
    }
    PriceData public priceData;

    mapping(address => bool) public admins;

    event FulfilledPrice(bytes32 requestId, uint128 price, uint32 timestamp);

    event SetOracle(address oracle);
    event SetJobId(bytes32 jobId);
    event SetFee(uint256 fee);
    event SetAdminStatus(address admin, bool status);

    modifier onlyAdmin() {
        require(admins[msg.sender], "Caller is not the admin");
        _;
    }

    constructor() public {
    	setPublicChainlinkToken();

        // KOVAN SETTINGS
    	oracle = 0x56dd6586DB0D08c6Ce7B2f2805af28616E082455; // oracle address
    	jobId = "dbd8725401c9456f8b55522f861a88c8"; // job id - Ferrari F12 TDF price - Zero Fault
    	fee = 0.1 * 10 ** 18; // 0.1 LINK

        admins[msg.sender] = true;
    }


    function latestPrice() external view returns (uint256) {
        return priceData.latestPrice;
    }

    function priceUpdateTime() external view returns (uint256) {
        return priceData.priceUpdateTime;
    }

    // current version compatibility
    function latestAnswer() external view returns (int256) {
        return int256(priceData.latestPrice);
    }


    // onlyAdmin function
    function requestPrice() external onlyAdmin returns (bytes32 requestId) {
    	Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfillPrice.selector);
    	return sendChainlinkRequestTo(oracle, req, fee);
    }
    
    // callback oracle function
    function fulfillPrice(bytes32 _requestId, uint256 _price) external recordChainlinkFulfillment(_requestId) {
        uint32 curTimestamp = uint32(block.timestamp);
    	priceData.latestPrice = uint128(_price);
        priceData.priceUpdateTime = curTimestamp;
        emit FulfilledPrice(_requestId, uint128(_price), curTimestamp);
    }


    // onlyOwner functions

    function setOracle(address _oracle) external onlyOwner {
        oracle = _oracle;
        emit SetOracle(_oracle);
    }

    function setJobId(bytes32 _jobId) external onlyOwner {
        jobId = _jobId;
        emit SetJobId(_jobId);
    }

    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
        emit SetFee(_fee);
    }

    function setAdminStatus(address _admin, bool _status) external onlyOwner {
        admins[_admin] = _status;
        emit SetAdminStatus(_admin, _status);
    }

    function withdrawTokens(IERC20 _token, uint256 _amount) external onlyOwner {
        _token.safeTransfer(owner(), _amount);
    }
}