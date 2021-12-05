// SPDX-License-Identifier: GPL-2.0-only
// Copyright 2020 Spilsbury Holdings Ltd
pragma solidity >=0.6.6 <0.8.0;
pragma experimental ABIEncoderV2;

import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IDefiBridge} from "./interfaces/IDefiBridge.sol";
import {Types} from "./Types.sol";

interface ICurvePool {
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;
}

contract CurveTricrypto2Bridge is IDefiBridge {
    using SafeMath for uint256;

    address public immutable rollupProcessor;

    address constant TETHER_0 = "0xdAC17F958D2ee523a2206206994597C13D831ec7";
    address constant WBTC_1 = "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599";
    address constant WETH_2 = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

    ICurvePool curvePool; // Update to Curve Pool

    constructor(address _rollupProcessor, address _curvePool) public {
        rollupProcessor = _rollupProcessor;
        curvePool = ICurvePool(_curvePool); // Update to Curve Pool
    }

    receive() external payable {}

    function convert(
        Types.AztecAsset calldata inputAssetA,
        Types.AztecAsset calldata,
        Types.AztecAsset calldata outputAssetA,
        Types.AztecAsset calldata,
        uint256 inputValue,
        uint256,
        uint64
    )
        external
        payable
        override
        returns (
            uint256,
            uint256,
            bool isAsync
        )
    {
        require(msg.sender == rollupProcessor, "CurveTricrypto2Bridge: INVALID_CALLER");
        isAsync = false;

        int128 i;
        int128 j;

        if (inputAssetA.erc20Address == TETHER_0) {
            i = 0;
        } else if (inputAssetA.erc20Address == WBTC_1) {
            i = 1;
        } else if (inputAssetA.erc20Address == WETH_2) {
            i = 2;
        } else {
            revert("CurveTricrypto2Bridge: INCOMPATIBLE_ASSET_PAIR");
        }

        if (outputAssetA.erc20Address == TETHER_0) {
            j = 0;
        } else if (outputAssetA.erc20Address == WBTC_1) {
            j = 1;
        } else if (outputAssetA.erc20Address == WETH_2) {
            j = 2;
        } else {
            revert("CurveTricrypto2Bridge: INCOMPATIBLE_ASSET_PAIR");
        }

        if (i == j) {
            revert("CurveTricrypto2Bridge: INCOMPATIBLE_ASSET_PAIR");
        }

        require(
            IERC20(inputAssetA.erc20Address).approve(
                address(curvePool),
                inputValue
            ),
            "CurveTricrypto2Bridge: APPROVE_FAILED"
        );

        curvePool.exchange(i, j, dx, 1);
    }

    function canFinalise(
        uint256 /*interactionNonce*/
    ) external view override returns (bool) {
        return false;
    }

    function finalise(
        Types.AztecAsset calldata,
        Types.AztecAsset calldata,
        Types.AztecAsset calldata,
        Types.AztecAsset calldata,
        uint256,
        uint64
    ) external payable override returns (uint256, uint256) {
        require(false);
    }
}
