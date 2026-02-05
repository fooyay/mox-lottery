# pragma version 0.4.3
"""
@license MIT
@title Lottery Contract
@author Sean Coates
@notice This contract creates and runs a simple lottery using VRF for randomness.
"""
from .interfaces import VRFCoordinatorV2


flag LotteryState:
    OPEN
    CALCULATING_WINNER

ticket_price: public(immutable(uint256))
fee: public(immutable(uint256))
min_duration: public(immutable(uint256))
owner: public(immutable(address))
accumulated_fees: uint256
participants: public(DynArray[address, 1000])  # max 1000 participants per round
lottery_balance: public(uint256)
lottery_start_time: public(uint256)
lottery_state: public(LotteryState)

last_winner: public(address)
last_winning_amount: public(uint256)

# VRF Configuration
VRF_COORDINATOR: public(immutable(VRFCoordinatorV2))
GAS_LANE: public(immutable(bytes32))
SUBSCRIPTION_ID: public(immutable(uint64))
REQUEST_CONFIRMATIONS: constant(uint16) = 3  # default is 3
CALLBACK_GAS_LIMIT: immutable(uint32)
NUM_WORDS: constant(uint32) = 1
MAX_ARRAY_SIZE: constant(uint256) = 1


@deploy
def __init__(
    _ticket_price: uint256,
    _fee: uint256,
    _min_duration: uint256,
    subscription_id: uint64,
    gas_lane: bytes32,
    callback_gas_limit: uint32,
    vrf_coordinator_v2: address,
):
    """
    @notice Constructor to initialize the lottery contract.
    @param _ticket_price The price of a lottery ticket.
    @param _fee The fee taken from each ticket purchase.
    @param _min_duration The minimum duration before picking a winner.
    """
    # Lottery configuration
    assert _min_duration >= 60  # at least 1 minute
    min_duration = _min_duration
    assert _ticket_price > 0
    assert _ticket_price > _fee
    ticket_price = _ticket_price
    fee = _fee
    owner = msg.sender


    # VRF setup
    SUBSCRIPTION_ID = subscription_id
    GAS_LANE = gas_lane
    CALLBACK_GAS_LIMIT = callback_gas_limit
    VRF_COORDINATOR = VRFCoordinatorV2(vrf_coordinator_v2)

    # Lottery setup
    self.accumulated_fees = 0
    self.lottery_start_time = block.timestamp
    self.lottery_state = LotteryState.OPEN


@payable
@external
def enter_lottery():
    """
    @notice Enter the lottery by sending the ticket price.
    """
    # check if the sent value is equal to the ticket price, else revert
    assert msg.value == ticket_price, "Incorrect ticket price sent"
    assert (
        self.lottery_state == LotteryState.OPEN
    ), "Lottery is not open, we are picking a winner. Try again later."

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
    assert (
        block.timestamp >= self.lottery_start_time + min_duration
    ), "Not enough time has passed"

    # request randomness from VRF
    self.lottery_state = LotteryState.CALCULATING_WINNER
    request_id: uint256 = extcall VRF_COORDINATOR.requestRandomWords(
        GAS_LANE,
        SUBSCRIPTION_ID,
        REQUEST_CONFIRMATIONS,
        CALLBACK_GAS_LIMIT,
        NUM_WORDS,
    )

@external
def rawFulfillRandomWords(requestId: uint256, randomWords: DynArray[uint256, MAX_ARRAY_SIZE]):
    """
    @notice Callback function used by VRF Coordinator to return the random number.
    @param requestId The Id of the randomness request.
    @param randomWords The array of random words returned by VRF.
    """
    assert (
        msg.sender == VRF_COORDINATOR.address
    ), "Only VRFCoordinator can fulfill"
    winner_index: uint256 = randomWords[0] % len(self.participants)

    self._calculate_winner(winner_index)
    

def _calculate_winner(_index: uint256):
    _winner: address = self.participants[_index]
    _winning_amount: uint256 = self.lottery_balance

    # send the winnings to the winner and reset the lottery
    self._send_winnings(_winner, _winning_amount)
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
    n: bytes32 = keccak256(
        concat(
            convert(block.timestamp, bytes32),
            convert(block.number, bytes32),
            convert(0, bytes32),
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
