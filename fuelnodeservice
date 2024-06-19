curl -fsSL https://install.fuel.network | sh -s -- --no-modify-path --yes
git clone  https://github.com/FuelLabs/chain-configuration.git
apt install jq  -y

#!/bin/bash

# Set environment variables
export SNAPSHOT_PATH="$PWD/chain-configuration/ignition"
export PATH="${HOME}/.fuelup/bin:${PATH}"

# Check if apiurl.txt file containing Ethereum RPC endpoint URL exists, or else prompt user and save it to that file.
if [ ! -f "$HOME/apiurl.txt" ]; then
    read -p "Enter Ethereum RPC endpoint URL: " rpc_endpoint
    echo "$rpc_endpoint" > "$HOME/apiurl.txt"
fi

export ETHEREUM_RPC_ENDPOINT=$(cat "$HOME/apiurl.txt")


# Check if fuelp2pkey.json exists
if [ ! -f "$HOME/fuelp2pkey.json" ]; then
    # Prompt the user to enter Y or N
    read -p "Do you have an existing P2P private key? Type 'Y' for yes, 'N' for no: " choice

    if [ "$choice" = "Y" ] || [ "$choice" = "y" ]; then
        # User has an existing key, prompt for input
        read -p "Please enter the P2P private key (without '0x'): " key_input
        export P2P_PRIVATE_KEY="$key_input"
    elif [ "$choice" = "N" ] || [ "$choice" = "n" ]; then
        # Generate new P2P_PRIVATE_KEY and save it to fuelp2pkey.json
        export P2P_PRIVATE_KEY=$("$HOME/.fuelup/bin/fuel-core-keygen" new --key-type peering > "$HOME/fuelp2pkey.json" && cat "$HOME/fuelp2pkey.json" | jq -r '.secret')
    else
        echo "Invalid choice. Please type 'Y' or 'N'."
        exit 1
    fi
else
    # fuelp2pkey.json exists, load the key from the file
    export P2P_PRIVATE_KEY=$(cat "$HOME/fuelp2pkey.json" | jq -r '.secret')
fi


# Write systemd service configuration
sudo tee /etc/systemd/system/fuelnode.service > /dev/null << EOF
[Unit]
Description=Fuel Node Beta-5
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$HOME/.fuelup/bin/fuel-core run \
--service-name=fuel-sepolia-testnet-node \
--keypair "$P2P_PRIVATE_KEY" \
--relayer "$ETHEREUM_RPC_ENDPOINT" \
--ip=0.0.0.0 --port=4000 --peering-port=30333 \
--db-path=$HOME/.fuel-sepolia-testnet \
--snapshot "$SNAPSHOT_PATH" \
--utxo-validation --poa-instant=false --enable-p2p \
--reserved-nodes /dns4/p2p-testnet.fuel.network/tcp/30333/p2p/16Uiu2HAmDxoChB7AheKNvCVpD4PHJwuDGn8rifMBEHmEynGHvHrf \
--sync-header-batch-size=100 \
--enable-relayer \
--relayer-v2-listening-contracts=0x01855B78C1f8868DE70e84507ec735983bf262dA \
--relayer-da-deploy-height=5827607 \
--relayer-log-page-size=500 \
--sync-block-stream-buffer-size=30
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon to pick up the new service definition
sudo systemctl daemon-reload

# Enable and start the fuelnode service
sudo systemctl enable fuelnode.service
sudo systemctl start fuelnode.service
sudo systemctl status fuelnode.service
sudo journalctl -u fuelnode -f -o cat
