import boa

from script.deploy import DECIMALS, TICKET_PRICE, TICKET_FEE

RANDOM_USER = boa.env.generate_address("random_user")


def test_ticket_price_is_set(lottery_contract):
    expected_ticket_price = int(TICKET_PRICE * 10**DECIMALS)
    expected_fee = int(TICKET_FEE * 10**DECIMALS)

    assert lottery_contract.ticket_price() == expected_ticket_price
    assert lottery_contract.fee() == expected_fee
    assert lottery_contract.owner() == boa.env.eoa


def test_revert_if_incorrect_ticket_price_sent(lottery_contract):
    incorrect_price: int = lottery_contract.ticket_price() + 1

    with boa.reverts("Incorrect ticket price sent"):
        lottery_contract.enter_lottery(value=incorrect_price)


def test_revert_if_no_eth_sent(lottery_contract):
    with boa.reverts("Incorrect ticket price sent"):
        lottery_contract.enter_lottery(value=0)


def test_user_cannot_show_fees(lottery_contract):
    with boa.env.prank(RANDOM_USER):
        with boa.reverts("Only owner can view fees"):
            lottery_contract.get_fees()


def test_owner_can_view_fees(lottery_contract):
    # Initially, fees should be zero
    assert lottery_contract.get_fees() == 0

    # Simulate a user entering the lottery
    boa.env.set_balance(RANDOM_USER, int(TICKET_PRICE * 10**DECIMALS * 2))
    with boa.env.prank(RANDOM_USER):
        lottery_contract.enter_lottery(value=lottery_contract.ticket_price())

    # Now, the accumulated fees should equal the ticket fee
    expected_fees = lottery_contract.fee()
    assert lottery_contract.get_fees() == expected_fees


def test_fees_accumulate_correctly(lottery_contract):
    # Simulate multiple users entering the lottery
    num_entries = 3
    for i in range(num_entries):
        user = boa.env.generate_address(f"user_{i}")
        boa.env.set_balance(user, int(TICKET_PRICE * 10**DECIMALS * 2))
        with boa.env.prank(user):
            lottery_contract.enter_lottery(value=lottery_contract.ticket_price())

    # The accumulated fees should equal the ticket fee multiplied by the number of entries
    expected_fees = lottery_contract.fee() * num_entries
    assert lottery_contract.get_fees() == expected_fees
