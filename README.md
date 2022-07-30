# SS-Obfuscator
Shadowsocks client (with GUI) and server (for VPS) with obfuscation  
**Dependencies:** shadowsocks-libev systemd  
  
SS-Obfuscator-Server
--
Rent a VPS with a foreign IP address and install a package on it `ss-obfuscator-server` (rpm/deb)

SS-Obfuscator-Client
--
Install the `ss-obfuscator-client` package to your computer, launch the GUI, enter the IP address of your server (VPS) and click the `Start` button. Set up a connection in your browser via the SOCKS5 proxy 127.0.0.1:1080. Also check the box `Send DNS requests via SOCKS5 proxy`. You can check your new location here: https://whoer.net  
  
![](https://github.com/AKotov-dev/SS-Obfuscator/blob/main/ScreenShots/ScreenShotClient-2.png)  
  
Details:
--
By default, the password is already set (50 characters). When changing the password to your own, do not forget to change it on the server in the file `/etc/ss-obfuscator-server/server.json`. If you need a client configuration file, it is here: `~/.config/ss-obfuscator-client/client.json`  
  
Similar project: [vmess-ws](https://github.com/AKotov-dev/vmess-ws)
