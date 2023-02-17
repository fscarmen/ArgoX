# 【ArgoX】 = Argo + Xray

* * *

# 目录

- [更新信息](README.md#更新信息)
- [项目特点](README.md#项目特点)
- [ArgoX for VPS 运行脚本](README.md#argox-for-vps-运行脚本)
- [Argo Token 的获取](README.md#argo-token-的获取)
- [Argo Json 的获取](README.md#argo-json-的获取)
- [鸣谢下列作者的文章和项目](README.md#鸣谢下列作者的文章和项目)
- [免责声明](README.md#免责声明)

* * *

## 更新信息
2023.2.17 beta2 1. extremely fast installation mode, [-f] followed by a parameter file path; 2. Support for switching between the three argo tunnels; 3. Synchronise Argo and Xray to the latest version at any time; 4. Optimize the code to achieve speedup.    
1.极速安装模式，[-f] 后带参数文件路径；2.安装后，支持三种argo隧道随意切换；3.随时同步Argo 和 Xray到最新版本；4.优化代码，达到提速的目的。

2023.2.16 beta Argo + Xray for vps

## 项目特点:

* 在 VPS 中部署 Xray，采用的方案为 Argo + Xray + WebSocket + TLS
* 使用 CloudFlare 的 Argo 隧道，使用TLS加密通信，可以将应用程序流量安全地传输到Cloudflare网络，提高了应用程序的安全性和可靠性。此外，Argo Tunnel也可以防止IP泄露和DDoS攻击等网络威胁。因为是内网穿透，Xray 的 inbound 甚至可以由监听所有 0.0.0.0 改为只监听本地 127.0.0.1
* Argo 隧道既支持临时隧道，又支持通过 Token 或者 cloudflared Cli 方式申请的固定域名，直接优选 + 隧道，不需要申请域名证书，并可以在安装后随时转换
* 回落分流，同时支持 Xray 4 种主流协议: vless /  vmess / trojan / shadowsocks + WSS (ws + tls)
* vmess 和 vless 的 uuid，trojan 和 shadowsocks 的 password，各协议的 ws 路径既可以自定义，又或者使用默认值
* 节点信息以 V2rayN / Clash / 小火箭 链接方式输出
* 极速安装，即可交互式安装，也在同类脚本中使用类似于 docker compose，提前把所有的参数放到一个配置文件，全程不到5秒

## ArgoX for VPS 运行脚本:

```
bash <(wget -qO- https://raw.githubusercontent.com/fscarmen/argox/main/argox.sh)
```

  | Option 参数 | Remark 备注 | 
  | -----------| ------ |
  | -c         | Chinese 中文 |
  | -e         | English 英文 | 
  | -f file    | Variable file 参数文件 | 
  | -u         | Uninstall 卸载 |
  | -l         | Export Node list 显示节点信息 |
  | -v         | Sync Argo Xray to the newest 同步 Argo Xray 到最新版本 |

## Argo Token 的获取

详细教程: [群晖套件：Cloudflare Tunnel 内网穿透中文教程 支持DSM6、7](https://imnks.com/5984.html)

<img width="1409" alt="image" src="https://user-images.githubusercontent.com/92626977/218253461-c079cddd-3f4c-4278-a109-95229f1eb299.png">

<img width="1619" alt="image" src="https://user-images.githubusercontent.com/92626977/218253838-aa73b63d-1e8a-430e-b601-0b88730d03b0.png">

<img width="1155" alt="image" src="https://user-images.githubusercontent.com/92626977/218253971-60f11bbf-9de9-4082-9e46-12cd2aad79a1.png">

## Argo Json 的获取

以 Debian 为例，需要用到的命令，[官方安装教程](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation)
```
wget -O cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb # 下载安装包
dpkg -i cloudflared.deb && rm -f cloudflared.deb # 安装并删除安装包
cloudflared login
cloudflared tunnel create 隧道名
cloudflared tunnel route dns 隧道名 二级域名.托管在CF上的一级域名
cat /root/.cloudflared/你生成的json文件  
```

详细教程: [使用Cloudflare Argo Tunnel快速免公网IP建站](https://blog.zapic.moe/archives/tutorial-176.html)

<img width="1532" alt="image" src="https://user-images.githubusercontent.com/62703343/219655506-13a6d716-ea9a-4955-801d-142ae20f3380.png">

<img width="1222" alt="image" src="https://user-images.githubusercontent.com/62703343/219655817-de05191b-47d2-4da1-8f4f-457240d200dd.png">

<img width="1068" alt="image" src="https://user-images.githubusercontent.com/62703343/219657489-f811c374-beb7-48d3-975c-706d94bf0dce.png">


## 鸣谢下列作者的文章和项目:


## 免责声明:
* 本程序仅供学习了解, 非盈利目的，请于下载后 24 小时内删除, 不得用作任何商业用途, 文字、数据及图片均有所属版权, 如转载须注明来源。
* 使用本程序必循遵守部署免责声明。使用本程序必循遵守部署服务器所在地、所在国家和用户所在国家的法律法规, 程序作者不对使用者任何不当行为负责。
