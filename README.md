# 【ArgoX】 = Argo + Xray

* * *

# 目录

- [更新信息](README.md#更新信息)
- [项目特点](README.md#项目特点)
- [ArgoX for VPS 运行脚本](README.md#argox-for-vps-运行脚本)
- [Argo Json 的获取](README.md#argo-json-的获取)
- [Argo Token 的获取](README.md#argo-token-的获取)
- [鸣谢下列作者的文章和项目](README.md#鸣谢下列作者的文章和项目)
- [免责声明](README.md#免责声明)

* * *
## 更新信息
2023.3.11 beta6 1. Users can easily obtain the JSON of a fixed domain name tunnel through the accompanying function website at https://fscarmen.cloudflare.now.cc ; 2. Change the sensitive path names; 3. Add CDN for download; 1. 用户可以通过配套的功能网轻松获取固定域名隧道的 json, https://fscarmen.cloudflare.now.cc;  2. 改掉敏感路径名; 3. 下载增加 CDN

2023.3.4 beta5 1. Change listening to all network addresses to only Argo tunnel directed listening for added security; 2. Argo Tunnel supports dualstack; 1. 把对所有的网络地址监听改为只对 Argo 隧道作定向监听，以增加安全性; 2. Argo 隧道支持双栈

2023.3.2 beta4 Change listening to all network addresses to only Argo tunnel directed listening for added security; 把对所有的网络地址监听改为只对 Argo 隧道作定向监听，以增加安全性

2023.2.24 beta3 1. Simplify the operation of changing argo tunnel; 2. Use wget global instead of cURL; 1. 简化转换 Argo 隧道的方法; 2. 全局用 wget 替代 cURL

2023.2.17 beta2 1. extremely fast installation mode, [-f] followed by a parameter file path; 2. Support for switching between the three argo tunnels; 3. Synchronise Argo and Xray to the latest version at any time; 4. Optimize the code to achieve speedup.
1.极速安装模式，[-f] 后带参数文件路径；2.安装后，支持三种argo隧道随意切换；3.随时同步Argo 和 Xray到最新版本；4.优化代码，达到提速的目的。

2023.2.16 beta1 Argo + Xray for vps


## 项目特点:

* 在 VPS 中部署 Xray，采用的方案为 Argo + Xray + WebSocket + TLS；
* 正常用 CF 是访问机房回源，Argo 则是每次创建两个反向链接到两个就近机房，然后回源是通过源服务器就近机房回源，其中用户访问机房到源服务器连接的就近机房之间是CF自己的黑盒线路；
* 使用 CloudFlare 的 Argo 隧道，使用TLS加密通信，可以将应用程序流量安全地传输到Cloudflare网络，提高了应用程序的安全性和可靠性。此外，Argo Tunnel也可以防止IP泄露和DDoS攻击等网络威胁；
* Argo 是内网穿透的隧道，既 Xray 的 inbound 不对外暴露端口增加安全性，也不用做伪装网浪费资源，还支持 Cloudflare 的全部端口，不会死守443被封，同时服务端输出 Argo Ws 数据流，大大简化数据处理流程，提高响应，tls 由 cf 提供，避免多重 tls；
* Argo 隧道既支持临时隧道，又支持通过 Token 或者 cloudflared Cli 方式申请的固定域名，直接优选 + 隧道，不需要申请域名证书，并可以在安装后随时转换；
* 回落分流，同时支持 Xray 4 种主流协议: vless /  vmess / trojan / shadowsocks + WSS (ws + tls)；
* vmess 和 vless 的 uuid，trojan 和 shadowsocks 的 password，各协议的 ws 路径既可以自定义，又或者使用默认值；
* 节点信息以 V2rayN / Clash / 小火箭 链接方式输出；
* 极速安装，即可交互式安装，也可像 docker compose 一样的非交互式安装，提前把所有的参数放到一个配置文件，全程不到5秒。


## ArgoX for VPS 运行脚本:

```
bash <(wget -qO- https://raw.githubusercontent.com/fscarmen/argox/main/argox.sh)
```

  | Option 参数 | Remark 备注 | 
  | -----------| ------ |
  | -c         | Chinese 中文 |
  | -e         | English 英文 | 
  | -f         | Variable file，refer to REPO file "config" 参数文件，可参数项目的文件 config | 
  | -u         | Uninstall 卸载 |
  | -e         | Export Node list 显示节点信息 |
  | -v         | Sync Argo Xray to the newest 同步 Argo Xray 到最新版本 |


## Argo Json 的获取

用户可以通过 Cloudflare Json 生成网轻松获取: https://fscarmen.cloudflare.now.cc

![image](https://user-images.githubusercontent.com/62703343/224388718-6adf22d0-01d3-46a0-8063-bc0a2210795f.png)

如想手动，可以参考，以 Debian 为例，需要用到的命令，[Deron Cheng - CloudFlare Argo Tunnel 试用](https://zhengweidong.com/try-cloudflare-argo-tunnel)


## Argo Token 的获取

详细教程: [群晖套件：Cloudflare Tunnel 内网穿透中文教程 支持DSM6、7](https://imnks.com/5984.html)

<img width="1409" alt="image" src="https://user-images.githubusercontent.com/92626977/218253461-c079cddd-3f4c-4278-a109-95229f1eb299.png">

<img width="1619" alt="image" src="https://user-images.githubusercontent.com/92626977/218253838-aa73b63d-1e8a-430e-b601-0b88730d03b0.png">

<img width="1155" alt="image" src="https://user-images.githubusercontent.com/92626977/218253971-60f11bbf-9de9-4082-9e46-12cd2aad79a1.png">


## 鸣谢下列作者的文章和项目:


## 免责声明:
* 本程序仅供学习了解, 非盈利目的，请于下载后 24 小时内删除, 不得用作任何商业用途, 文字、数据及图片均有所属版权, 如转载须注明来源。
* 使用本程序必循遵守部署免责声明。使用本程序必循遵守部署服务器所在地、所在国家和用户所在国家的法律法规, 程序作者不对使用者任何不当行为负责。