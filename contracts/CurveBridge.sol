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

// import 'hardhat/console.sol';

contract CurveBridge is IDefiBridge {
    using SafeMath for uint256;

    address public immutable rollupProcessor;
    int128 public i;
    int128 public j;

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
            uint256 outputValueA,
            uint256,
            bool isAsync
        )
    {
        require(msg.sender == rollupProcessor, "CurveBridge: INVALID_CALLER");
        isAsync = false;

        if (
            inputAssetA.erc20Address ==
            "0x0000000000000000000000000000000000000000" &&
            outputAssetA.erc20Address ==
            "0x0000000000000000000000000000000000000000"
        ) {
            i = 0;
            j = 1;
            // 0 and 1
        } else if (
            inputAssetA.erc20Address ==
            "0x0000000000000000000000000000000000000000" &&
            outputAssetA.erc20Address ==
            "0x0000000000000000000000000000000000000000"
        ) {
            // 0 and 2
        } else if (
            inputAssetA.erc20Address ==
            "0x0000000000000000000000000000000000000000" &&
            outputAssetA.erc20Address ==
            "0x0000000000000000000000000000000000000000"
        ) {
            // 1 and 2
        } else if (
            inputAssetA.erc20Address ==
            "0x0000000000000000000000000000000000000000" &&
            outputAssetA.erc20Address ==
            "0x0000000000000000000000000000000000000000"
        ) {
            // 1 and 0
        } else if (
            inputAssetA.erc20Address ==
            "0x0000000000000000000000000000000000000000" &&
            outputAssetA.erc20Address ==
            "0x0000000000000000000000000000000000000000"
        ) {
            // 2 and 0
        } else if (
            inputAssetA.erc20Address ==
            "0x0000000000000000000000000000000000000000" &&
            outputAssetA.erc20Address ==
            "0x0000000000000000000000000000000000000000"
        ) {
            // 2 and 1
        } else {
            revert("CurveBridge: INCOMPATIBLE_ASSET_PAIR");
        }
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
