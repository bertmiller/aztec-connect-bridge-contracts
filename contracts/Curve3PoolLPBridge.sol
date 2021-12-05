// SPDX-License-Identifier: GPL-2.0-only
// Copyright 2020 Spilsbury Holdings Ltd
pragma solidity >=0.6.6 <0.8.0;
pragma experimental ABIEncoderV2;

import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IDefiBridge} from "./interfaces/IDefiBridge.sol";
import {Types} from "./Types.sol";

interface ICurvePool {
    function add_liquidity{
        uint256[4] _amounts,
        uint256 _min_mint_amount
    } external;
}

contract Curve3PoolLPBridge is IDefiBridge {
    using SafeMath for uint256;

    address public immutable rollupProcessor;

    address constant MIM = "0x99D8a9C45b2ecA8864373A26D1459e3Dff1e17F3";
    address constant 3CRV = "0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490";

    int128 constant N_COINS = 2;
    int128 constant BASE_N_COINS = 3;
    int128 constant N_ALL_COINS = N_COINS + BASE_N_COINS - 1;

    address constant DAI_1 = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
    address constant USDC_2 = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
    address constant USDT_3 = "0xdAC17F958D2ee523a2206206994597C13D831ec7";

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
        uint256 totalInputValue,
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
        require(msg.sender == rollupProcessor, "Curve3PoolLPBridge: INVALID_CALLER");
        isAsync = false;

        uint256[N_COINS] amounts = [0, 0, 0, 0];

        if (outputAssetA.erc20Address == MIM_LP_TOKEN) {
            _pool = MIM_POOL;
        } else if (outputAssetA.erc20Address == MIM_LP_TOKEN) {
        } else {
            revert("Curve3PoolLPBridge: INVALID_OUTPUT_ASSET_A");
        }


        address coin = CurveMeta(_pool).coins(0)

        if (inputAssetA.erc20Address == coin) {
            amount[0] = totalInputValue;
        } else if (inputAssetA.erc20Address == DAI_1) {
            amount[1] = totalInputValue;
        } else if (inputAssetA.erc20Address == USDC_2) {
            amount[2] = totalInputValue;
        } else if (inputAssetA.erc20Address == USDT_3) {
            amount[3] = totalInputValue;
        } else {
            revert("Curve3PoolLPBridge: INCOMPATIBLE_ASSET_A");
        }

        require(
            IERC20(inputAssetA.erc20Address).approve(
                address(curvePool),
                totalInputValue
            ),
            "Curve3PoolLPBridge: APPROVE_FAILED"
        );

        // FIXME: some reasonable value for min_mint_amount
        outputValueA = curvePool.add_liquidity(_pool, amounts, 0);
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
