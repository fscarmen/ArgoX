# 【ArgoX】 = Argo + Xray

中文 | [English](README_EN.md)

* * *

# 目录

- [更新信息](README.md#更新信息)
- [项目特点](README.md#项目特点)
- [交互式运行脚本](README.md#交互式运行脚本)
- [无交互极速安装](README.md#无交互极速安装)
- [Argo Json 的获取](README.md#argo-json-的获取)
- [Argo Token 的获取](README.md#argo-token-的获取)
- [使用 Cloudflare API 自动创建 Argo](README.md#使用-cloudflare-api-自动创建-argo)
- [各种场景下 xray outbound 和 routing 模板的说明](README.md#各种场景下-xray-outbound-和-routing-模板的说明)
- [主体目录文件及说明](README.md#主体目录文件及说明)
- [免责声明](README.md#免责声明)

* * *
## 更新信息
2025.12.15 v1.6.13 Argo 隧道新增通过 API 创建 --- 自动完成：创建隧道 > DNS 配置 > 回源设置。感谢热心网友 [zmlu] 提供的方法: https://raw.githubusercontent.com/zmlu/sba/main/tunnel.sh

2025.12.09 v1.6.12 极速安装模式：新增一键安装功能，所有参数自动填充，简化部署流程。中文用户使用 `-l` 或 `-L`，英文用户使用 `-k` 或 `-K`，大小写均支持，操作更灵活

2025.11.08 v1.6.11 在 AI 帮助下，完善主流客户端 shadowsocks + v2ray-plugin 的设置与 URI

2025.09.01 v1.6.10 1. 适配 xray 25.8.31 reality 公私钥生成方式; 2. 更换 Github 代理

<details>
    <summary>历史更新 history（点击即可展开或收起）</summary>
<br>

>
>2025.04.26 v1.6.9 新增使用 [argox -d] 在线更换 CDN 功能
>
>2025.04.25 v1.6.8 1. 更改 GitHub 代理; 2. 处理 CentOS 防火墙端口管理; 3. 优化代码
>
>2025.04.21 v1.6.7 在 Alpine 系统中使用 OpenRC 取代兼容 Python3 的 systemctl 实现
>
>2024.12.24 v1.6.6 根据 lmc999 的检测解锁脚本，重构了检测 chatGPT 方法
>
>2024.5.20 v1.6.5 1. 添加 Github 加速 CDN; 2. 去掉订阅模板2
>
>2024.3.26 v1.6.4 感谢 UUb 兄弟的官改编译，依赖 jq, qrencode 从 apt 安装改为下载二进制文件，缩减安装时间约15秒，贯彻项目轻量化的定位，尽最大可能安装最少的系统依赖
>
>2024.3.24 v1.6.3 1. 适配 CentOS 7,8,9; 2. 去掉默认的 Github 加速网
>
>2024.3.13 v1.6.2 1. 在线订阅改为可选项，如不需要，不安装 nginx 和 qrcode; 2. 如自身支持解锁 chatGPT，则使用原生 IP，否则使用 warp 链式代理解锁
>
>2024.3.10 v1.6.1 1. 为保护节点数据安全，在 api 转订阅时，使用虚假信息; 2. 自适应以上的客户端，https://\<argo tunnel url\>/\<uuid\>/\<auto | auto2\>
>
>2024.3.2 v1.6 1. 增加 V2rayN / Nekobox / Clash / sing-box / Shadowrocket 订阅，https://\<argo tunnel url\>/\<uuid\>/\<base64 | clash | sing-box-pc | sing-box-phone | proxies | qr\>， 所有订阅的索引: https://\<argo tunnel url\>/\<uuid\>/，需要重新安装; 2. 自适应以上的客户端，https://\<argo tunnel url\>/\<uuid\>/\<auto | auto2\>
>
>2024.2.6 V1.5 Argo 运行的协议使用默认值，而不是 http2。默认值为 auto，将自动配置 quic 协议。如果 cloudflared 无法建立 UDP 连接，它将回落到使用 http2 协议。
>
>2023.10.25 V1.4 1. 支持 Reality-Vison and Reality-gRPC，两个均为直连方案; 2. 临时隧道通过 API 查动态域名; 3. 安装后，增加 [argox] 的快捷运行方式; 4. 输出 Sing-box Client 的配置
>
>2023.10.16 V1.3 1. 支持 Alpine; 2. 菜单中增加 sing-box 内存占用显示; 3. 去掉使用 warp 回国的选项
>
>2023.10.11 V1.2 1. 增加禁止归国选项; 2. 增加线上收录的若干优质 cdn 3. 使用 Warp IPv6 访问 chatGPT
>
>2023.6.23 V1.1 为了更好的在各种情景下分流，把 `config.json` 拆分为 `inbound.json` 和 `outbound.json`
>
>2023.4.13 1.0 正式版
>
>2023.3.11 beta6 1. 用户可以通过配套的功能网轻松获取固定域名隧道的 json, https://fscarmen.cloudflare.now.cc;  2. 改掉敏感路径名; 3. 下载增加 CDN
>
>2023.3.4 beta5 1. 把对所有的网络地址监听改为只对 Argo 隧道作定向监听，以增加安全性; 2. Argo 隧道支持双栈
>
>2023.3.2 beta4 把对所有的网络地址监听改为只对 Argo 隧道作定向监听，以增加安全性
>
>2023.2.24 beta3 1. 简化转换 Argo 隧道的方法; 2. 全局用 wget 替代 cURL
>
>2023.2.17 beta2 1.极速安装模式，[-f] 后带参数文件路径；2.安装后，支持三种argo隧道随意切换；3.随时同步Argo 和 Xray到最新版本；4.优化代码，达到提速的目的。
</details>

2023.2.16 beta1 Argo + Xray for vps


## 项目特点:

* 在 VPS 中部署 Xray，采用的方案为  Argo + Xray + Reality / Argo + Xray + WebSocket + TLS；
* 正常用 CF 是访问机房回源，Argo 则是每次创建两个反向链接到两个就近机房，然后回源是通过源服务器就近机房回源，其中用户访问机房到源服务器连接的就近机房之间是CF自己的黑盒线路；
* 使用 CloudFlare 的 Argo 隧道，使用TLS加密通信，可以将应用程序流量安全地传输到Cloudflare网络，提高了应用程序的安全性和可靠性。此外，Argo Tunnel也可以防止IP泄露和DDoS攻击等网络威胁；
* Argo 是内网穿透的隧道，既 Xray 的 inbound 不对外暴露端口增加安全性，也不用做伪装网浪费资源，还支持 Cloudflare 的全部端口，不会死守443被封，同时服务端输出 Argo Ws 数据流，大大简化数据处理流程，提高响应，tls 由 cf 提供，避免多重 tls；
* Argo 隧道既支持临时隧道，又支持通过 Token 或者 cloudflared Cli 方式申请的固定域名，直接优选 + 隧道，不需要申请域名证书，并可以在安装后随时转换；
* 同时支持 Xray 的直连协议: reality vison 和 reality gRPC; 以及 ws 回落分流的 4 种主流协议: vless /  vmess / trojan / shadowsocks + WSS (ws + tls)；
* 内置 warp 链式代理解锁 chatGPT；
* 节点信息输出到 V2rayN / Clash Meta / 小火箭 / Nekobox / Sing-box (SFI, SFA, SFM)，订阅自动适配客户端，一个订阅 url 走天下；
* 极速安装，即可交互式安装，也可像 docker compose 一样的非交互式安装，提前把所有的参数放到一个配置文件，全程不到5秒。


## 交互式运行脚本

```
bash <(wget -qO- https://raw.githubusercontent.com/fscarmen/argox/main/argox.sh)
```

  | Option 参数 | Remark 备注 |
  | -----------| ------ |
  | -c         | Chinese 中文 |
  | -e         | English 英文 |
  | -l         | 使用中文快速安装 |
  | -k         | 使用英文快速安装 |
  | -a         | Argo 开关 |
  | -x         | Xray 开关 |
  | -f         | 参数文件，可参数项目的文件 config.conf |
  | -t         | 更换 Argo 隧道 |
  | -d         | 更换优选域名 |
  | -u         | 卸载 |
  | -n         | 显示节点信息 |
  | -v         | 同步 Argo Xray 到最新版本 |
  | -b         | 升级内核、安装BBR、DD脚本 |


## 无交互极速安装

### 中文
```
bash <(wget -qO- https://raw.githubusercontent.com/fscarmen/argox/main/argox.sh) -l
```

### 英文
```
bash <(wget -qO- https://raw.githubusercontent.com/fscarmen/argox/main/argox.sh) -k
```


## Argo Json 的获取

用户可以通过 Cloudflare Json 生成网轻松获取: https://fscarmen.cloudflare.now.cc

![image](https://user-images.githubusercontent.com/62703343/224388718-6adf22d0-01d3-46a0-8063-bc0a2210795f.png)

如想手动，可以参考，以 Debian 为例，需要用到的命令，[Deron Cheng - CloudFlare Argo Tunnel 试用](https://zhengweidong.com/try-cloudflare-argo-tunnel)


## Argo Token 的获取

详细教程: [群晖套件：Cloudflare Tunnel 内网穿透中文教程 支持DSM6、7](https://imnks.com/5984.html)

<img width="1409" alt="image" src="https://user-images.githubusercontent.com/92626977/218253461-c079cddd-3f4c-4278-a109-95229f1eb299.png">

<img width="1619" alt="image" src="https://user-images.githubusercontent.com/92626977/218253838-aa73b63d-1e8a-430e-b601-0b88730d03b0.png">

<img width="1155" alt="image" src="https://user-images.githubusercontent.com/92626977/218253971-60f11bbf-9de9-4082-9e46-12cd2aad79a1.png">


## 使用 Cloudflare API 自动创建 Argo

1. 访问 https://dash.cloudflare.com/profile/api-tokens
2. API 令牌 > 创建令牌 > 创建自定义令牌
3. 添加以下权限:
   - 帐户 > Cloudflare One连接器: Cloudflared > 编辑
   - 区域 > DNS > 编辑
4. 帐户资源 > 包括 > 所需账户
5. 区域资源 > 包括 > 特定区域 > 所需域名

<img width="1366" height="646" alt="image" src="https://github.com/user-attachments/assets/207bfee1-583d-4a28-acfc-1041555ecf35" />


## 各种场景下 xray outbound 和 routing 模板的说明

* 域名分类中包含的各具体域名: https://github.com/v2fly/domain-list-community/blob/master/data
* Routing 路由说明: https://www.v2fly.org/config/routing.html
* 修改 `/etc/argox/outbound.json`，注意: 请先备份好原 `outbound.json` 文件，修改的 json 做到 https://www.json.cn/ 查看格式
* 修改后运行 `systemctl restart xray; sleep 1; systemctl is-active xray` ，反显 active 即生效，如为 failed 即为失败，请检查配置文件格式

| 说明 | 模板示例 |
| --- | ------ |
| chatGPT 使用链式 warp 代理，不需要本地安装 warp，其余流量走 vps 默认的网络出口 | [warp](https://gitlab.com/fscarmen/warp#通过-warp-解锁-chatgpt-的方法) |
| 指定流量走本机指定的网络接口，对于双栈能区分 IPv4 或 IPv6，其余流量走 vps 默认的网络出口 | [interface](https://gitlab.com/fscarmen/warp#指定网站分流到-interface-的-xray-配置模板适用于-warp-client-warp-和-warp-warp-go-非全局) |
| 指定流量走本机指定的socks5代理，对于双栈能区分 IPv4 或 IPv6，其余流量走 vps 默认的网络出口 | [socks5](https://gitlab.com/fscarmen/warp#指定网站分流到-socks5-的-xray-配置模板-适用于-warp-client-proxy-和-wireproxy) |


## 主体目录文件及说明

```
/etc/argox                    # 项目主体目录
├── subscribe                 # 订阅文件目录
│   ├── qr                    # Nekoray / V2rayN 订阅二维码
│   ├── base64                # Nekoray / V2rayN 订阅文件
│   ├── clash                 # Clash 订阅文件
│   ├── clash2                # Clash 订阅文件2
│   ├── proxies               # Clash proxy provider 订阅文件
│   ├── shadowrocket          # Shadowrocket 订阅文件
│   ├── sing-box-pc           # SFM 订阅文件
│   ├── sing-box-phone        # SFI / SFA 订阅文件
│   └── sing-box2             # SFI / SFA / SFM 订阅文件2
├── cloudflared               # argo tunnel 主程序
├── geoip.dat                 # 用于根据 IP 地址来进行地理位置策略或访问控制
├── geosite.dat               # 用于基于域名或网站分类来进行访问控制、内容过滤或安全策略
├── inbound.json              # vless / vmess / ss / trojan + WSS 入站配置文件
├── language                  # 存放脚本语言文件，E 为英文，C 为中文
├── list                      # 节点信息列表
├── outbound.json             # 出站和路由配置文件，chatGPT 使用 warp ipv6 链式代理出站
├── xray                      # xray 主程序
├── nginx.conf                # Nginx 配置文件
├── ax.sh                     # 快捷方式脚本文件
├── jq                        # 命令行 JSON 处理器
└── qrencode                  # QR 码编码二进制文件
```


## 免责声明:
* 本程序仅供学习了解, 非盈利目的，请于下载后 24 小时内删除, 不得用作任何商业用途, 文字、数据及图片均有所属版权, 如转载须注明来源。
* 使用本程序必循遵守部署免责声明。使用本程序必循遵守部署服务器所在地、所在国家和用户所在国家的法律法规, 程序作者不对使用者任何不当行为负责。