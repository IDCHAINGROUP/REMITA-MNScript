#!/bin/bash

#stop_daemon function
function stop_daemon {
    if pgrep -x 'remitad' > /dev/null; then
        echo -e "${YELLOW}Attempting to stop remitad${NC}"
        remita-cli stop
        sleep 30
        if pgrep -x 'remitad' > /dev/null; then
            echo -e "${RED}remitad daemon is still running!${NC} \a"
            echo -e "${RED}Attempting to kill...${NC}"
            sudo pkill -9 remitad
            sleep 30
            if pgrep -x 'remitad' > /dev/null; then
                echo -e "${RED}Can't stop remitad! Reboot and try again...${NC} \a"
                exit 2
            fi
        fi
    fi
}


echo "Your Remitacoin Masternode Will be Updated To The Latest Version v2.0.0 Now" 
sudo apt-get -y install unzip

#remove crontab entry to prevent daemon from starting
crontab -l | grep -v 'remitaauto.sh' | crontab -

#Stop remitad by calling the stop_daemon function
stop_daemon

rm -rf /usr/local/bin/remita*
mkdir REMIT_2.0.0
cd REMIT_2.0.0
wget https://github.com/IDCHAINGROUP/REMITA/releases/download/v2.0.0/remita-2.0.0-ubuntu-daemon.tar.gz
tar -xzvf remita-2.0.0-ubuntu-daemon.tar.gz
mv remitad /usr/local/bin/remitad
mv remita-cli /usr/local/bin/remita-cli
chmod +x /usr/local/bin/remita*
rm -rf ~/.remita/blocks
rm -rf ~/.remita/chainstate
rm -rf ~/.remita/sporks
rm -rf ~/.remita/peers.dat
cd ~/.remita/
wget https://github.com/IDCHAINGROUP/REMITA/releases/download/v2.0.0/bootstrap.zip
unzip bootstrap.zip

cd ..
rm -rf ~/.remita/bootstrap.zip ~/REMIT_2.0.0

# add new nodes to config file
sed -i '/addnode/d' ~/.remita/remita.conf

echo "addnode=45.63.2.245
addnode=207.246.94.60
addnode=45.77.151.81
addnode=45.77.96.149" >> ~/.remita/remita.conf

#start remitad
remitad -daemon

printf '#!/bin/bash\nif [ ! -f "~/.remita/remitad.pid" ]; then /usr/local/bin/remitad -daemon ; fi' > /root/remitaauto.sh
chmod -R 755 /root/remitaauto.sh
#Setting auto start cron job for Remitacoin
if ! crontab -l | grep "remitaauto.sh"; then
    (crontab -l ; echo "*/5 * * * * /root/remitaauto.sh")| crontab -
fi

echo "Masternode Updated!"
echo "Please wait a few minutes and start your Masternode again on your Local Wallet"