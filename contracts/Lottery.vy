# pragma version 0.4.3
"""
@license MIT 
@title Lottery Contract
@author Sean Coates
@notice This contract creates and runs a simple lottery.
"""


MIN_DURATION: public(constant(uint256)) = 60  # minimum duration between lotteries in seconds
ticket_price: public(immutable(uint256))
fee: public(immutable(uint256))
owner: public(immutable(address))
accumulated_fees: uint256
participants: DynArray[address, 1000]  # max 1000 participants per round
lottery_balance: public(uint256)
lottery_start_time: public(uint256)



@deploy
def __init__(_ticket_price: uint256, _fee: uint256):
    assert _ticket_price > 0
    assert _ticket_price > _fee
    ticket_price = _ticket_price
    fee = _fee
    owner = msg.sender
    self.accumulated_fees = 0
    self.lottery_start_time = block.timestamp

@payable
@external
def enter_lottery():
    """
    @notice Enter the lottery by sending the ticket price.
    """
    # check if the sent value is equal to the ticket price, else revert
    assert msg.value == ticket_price, "Incorrect ticket price sent"

    # increment accumulated fees
    self.accumulated_fees += fee
    self.lottery_balance += ticket_price - fee

    # add the sender to the participants list
    self.participants.append(msg.sender)

    pass

@external
def pick_winner():
    """
    @notice Pick a random winner from the participants.
    @dev This function can only be called by the contract owner.
    """
    # handle the case of no participants
    assert len(self.participants) > 0, "No participants in the lottery"

    # check if enough time has passed
    assert block.timestamp >= self.lottery_start_time + MIN_DURATION, "Not enough time has passed"

    # randomly select a winner from the participants

    # send the winnings to the winner minus the fee

    # reset the participants list for the next round
    # reset the lottery balance

    pass

def admin_withdraw_fees():
    """
    @notice Withdraw the accumulated fees by the contract owner.
    @dev This function can only be called by the contract owner.
    """
    pass

@external
def get_fees() -> uint256:
    """
    @notice Get the current accumulated fees.
    @return The amount of accumulated fees.
    """
    assert msg.sender == owner, "Only owner can view fees"
    return self.accumulated_fees


@external
def get_number_of_participants() -> uint256:
    """
    @notice Get the current number of participants in the lottery.
    @return The number of participants.
    """
    return len(self.participants)
    



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