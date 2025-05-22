# Charity Raffle Smart Contract

## How to Install

```bash
forge install
```

## How to Test

- No automated tests provided yet.

## Deployment Steps

1. Add the following variables to your `.env` file:

```env
SEPOLIA_RPC_URL=
ETHERSCAN_API_KEY=
```

2. Run the deploy script:

```bash
forge script script/deploy.s.sol:DeployScript --rpc-url sepolia --broadcast --verify -vv --private-key <PRIVATE_KEY>
```

3. Run the verify script (if needed):

```bash
forge verify-contract <CONTRACT_ADDRESS_FOR_VERIFY> ./src/CharityRaffle.sol:CharityRaffle --chain-id 11155111
```

## Links to Contracts

- **Proxy:** [0x6053eE11Cf54282B95B2511b5D9811caA2859C48](https://sepolia.etherscan.io/address/0x6053eE11Cf54282B95B2511b5D9811caA2859C48)
- **Implementation:** [0x4bf93930d96c0ED2a9E5895ec7Fe6B4812356483](https://sepolia.etherscan.io/address/0x4bf93930d96c0ED2a9E5895ec7Fe6B4812356483)

## Proof of Execution

- 🎟️ **Ticket Purchase:** [View TX](https://sepolia.etherscan.io/tx/0xe1d811fd0c9d79a017a369784774e4e4cf84cafe5daa9fffc369bd30dfb13bf1)
- 🎲 **Request Random Winners:** [View TX](https://sepolia.etherscan.io/tx/0x68961ef52f625e5765a7b992716ae24a71c9cd9797eae2fc087ad8dbbfc4b1ef)
- ✅ **Fulfill Random Words:** [View TX](https://sepolia.etherscan.io/tx/0xf140a40d6200426a9dc20ac468ff76de2373bc1ab5b9223db4e265027d1e06c9)
- 🏆 **Claim Prize:** [View TX](https://sepolia.etherscan.io/tx/0x7db4b7eeba2fd9bbba049b037d78d9cfc30fe80ffccf884071963d04c6dea4eb)
- 💖 **Claim Charity Funds:** [View TX](https://sepolia.etherscan.io/tx/0x5dcd6ffc5b0da4d9d0c034778abc9edfd1c0ad183a05e78e33bce2390ec1a4b7)


