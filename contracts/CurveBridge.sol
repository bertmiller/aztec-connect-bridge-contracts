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
            // 0 and 1
        } else if {
          // 0 and 2
        } else if (){
          // 1 and 2
        } else if (){
          // 1 and 0
        } else if (){
          // 2 and 0
        } else () {
          // 2 and 1
        }


        // OLD CODE
        if (
            inputAssetA.assetType == Types.AztecAssetType.ETH &&
            outputAssetA.assetType == Types.AztecAssetType.ERC20
        ) {
            address[] memory path = new address[](2);
            path[0] = weth;
            path[1] = outputAssetA.erc20Address;
            amounts = curvePool.swapExactETHForTokens{value: inputValue}(
                0,
                path,
                rollupProcessor,
                deadline
            );
            outputValueA = amounts[1];
        } else if (
            inputAssetA.assetType == Types.AztecAssetType.ERC20 &&
            outputAssetA.assetType == Types.AztecAssetType.ETH
        ) {
            address[] memory path = new address[](2);
            path[0] = inputAssetA.erc20Address;
            path[1] = weth;
            require(
                IERC20(inputAssetA.erc20Address).approve(
                    address(curvePool),
                    inputValue
                ),
                "CurveBridge: APPROVE_FAILED"
            );
            amounts = curvePool.swapExactTokensForETH(
                inputValue,
                0,
                path,
                rollupProcessor,
                deadline
            );
            outputValueA = amounts[1];
        } else {
            // TODO what about swapping tokens?
            revert("CurveBridge: INCOMPATIBLE_ASSET_PAIR");
        }
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
