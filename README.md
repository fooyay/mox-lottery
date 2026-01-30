# Lottery Project using Moccasin

🐍 This is a basic lottery smart contract, built using Vyper and Moccasin.

## Features
### Deployment
The ticket price and fee are set at deployment time. Adjust the values in `script/deploy.py` before deploying.
The values are based in ETH.

### Entering the Lottery
Users can enter the lottery by calling the `enter_lottery` function and sending the required ticket price in wei. The amount sent must be equal to the ticket price set during deployment.

Users can check the number of participants by calling the `get_number_of_participants` function.

Users can check the current lottery balance (total amount collected from ticket sales minus fees) by calling the `lottery_balance` function.


## Quickstart

1. Deploy to a fake local network that titanoboa automatically spins up!

```bash
mox run deploy
```

2. Run tests

```
mox test
```

## Plan to implement the following features:
- have a function `pick_winner` that can be called by the contract owner to pick a random winner from the participants, only executes if enough time has passed
- winner receives the sum of all fees entered by other participants, minus a small fee for the contract owner
- initially, use weak randomness (blockhash) to pick a winner
- replace with Chainlink VRF later
- display most recent winner and their winnings

_For documentation, please run `mox --help` or visit [the Moccasin documentation](https://cyfrin.github.io/moccasin)_
