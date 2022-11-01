pragma solidity ^0.8.13;

interface IExchangeRegistry {
    function get_exchange_amount(
        address,
        address,
        address,
        uint256
    ) external view returns (uint256);
}
