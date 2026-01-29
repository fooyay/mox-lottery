import pytest
from script.deploy import deploy_lottery


@pytest.fixture(scope="function")
def lottery_contract():
    return deploy_lottery()
