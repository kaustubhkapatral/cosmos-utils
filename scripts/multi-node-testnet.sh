#/bin/sh

command_exists () {
    type "$1" &> /dev/null ;
}

if command_exists go ; then
    echo "Golang is already installed"
else
  echo "Install dependencies"
  sudo apt update
  sudo apt install build-essential jq -y

  wget https://dl.google.com/go/go1.15.2.linux-amd64.tar.gz
  tar -xvf go1.15.2.linux-amd64.tar.gz
  sudo mv go /usr/local

  echo "" >> ~/.profile
  echo 'export GOPATH=$HOME/go' >> ~/.profile
  echo 'export GOROOT=/usr/local/go' >> ~/.profile
  echo 'export GOBIN=$GOPATH/bin' >> ~/.profile
  echo 'export PATH=$PATH:/usr/local/go/bin:$GOBIN' >> ~/.profile

  #source ~/.profile
  . ~/.profile

  go version
fi

echo "--------- Install $DAEMON ---------"
go get $GH_URL
cd ~/go/src/$GH_URL
git fetch && git checkout $CHAIN_VERSION
make install

# check version
$DAEMON version --long

#echo "----------Create test keys-----------"

echo "---------Initializing the chain ($CHAINID)---------"

$DAEMON unsafe-reset-all  --home $DAEMON_HOME_1
$DAEMON unsafe-reset-all  --home $DAEMON_HOME_2
$DAEMON unsafe-reset-all  --home $DAEMON_HOME_3
$DAEMON unsafe-reset-all  --home $DAEMON_HOME_4
rm -rf ~/.$DAEMON/config/gen*

echo "-----Create daemon home directories if not exist------"

mkdir -p "$DAEMON_HOME_1"
mkdir -p "$DAEMON_HOME_2"
mkdir -p "$DAEMON_HOME_3"
mkdir -p "$DAEMON_HOME_4"

echo "--------Start initializing the chain ($CHAINID)---------"

$DAEMON init --chain-id $CHAINID $CHAINID --home $DAEMON_HOME_1
$DAEMON init --chain-id $CHAINID $CHAINID --home $DAEMON_HOME_2
$DAEMON init --chain-id $CHAINID $CHAINID --home $DAEMON_HOME_3
$DAEMON init --chain-id $CHAINID $CHAINID --home $DAEMON_HOME_4

echo "----------Update chain config---------"

echo "----------Updating $DEAMON_HOME_1 chain config-----------"

sed -i 's#tcp://127.0.0.1:26657#tcp://0.0.0.0:16657#g' $DAEMON_HOME_1/config/config.toml
sed -i 's#tcp://127.0.0.1:26656#tcp://0.0.0.0:16656#g' $DAEMON_HOME_1/config/config.toml
sed -i 's/"timeout_commit" = "5s"'
sed -i "s/172800000000000/600000000000/g" $DAEMON_HOME_1/config/genesis.json
sed -i "s/172800s/600s/g" $DAEMON_HOME_1/config/genesis.json
sed -i "s/stake/$DENOM/g" $DAEMON_HOME_1/config/genesis.json

echo "----------Updating $DEAMON_HOME_2 chain config-----------"

sed -i 's#tcp://127.0.0.1:26657#tcp://0.0.0.0:26657#g' $DAEMON_HOME_2/config/config.toml
sed -i 's#tcp://127.0.0.1:26656#tcp://0.0.0.0:26656#g' $DAEMON_HOME_2/config/config.toml
sed -i 's/"timeout_commit" = "5s"'
sed -i "s/172800000000000/600000000000/g" $DAEMON_HOME_2/config/genesis.json
sed -i "s/172800s/600s/g" $DAEMON_HOME_2/config/genesis.json
sed -i "s/stake/$DENOM/g" $DAEMON_HOME_2/config/genesis.json

echo "----------Updating $DEAMON_HOME_3 chain config------------"

