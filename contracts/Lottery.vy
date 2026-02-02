# pragma version 0.4.3
"""
@license MIT 
@title Lottery Contract
@author Sean Coates
@notice This contract creates and runs a simple lottery.
"""


ticket_price: public(immutable(uint256))
fee: public(immutable(uint256))
min_duration: public(immutable(uint256))
owner: public(immutable(address))
accumulated_fees: uint256
participants: public(DynArray[address, 1000])  # max 1000 participants per round
lottery_balance: public(uint256)
lottery_start_time: public(uint256)
random_nonce: uint256

last_winner: public(address)
last_winning_amount: public(uint256)




@deploy
def __init__(_ticket_price: uint256, _fee: uint256, _min_duration: uint256):
    """
    @notice Constructor to initialize the lottery contract.
    @param _ticket_price The price of a lottery ticket.
    @param _fee The fee taken from each ticket purchase.
    @param _min_duration The minimum duration before picking a winner.
    """
    assert _min_duration >= 60  # at least 1 minute
    min_duration = _min_duration
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


@external
def pick_winner():
    """
    @notice Pick a random winner from the participants.
    @dev This function can only be called by the contract owner.
    """
    # handle the case of no participants
    assert len(self.participants) > 0, "No participants in the lottery"

    # check if enough time has passed
    assert block.timestamp >= self.lottery_start_time + min_duration, "Not enough time has passed"

    # randomly select a winner from the participants
    winner_index: uint256 = self._get_random_number(len(self.participants))

    _winner: address = self.participants[winner_index]
    _winning_amount: uint256 = self.lottery_balance

    # send the winnings to the winner minus the fee
    self._send_winnings(_winner, _winning_amount)
    # reset the participants list for the next round
    # reset the lottery balance

    self._reset_lottery(_winner, _winning_amount)


@external
def admin_withdraw_fees():
    """
    @notice Withdraw the accumulated fees by the contract owner.
    @dev This function can only be called by the contract owner.
    """
    assert msg.sender == owner, "Only owner can withdraw fees"
    raw_call(owner, b"", value=self.accumulated_fees)
    self.accumulated_fees = 0


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
    

def _send_winnings(_winner: address, _amount: uint256):
    """
    @notice Internal function to send winnings to the winner and reset the lottery.
    @param _winner The address of the winner.
    @param _amount The amount to send to the winner.
    """
    # send the amount to the winner
    raw_call(_winner, b"", value=_amount)


def _reset_lottery(_winner: address, _amount: uint256):
    """
    @notice Internal function to reset the lottery state after picking a winner.
    @param _winner The address of the winner.
    @param _amount The amount won by the winner.
    """
    self.lottery_start_time = block.timestamp
    self.last_winner = _winner
    self.last_winning_amount = _amount
    self.participants = []
    self.lottery_balance = 0
    

def _get_random_number(limit: uint256) -> uint256:
    """
    @notice Internal function to get a pseudo-random number.
    @param limit The upper limit for the random number.
    @return A pseudo-random number between 0 and limit - 1.
    """
    self.random_nonce += 1
    n: bytes32 = keccak256(
        concat(
            convert(block.timestamp, bytes32),
            convert(block.number, bytes32),
            convert(self.random_nonce, bytes32),
            convert(msg.sender, bytes32),
        )
    )
    return convert(n, uint256) % limit

@external
def test_random(limit: uint256) -> uint256:
    """
    @notice Test function to get a pseudo-random number.
    @param limit The upper limit for the random number.
    @return A pseudo-random number between 0 and limit - 1.
    """
    assert msg.sender == owner, "Only owner can test randomness"
    return self._get_random_number(limit)
