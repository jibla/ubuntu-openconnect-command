# Install openconnect
`sudo apt-get install openconnect lib32ncurses5 lib32tinfo5 lib32z1 libc6-i386 libpkcs11-helper1 openvpn vpnc-scripts`

# Usage

* Clone this repo
* Modify `vpn.sh` with your credentials
* chmod o+x vpn.sh
* mv vpn.sh /etc/init.d/
* Use it with `service vpn start|stop|restart` command patterns.
