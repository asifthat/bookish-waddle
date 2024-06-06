curl -fsSL https://install.fuel.network | sh -s -- --no-modify-path --yes
git clone  https://github.com/FuelLabs/chain-configuration.git

read -p "Please enter the INFURA or ALCHEMY URL: " URL && export ETHEREUM_RPC_ENDPOINT=$URL
export SNAPSHOT_PATH=$PWD/chain-configuration/ignition
export PATH="${HOME}/.fuelup/bin:${PATH}"
# export P2P_PRIVATE_KEY=$(cd  $HOME/.fuelup && fuel-core-keygen new --key-type peering | jq -r '.secret')
read -p "Please enter P2P private key (without 0x): " KEY &&  export P2P_PRIVATE_KEY=$KEY


cd  $HOME/.fuelup
fuel-core run \
--service-name=fuel-sepolia-testnet-node \
--keypair $P2P_PRIVATE_KEY \
--relayer $ETHEREUM_RPC_ENDPOINT \
--ip=0.0.0.0 --port=4000 --peering-port=30333 \
--db-path=~/.fuel-sepolia-testnet \
--snapshot $SNAPSHOT_PATH \
--utxo-validation --poa-instant false --enable-p2p \
--reserved-nodes /dns4/p2p-testnet.fuel.network/tcp/30333/p2p/16Uiu2HAmDxoChB7AheKNvCVpD4PHJwuDGn8rifMBEHmEynGHvHrf \
--sync-header-batch-size 100 \
--enable-relayer \
--relayer-v2-listening-contracts=0x01855B78C1f8868DE70e84507ec735983bf262dA \
--relayer-da-deploy-height=5827607 \
--relayer-log-page-size=500 \
--sync-block-stream-buffer-size 30
