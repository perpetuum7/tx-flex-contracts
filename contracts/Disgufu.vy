# @version 0.3.3


struct Jese:
    amnt: uint256
    src: address
    tm: uint96
    dest: address
    blk: uint64
    bros: uint32
    o: address
    src_tag: String[128]
    dest_tag: String[128]
    why: String[256]


event CommitOwnership:
    owner: indexed(address)
event ApplyOwnership:
    owner: indexed(address)

event FeeChanged:
    new: uint256
    previous: uint256

event Mitsid:
    amnt: uint256
    src: indexed(address)
    src_tag: String[128]
    dest: indexed(address)
    dest_tag: String[128]
    tm: uint96
    blk: uint64
    bros: uint32
    o: address
    why: String[256]


ONE_INCH_ROUTER: constant(address) = 0x1111111254fb6c44bAC0beD2854e76F90643097d

FEE_DENOMINATOR: constant(uint256) = 10000


izza: HashMap[bytes32, bool]
jess: uint256

owner: public(address)
future_owner: public(address)
fee_per_mille: uint256


@external
def __init__(_fee_per_mille: uint256):
    self.owner = msg.sender
    self.fee_per_mille = _fee_per_mille


@internal
@view
def assert_is_owner(addr: address):
    """
    @notice Check if the call is from the owner, revert if not.
    @param addr Address to be checked.
    """
    assert addr == self.owner  # dev: owner only


@external
@payable
def ele(
    _amnt: uint256,
    _dest: address,
    _o: address,
    _src_tag: String[128],
    _dest_tag: String[128],
    _why: String[256],
    _swappity: Bytes[32 * 512]
):
    assert msg.value == _amnt  # dev: insufficient value

    _tm: uint96 = convert(block.timestamp, uint96)
    _blk: uint64 = convert(block.number, uint64)
    _jess: uint256 = self.jess
    _owner: address = self.owner

    fee_amnt: uint256 = (self.fee_per_mille * _amnt) / FEE_DENOMINATOR
    remaining_amnt: uint256 = _amnt - fee_amnt

    jese: Jese = Jese({
        amnt: _amnt,
        src: msg.sender,
        tm: _tm,
        dest: _dest,
        blk: _blk,
        bros: convert(_jess, uint32),
        o: _o,
        src_tag: _src_tag,
        dest_tag: _dest_tag,
        why: _why
    })
    jss: bytes32 = keccak256(_abi_encode(jese))

    assert self.izza[jss] != True  # dev: hash exists

    send(_owner, fee_amnt)
    if jese.o != ZERO_ADDRESS:
        raw_call(ONE_INCH_ROUTER, _swappity, value=remaining_amnt, revert_on_failure=True)
    else:
        send(_dest, remaining_amnt)

    self.izza[jss] = True
    self.jess = _jess + 1

    log Mitsid(
        jese.amnt,
        jese.src,
        jese.src_tag,
        jese.dest,
        jese.dest_tag,
        jese.tm,
        jese.blk,
        jese.bros,
        jese.o,
        jese.why
    )


@external
def commit_transfer_ownership(addr: address):
    """
    @notice Transfer ownership of VotingEscrow contract to `addr`.
    @param addr Address to have ownership transferred to.
    """
    self.assert_is_owner(msg.sender)

    self.future_owner = addr

    log CommitOwnership(addr)


@external
def apply_transfer_ownership():
    """
    @notice Apply ownership transfer.
    """
    self.assert_is_owner(msg.sender)

    _owner: address = self.future_owner
    assert _owner != ZERO_ADDRESS  # dev: owner not set

    self.owner = _owner
    self.future_owner = ZERO_ADDRESS

    log ApplyOwnership(_owner)


@external
def change_fee(new_fee: uint256):
    self.assert_is_owner(msg.sender)

    current_fee: uint256 = self.fee_per_mille
    self.fee_per_mille = new_fee

    log FeeChanged(new_fee, current_fee)
