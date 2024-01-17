// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title oracleLib
 * @author Patrick collins
 * @notice This library is used to check chainlink oracle for state data
 * If a price is stale, then function will revert, and render the DSCEngine unusable - this is by design
 * We want the DSCEngine to freeze if prices become stale
 * so if chainlink network explodes and you have a lot of money lock in the protocol...
 */
library OracleLib {
    uint256 private constant TIMEOUT = 3 hours;

    error OracleLib__StalePrice();

    function staleCheckLatestRoundData(AggregatorV3Interface priceFeed)
        public
        view
        returns (uint80, int256, uint256, uint256, uint80)
    {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            priceFeed.latestRoundData();

        uint256 secondsSince = block.timestamp - updatedAt;
        if (secondsSince > TIMEOUT) revert OracleLib__StalePrice(); //latest price shouldn't be older than timeout
        return (roundId, answer, startedAt, updatedAt, answeredInRound);
    }
}
