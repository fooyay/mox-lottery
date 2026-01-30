import re
import pytest
from script.deploy import deploy_lottery, TICKET_PRICE, DECIMALS
import boa

NUM_ENTRIES: int = 7


@pytest.fixture(scope="function")
def lottery_contract():
    return deploy_lottery()


@pytest.fixture(scope="function")
def funded_lottery(lottery_contract):
    # Simulate multiple users entering the lottery
    user_balance = int(TICKET_PRICE * 10**DECIMALS * 2)
    ticket_price = lottery_contract.ticket_price()

    for i in range(NUM_ENTRIES):
        user = boa.env.generate_address(f"user_{i}")
        boa.env.set_balance(user, user_balance)
        with boa.env.prank(user):
            lottery_contract.enter_lottery(value=ticket_price)
    return lottery_contract


@pytest.fixture(scope="function")
def random_user():
    return boa.env.generate_address("random_user")
