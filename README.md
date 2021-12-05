# Open Source Curve Aztec Connect Bridge Contracts

0xFawkes and I implemented a series of Aztec Bridge Contracts:

Swap stablecoins on Curve's 3pool (USDC/DAI/USDT)
Swap ETH/WBTC/USDT on Curve's TriCrypto2 (USDT/WBTC/WETH)
Swap stablecoins on Curve's MIM pool (MIM/USDC/DAI/USDT)
Add or remove liquidity on any Curve 3pool meta pool (e.g. MIM, LUSD, alUSD, FEI, etc)
... more to come


The add and remove liquidity contract for Curve's 3pool meta pools was the most complicated of these, but was fun. To remove liquidity, users need to input LP tokens and attempt to output DAI/USDC/USDT or the base stablecoin of a 3pool meta pool. Similarly, to add liquidity users need to input a stablecoin and specify the LP token of the pool that they would like to add liquidity to.



Note that this is only valid for Curve pool where the LP token and the Curve pool are the same contract. For the largest Curve stablecoin pools this is the case, but for some of the long tail it is not.



All together it was a fun exercise implementing these and we would encourage others to try and do so as well.
