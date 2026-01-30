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