sed -i 's#tcp://127.0.0.1:26657#tcp://0.0.0.0:36657#g' $DAEMON_HOME_3/config/config.toml
sed -i 's#tcp://127.0.0.1:26656#tcp://0.0.0.0:36656#g' $DAEMON_HOME_3/config/config.toml
sed -i 's/"timeout_commit" = "5s"'
sed -i "s/172800000000000/600000000000/g" $DAEMON_HOME_3/config/genesis.json
sed -i "s/172800s/600s/g" $DAEMON_HOME_3/config/genesis.json
sed -i "s/stake/$DENOM/g" $DAEMON_HOME_3/config/genesis.json

echo "----------Updating $DEAMON_HOME_4 chain config------------"

sed -i 's#tcp://127.0.0.1:26657#tcp://0.0.0.0:46657#g' $DAEMON_HOME_4/config/config.toml
sed -i 's#tcp://127.0.0.1:26656#tcp://0.0.0.0:46656#g' $DAEMON_HOME_4/config/config.toml
sed -i 's/"timeout_commit" = "5s"'
sed -i "s/172800000000000/600000000000/g" $DAEMON_HOME_4/config/genesis.json
sed -i "s/172800s/600s/g" $DAEMON_HOME_4/config/genesis.json
sed -i "s/stake/$DENOM/g" $DAEMON_HOME_4/config/genesis.json

echo "---------Create four validators-------------"

$DAEMON keys add validator1 --keyring-backend test --home $DAEMON_HOME_1
$DAEMON keys add validator2 --keyring-backend test --home $DAEMON_HOME_2
$DAEMON keys add validator3 --keyring-backend test --home $DAEMON_HOME_3
$DAEMON keys add validator4 --keyring-backend test --home $DAEMON_HOME_4

echo "----------Genesis creation---------"

# Now its time to construct the genesis file
CURRENT_TIME_SECONDS=$(( date +%s ))
VESTING_STARTTIME=$(( $CURRENT_TIME_SECONDS + 10 ))
VESTING_ENDTIME=$(( $CURRENT_TIME_SECONDS + 10000 ))

$DAEMON --home $DAEMON_HOME add-genesis-account w1 --keyring-backend test 1000000000000$DENOM --vesting-amount 1000000000000$DENOM --vesting-start-time $VESTING_STARTTIME --vesting-end-time $VESTING_ENDTIME
$DAEMON --home $DAEMON_HOME add-genesis-account w5 1000000000000$DENOM  --keyring-backend test
$DAEMON --home $DAEMON_HOME add-genesis-account validator 1000000000000$DENOM  --keyring-backend test
$DAEMON --home $DAEMON_HOME add-genesis-account faucet 1000000000000$DENOM  --keyring-backend test
$DAEMON --home $DAEMON_HOME add-genesis-account w2 --keyring-backend test 1000000000000$DENOM --vesting-amount 100000000000$DENOM --vesting-start-time $VESTING_STARTTIME --vesting-end-time $VESTING_ENDTIME
$DAEMON --home $DAEMON_HOME add-genesis-account w3 --keyring-backend test 1000000000000$DENOM --vesting-amount 500000000000$DENOM --vesting-start-time $VESTING_STARTTIME --vesting-end-time $VESTING_ENDTIME
$DAEMON --home $DAEMON_HOME add-genesis-account w4 --keyring-backend test 1000000000000$DENOM --vesting-amount 500000000000$DENOM --vesting-start-time $VESTING_STARTTIME --vesting-end-time $VESTING_ENDTIME

$DAEMON gentx validator 90000000000$DENOM --chain-id $CHAINID  --keyring-backend test --home $DAEMON_HOME
$DAEMON collect-gentxs --home $DAEMON_HOME

VAL_OPR_ADDRESS=$($CLI keys show validator -a --bech val --keyring-backend test)

echo "---------Creating system file---------"

echo "[Unit]
Description=${DAEMON} daemon
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which $DAEMON) start --home $DAEMON_HOME
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
">$DAEMON.service

sudo mv $DAEMON.service /lib/systemd/system/$DAEMON.service

echo "-------Start $DAEMON service-------"

sudo -S systemctl daemon-reload
sudo -S systemctl start $DAEMON

sleep 10s

echo "Checking chain status"

$CLI status --home $DAEMON_HOME

echo
echo