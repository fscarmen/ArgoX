# 【ArgoX】 = Argo + Xray

* * *

# 目录

- [更新信息](README.md#更新信息)
- [项目特点](README.md#项目特点)
- [ArgoX for VPS 运行脚本](README.md#argox-for-vps-运行脚本)
- [鸣谢下列作者的文章和项目](README.md#鸣谢下列作者的文章和项目)
- [免责声明](README.md#免责声明)

* * *

## 更新信息
2023.2.16 beta Argo + Xray for vps

## 项目特点:

* 在 VPS 中部署 Xray，采用的方案为 Argo + Xray + WebSocket + TLS
* 使用 CloudFlare 的 Argo 隧道，既支持临时隧道，又支持通过 Token 或者 cloudflared Cli 方式申请的固定域名，直接优选 + 隧道，不需要申请域名证书
* 回流分流，同时支持 Xray 4 种主流协议: vless /  vmess / trojan / shadowsocks + WSS (ws + tls)
* vmess 和 vless 的 uuid，trojan 和 shadowsocks 的 password，各协议的 ws 路径既可以自定义，又或者使用默认值
* 节点信息以 V2rayN / Clash / 小火箭 链接方式输出
* 极速安装，大大节省用户时间

## ArgoX for VPS 运行脚本:

```
bash <(wget -qO- https://raw.githubusercontent.com/fscarmen/argox/main/argox.sh)
```

  | Option 参数 | Remark 备注 | 
  | -----------| ------ |
  | -c         | Chinese 中文 |
  | -e         | English 英文 | 
  | -u         | Uninstall 卸载 |
  | -l         | Export Node list 显示节点信息 |
  | -d         | Argo Domain 认证域名 |
  | -a         | Argo Token / Argo Json |
  | -i         | Xray UUID. Default : ffffffff-ffff-ffff-ffff-ffffffffffff |
  | -w         | Xray WS PATH. Default: argox |

## Argo Token 的获取

详细教程: [群晖套件：Cloudflare Tunnel 内网穿透中文教程 支持DSM6、7](https://imnks.com/5984.html)

<img width="1409" alt="image" src="https://user-images.githubusercontent.com/92626977/218253461-c079cddd-3f4c-4278-a109-95229f1eb299.png">

<img width="1619" alt="image" src="https://user-images.githubusercontent.com/92626977/218253838-aa73b63d-1e8a-430e-b601-0b88730d03b0.png">

<img width="1155" alt="image" src="https://user-images.githubusercontent.com/92626977/218253971-60f11bbf-9de9-4082-9e46-12cd2aad79a1.png">


## 鸣谢下列作者的文章和项目:


## 免责声明:
* 本程序仅供学习了解, 非盈利目的，请于下载后 24 小时内删除, 不得用作任何商业用途, 文字、数据及图片均有所属版权, 如转载须注明来源。
* 使用本程序必循遵守部署免责声明。使用本程序必循遵守部署服务器所在地、所在国家和用户所在国家的法律法规, 程序作者不对使用者任何不当行为负责。