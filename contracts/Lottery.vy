# pragma version 0.4.3
"""
@license MIT 
@title Lottery Contract
@author Sean Coates
@notice This contract creates and runs a simple lottery.
"""

# store the ticket price
# store the list of participants
# store the owner of the contract


# initialize the contract and set the owner and ticket price
# set price to 0.001 ETH in the deploy script

def enter_lottery():
    """
    @notice Enter the lottery by sending the ticket price.
    """
    pass

def pick_winner():
    """
    @notice Pick a random winner from the participants.
    @dev This function can only be called by the contract owner.
    """
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