from brownie import accounts, Disgufu


REQUIRED_CONFIRMATIONS = 2
admin = accounts.load('p7m')


def tx_params(gas_limit: int = None):
    return {
        "from": admin,
        "required_confs": REQUIRED_CONFIRMATIONS,
        "gas_limit": gas_limit
    }


def main():
    digufu = Disgufu.deploy(10, tx_params())
