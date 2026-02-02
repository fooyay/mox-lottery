# Lottery Project using Moccasin

🐍 This is a basic lottery smart contract, built using Vyper and Moccasin.

## Features
### Deployment
The ticket price, fee, and minimum duration are set at deployment time. Adjust the values in `script/deploy.py` before deploying.

Example values:
- Ticket Price: 0.001 ETH
- Fee: 0.00005 ETH
- Minimum Duration: 3600 seconds (1 hour)

Ticket price must be greater than fee, and minimum duration must be at least 60 seconds.

### Entering the Lottery
Users can enter the lottery by calling the `enter_lottery` function and sending the required ticket price in wei. The amount sent must be equal to the ticket price set during deployment.

Users can check the number of participants by calling the `get_number_of_participants` function.

Users can check the current lottery balance (total amount collected from ticket sales minus fees) by calling the `lottery_balance` function.

### Picking a Winner
Anyone may call the `pick_winner` function to randomly select a winner from the participants, but only if enough time has passed since the last lottery started (as defined by the minimum duration set during deployment).

If enough time has not passed, the function will revert with an error message.

If enough time has passed, the winner receives the total lottery balance (sum of all ticket prices minus fees). The participants list and lottery balance are then reset for the next round.

### Admin Can Withdraw Fees
The contract owner can withdraw the accumulated fees by calling the `admin_withdraw_fees` function.

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
- replace with Chainlink VRF later

_For documentation, please run `mox --help` or visit [the Moccasin documentation](https://cyfrin.github.io/moccasin)_
