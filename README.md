# Lottery Project using Moccasin

🐍 This is a basic lottery smart contract, built using Vyper and Moccasin.

## Quickstart

1. Deploy to a fake local network that titanoboa automatically spins up!

```bash
mox run deploy
```

2. Run tests

```
mox test
```

## Features
- determine the ticket price
- have a function `enter_lottery` that allows users to enter the lottery by sending some ETH
- have a function `pick_winner` that can be called by the contract owner to pick a random winner from the participants
- have the lottery pick a winner after X seconds automatically
- winner receives the sum of all fees entered by other participants, minus a small fee for the contract owner
- initially, use weak randomness (blockhash) to pick a winner
- replace with Chainlink VRF later

_For documentation, please run `mox --help` or visit [the Moccasin documentation](https://cyfrin.github.io/moccasin)_
