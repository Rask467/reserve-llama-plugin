pragma solidity ^0.8.13;

interface ICryptoPool {
    function get_dy_underlying(
        uint256,
        uint256,
        uint256
    ) external view returns (uint256);
}
