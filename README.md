# Oracle Source

Serves as an interleave between an oracle and OSM contract. Chainlink aggregation contract as oracle is supported.

## Requirements
You must have a Unix-like operating system. To compile, test and deploy smart contracts, utilities are used that require a Nix environment.

## Installation

Install [Nix](https://nixos.org/) if you haven't already:

```shell script
# run into '/' directory

# user must be in sudoers
curl -L https://nixos.org/nix/install | sh

# Run this or login again to use Nix
. "$HOME/.nix-profile/etc/profile.d/nix.sh"
```

Then install [dapptools](https://github.com/dapphub/dapptools) into project root directory:

```shell script
curl https://dapp.tools/install | sh  

nix-env -f https://github.com/dapphub/dapptools/archive/master.tar.gz -iA solc-static-versions.solc_0_7_2
```

## Usage

### Compile

```shell script
dapp build --optimize
```

### Deploy

Configuration:

* use ETH v3 encoded private key of deployer wallet and copy JSON part to ```./keystore/me.json```
* copy the password of deployer wallet JSON file to ```./keystore/pwd```
* replace the values ```{deployer_address}``` (as in JSON file), ```{eth_net}``` (```mainnet```, ```kovan```, ... ), ```{infura_project_id}``` you need in the command below
* set value ```{price_source_contract_address}``` as address of price feed contract (e.g. Chainlink aggregation contract)

**Note:** Deployment of smart contract requires about 150,000 gas units (used gas). You can set variables ```ETH_GAS``` (gas limit in gas units), ```ETH_GAS_PRICE``` (gas price in wei) to adjust the gas.

Run deploy command:

```shell script
ETH_FROM={deployer_address} \
ETH_PASSWORD=./keystore/pwd \
ETH_KEYSTORE=./keystore \
ETH_GAS=150000 \
ETH_GAS_PRICE={gas_price_wei} \
ETH_RPC_URL=https://{eth_net}.infura.io/v3/{infura_project_id} \
TMPDIR=/tmp \
dapp create OracleProxy "{price_source_contract_address}"
```

The deployed contract address will be displayed in the command output.

### Clean output directory

```shell script
dapp clean
```

## Deployed contracts

The deployed contract data is contained in the ```deployed``` directory.
