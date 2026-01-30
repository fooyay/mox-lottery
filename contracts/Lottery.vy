# pragma version 0.4.3
"""
@license MIT 
@title Lottery Contract
@author Sean Coates
@notice This contract creates and runs a simple lottery.
"""


# store the list of participants
# store the accumulated fees

ticket_price: public(immutable(uint256))
fee: public(immutable(uint256))
owner: public(immutable(address))


# initialize the contract and set the owner, ticket price, and fee
# set price to 0.001 ETH in the deploy script

@deploy
def __init__(_ticket_price: uint256, _fee: uint256):
    assert _ticket_price > 0
    ticket_price = _ticket_price
    fee = _fee
    owner = msg.sender

@payable
@external
def enter_lottery():
    """
    @notice Enter the lottery by sending the ticket price.
    """
    # check if the sent value is equal to the ticket price, else revert
    assert msg.value == ticket_price, "Incorrect ticket price sent"

    # increment accumulated fees

    # add the sender to the participants list

    pass

def pick_winner():
    """
    @notice Pick a random winner from the participants.
    @dev This function can only be called by the contract owner.
    """
    # handle the case of no participants

    # check if enough time has passed

    # randomly select a winner from the participants

    # send the winnings to the winner minus the fee

    # reset the participants list for the next round
    pass

def admin_withdraw_fees():
    """
    @notice Withdraw the accumulated fees by the contract owner.
    @dev This function can only be called by the contract owner.
    """
    pass

def _send_winnings(winner: address, amount: uint256):
    """
    @notice Internal function to send winnings to the winner.
    @param winner The address of the winner.
    @param amount The amount to send to the winner.
    """
    pass

def _get_random_number(limit: uint256) -> uint256:
    """
    @notice Internal function to get a pseudo-random number.
    @param limit The upper limit for the random number.
    @return A pseudo-random number between 0 and limit - 1.
    """
    return 0  # placeholder