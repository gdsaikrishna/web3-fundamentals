from solcx import compile_standard, install_solc
import json, os
from dotenv import load_dotenv
from web3 import Web3

#Load env vaiables
load_dotenv()

with open("./SimpleStorage.sol","r") as file:
    simple_storage_file = file.read()

#Compiling solidity code
install_solc("0.6.0")
compiled_sol = compile_standard(
    {
        "language": "Solidity",
        "sources": {"SimpleStorage.sol": {"content": simple_storage_file}},
        "settings": {
            "outputSelection": {
                "*": {
                    "*": ["abi", "metadata", "evm.bytecode", "evm.bytecode.sourceMap"]
                }
            }
        },
    },
    solc_version="0.6.0",
)

#Save compiled code in JSON format
with open("compiled_code.json", "w") as file:
    json.dump(compiled_sol, file)

# get bytecode
bytecode = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["evm"][
    "bytecode"
]["object"]

# get abi
abi = json.loads(
    compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["metadata"]
)["output"]["abi"]


#Connection to ganache
# w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))
# chain_id = 1337

#Connection to Infura Rinkeby
w3 = Web3(Web3.HTTPProvider(os.getenv("RINKEBY_RPC_URL")))
chain_id = 4

#Ganache creds
# my_address = "0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1"
# private_key = os.getenv("PRIVATE_KEY_GANACHE")

# my meta address
my_address = "0x264Ca294fCD4b1C764aF4C9724Ab2Ff9B93F4F78"
private_key = os.getenv("PRIVATE_KEY")


#STEPS:  1. Create and Build the Transaction  2. Sign the Transaction  3. Deploy the transaction 
# Create the contract in Python
SimpleStorage = w3.eth.contract(abi=abi, bytecode=bytecode)
# Get the latest transaction
nonce = w3.eth.getTransactionCount(my_address)
# Submit the transaction that deploys the contract
transaction = SimpleStorage.constructor().buildTransaction(
    {"chainId": chain_id, "from": my_address, "nonce": nonce}
)
# Sign the transaction
signed_txn = w3.eth.account.sign_transaction(
    transaction, private_key=private_key)
print("Deploying Contract!")
# Send it!
tx_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
# Wait for the transaction to be mined, and get the transaction receipt
print("Waiting for transaction to finish...")
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
print(f"Done! Contract deployed to {tx_receipt.contractAddress}")


# Working with deployed Contracts
simple_storage = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)
print(f"Initial Stored Value {simple_storage.functions.retrieve().call()}")
greeting_transaction = simple_storage.functions.store(15).buildTransaction(
    {"chainId": chain_id, "from": my_address, "nonce": nonce + 1}
)
signed_greeting_txn = w3.eth.account.sign_transaction(
    greeting_transaction, private_key=private_key
)
tx_greeting_hash = w3.eth.send_raw_transaction(
    signed_greeting_txn.rawTransaction)
print("Updating stored Value...")
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_greeting_hash)

print(simple_storage.functions.retrieve().call())