// SPDX-License-Identifier: GPL-2.0-only
// Copyright 2020 Spilsbury Holdings Ltd
pragma solidity >=0.6.6 <=0.8.0;
pragma experimental ABIEncoderV2;

import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IDefiBridge} from "./interfaces/IDefiBridge.sol";
import {Types} from "./Types.sol";

interface ICurvePool {
    function add_liquidity(
        address _pool,
        uint256[4] memory _amounts, // N_ALL_COINS
        uint256 _min_mint_amount
    ) external returns (uint256);

    function remove_liquidity_one_coin(
        address _pool,
        uint256 _burn_amount,
        int128 _i,
        uint256 _min_amount
    ) external returns (uint256);

    function coins(uint256 i) external view returns (address);

    function name() external view returns (string memory);
}

contract Curve3PoolLPBridge is IDefiBridge {
    using SafeMath for uint256;

    address public immutable rollupProcessor;
    int128 constant N_COINS = 2;
    int128 constant BASE_N_COINS = 3;
    int128 constant N_ALL_COINS = N_COINS + BASE_N_COINS - 1;

    address constant DAI_1 =
        address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address constant USDC_2 =
        address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address constant USDT_3 =
        address(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    ICurvePool curvePool; // Update to Curve Pool

    event CatchError(bytes reason);

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
        require(
            msg.sender == rollupProcessor,
            "Curve3PoolLPBridge: INVALID_CALLER"
        );
        isAsync = false;

        bool isInputLP = false;
        bool isOutputLP = false;
        try ICurvePool(inputAssetA.erc20Address).name() {
            string memory name = ICurvePool(inputAssetA.erc20Address).name();
            isInputLP = isCurveFi(name);
        } catch (bytes memory reason) {
            emit CatchError(reason);
        }

        try ICurvePool(outputAssetA.erc20Address).name() {
            string memory name = ICurvePool(outputAssetA.erc20Address).name();
            isOutputLP = isCurveFi(name);
        } catch (bytes memory reason) {
            emit CatchError(reason);
        }

        if (isOutputLP == isInputLP) {
            revert("Curve3PoolLPBridge: INVALID_ASSET_PAIR");
        }

        require(
            IERC20(inputAssetA.erc20Address).approve(
                outputAssetA.erc20Address,
                totalInputValue
            ),
            "Curve3PoolLPBridge: APPROVE_FAILED"
        );

        if (isOutputLP) {
            // The output is an LP contract, so we are adding liquidity
            uint256[4] memory amounts;

            address _pool = outputAssetA.erc20Address;
            address coin = ICurvePool(_pool).coins(0);

            if (inputAssetA.erc20Address == coin) {
                amounts[0] = totalInputValue;
            } else if (inputAssetA.erc20Address == DAI_1) {
                amounts[1] = totalInputValue;
            } else if (inputAssetA.erc20Address == USDC_2) {
                amounts[2] = totalInputValue;
            } else if (inputAssetA.erc20Address == USDT_3) {
                amounts[3] = totalInputValue;
            } else {
                revert("Curve3PoolLPBridge: INCOMPATIBLE_ASSET_A");
            }

            outputValueA = curvePool.add_liquidity(_pool, amounts, 1);
        } else {
            // The input is an LP contract, so we are removing liquidity
            int128 coin = 0;
            address _pool = inputAssetA.erc20Address;

            if (outputAssetA.erc20Address == DAI_1) {
                coin = 1;
            } else if (outputAssetA.erc20Address == USDC_2) {
                coin = 2;
            } else if (outputAssetA.erc20Address == USDT_3) {
                coin = 3;
            }

            outputValueA = curvePool.remove_liquidity_one_coin(
                _pool,
                totalInputValue,
                coin,
                0
            );
        }
    }

    function isCurveFi(string memory name) internal returns (bool) {
        bytes memory name_b = bytes(name);
        bytes memory comp_b = bytes("Curve.fi");

        if (name_b.length < comp_b.length) {
            return false;
        }

        uint256 i;
        while (i < comp_b.length) {
            if (name_b[i] != comp_b[i]) return false;
            i++;
        }

        return true;
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
