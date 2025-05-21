# Decentralized Lottery DApp

A decentralized lottery application built for COMP4541 Blockchain, Cryptocurrencies and Smart Contracts course.

## Overview

This DApp allows users to participate in a decentralized lottery system with the following features:
- Purchase lottery tickets using ETH
- Automatic winner selection based on a random algorithm
- Transparent prize distribution (90% to winner, 10% to platform)
- View ongoing lottery information (time remaining, prize pool, etc.)

## Technical Details

- Smart Contract: Solidity (^0.8.0)
- Frontend: HTML, CSS, JavaScript
- Web3 Integration: web3.js
- Wallet Connection: MetaMask

## Ethereum Testnet Used

This project uses the Sepolia Ethereum testnet for deployment and testing.

## Setup & Installation

1. Clone this repository
```
git clone <repository-url>
cd dlottery
```

2. Install dependencies
```
npm install
```

3. Start the local server
```
node server.js
```

4. Open your browser and visit: `http://localhost:3000`

## Smart Contract Deployment

1. Install Truffle (if not already installed)
```
npm install -g truffle
```

2. Deploy to Sepolia testnet
```
truffle migrate --network sepolia
```

3. Update the contract address in `index.html` (line 310) with your deployed contract address

## Usage Instructions

1. Connect your MetaMask wallet (make sure it's configured for Sepolia testnet)
2. Purchase lottery tickets by specifying the quantity and confirming the transaction
3. Wait for the lottery to end (7 days from start)
4. If you win, the prize will be automatically transferred to your wallet

## Testing

The smart contract has been tested using the platform at https://mycontract.fun/. Testing logs are available in the `testing/` directory.

## Security Considerations

1. The randomness mechanism uses block variables which can be manipulated by miners in a production environment. For a truly secure solution, consider using Chainlink VRF.
2. The contract includes basic access control but could be enhanced with more sophisticated mechanisms.
3. Gas optimization has been considered but could be further improved.

## Demo

A live demo is available at: [https://your-username.github.io/dlottery](https://your-username.github.io/dlottery)

## License

This project is licensed under the MIT License - see the LICENSE file for details. 