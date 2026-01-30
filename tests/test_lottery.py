import boa

from script.deploy import DECIMALS, TICKET_PRICE, TICKET_FEE
from tests.conftest import NUM_ENTRIES


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


def test_user_cannot_show_fees(lottery_contract, random_user):
    with boa.env.prank(random_user):
        with boa.reverts("Only owner can view fees"):
            lottery_contract.get_fees()


def test_owner_can_view_fees(lottery_contract, random_user):
    # Initially, fees should be zero
    assert lottery_contract.get_fees() == 0

    # Simulate a user entering the lottery
    boa.env.set_balance(random_user, int(TICKET_PRICE * 10**DECIMALS * 2))
    with boa.env.prank(random_user):
        lottery_contract.enter_lottery(value=lottery_contract.ticket_price())

    # Now, the accumulated fees should equal the ticket fee
    expected_fees = lottery_contract.fee()
    assert lottery_contract.get_fees() == expected_fees


def test_fees_accumulate_correctly(funded_lottery):
    # The accumulated fees should equal the ticket fee multiplied by the number of entries
    expected_fees: int = funded_lottery.fee() * NUM_ENTRIES
    assert funded_lottery.get_fees() == expected_fees


def test_user_can_see_number_of_participants(funded_lottery, random_user):
    with boa.env.prank(random_user):
        assert funded_lottery.get_number_of_participants() == NUM_ENTRIES


def test_show_lottery_balance(funded_lottery, random_user):
    expected_balance: int = (
        funded_lottery.ticket_price() - funded_lottery.fee()
    ) * NUM_ENTRIES
    with boa.env.prank(random_user):
        assert funded_lottery.lottery_balance() == expected_balance


def test_wont_pick_winner_with_no_participants(lottery_contract):
    with boa.reverts("No participants in the lottery"):
        lottery_contract.pick_winner()
