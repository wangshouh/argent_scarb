import pytest
import asyncio
from starkware.starknet.testing.starknet import Starknet
from utils.deploy import deploy

user1 = 0x69221ff9023c4d7ba9123f0f9c32634c23fc5776d86657f464ecb51fd811445
user2 = 0x72648c3b1953572d2c4395a610f18b83cca14fa4d1ba10fc4484431fd463e5c


@pytest.fixture(scope='module')
def event_loop():
    return asyncio.new_event_loop()


@pytest.fixture(scope='module')
async def get_starknet():
    starknet = await Starknet.empty()
    return starknet


@pytest.mark.asyncio
async def test_eip712(get_starknet):
    starknet = get_starknet
    eip712 = await deploy(starknet, "contracts/StructHash.cairo")

    response = await eip712.test().call()

    assert response.result.hash == 941141766170116937295581121140425199172770042801890316068798201059101839897
