from contracts import Lottery
from moccasin.boa_tools import VyperContract

TICKET_PRICE = 0.001  # in ETH
DECIMALS = 18


def deploy() -> VyperContract:
    ticket_price_in_wei = int(TICKET_PRICE * 10**DECIMALS)
    lottery: VyperContract = Lottery.deploy(ticket_price_in_wei)

    return lottery


def moccasin_main() -> VyperContract:
    return deploy()
