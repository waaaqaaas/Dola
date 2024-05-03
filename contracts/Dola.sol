// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(
        uint80 _roundId
    )
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract DOLA {
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    uint256 public exchangeRate;
    uint256 public collateralRatio;
    IERC20 public bdolaTokenAddress;
    address public owner;
    // Address of the Chainlink oracle for ROI price data
    // address public oracleAddress;

    event Mint(address indexed to, uint256 amount);
    event Redeem(address indexed from, uint256 amount);
    event ExchangeRateUpdated(uint256 newRate);
    event BDOLATransferFailed(address from, uint256 amount);
    event DOLATransferFailed(address to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(IERC20 _bdolaTokenAddress) {
        exchangeRate = 1;
        collateralRatio = 1;
        bdolaTokenAddress = _bdolaTokenAddress;
        owner = msg.sender;
        // oracleAddress = 0xE4eE17114774713d2De0eC0f035d4F7665fc025D; //binance smart chain testnet
    }

    function mint(uint256 _amount) external {
        require(_amount > 0, "Mint amount must be greater than zero");
        require(
            bdolaTokenAddress.transferFrom(msg.sender, address(this), _amount),
            "BDOLA transfer failed"
        );

        balanceOf[msg.sender] += _amount;
        totalSupply += _amount;

        emit Mint(msg.sender, _amount);
    }

    function redeem(uint256 _amount) external {
        require(_amount > 0, "Redeem amount must be greater than zero");
        require(balanceOf[msg.sender] >= _amount, "Insufficient DOLA balance");
        // Get current ROI price from Chainlink oracle
        // uint256 roiPrice = getROIPrice();
        uint256 roiPrice = 99990200; // Simulated ROI price
        require(roiPrice > 0, "Invalid ROI price");

        uint256 redeemableCollateral = (_amount * collateralRatio * (10 ** 8)) /
            (exchangeRate * roiPrice);

        require(
            bdolaTokenAddress.transfer(msg.sender, redeemableCollateral),
            "DOLA transfer failed"
        );

        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;

        emit Redeem(msg.sender, _amount);
    }
    // // Function to get ROI price from Chainlink oracle
    // function getROIPrice() public view returns (uint256) {
    //     AggregatorV3Interface priceFeed = AggregatorV3Interface(oracleAddress);
    //     (, int256 answer, , , ) = priceFeed.latestRoundData();
    //     // Handle potential oracle errors
    //     if (answer <= 0) {
    //         return 0;
    //     }
    //     return uint256(answer);
    // }

    function updateExchangeRate(uint256 _newRate) external onlyOwner {
        exchangeRate = _newRate;
        emit ExchangeRateUpdated(_newRate);
    }
}
