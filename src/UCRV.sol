// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "protocol/plugins/assets/AbstractCollateral.sol";
import "protocol/plugins/assets/OracleLib.sol";
import "protocol/libraries/Fixed.sol";
import "openzeppelin/utils/math/Math.sol";

/**
 * @title UCRV
 * @notice Collateral plugin for Llama Airforce's uCRV
 * {tok} = uCRV, {ref} = cvxCRV, {target} = CRV, {UoA} = USD
 */
contract UCRV is Collateral {
    using FixLib for uint192;
    using OracleLib for AggregatorV3Interface;

    AggregatorV3Interface public immutable targetUnitChainlinkFeed;
    uint192 public prevReferencePrice; // previous rate, {collateral/reference}
    address public immutable comptrollerAddr;
    address private constant uCRVAddr =
        "0x83507cc8C8B67Ed48BADD1F59F684D5d02884C81";

    int8 public immutable referenceERC20Decimals;

    constructor(
        uint192 fallbackPrice_,
        AggregatorV3Interface refUnitChainlinkFeed_,
        AggregatorV3Interface targetUnitUSDChainlinkFeed_,
        IERC20Metadata erc20_,
        IERC20Metadata rewardERC20_,
        uint192 maxTradeVolume_,
        uint48 oracleTimeout_,
        bytes32 targetName_,
        uint192 defaultThreshold_,
        uint256 delayUntilDefault_,
        int8 referenceERC20Decimals_,
        address comptrollerAddr_
    )
        Collateral(
            fallbackPrice_,
            refUnitChainlinkFeed_,
            erc20_,
            rewardERC20_,
            maxTradeVolume_,
            oracleTimeout_,
            targetName_,
            delayUntilDefault_
        )
    {
        require(defaultThreshold_ > 0, "defaultThreshold zero");
        require(
            address(targetUnitUSDChainlinkFeed_) != address(0),
            "missing target unit chainlink feed"
        );
        require(address(rewardERC20_) != address(0), "rewardERC20 missing");
        require(referenceERC20Decimals_ > 0, "referenceERC20Decimals missing");
        require(
            address(comptrollerAddr_) != address(0),
            "comptrollerAddr missing"
        );
        defaultThreshold = defaultThreshold_;
        targetUnitChainlinkFeed = targetUnitUSDChainlinkFeed_;
        referenceERC20Decimals = referenceERC20Decimals_;
        prevReferencePrice = refPerTok();
        comptrollerAddr = comptrollerAddr_;
    }

    function strictPrice() public view virtual override returns (uint192) {
        // {UoA/tok} = {UoA/target} * {target/ref} * {ref/tok}
        return
            targetUnitChainlinkFeed
                .price(oracleTimeout)
                .mul(chainlinkFeed.price(oracleTimeout))
                .mul(refPerTok());
    }

    // {ref/tok}
    function refPerTok() public view override returns (uint192) {
        // 1. Get totalSupply of uCRV
        // 2. (_shares * totalUnderlying) / totalSupply
        // _shares = 1e18???
        // totalUnderlying call uCRV contract
        // totalSupply call uCRV contract
    }
}
