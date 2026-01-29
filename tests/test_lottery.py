import boa

from script.deploy import DECIMALS, TICKET_PRICE, TICKET_FEE


def test_ticket_price_is_set(lottery_contract):
    expected_ticket_price = int(TICKET_PRICE * 10**DECIMALS)
    expected_fee = int(TICKET_FEE * 10**DECIMALS)

    assert lottery_contract.ticket_price() == expected_ticket_price
    assert lottery_contract.fee() == expected_fee
    assert lottery_contract.owner() == boa.env.eoa
