# 【ArgoX】 = Argo + Xray

[中文](README.md) | English

* * *

# Table of Contents

- [Update Information](README_EN.md#update-information)
- [Project Features](README_EN.md#project-features)
- [Interactive Running Script](README.md#interactive-running-script)
- [Non-interactive Ultra-fast Installation](README_EN.md#non-interactive-ultra-fast-installation)
- [Obtaining Argo Json](README_EN.md#obtaining-argo-json)
- [Obtaining Argo Token](README_EN.md#obtaining-argo-token)
- [Use Cloudflare API to automatically create Argo](README_EN.md#use-cloudflare-api-to-automatically-create-argo)
- [Description of Xray outbound and routing templates in various scenarios](README_EN.md#description-of-xray-outbound-and-routing-templates-in-various-scenarios)
- [Main directory files and descriptions](README_EN.md#main-directory-files-and-descriptions)
- [Disclaimer](README_EN.md#disclaimer)

* * *

## Update Information
2025.12.15 v1.6.13 Argo tunnel creation via API --- Automatically completed: Create tunnel > DNS configuration > Origin settings. Thanks to [zmlu] for providing the method: https://raw.githubusercontent.com/zmlu/sba/main/tunnel.sh

2025.12.09 v1.6.12 Quick Install Mode: Added a one-click installation feature that auto-fills all parameters, simplifying the deployment process. Chinese users can use `-l` or `-L`; English users can use `-k` or `-K`. Case-insensitive support makes operations more flexible.

2025.11.08 v1.6.11 feat: Refine Shadowsocks + v2ray-plugin configurations and URIs for mainstream clients with AI assistance

2025.09.01 v1.6.10 1. Adapted to the new reality key pair generation method in xray 25.8.31; 2. Updated GitHub proxy

<details>
    <summary>Historical Updates（Click to expand or collapse）</summary>
<br>

>2025.04.26 v1.6.9 Added the ability to change CDNs online using [argox -d]
>
>2025.04.25 v1.6.8 1. Change GitHub proxy; 2. Handle CentOS firewall port management 3. Optimize code
>
>2025.04.21 v1.6.7 Use OpenRC on Alpine to replace systemctl (Python3-compatible version)
>
>2024.12.24 v1.6.6 Refactored the chatGPT detection method based on lmc999's detection and unlocking script

>2024.5.20 v1.6.5 1. Add Github CDN; 2. Remove subscription template 2

>2024.3.26 v1.6.4 Thanks to UUb for the official change of the compilation, dependencies jq, qrencode from apt installation to download the binary file, reduce the installation time of about 15 seconds, the implementation of the project's positioning of lightweight, as far as possible to install the least system dependencies

>2024.3.24 v1.6.3 1. Compatible with CentOS 7,8,9; 2. Remove default Github CDN

>2024.3.13 v1.6.2 1. Subscription made optional, no nginx and qrcode installed if not needed; 2. Use native IP if it supports unlocking chatGPT, otherwise use warp chained proxy unlocking

>2024.3.10 v1.6.1 1. To protect node data security, use fake information to fetch subscribe api; 2. Adaptive the above clients. https://\<argo tunnel url\>/\<uuid\>/\<auto | auto2\>

>2024.3.2 v1.6 1. Support V2rayN / Nekobox / Clash / sing-box / Shadowrocket subscribe. https://\<argo tunnel url\>/\<uuid\>/\<base64 | clash | sing-box-pc | sing-box-phone | proxies | qr\>. Index of all subscribes: https://\<argo tunnel url\>/\<uuid\>/  ; Reinstall is required; 2. Adaptive the above clients. https://\<argo tunnel url\>/\<uuid\>/\<auto | auto2\>

>2024.2.6 V1.5 Argo run protocol uses default instead of http2. The default value is auto, what will automatically configure the quic protocol. If cloudflared is unable to establish UDP connections, it will fallback to using the http2 protocol

>2023.10.25 V1.4 1. Support Reality-Vison and Reality-gRPC, Both are direct connect solutions; 2. Quick-tunnel through the API to check dynamic domain names1; 3. After installing, add [argox] shortcut; 4. Output the configuration for Sing-box Client

>2023.10.16 V1.3 1. Support Alpine; 2. Add Sing-box PID, runtime, and memory usage to the menu; 3. Remove the option of using warp on returning to China

>2023.10.11 V1.2 1. Add the option of blocking on returning to China; 2. Add a number of quality cdn's that are collected online; 3. Use Warp IPv6 to visit chatGPT

>2023.6.23 V1.1 For better network traffic diversion in various scenarios, split `config.json` into `inbound.json` and `outbound.json`

>2023.4.13 1.0

>2023.3.11 beta6 1. Users can easily obtain the JSON of a fixed domain name tunnel through the accompanying function website at https://fscarmen.cloudflare.now.cc ; 2. Change the sensitive path names; 3. Add CDN for download

>2023.3.4 beta5 1. Change listening to all network addresses to only Argo tunnel directed listening for added security; 2. Argo Tunnel supports dualstack

>2023.3.2 beta4 Change listening to all network addresses to only Argo tunnel directed listening for added security

>2023.2.24 beta3 1. Simplify the operation of changing argo tunnel; 2. Use wget global instead of cURL

>2023.2.17 beta2 1. extremely fast installation mode, [-f] followed by a parameter file path; 2. Support for switching between the three argo tunnels; 3. Synchronise Argo and Xray to the newest version at any time; 4. Optimize the code to achieve speedup.

>2023.2.16 beta1 Argo + Xray for vps
</details>

## Project Features:

* Deploy Xray in VPS, using the scheme Argo + Xray + Reality / Argo + Xray + WebSocket + TLS;
* Normally CF backhauls from data centers, Argo creates two reverse links to two nearby data centers, and backhauls from the source server through the nearby data centers. The line between the user's data center and the source server's nearby data center is CF's proprietary black box line;
* Using CloudFlare's Argo Tunnel with TLS encrypted communication, application traffic can be securely transmitted to the Cloudflare network, improving application security and reliability. In addition, Argo Tunnel can also prevent network threats such as IP leaks and DDoS attacks;
* Argo is an intranet tunnel, meaning Xray's inbound does not expose ports externally, increasing security, and does not require camouflage websites that waste resources. It also supports all Cloudflare ports, not just port 443 which can be blocked. At the same time, the server outputs Argo Ws data streams, greatly simplifying data processing and improving response. TLS is provided by CF, avoiding multiple TLS;
* Argo Tunnel supports both temporary tunnels and fixed domain names through Token or cloudflared Cli methods. Direct optimization + tunnel does not require domain certificates and can be converted at any time after installation;
* Supports Xray's direct connection protocols: reality vision and reality gRPC; as well as ws fallback traffic splitting for 4 mainstream protocols: vless / vmess / trojan / shadowsocks + WSS (ws + tls);
* Built-in warp chained proxy to unlock chatGPT;
* Node information output to V2rayN / Clash Meta / Shadowrocket / Nekobox / Sing-box (SFI, SFA, SFM), subscription automatically adapts to clients, one subscription url for everything;
* Ultra-fast installation, either interactive or non-interactive like docker compose. Put all parameters in a configuration file in advance, taking less than 5 seconds.

## Interactive Running Script

```
bash <(wget -qO- https://raw.githubusercontent.com/fscarmen/argox/main/argox.sh)
```

  | Option | Remark |
  | ------ | ------ |
  | -c     | Chinese |
  | -e     | English |
  | -l     | Quick deploy (Chinese version) |
  | -k     | Quick deploy (English version) |
  | -a     | Argo on-off |
  | -x     | Xray on-off |
  | -f     | Variable file, refer to REPO file "config" |
  | -t     | Change the Argo Tunnel |
  | -d     | Change the CDN |
  | -u     | Uninstall |
  | -n     | Export Nodes list |
  | -v     | Sync Argo Xray to the newest |
  | -b     | Upgrade kernel, turn on BBR, change Linux system |

## Non-interactive Ultra-fast Installation

### Chinese
```
bash <(wget -qO- https://raw.githubusercontent.com/fscarmen/argox/main/argox.sh) -l
```

### English
```
bash <(wget -qO- https://raw.githubusercontent.com/fscarmen/argox/main/argox.sh) -k
```

## Obtaining Argo Json

Users can easily obtain it through the Cloudflare Json generation website: https://fscarmen.cloudflare.now.cc

![image](https://user-images.githubusercontent.com/62703343/224388718-6adf22d0-01d3-46a0-8063-bc0a2210795f.png)

If you want to do it manually, you can refer to the commands needed for Debian as an example, [Deron Cheng - CloudFlare Argo Tunnel Trial](https://zhengweidong.com/try-cloudflare-argo-tunnel)

## Obtaining Argo Token

Detailed tutorial: [Synology Suite: Chinese Tutorial for Cloudflare Tunnel Penetration Support DSM6, 7](https://imnks.com/5984.html)

<img width="1409" alt="image" src="https://user-images.githubusercontent.com/92626977/218253461-c079cddd-3f4c-4278-a109-95229f1eb299.png">

<img width="1619" alt="image" src="https://user-images.githubusercontent.com/92626977/218253838-aa73b63d-1e8a-430e-b601-0b88730d03b0.png">

<img width="1155" alt="image" src="https://user-images.githubusercontent.com/92626977/218253971-60f11bbf-9de9-4082-9e46-12cd2aad79a1.png">

## Use Cloudflare API to automatically create Argo

1. Visit https://dash.cloudflare.com/profile/api-tokens
2. API Tokens > Create Token > Create Custom Token
3. Add the following permissions:
   - Account > Cloudflare One Connectors: cloudflared > Edit
   - Zone > DNS > Edit
4. Account Resources: Include > Required Account
5. Zone Resources: Include > Specific zone > Argo Root Domain

<img width="1336" height="691" alt="image" src="https://github.com/user-attachments/assets/e9c6d946-02ed-48fc-81c4-0fe374461eca" />

## Description of Xray outbound and routing templates in various scenarios

* Domain classifications containing specific domains: https://github.com/v2fly/domain-list-community/blob/master/data
* Routing instructions: https://www.v2fly.org/config/routing.html
* Modify `/etc/argox/outbound.json`. Note: Please backup the original `outbound.json` file first. Check the format of the modified json at https://www.json.cn/
* After modification, run `systemctl restart xray; sleep 1; systemctl is-active xray`. If it shows active, it's effective. If it shows failed, check the configuration file format.

| Description | Template Example |
| --- | ------ |
| chatGPT uses chained warp proxy, no need to install warp locally, other traffic goes through vps default network exit | [warp](https://gitlab.com/fscarmen/warp#通过-warp-解锁-chatgpt-的方法) |
| Specified traffic goes through the specified network interface on the local machine, for dual-stack IPv4 or IPv6 differentiation, other traffic goes through vps default network exit | [interface](https://gitlab.com/fscarmen/warp#指定网站分流到-interface-的-xray-配置模板适用于-warp-client-warp-和-warp-warp-go-非全局) |
| Specified traffic goes through the specified socks5 proxy on the local machine, for dual-stack IPv4 or IPv6 differentiation, other traffic goes through vps default network exit | [socks5](https://gitlab.com/fscarmen/warp#指定网站分流到-socks5-的-xray-配置模板-适用于-warp-client-proxy-和-wireproxy) |

## Main directory files and descriptions

```
/etc/argox                    # Project main directory
├── subscribe                 # Subscription files directory
│   ├── qr                    # Nekoray / V2rayN subscription QR codes
│   ├── base64                # Nekoray / V2rayN subscription files
│   ├── clash                 # Clash subscription files
│   ├── clash2                # Clash subscription files2
│   ├── proxies               # Clash proxy provider subscription files
│   ├── shadowrocket          # Shadowrocket subscription files
│   ├── sing-box-pc           # SFM subscription files
│   ├── sing-box-phone        # SFI / SFA subscription files
│   └── sing-box2             # SFI / SFA / SFM subscription files2
├── cloudflared               # argo tunnel program
├── geoip.dat                 # Used for geographical location policies or access control based on IP addresses
├── geosite.dat               # Used for access control, content filtering or security policies based on domain names or website classifications
├── inbound.json              # vless / vmess / ss / trojan + WSS inbound configuration file
├── language                  # Store script language files, E for English, C for Chinese
├── list                      # Node information list
├── outbound.json             # Outbound and routing configuration file, chatGPT uses warp ipv6 chained proxy outbound
├── xray                      # xray main program
├── nginx.conf                # Nginx configuration file
├── ax.sh                     # Shortcut script file
├── jq                        # Command-line JSON processor
└── qrencode                  # QR code encoding binary file
```

## Disclaimer:
* This program is for learning and understanding only, non-profit. Please delete within 24 hours after downloading. It must not be used for any commercial purposes. Text, data and images are copyrighted. Reproduction must indicate the source.
* Use of this program must comply with the deployment disclaimer. Users must abide by the laws and regulations of the deployment server's location, country and the user's country. The program author is not responsible for any improper actions by users.