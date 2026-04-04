#!/usr/bin/env bash

# 当前脚本版本号
VERSION='2.0.2 (2026.04.04)'

# Github 反代加速代理
GITHUB_PROXY=('https://v6.gh-proxy.org/' 'https://gh-proxy.com/' 'https://hub.glowp.xyz/' 'https://proxy.vvvv.ee/' 'https://ghproxy.lvedong.eu.org/')

# 协议列表和对应的节点标签，顺序必须一一对应
PROTOCOL_LIST=("VLESS + Reality Vision" "Hysteria2" "VLESS + Reality gRPC" "VLESS + WS" "VMess + WS" "Trojan + WS" "Shadowsocks + WS" "VLESS + XHTTP" "VLESS + XHTTP Direct" "Trojan Direct" "Shadowsocks 2022 Direct")
NODE_TAG=("reality-vision" "hysteria2" "reality-grpc" "vless-ws" "vmess-ws" "trojan-ws" "ss-ws" "vless-xhttp" "xhttp-h3-direct" "trojan-direct" "ss2022-direct")

# 端口范围限制
MIN_PORT=100
MAX_PORT=65520
MIN_HOPPING_PORT=10000
MAX_HOPPING_PORT=65535

# 各变量默认值
WS_PATH_DEFAULT='argox'
WORK_DIR='/etc/argox'
TEMP_DIR='/tmp/argox'
CUSTOM_FILE="$WORK_DIR/custom"
TLS_SERVER='addons.mozilla.org'
START_PORT_DEFAULT='30000'  # WS/XHTTP 内部端口起始值，各协议在此基础上顺数
NGINX_PORT_DEFAULT='8080'   # Nginx 默认端口，可交互修改
CDN_DOMAIN=("skk.moe" "ip.sb" "time.is" "cfip.xxxxxxxx.tk" "bestcf.top" "cdn.2020111.xyz" "xn--b6gac.eu.org" "cf.090227.xyz")
SUBSCRIBE_TEMPLATE="https://raw.githubusercontent.com/fscarmen/client_template/main"
DEFAULT_XRAY_VERSION='26.2.6'

export DEBIAN_FRONTEND=noninteractive

cleanup_temp() {
  rm -rf "$TEMP_DIR"
}

on_interrupt_exit() {
  cleanup_temp
  echo -e '\n'
  exit 1
}

trap cleanup_temp EXIT
trap on_interrupt_exit INT QUIT TERM

mkdir -p "$TEMP_DIR"

E[0]="Language:\n 1. English (default) \n 2. 简体中文"
C[0]="${E[0]}"
E[1]="1. Refactor ArgoX into a modular protocol system with fully customizable protocol installation.\n2. Add support for Hysteria2, VLESS/XHTTP over CDN, VLESS/XHTTP Direct, Trojan Direct, and Shadowsocks 2022 Direct.\n3. Regenerate the self-signed certificate automatically when changing the TLS domain."
C[1]="1. 将 ArgoX 重构为模块化协议架构，并支持协议的自定义安装与管理\n2. 新增 Hysteria2、CDN 模式的 VLESS/XHTTP、VLESS/XHTTP Direct、Trojan Direct 和 Shadowsocks 2022 Direct 支持\n3. 更换 TLS 域名时会自动重新生成自签证书"
E[2]="Project to create Argo tunnels and Xray specifically for VPS, detailed:[https://github.com/fscarmen/argox]\n Features:\n\t • Allows the creation of Argo tunnels via Token, Json and ad hoc methods. User can easily obtain the json at https://fscarmen.cloudflare.now.cc .\n\t • Extremely fast installation method, saving users time.\n\t • Support system: Ubuntu, Debian, CentOS, Alpine and Arch Linux 3.\n\t • Support architecture: AMD,ARM and s390x\n"
C[2]="本项目专为 VPS 添加 Argo 隧道及 Xray,详细说明: [https://github.com/fscarmen/argox]\n 脚本特点:\n\t • 允许通过 Token, Json 及 临时方式来创建 Argo 隧道,用户通过以下网站轻松获取 json: https://fscarmen.cloudflare.now.cc\n\t • 极速安装方式,大大节省用户时间\n\t • 智能判断操作系统: Ubuntu 、Debian 、CentOS 、Alpine 和 Arch Linux,请务必选择 LTS 系统\n\t • 支持硬件结构类型: AMD 和 ARM\n"
E[3]="Input errors up to 5 times.The script is aborted."
C[3]="输入错误达5次,脚本退出"
E[4]="UUID should be 36 characters, please re-enter (\${a} times remaining)"
C[4]="UUID 应为36位字符,请重新输入 (剩余\${a}次)"
E[5]="The script supports Debian, Ubuntu, CentOS, Alpine or Arch systems only. Feedback: [https://github.com/fscarmen/argox/issues]"
C[5]="本脚本只支持 Debian、Ubuntu、CentOS、Alpine 或 Arch 系统，问题反馈:[https://github.com/fscarmen/argox/issues]"
E[6]="Port Hopping range (current: \${_val}) [leave blank to disable]"
C[6]="端口跳跃范围 (当前：\${_val}) [留空则禁用]"
E[7]="Install dependence-list:"
C[7]="安装依赖列表:"
E[8]="All dependencies already exist and do not need to be installed additionally."
C[8]="所有依赖已存在，不需要额外安装"
E[9]="To upgrade, press [y]. No upgrade by default:"
C[9]="升级请按 [y]，默认不升级:"
E[10]="\${TOTAL_STEPS:+(\${STEP_NUM}/\${TOTAL_STEPS}) }Please enter Argo Domain (Default is temporary domain if left blank):"
C[10]="\${TOTAL_STEPS:+(\${STEP_NUM}/\${TOTAL_STEPS}) }请输入 Argo 域名 (如果没有，可以跳过以使用 Argo 临时域名):"
E[11]="Please enter Argo Token, Argo Json or Cloudflare API\n\n [*] Token: Visit https://dash.cloudflare.com/ , Zero Trust > Networks > Connectors > Create a tunnel > Select Cloudflared\n\n [*] Json: Users can easily obtain it through the following website: https://fscarmen.cloudflare.now.cc\n\n [*] Cloudflare API: Visit https://dash.cloudflare.com/profile/api-tokens > Create Token > Create Custom Token > Add the following permissions:\n - Account > Cloudflare One Connectors: cloudflared > Edit\n - Zone > DNS > Edit\n\n - Account Resources: Include > Required Account\n - Zone Resources: Include > Specific zone > Argo Root Domain"
C[11]="请输入 Argo Token, Argo Json 或者 Cloudflare API\n\n [*] Token: 访问 https://dash.cloudflare.com/ ，Zero Trust > 网络 > 连接器 > 创建隧道 > 选择 Cloudflared\n\n [*] Json: 用户通过以下网站轻松获取: https://fscarmen.cloudflare.now.cc\n\n [*] Cloudflare API: 访问 https://dash.cloudflare.com/profile/api-tokens > 创建令牌 > 创建自定义令牌 > 添加以下权限:\n - 帐户 > Cloudflare One连接器: Cloudflared > 编辑\n - 区域 > DNS > 编辑\n\n - 帐户资源: 包括 > 所需账户\n - 区域资源: 包括 > 特定区域 > 所需域名"
E[12]="(\${STEP_NUM}/\${TOTAL_STEPS}) Please enter Xray UUID (Default is \${UUID_DEFAULT}):"
C[12]="(\${STEP_NUM}/\${TOTAL_STEPS}) 请输入 Xray UUID (默认为 \${UUID_DEFAULT}):"
E[13]="(\${STEP_NUM}/\${TOTAL_STEPS}) Please enter Xray WS Path (Default is \${WS_PATH_DEFAULT}):"
C[13]="(\${STEP_NUM}/\${TOTAL_STEPS}) 请输入 Xray WS 路径 (默认为 \${WS_PATH_DEFAULT}):"
E[14]="Xray WS Path only allow uppercase and lowercase letters, numeric characters, hyphens, underscores, dots and @, please re-enter (\${a} times remaining):"
C[14]="Xray WS 路径只允许英文大小写、数字、连字符、下划线、点和@字符，请重新输入 (剩余\${a}次):"
E[15]="ArgoX script has not been installed yet."
C[15]="ArgoX 脚本还没有安装"
E[16]="ArgoX is completely uninstalled."
C[16]="ArgoX 已彻底卸载"
E[17]="Version"
C[17]="脚本版本"
E[18]="New features"
C[18]="功能新增"
E[19]="System infomation"
C[19]="系统信息"
E[20]="Operating System"
C[20]="当前操作系统"
E[21]="Kernel"
C[21]="内核"
E[22]="Architecture"
C[22]="处理器架构"
E[23]="Virtualization"
C[23]="虚拟化"
E[24]="Choose:"
C[24]="请选择:"
E[25]="Curren architecture \$(uname -m) is not supported. Feedback: [https://github.com/fscarmen/argox/issues]"
C[25]="当前架构 \$(uname -m) 暂不支持,问题反馈:[https://github.com/fscarmen/argox/issues]"
E[26]="Not install"
C[26]="未安装"
E[27]="close"
C[27]="关闭"
E[28]="open"
C[28]="开启"
E[29]="View links (argox -n)"
C[29]="查看节点信息 (argox -n)"
E[30]="Change the Argo tunnel (argox -t)"
C[30]="更换 Argo 隧道 (argox -t)"
E[31]="Sync Argo and Xray to the latest version (argox -v)"
C[31]="同步 Argo 和 Xray 至最新版本 (argox -v)"
E[32]="Upgrade kernel, turn on BBR, change Linux system (argox -b)"
C[32]="升级内核、安装BBR、DD脚本 (argox -b)"
E[33]="Uninstall (argox -u)"
C[33]="卸载 (argox -u)"
E[34]="Install ArgoX script (argo + xray)"
C[34]="安装 ArgoX 脚本 (argo + xray)"
E[35]="Exit"
C[35]="退出"
E[36]="Please enter the correct number"
C[36]="请输入正确数字"
E[37]="successful"
C[37]="成功"
E[38]="failed"
C[38]="失败"
E[39]="ArgoX is not installed."
C[39]="ArgoX 未安装"
E[40]="Argo tunnel is: \${ARGO_TYPE}\\\n The domain is: \${ARGO_DOMAIN}"
C[40]="Argo 隧道类型为: \${ARGO_TYPE}\\\n 域名是: \${ARGO_DOMAIN}"
E[41]="Argo tunnel type:\n 1. Try (VLESS + XHTTP not supported)\n 2. Token or Json"
C[41]="Argo 隧道类型:\n 1. Try（不支持 VLESS + XHTTP）\n 2. Token 或者 Json"
E[42]="\${TOTAL_STEPS:+(\${STEP_NUM}/\${TOTAL_STEPS}) }Please select or enter the preferred domain, the default is \${CDN_DOMAIN[0]}:"
C[42]="\${TOTAL_STEPS:+(\${STEP_NUM}/\${TOTAL_STEPS}) }请选择或者填入优选域名，默认为 \${CDN_DOMAIN[0]}:"
E[43]="\${APP} local version: \${LOCAL}.\\\t The newest version: \${ONLINE}"
C[43]="\${APP} 本地版本: \${LOCAL}.\\\t 最新版本: \${ONLINE}"
E[44]="No upgrade required."
C[44]="不需要升级"
E[45]="Argo authentication message does not match the rules, neither Token nor Json, script exits. Feedback:[https://github.com/fscarmen/argox/issues]"
C[45]="Argo 认证信息不符合规则，既不是 Token，也是不是 Json，脚本退出，问题反馈:[https://github.com/fscarmen/argox/issues]"
E[46]="Connect"
C[46]="连接"
E[47]="The script must be run as root, you can enter sudo -i and then download and run again. Feedback:[https://github.com/fscarmen/argox/issues]"
C[47]="必须以root方式运行脚本，可以输入 sudo -i 后重新下载运行，问题反馈:[https://github.com/fscarmen/argox/issues]"
E[48]="Downloading the latest version \${APP} failed, script exits. Feedback:[https://github.com/fscarmen/argox/issues]"
C[48]="下载最新版本 \${APP} 失败，脚本退出，问题反馈:[https://github.com/fscarmen/argox/issues]"
E[49]="(\${STEP_NUM}/\${TOTAL_STEPS}) Please enter the node name. (Default is \${NODE_NAME_DEFAULT}):"
C[49]="(\${STEP_NUM}/\${TOTAL_STEPS}) 请输入节点名称 (默认为 \${NODE_NAME_DEFAULT}):"
E[50]="\${APP[*]} services are not enabled, node information cannot be output. Press [y] if you want to open."
C[50]="\${APP[*]} 服务未开启，不能输出节点信息。如需打开请按 [y]: "
E[51]="Install Sing-box multi-protocol scripts [https://github.com/fscarmen/sing-box]"
C[51]="安装 Sing-box 协议全家桶脚本 [https://github.com/fscarmen/sing-box]"
E[52]="Memory Usage"
C[52]="内存占用"
E[53]="The xray service is detected to be installed. Script exits."
C[53]="检测到已安装 xray 服务，脚本退出!"
E[54]="Warp / warp-go was detected to be running. Please enter the correct server IP:"
C[54]="检测到 warp / warp-go 正在运行，请输入确认的服务器 IP:"
E[55]="The script runs today: \${TODAY}. Total: \${TOTAL}"
C[55]="脚本当天运行次数: \${TODAY}，累计运行次数: \${TOTAL}"
E[56]="(\${STEP_NUM}/\${TOTAL_STEPS}) Please enter the starting port for all protocols. Must be \${MIN_PORT}-\${MAX_PORT}, need \${NUM} consecutive free ports (Default: \${START_PORT_DEFAULT}):"
C[56]="(\${STEP_NUM}/\${TOTAL_STEPS}) 请输入所有协议的起始端口，必须是 \${MIN_PORT}-\${MAX_PORT}，需要 \${NUM} 个连续空闲端口(默认为 \${START_PORT_DEFAULT}):"
E[57]="Install sba scripts (argo + sing-box) [https://github.com/fscarmen/sba]"
C[57]="安装 sba 脚本 (argo + sing-box) [https://github.com/fscarmen/sba]"
E[58]="No server ip, script exits. Feedback:[https://github.com/fscarmen/sing-box/issues]"
C[58]="没有 server ip，脚本退出，问题反馈:[https://github.com/fscarmen/sing-box/issues]"
E[59]="(\${STEP_NUM}/\${TOTAL_STEPS}) Please enter VPS IP (Default is: \${SERVER_IP_DEFAULT}):"
C[59]="(\${STEP_NUM}/\${TOTAL_STEPS}) 请输入 VPS IP (默认为: \${SERVER_IP_DEFAULT}):"
E[60]="Please enter new value (press Enter to skip):"
C[60]="请输入新值 (回车跳过):"
E[61]="Port already in use:"
C[61]="端口已被占用:"
E[62]="Create shortcut [ argox ] successfully."
C[62]="创建快捷 [ argox ] 指令成功!"
E[63]="The full template can be found at:\n https://t.me/ztvps/67\n https://github.com/chika0801/sing-box-examples/tree/main/Tun"
C[63]="完整模板可参照:\n https://t.me/ztvps/67\n https://github.com/chika0801/sing-box-examples/tree/main/Tun"
E[64]="subscribe"
C[64]="订阅"
E[65]="To uninstall Nginx press [y], it is not uninstalled by default:"
C[65]="如要卸载 Nginx 请按 [y]，默认不卸载:"
E[66]="Adaptive Clash / V2rayN / NekoBox / ShadowRocket / SFI / SFA / SFM Clients"
C[66]="自适应 Clash / V2rayN / NekoBox / ShadowRocket / SFI / SFA / SFM 客户端"
E[67]="not set"
C[67]="未设置"
E[68]="(\${STEP_NUM}/\${TOTAL_STEPS}) Nginx is used for subscription, QR code output, and WS/XHTTP protocol proxying. Please enter the port number, must be \${MIN_PORT}-\${MAX_PORT} (Default: \${NGINX_PORT_DEFAULT}):"
C[68]="(\${STEP_NUM}/\${TOTAL_STEPS}) Nginx 用于订阅输出、二维码生成以及 WS/XHTTP 协议的反代分流，请输入端口号，必须是 \${MIN_PORT}-\${MAX_PORT}(默认为 \${NGINX_PORT_DEFAULT}):"
E[69]="Set SElinux: enforcing --> disabled"
C[69]="设置 SElinux: enforcing --> disabled"
E[70]="ArgoX is not installed and cannot change the CDN."
C[70]="ArgoX 未安装，不能更换 CDN"
E[71]="Current CDN is: \${CDN_NOW}"
C[71]="当前 CDN 为: \${CDN_NOW}"
E[72]="Please select or enter a new CDN (press Enter to keep the current one):"
C[72]="请选择或输入新的 CDN (回车保持当前值):"
E[73]="CDN has been changed from \${CDN_NOW} to \${CDN_NEW}"
C[73]="CDN 已从 \${CDN_NOW} 更改为 \${CDN_NEW}"
E[74]="Unable to access api.github.com. This may be due to IP restrictions (HTTP/1.1 403 Rate Limit Exceeded). Please try again later"
C[74]="无法访问 api.github.com，可能是由于 IP 限制导致的（HTTP/1.1 403 Rate Limit Exceeded），请稍后重试"
E[75]="When using shadows-ws in Nekobox, set UoT to 2 to enable UDP over TCP."
C[75]="在 Nekobox 中使用 shadows-ws 时，将 UoT 设为 2，即可启用 UDP over TCP 功能"
E[76]="Change preferred domain / SNI (Reality & Hysteria2 TLS) / node info (argox -d)"
C[76]="更换优选域名 / SNI（Reality 和 Hysteria2 TLS 共用）/ 节点信息 (argox -d)"
E[77]="Quick install mode (argox -k)"
C[77]="极速安装模式 (argox -l)"
E[78]="Using Cloudflare API to create Tunnel and handle DNS config..."
C[78]="使用 Cloudflare API 创建 Tunnel 和处理 DNS 配置..."
E[79]="Found existing tunnel with the same name. Tunnel ID: \$EXISTING_TUNNEL_ID. Status: \$EXISTING_TUNNEL_STATUS. Overwrite? [y/N] (default y):"
C[79]="发现同名隧道已创建，隧道 ID: \$EXISTING_TUNNEL_ID，状态: \$EXISTING_TUNNEL_STATUS。是否覆盖? [y/N] (默认为 y):"
E[80]="Continue with quick fast tunnel"
C[80]="使用临时隧道继续"
E[81]="Invalid access token. Please roll at https://dash.cloudflare.com/profile/api-tokens to re-generate."
C[81]="Token 访问令牌无效。请在 https://dash.cloudflare.com/profile/api-tokens 轮转，以重新获取"
E[82]="Network request URL structure is wrong. Missing Zone ID"
C[82]="网络请求地址（URL）结构不对，缺少 Zone ID"
E[83]="Token zone resource failed. The tunnel root domain and the authorized domain of the token are inconsistent. Please go to https://dash.cloudflare.com/profile/api-tokens to re-authorize."
C[83]="Token 区域资源获取失败，隧道的根域名和 Token 授权的域名不一致，请到 https://dash.cloudflare.com/profile/api-tokens 检查"
E[84]="API execution failed. Response: \$RESPONSE"
C[84]="执行 API 失败，返回: \$RESPONSE"
E[85]="API does not have enough permissions. Please check at https://dash.cloudflare.com/profile/api-tokens\n\n [*] Token: Visit https://dash.cloudflare.com/ , Zero Trust > Networks > Connectors > Create a tunnel > Select Cloudflared\n\n [*] Json: Users can easily obtain it through the following website: https://fscarmen.cloudflare.now.cc\n\n [*] Cloudflare API: Visit https://dash.cloudflare.com/profile/api-tokens > Create Token > Create Custom Token > Add the following permissions:\n - Account > Cloudflare One Connectors: cloudflared > Edit\n - Zone > DNS > Edit\n\n - Account Resources: Include > Required Account\n - Zone Resources: Include > Specific zone > Argo Root Domain"
C[85]="API 没有足够权限，请在 https://dash.cloudflare.com/profile/api-tokens 检查 Token 权限配置\n\n [*] Token: 访问 https://dash.cloudflare.com/ ，Zero Trust > 网络 > 连接器 > 创建隧道 > 选择 Cloudflared\n\n [*] Json: 用户通过以下网站轻松获取: https://fscarmen.cloudflare.now.cc\n\n [*] Cloudflare API: 访问 https://dash.cloudflare.com/profile/api-tokens > 创建令牌 > 创建自定义令牌 > 添加以下权限:\n - 帐户 > Cloudflare One连接器: Cloudflared > 编辑\n - 区域 > DNS > 编辑\n\n - 帐户资源: 包括 > 所需账户\n - 区域资源: 包括 > 特定区域 > 所需域名"
E[86]="Please enter [Token, Json, API] value:"
C[86]="请输入 [Token, Json, API] 的值:"
E[87]="(\${STEP_NUM}/\${TOTAL_STEPS:-?}) Select protocols to install (e.g. bdf). a = all (default):"
C[87]="(\${STEP_NUM}/\${TOTAL_STEPS:-?}) 选择要安装的协议（如 bdf），a = 全部（默认）:"
E[88]="Installed protocols."
C[88]="已安装的协议"
E[89]="Please select protocols to remove (multiple allowed, Enter to skip):"
C[89]="请选择需要删除的协议（可多选，回车跳过）:"
E[90]="Uninstalled protocols."
C[90]="未安装的协议"
E[91]="Please select protocols to add (multiple allowed, Enter to skip):"
C[91]="请选择需要增加的协议（可多选，回车跳过）:"
E[92]="Confirm all protocols for reloading."
C[92]="确认重装的所有协议"
E[93]="Press [n] if there is an error, other keys to continue:"
C[93]="如有错误请按 [n]，其他键继续:"
E[94]="No protocols left. Use [ argox -u ] to uninstall all."
C[94]="没有协议剩下，如确定请重新执行 [ argox -u ] 卸载所有"
E[95]="Add / Remove protocols (argox -r)"
C[95]="增加 / 删除协议 (argox -r)"
E[96]="Keep protocols"
C[96]="保留协议"
E[97]="Add protocols"
C[97]="新增协议"
E[98]="\${TOTAL_STEPS:+(\${STEP_NUM}/\${TOTAL_STEPS}) }Please enter the Reality privateKey, skip to generate randomly (Default is random):"
C[98]="\${TOTAL_STEPS:+(\${STEP_NUM}/\${TOTAL_STEPS}) }请输入 Reality 的密钥(privateKey)，跳过则随机生成 (默认为随机生成):"
E[99]="Invalid Reality privateKey, generating randomly..."
C[99]="Reality 私钥无效，随机生成中..."
E[100]=" a. all (default)"
C[100]=" a. 全部（默认）"
E[101]="VLESS + XHTTP over CDN (Temporary tunnel NOT supported)"
C[101]="VLESS + XHTTP 使用 CDN（临时隧道不支持）"
E[102]="Cannot get quicktunnel domain."
C[102]="获取临时隧道域名失败"
E[103]="No change was made."
C[103]="未做任何修改"
E[104]="Port Hopping: ISPs sometimes block or throttle persistent UDP on a single port. Port hopping works around this by forwarding a range of ports to the Hysteria2 listen port via iptables NAT.\n Tip1: Recommended ~1000 ports, min: \$MIN_HOPPING_PORT, max: \$MAX_HOPPING_PORT.\n Tip2: NAT machines have very few open ports (20-30); use with caution.\n Leave blank to disable."
C[104]="端口跳跃介绍：运营商有时会阻断或限速单个 UDP 端口的持续连接，端口跳跃通过 iptables NAT 将端口段转发到 Hysteria2 监听端口来解决这个问题。\n Tip1: 推荐约 1000 个端口，最小值：\$MIN_HOPPING_PORT，最大值：\$MAX_HOPPING_PORT。\n Tip2: NAT 机器可开放端口很少（20-30 个），请谨慎使用。\n 留空则禁用该功能。"
E[105]="\${TOTAL_STEPS:+(\${STEP_NUM}/\${TOTAL_STEPS}) }Enter port range for Hysteria2 port hopping (e.g. 50000:51000). Leave blank to disable:"
C[105]="\${TOTAL_STEPS:+(\${STEP_NUM}/\${TOTAL_STEPS}) }请输入 Hysteria2 端口跳跃范围（如 50000:51000），留空禁用:"
E[106]="Please select what to modify:"
C[106]="请选择修改项目:"
E[107]="Preferred CDN (current: \${_val})"
C[107]="优选域名/IP (当前：\${_val})"
E[108]="SNI / TLS domain (current: \${_val}) [Reality & Hysteria2]"
C[108]="SNI / TLS 域名 (当前：\${_val}) [Reality 和 Hysteria2 共用]"
E[109]="Node name (current: \${_val})"
C[109]="节点名称 (当前：\${_val})"
E[110]="UUID / Password (current: \${_val})"
C[110]="UUID / 密码 (当前：\${_val})"
E[111]="Server IP (current: \${_val})"
C[111]="服务器 IP (当前：\${_val})"
E[112]="Invalid IP address format"
C[112]="IP 地址格式错误"
E[113]="(VLESS + XHTTP not supported)"
C[113]="（不支持 VLESS + XHTTP）"
E[114]="Port range out of bounds. Start must be \${MIN_HOPPING_PORT}–\${MAX_HOPPING_PORT}, end must be \${MIN_HOPPING_PORT}–\${MAX_HOPPING_PORT}, and start < end."
C[114]="端口范围超界。起始端口必须在 \${MIN_HOPPING_PORT}–\${MAX_HOPPING_PORT} 之间，结束端口同理，且起始 < 结束。"

# 自定义字体彩色，read 函数
warning() { echo -e "\033[31m\033[01m$*\033[0m"; }         # 红色
error() { echo -e "\033[31m\033[01m$*\033[0m" && exit 1; } # 红色
info() { echo -e "\033[32m\033[01m$*\033[0m"; }            # 绿色
hint() { echo -e "\033[33m\033[01m$*\033[0m"; }            # 黄色
reading() { read -rp "$(info "$1")" "$2"; }

# 标记哪些文本需要 eval
declare -A TEXT_NEEDS_EVAL
for _text_i in "${!E[@]}"; do
  [[ "${E[${_text_i}]}" == *'$'* || "${C[${_text_i}]}" == *'$'* ]] && TEXT_NEEDS_EVAL[${_text_i}]=1
done
unset _text_i

text() {
  local -n _text_arr="${L}"        # nameref 指向 E 或 C，零子进程
  local _text_val="${_text_arr[$*]}"
  if [[ -n "${TEXT_NEEDS_EVAL[$*]}" ]]; then
    eval "printf '%s' \"${_text_val}\""
  else
    printf '%s' "${_text_val}"
  fi
}

# 转换字母和 ASCII 码之间的关系，支持单个字符和数字的双向转换，第二个参数可选 '++' 表示字母加一
asc() {
  if [[ "$1" = [a-z] ]]; then
    [ "$2" = '++' ] && printf "\\$(printf '%03o' "$(( $(printf "%d" "'$1'") + 1 ))")" || printf "%d" "'$1'"
  else
    [[ "$1" =~ ^[0-9]+$ ]] && printf "\\$(printf '%03o' "$1")"
  fi
}

# 检查端口占用，ss 命令输出格式较复杂且不稳定，使用全局变量 PORT_SNAPSHOT 来存储快照，避免多次调用 ss 导致性能问题
refresh_port_snapshot() {
  PORT_SNAPSHOT=$(ss -nltup 2>/dev/null)
}

# 判断端口是否被占用，使用预先获取的 PORT_SNAPSHOT 进行匹配，避免多次调用 ss 导致性能问题
is_port_in_use() {
  local _PORT="$1"
  grep -qE "(^|[[:space:]])[^[:space:]]*:${_PORT}([[:space:]]|$)" <<< "$PORT_SNAPSHOT"
}

# 检测是否启用 Github CDN，如能直接连通当前项目 raw 地址，则不使用
check_cdn() {
  local PROXY CODE PID
  local _WAIT_COUNT=120
  local PIDS=()
  local RAW_URL='https://raw.githubusercontent.com/fscarmen/argox/main/argox.sh'

  CODE=$(wget -qT5 -O /dev/null --server-response "$RAW_URL" 2>&1 | awk '/HTTP\//{code=$2} END{print code}')
  if [ "$CODE" = '200' ]; then
    GH_PROXY=''
    return
  fi

  for PROXY in "${GITHUB_PROXY[@]}"; do
    {
      CODE=$(wget -qT5 -O /dev/null --server-response "${PROXY}${RAW_URL}" 2>&1 | awk '/HTTP\//{code=$2} END{print code}')
      [ "$CODE" = '200' ] && [ ! -e "${TEMP_DIR}/cdn_proxy" ] && printf '%s' "$PROXY" > "${TEMP_DIR}/cdn_proxy"
    } &
    PIDS+=("$!")
  done

  # 等第一个成功，超时则回退为直连，避免无限等待卡死
  while [ ! -e "${TEMP_DIR}/cdn_proxy" ] && [ "$_WAIT_COUNT" -gt 0 ]; do
    sleep 0.05
    (( _WAIT_COUNT-- )) || true
  done

  if [ -e "${TEMP_DIR}/cdn_proxy" ]; then
    GH_PROXY=$(cat "${TEMP_DIR}/cdn_proxy")
  else
    GH_PROXY=''
  fi

  # 清理后台探测任务和临时文件，避免慢连接拖住函数返回
  for PID in "${PIDS[@]}"; do
    kill "$PID" >/dev/null 2>&1 || true
  done
  for PID in "${PIDS[@]}"; do
    wait "$PID" 2>/dev/null || true
  done
  rm -f "${TEMP_DIR}/cdn_proxy"
}

# 检测是否解锁 chatGPT，以决定是否使用 warp 链式代理或者是 direct out，此处判断改编自 https://github.com/lmc999/RegionRestrictionCheck
check_chatgpt() {
  local CHECK_STACK=$1
  local UA_BROWSER="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"
  local UA_SEC_CH_UA='"Google Chrome";v="125", "Chromium";v="125", "Not.A/Brand";v="24"'
  wget --help | grep -q '\-\-ciphers' && local IS_CIPHERS=is_ciphers

  local CHECK_RESULT1=$(wget --timeout=2 --tries=2 --retry-connrefused --waitretry=5 ${CHECK_STACK} -qO- --content-on-error --header='authority: api.openai.com' --header='accept: */*' --header='accept-language: en-US,en;q=0.9' --header='authorization: Bearer null' --header='content-type: application/json' --header='origin: https://platform.openai.com' --header='referer: https://platform.openai.com/' --header="sec-ch-ua: ${UA_SEC_CH_UA}" --header='sec-ch-ua-mobile: ?0' --header='sec-ch-ua-platform: "Windows"' --header='sec-fetch-dest: empty' --header='sec-fetch-mode: cors' --header='sec-fetch-site: same-site' --user-agent="${UA_BROWSER}" 'https://api.openai.com/compliance/cookie_requirements')

  grep -q "^$" <<< "$CHECK_RESULT1" && grep -qw is_ciphers <<< "$IS_CIPHERS" && local CHECK_RESULT1=$(wget --timeout=2 --tries=2 --retry-connrefused --waitretry=5 ${CHECK_STACK} --ciphers=DEFAULT@SECLEVEL=1 --no-check-certificate -qO- --content-on-error --header='authority: api.openai.com' --header='accept: */*' --header='accept-language: en-US,en;q=0.9' --header='authorization: Bearer null' --header='content-type: application/json' --header='origin: https://platform.openai.com' --header='referer: https://platform.openai.com/' --header="sec-ch-ua: ${UA_SEC_CH_UA}" --header='sec-ch-ua-mobile: ?0' --header='sec-ch-ua-platform: "Windows"' --header='sec-fetch-dest: empty' --header='sec-fetch-mode: cors' --header='sec-fetch-site: same-site' --user-agent="${UA_BROWSER}" 'https://api.openai.com/compliance/cookie_requirements')

  if grep -q "^$" <<< "$CHECK_RESULT1" || grep -qi 'unsupported_country' <<< "$CHECK_RESULT1"; then
    echo "ban"
    return
  fi

  local CHECK_RESULT2=$(wget --timeout=2 --tries=2 --retry-connrefused --waitretry=5 ${CHECK_STACK} -qO- --content-on-error --header='authority: ios.chat.openai.com' --header='accept: */*;q=0.8,application/signed-exchange;v=b3;q=0.7' --header='accept-language: en-US,en;q=0.9' --header="sec-ch-ua: ${UA_SEC_CH_UA}" --header='sec-ch-ua-mobile: ?0' --header='sec-ch-ua-platform: "Windows"' --header='sec-fetch-dest: document' --header='sec-fetch-mode: navigate' --header='sec-fetch-site: none' --header='sec-fetch-user: ?1' --header='upgrade-insecure-requests: 1' --user-agent="${UA_BROWSER}" https://ios.chat.openai.com/)

  [ -z "$CHECK_RESULT2" ] && grep -qw is_ciphers <<< "$IS_CIPHERS" && local CHECK_RESULT2=$(wget --timeout=2 --tries=2 --retry-connrefused --waitretry=5 ${CHECK_STACK} --ciphers=DEFAULT@SECLEVEL=1 --no-check-certificate -qO- --content-on-error --header='authority: ios.chat.openai.com' --header='accept: */*;q=0.8,application/signed-exchange;v=b3;q=0.7' --header='accept-language: en-US,en;q=0.9' --header="sec-ch-ua: ${UA_SEC_CH_UA}" --header='sec-ch-ua-mobile: ?0' --header='sec-ch-ua-platform: "Windows"' --header='sec-fetch-dest: document' --header='sec-fetch-mode: navigate' --header='sec-fetch-site: none' --header='sec-fetch-user: ?1' --header='upgrade-insecure-requests: 1' --user-agent="${UA_BROWSER}" https://ios.chat.openai.com/)

  if [ -z "$CHECK_RESULT2" ] || grep -qi 'VPN' <<< "$CHECK_RESULT2"; then
    echo "ban"
  else
    echo "unlock"
  fi
}

# 脚本当天及累计运行次数统计
statistics_of_run-times() {
  local UPDATE_OR_GET=$1
  local SCRIPT=$2
  if grep -q 'update' <<< "$UPDATE_OR_GET"; then
    { wget --no-check-certificate -qO- --timeout=3 "https://stat.cloudflare.now.cc/api/updateStats?script=${SCRIPT}" > $TEMP_DIR/statistics 2>/dev/null || true; }&
  elif grep -q 'get' <<< "$UPDATE_OR_GET"; then
    [ -s $TEMP_DIR/statistics ] && [[ $(cat $TEMP_DIR/statistics) =~ \"todayCount\":([0-9]+),\"totalCount\":([0-9]+) ]] && local TODAY="${BASH_REMATCH[1]}" && local TOTAL="${BASH_REMATCH[2]}" && rm -f $TEMP_DIR/statistics
    hint "\n*******************************************\n\n $(text 55) \n"
  fi
}

# 从 inbound.json 实时解析已安装协议列表，grep pattern 由 NODE_TAG 数组自动构建
# 新增协议只需在顶部 NODE_TAG 数组里追加，此处无需手动维护
get_installed_protocols() {
  [ -s $WORK_DIR/inbound.json ] || return
  local _TAG_PATTERN
  _TAG_PATTERN=$(IFS='|'; echo "${NODE_TAG[*]}")
  $WORK_DIR/jq -r '.inbounds[].tag' $WORK_DIR/inbound.json 2>/dev/null \
    | grep -oE "$_TAG_PATTERN"
}

# 读取或更新 custom 文件中的 key=value（可用 . $CUSTOM_FILE 批量加载）
write_custom() {
  local _KEY="$1" _VAL="$2"
  if [ -s "$CUSTOM_FILE" ] && grep -q "^${_KEY}=" "$CUSTOM_FILE"; then
    sed -i "s|^${_KEY}=.*|${_KEY}=${_VAL}|" "$CUSTOM_FILE"
  else
    echo "${_KEY}=${_VAL}" >> "$CUSTOM_FILE"
  fi
}

# 选择中英语言
select_language() {
  if [ -z "$L" ]; then
    local _LANG_IN_CUSTOM
    [ -s "$CUSTOM_FILE" ] && _LANG_IN_CUSTOM=$(awk -F= '/^language=/{print $2}' "$CUSTOM_FILE")
    case "${_LANG_IN_CUSTOM,,}" in
      e|english ) L=E ;;
      c|chinese ) L=C ;;
      * ) [ -z "$L" ] && L=E && ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL" && hint "\n $(text 0) \n" && reading " $(text 24) " LANGUAGE
      [ "$LANGUAGE" = 2 ] && L=C ;;
    esac
  fi
}

# 只允许 root 用户安装脚本
check_root() {
  [ "$(id -u)" != 0 ] && error "\n $(text 47) \n"
}

# 判断处理器架构
check_arch() {
  case $(uname -m) in
    aarch64|arm64 )
      ARGO_ARCH=arm64; XRAY_ARCH=arm64-v8a; JQ_ARCH=arm64; QRENCODE_ARCH=arm64
      ;;
    x86_64|amd64 )
      ARGO_ARCH=amd64; XRAY_ARCH=64; JQ_ARCH=amd64; QRENCODE_ARCH=amd64
      ;;
    armv7l )
      ARGO_ARCH=arm; XRAY_ARCH=arm32-v7a; JQ_ARCH=armhf; QRENCODE_ARCH=arm
      ;;
    * )
      error " $(text 25) "
  esac
}

# 查安装及运行状态，下标0: argo，下标1: xray，下标2: nginx；状态码: 26 未安装， 27 已安装未运行， 28 运行中
check_install() {
  [ -s $WORK_DIR/nginx.conf ] && IS_NGINX=is_nginx || IS_NGINX=no_nginx
  STATUS[0]=$(text 26)

  [ -s ${ARGO_DAEMON_FILE} ] && STATUS[0]=$(text 27) && cmd_systemctl status argo &>/dev/null && STATUS[0]=$(text 28)
  STATUS[1]=$(text 26)
  if [ -s ${XRAY_DAEMON_FILE} ]; then
    ! grep -q "$WORK_DIR" ${XRAY_DAEMON_FILE} && error " $(text 53)\n $(grep "${DAEMON_RUN_PATTERN}" ${XRAY_DAEMON_FILE}) "
    STATUS[1]=$(text 27) && cmd_systemctl status xray &>/dev/null && STATUS[1]=$(text 28)
  fi
  STATUS[2]=$(text 26)
  if [ "$IS_NGINX" = 'is_nginx' ]; then
    local _NGINX_PID=$(pgrep -f "nginx: master process" 2>/dev/null)
    [ -n "$_NGINX_PID" ] && STATUS[2]=$(text 28) || STATUS[2]=$(text 27)
  fi

  {
    wget --no-check-certificate --continue -qO $TEMP_DIR/clash ${GH_PROXY}${SUBSCRIBE_TEMPLATE}/clash 2>/dev/null &
    wget --no-check-certificate --continue -qO $TEMP_DIR/sing-box ${GH_PROXY}${SUBSCRIBE_TEMPLATE}/sing-box 2>/dev/null &
    wait
  } &

  mapfile -t CURRENT_PROTOCOLS < <(get_installed_protocols)

  [[ ${STATUS[0]} = "$(text 26)" ]] && [ ! -s $WORK_DIR/cloudflared ] && { wget --no-check-certificate -qO $TEMP_DIR/cloudflared ${GH_PROXY}https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$ARGO_ARCH >/dev/null 2>&1 && chmod +x $TEMP_DIR/cloudflared >/dev/null 2>&1; }&
  [[ ${STATUS[1]} = "$(text 26)" ]] && [ ! -s $WORK_DIR/xray ] && { wget --no-check-certificate -qO $TEMP_DIR/Xray.zip ${GH_PROXY}https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-$XRAY_ARCH.zip >/dev/null 2>&1; unzip -qo $TEMP_DIR/Xray.zip xray *.dat -d $TEMP_DIR >/dev/null 2>&1; }&
  [ ! -s $WORK_DIR/jq ] && { wget --no-check-certificate --continue -qO $TEMP_DIR/jq ${GH_PROXY}https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-$JQ_ARCH >/dev/null 2>&1 && chmod +x $TEMP_DIR/jq >/dev/null 2>&1; }&
  [ ! -s $WORK_DIR/qrencode ] && { wget --no-check-certificate --continue -qO $TEMP_DIR/qrencode ${GH_PROXY}https://github.com/fscarmen/client_template/raw/main/qrencode-go/qrencode-go-linux-$QRENCODE_ARCH >/dev/null 2>&1 && chmod +x $TEMP_DIR/qrencode >/dev/null 2>&1; }&
}

# 为了适配 alpine，定义 cmd_systemctl 的函数
cmd_systemctl() {
  nginx_run() {
    $(type -p nginx) -c $WORK_DIR/nginx.conf
  }

  nginx_stop() {
    local NGINX_PID=$(ps -eo pid,args | awk -v work_dir="$WORK_DIR" '$0~(work_dir"/nginx.conf"){print $1;exit}')
    ss -nltp | awk -v p="$NGINX_PID" '$0 ~ "pid=" p "," {print $6}' | tr ',' '\n' | awk -F= '/^pid=/{print $2}' | sort -u | xargs -r kill -9 >/dev/null 2>&1
  }

  [ -s $WORK_DIR/nginx.conf ] && local IS_NGINX=is_nginx || local IS_NGINX=no_nginx
  local ENABLE_DISABLE=$1
  local APP=$2
  if [ "$ENABLE_DISABLE" = 'enable' ]; then
    if [ "$SYSTEM" = 'Alpine' ]; then
      rc-service $APP start >/dev/null 2>&1
      rc-update add $APP default >/dev/null 2>&1
    elif [ "$IS_CENTOS" = 'CentOS7' ]; then
      systemctl daemon-reload
      systemctl enable --now $APP >/dev/null 2>&1
      [[ "$APP" = 'xray' && "$IS_NGINX" = 'is_nginx' ]] && [ -s $WORK_DIR/nginx.conf ] && { nginx_run; firewall_configuration open; }
    else
      systemctl daemon-reload
      systemctl enable --now $APP >/dev/null 2>&1
    fi

  elif [ "$ENABLE_DISABLE" = 'disable' ]; then
    if [ "$SYSTEM" = 'Alpine' ]; then
      rc-service $APP stop >/dev/null 2>&1
      rc-update del $APP default >/dev/null 2>&1
    elif [ "$IS_CENTOS" = 'CentOS7' ]; then
      systemctl disable --now $APP >/dev/null 2>&1
      [[ "$APP" = 'xray' && "$IS_NGINX" = 'is_nginx' ]] && [ -s $WORK_DIR/nginx.conf ] && { nginx_stop; firewall_configuration close; }
    else
      systemctl disable --now $APP >/dev/null 2>&1
    fi
  elif [ "$ENABLE_DISABLE" = 'status' ]; then
    if [ "$SYSTEM" = 'Alpine' ]; then
      rc-service $APP status
    else
      systemctl is-active $APP
    fi
  fi
}

check_system_info() {
  [ -s /etc/os-release ] && SYS="$(awk -F '"' 'tolower($0) ~ /pretty_name/{print $2}' /etc/os-release)"
  [[ -z "$SYS" && -x "$(type -p hostnamectl)" ]] && SYS="$(hostnamectl | awk -F ': ' 'tolower($0) ~ /operating system/{print $2}')"
  [[ -z "$SYS" && -x "$(type -p lsb_release)" ]] && SYS="$(lsb_release -sd)"
  [[ -z "$SYS" && -s /etc/lsb-release ]] && SYS="$(awk -F '"' 'tolower($0) ~ /distrib_description/{print $2}' /etc/lsb-release)"
  [[ -z "$SYS" && -s /etc/redhat-release ]] && SYS="$(cat /etc/redhat-release)"
  [[ -z "$SYS" && -s /etc/issue ]] && SYS="$(sed -E '/^$|^\\/d' /etc/issue | awk -F '\\' '{print $1}' | sed 's/[ ]*$//g')"

  REGEX=("debian" "ubuntu" "centos|red hat|kernel|alma|rocky" "arch linux" "alpine" "fedora")
  RELEASE=("Debian" "Ubuntu" "CentOS" "Arch" "Alpine" "Fedora")
  PACKAGE_UPDATE=("apt -y update" "apt -y update" "yum -y update" "pacman -Sy" "apk update -f" "dnf -y update")
  PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "pacman -S --noconfirm" "apk add --no-cache" "dnf -y install")
  PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove" "pacman -Rcnsu --noconfirm" "apk del -f" "dnf -y autoremove")

  for int in "${!REGEX[@]}"; do
    [[ "${SYS,,}" =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && break
  done
  if [ -z "$SYSTEM" ]; then
    [ -x "$(type -p yum)" ] && int=2 && SYSTEM='CentOS' || error " $(text 5) "
  fi

  ARGO_DAEMON_FILE='/etc/systemd/system/argo.service'; XRAY_DAEMON_FILE='/etc/systemd/system/xray.service'; DAEMON_RUN_PATTERN="ExecStart="
  if [ "$SYSTEM" = 'CentOS' ]; then
    IS_CENTOS="CentOS$(echo "$SYS" | sed "s/[^0-9.]//g" | cut -d. -f1)"
  elif [ "$SYSTEM" = 'Alpine' ]; then
    ARGO_DAEMON_FILE='/etc/init.d/argo'; XRAY_DAEMON_FILE='/etc/init.d/xray'; DAEMON_RUN_PATTERN="command_args="
  fi

  if [ -x "$(type -p systemd-detect-virt)" ]; then
    VIRT=$(systemd-detect-virt)
  elif grep -qa container= /proc/1/environ 2>/dev/null; then
    VIRT=$(tr '\0' '\n' </proc/1/environ | awk -F= '/container=/{print $2; exit}')
  elif grep -Eq '(lxc|docker|kubepods|containerd)' /proc/1/cgroup 2>/dev/null; then
    VIRT=$(grep -Eo '(lxc|docker|kubepods|containerd)' /proc/1/cgroup | sed -n 1p)
  elif [ -x "$(type -p hostnamectl)" ]; then
    VIRT=$(hostnamectl | awk '/Virtualization/{print $NF}')
  else
    [ -x "$(type -p virt-what)" ] && ${PACKAGE_INSTALL[int]} virt-what >/dev/null 2>&1
    [ -x "$(type -p virt-what)" ] && VIRT=$(virt-what | sed -n 1p) || VIRT=unknown
  fi
}

# 检测 IPv4 IPv6 信息
check_system_ip() {
  [ "$L" = 'C' ] && local IS_CHINESE='?lang=zh-CN'
  local BIND_ADDRESS4='' BIND_ADDRESS6=''
  local DEFAULT_LOCAL_INTERFACE4=$(ip -4 route show default | awk '/default/ {for (i=0; i<NF; i++) if ($i=="dev") {print $(i+1); exit}}')
  local DEFAULT_LOCAL_INTERFACE6=$(ip -6 route show default | awk '/default/ {for (i=0; i<NF; i++) if ($i=="dev") {print $(i+1); exit}}')
  if [ -n "${DEFAULT_LOCAL_INTERFACE4}${DEFAULT_LOCAL_INTERFACE6}" ]; then
    local DEFAULT_LOCAL_IP4=$(ip -4 addr show $DEFAULT_LOCAL_INTERFACE4 | sed -n 's#.*inet \([^/]\+\)/[0-9]\+.*global.*#\1#gp')
    local DEFAULT_LOCAL_IP6=$(ip -6 addr show $DEFAULT_LOCAL_INTERFACE6 | sed -n 's#.*inet6 \([^/]\+\)/[0-9]\+.*global.*#\1#gp')
    [ -n "$DEFAULT_LOCAL_IP4" ] && local BIND_ADDRESS4="--bind-address=$DEFAULT_LOCAL_IP4"
    [ -n "$DEFAULT_LOCAL_IP6" ] && local BIND_ADDRESS6="--bind-address=$DEFAULT_LOCAL_IP6"
  fi

  {
    local IP4_JSON=$(wget $BIND_ADDRESS4 -4 -qO- --no-check-certificate --tries=2 --timeout=2 https://ip.cloudflare.now.cc${IS_CHINESE})
    [ -n "$IP4_JSON" ] && echo "$IP4_JSON" > $TEMP_DIR/ip4.json
  }&

  {
    local IP6_JSON=$(wget $BIND_ADDRESS6 -6 -qO- --no-check-certificate --tries=2 --timeout=2 https://ip.cloudflare.now.cc${IS_CHINESE})
    [ -n "$IP6_JSON" ] && echo "$IP6_JSON" > $TEMP_DIR/ip6.json
  }&

  wait

  if [ -s $TEMP_DIR/ip4.json ]; then
    local IP4_DATA=$(cat $TEMP_DIR/ip4.json)
    WAN4=$(awk -F '"' '/"ip"/{print $4}' <<< "$IP4_DATA")
    COUNTRY4=$(awk -F '"' '/"country"/{print $4}' <<< "$IP4_DATA")
    EMOJI4=$(awk -F '"' '/"emoji"/{print $4}' <<< "$IP4_DATA")
    ASNORG4=$(awk -F '"' '/"isp"/{print $4}' <<< "$IP4_DATA")
    rm -f $TEMP_DIR/ip4.json
  fi

  if [ -s $TEMP_DIR/ip6.json ]; then
    local IP6_DATA=$(cat $TEMP_DIR/ip6.json)
    WAN6=$(awk -F '"' '/"ip"/{print $4}' <<< "$IP6_DATA")
    COUNTRY6=$(awk -F '"' '/"country"/{print $4}' <<< "$IP6_DATA")
    EMOJI6=$(awk -F '"' '/"emoji"/{print $4}' <<< "$IP6_DATA")
    ASNORG6=$(awk -F '"' '/"isp"/{print $4}' <<< "$IP6_DATA")
    rm -f $TEMP_DIR/ip6.json
  fi

  if grep -qi 'cloudflare' <<< "$ASNORG4$ASNORG6"; then
    if grep -qi 'cloudflare' <<< "$ASNORG6" && [ -n "$WAN4" ] && ! grep -qi 'cloudflare' <<< "$ASNORG4"; then
      SERVER_IP_DEFAULT=$WAN4
    elif grep -qi 'cloudflare' <<< "$ASNORG4" && [ -n "$WAN6" ] && ! grep -qi 'cloudflare' <<< "$ASNORG6"; then
      SERVER_IP_DEFAULT=$WAN6
    else
      local a=6
      until [ -n "$SERVER_IP" ]; do
        ((a--)) || true
        [ "$a" = 0 ] && error "\n $(text 3) \n"
        reading "\n $(text 54) " SERVER_IP
      done
    fi
  elif [ -n "$WAN4" ]; then
    SERVER_IP_DEFAULT=$WAN4
  elif [ -n "$WAN6" ]; then
    SERVER_IP_DEFAULT=$WAN6
  fi
}

# 定义 Argo 变量（协议选择已在 xray_variable 中完成，此处只处理隧道配置）
argo_variable() {
  [ "${INSTALL_NGINX,,}" != 'n' ] && check_nginx >/dev/null 2>&1 &
  NGINX_PORT=${NGINX_PORT:-"$NGINX_PORT_DEFAULT"}

  if [ -z "$SERVER_IP" ]; then
    check_system_ip
    SERVER_IP="$SERVER_IP_DEFAULT"
  fi

  if [ ! -d $WORK_DIR ]; then
    [ -z "$SERVER_IP" ] && error " $(text 58) "

    [[ "$SERVER_IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] && CHATGPT_STACK='-4' || CHATGPT_STACK='-6'
    if [ "$(check_chatgpt ${CHATGPT_STACK})" = 'unlock' ]; then
      CHAT_GPT_OUT_V4=direct && CHAT_GPT_OUT_V6=direct
    else
      CHAT_GPT_OUT_V4=warp-IPv4 && CHAT_GPT_OUT_V6=warp-IPv6
    fi
  fi

  ARGO_DOMAIN=$(sed 's/[ ]*//g; s/:[ ]*//' <<< "$ARGO_DOMAIN")

  if [[ "$ARGO_AUTH" =~ TunnelSecret ]]; then
    ARGO_JSON=${ARGO_AUTH//[ ]/}
  elif [[ "$ARGO_AUTH" =~ [A-Z0-9a-z=]{120,250}$ ]]; then
    ARGO_TOKEN=$(awk '{print $NF}' <<< "$ARGO_AUTH")
  elif [[ "${#ARGO_AUTH}" = 40 ]]; then
    hint "\n $(text 78) \n "
    create_argo_tunnel "${ARGO_AUTH}" "${ARGO_DOMAIN}" "${NGINX_PORT}"
    if [[ ! "$ARGO_JSON" =~ TunnelSecret ]]; then
      hint "\n $(text 80) \n "
      unset ARGO_DOMAIN
    fi
  fi
}

# 定义 Xray 变量（含协议选择交互）
# 根据 INSTALL_PROTOCOLS 计算安装流程总步骤数
calc_install_steps() {
  local _total=7  # 固定步骤：协议选择、起始端口、Nginx端口、VPS IP、Argo域名、UUID、节点名
  local _has_reality=false _has_ws_xhttp=false _has_hy2=false
  for _p in "${INSTALL_PROTOCOLS[@]}"; do
    [[ "$_p" =~ ^[bd]$ ]] && _has_reality=true
    [[ "$_p" =~ ^[efghi]$ ]] && _has_ws_xhttp=true
    [[ "$_p" == 'c' ]] && _has_hy2=true
  done
  grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL" && (( _total-- ))  # 非交互安装时不单独询问 VPS IP
  $_has_reality && (( _total++ ))      # Reality 密钥
  $_has_ws_xhttp && (( _total += 2 ))  # CDN 域名 + WS 路径
  $_has_hy2 && (( _total++ ))          # 端口跳跃
  TOTAL_STEPS=$_total
}

# 生成 Reality 密钥对
generate_reality_keypair() {
  local KEYPAIR
  local _XRAY_BIN="$TEMP_DIR/xray"
  [ ! -x "$_XRAY_BIN" ] && _XRAY_BIN="$WORK_DIR/xray"

  # 如果 xray 二进制文件尚不可用（如非交互式安装且下载未完成），则回退到 openssl 生成
  if [ -x "$_XRAY_BIN" ]; then
    KEYPAIR=$($_XRAY_BIN x25519)
    REALITY_PRIVATE=$(awk '/Private/{print $NF}' <<< "$KEYPAIR")
    REALITY_PUBLIC=$(awk '/Public/{print $NF}' <<< "$KEYPAIR")
  else
    # 回退逻辑：使用 openssl 生成私钥并派生公钥
    [ ! -x "$(type -p openssl)" ] && return
    REALITY_PRIVATE=$(openssl genpkey -algorithm x25519 -outform DER 2>/dev/null | tail -c 32 | base64 | tr '/+' '_-' | tr -d '=')
    REALITY_PUBLIC=''
  fi
}

xray_variable() {
  local STEP_NUM=0
  local TOTAL_STEPS=''
  # Pre-calculate the maximum step count with all protocols selected for prompt display.
  local _saved_protocols=("${INSTALL_PROTOCOLS[@]}")
  local _all_protocol_letters=''
  local _idx
  for _idx in "${!PROTOCOL_LIST[@]}"; do
    _all_protocol_letters+="$(asc $((98 + _idx))) "
  done
  read -r -a INSTALL_PROTOCOLS <<< "${_all_protocol_letters% }"
  calc_install_steps
  INSTALL_PROTOCOLS=("${_saved_protocols[@]}")
  # 兼容 config.conf 字符串写法：INSTALL_PROTOCOLS='bcef' → 拆成 (b c e f)
  if [[ "${#INSTALL_PROTOCOLS[@]}" -eq 1 && ! "${INSTALL_PROTOCOLS[0]}" =~ ^[[:space:]]*$ ]]; then
    local _proto_str="${INSTALL_PROTOCOLS[0]}"
    if [[ "$_proto_str" =~ ^[aA]$ ]]; then
      read -r -a INSTALL_PROTOCOLS <<< "${_all_protocol_letters% }"
    elif [[ "${#_proto_str}" -gt 1 ]]; then
      INSTALL_PROTOCOLS=()
      while IFS= read -r -n1 _ch; do
        [ -n "$_ch" ] && INSTALL_PROTOCOLS+=("$_ch")
      done <<< "$_proto_str"
    fi
  fi
  (( STEP_NUM++ )) || true
  if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL" && [ -z "${INSTALL_PROTOCOLS[*]}" ]; then
    hint "\n $(text 87)"
    hint "$(text 100)"
    for p in "${!PROTOCOL_LIST[@]}"; do
      local letter=$(asc $((p + 98)))
      local p_name="${PROTOCOL_LIST[p]}"
      if [ "$letter" = "i" ]; then
        p_name=$(text 101)
      elif [ "$letter" = "j" ]; then
        p_name="VLESS + XHTTP Direct (h3)"
      elif [ "$letter" = "k" ]; then
        p_name="Trojan Direct"
      elif [ "$letter" = "l" ]; then
        p_name="Shadowsocks 2022 Direct"
      fi
      hint " ${letter}. ${p_name}"
    done
    reading "\n $(text 24) " CHOOSE_PROTOCOLS
  fi

  if [ -z "${INSTALL_PROTOCOLS[*]}" ]; then
    local MAX_LETTER=$(asc $((97 + ${#PROTOCOL_LIST[@]})))
    if [[ -z "$CHOOSE_PROTOCOLS" || "${CHOOSE_PROTOCOLS,,}" =~ ^a$ ]]; then
      read -r -a INSTALL_PROTOCOLS <<< "${_all_protocol_letters% }"
    else
      local filtered
      filtered=$(grep -o . <<< "${CHOOSE_PROTOCOLS,,}" | grep -E "^[b-${MAX_LETTER}]$" | awk '!seen[$0]++' | tr -d '\n')
      [ -z "$filtered" ] && read -r -a INSTALL_PROTOCOLS <<< "${_all_protocol_letters% }" || {
        INSTALL_PROTOCOLS=()
        while IFS= read -r -n1 ch; do
          [ -n "$ch" ] && INSTALL_PROTOCOLS+=("$ch")
        done <<< "$filtered"
      }
    fi
  fi

  # 协议已确定，计算总步骤数
  calc_install_steps

  local NUM=${#INSTALL_PROTOCOLS[@]}
  if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL" && [ -z "$START_PORT" ]; then
    (( STEP_NUM++ )) || true
    input_start_port "$NUM"
  fi
  START_PORT=${START_PORT:-"$START_PORT_DEFAULT"}
  grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL" && SERVER_IP=${SERVER_IP:-"$SERVER_IP_DEFAULT"}
  TLS_SERVER=${TLS_SERVER:-"addons.mozilla.org"}

  for i in "${!INSTALL_PROTOCOLS[@]}"; do
    local p="${INSTALL_PROTOCOLS[$i]}"
    case "$p" in
      b) REALITY_PORT=$(( START_PORT + i )) ;;
      c) HY2_PORT=$(( START_PORT + i )) ;;
      d) GRPC_PORT=$(( START_PORT + i )) ;;
      e) WS_PORT_e=$(( START_PORT + i )) ;;
      f) WS_PORT_f=$(( START_PORT + i )) ;;
      g) WS_PORT_g=$(( START_PORT + i )) ;;
      h) WS_PORT_h=$(( START_PORT + i )) ;;
      i) WS_PORT_i=$(( START_PORT + i )) ;;
      j) XHTTP_PORT_j=$(( START_PORT + i )) ;;
      k) TROJAN_PORT_k=$(( START_PORT + i )) ;;
      l) SS2022_PORT_l=$(( START_PORT + i )) ;;
    esac
  done

  INSTALL_NGINX="y"
  if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL" && [ -z "$NGINX_PORT" ]; then
    (( STEP_NUM++ )) || true
    input_nginx_port
  fi
  NGINX_PORT=${NGINX_PORT:-"$NGINX_PORT_DEFAULT"}

  if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL"; then
    (( STEP_NUM++ )) || true
    reading "\n $(text 59) " SERVER_IP
  fi
  SERVER_IP=${SERVER_IP:-"$SERVER_IP_DEFAULT"}

  if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL"; then
    if [ -z "$ARGO_DOMAIN" ]; then
      (( STEP_NUM++ )) || true
      reading "\n $(text 10) " ARGO_DOMAIN
    fi
    if [[ -n "$ARGO_DOMAIN" && ! "$ARGO_DOMAIN" =~ trycloudflare\.com$ && -z "$ARGO_AUTH" ]]; then
      hint "\n $(text 11)"
      reading "\n $(text 86) " ARGO_AUTH
    fi
  fi

  local HAS_REALITY=false
  for p in "${INSTALL_PROTOCOLS[@]}"; do [[ "$p" =~ ^[bd]$ ]] && HAS_REALITY=true && break; done
  if $HAS_REALITY; then
    if [ -z "$REALITY_PRIVATE" ] && [ -s "$CUSTOM_FILE" ]; then
      local _pk_in_custom
      _pk_in_custom=$(awk -F= '/^privateKey=/{print $2}' "$CUSTOM_FILE")
      [[ -n "$_pk_in_custom" && "$_pk_in_custom" != '__KEY_UNSET__' ]] && REALITY_PRIVATE="$_pk_in_custom"
      [[ -n "$REALITY_PRIVATE" && "$REALITY_PRIVATE" != '__KEY_UNSET__' ]] && REALITY_PUBLIC=$(awk -F= '/^publicKey=/{print $2}' "$CUSTOM_FILE")
    fi
    [[ "$REALITY_PRIVATE" == '__KEY_UNSET__' ]] && REALITY_PRIVATE=''
    [[ "$REALITY_PUBLIC" == '__KEY_UNSET__' ]] && REALITY_PUBLIC=''
    if [ -z "$REALITY_PRIVATE" ]; then
      if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL"; then
        (( STEP_NUM++ )) || true
        reading "\n $(text 98) " REALITY_PRIVATE
      fi
      if [ -z "$REALITY_PRIVATE" ]; then
        generate_reality_keypair
      else
        # 从私钥生成公钥：优先使用 OpenSSL 本地生成，回退使用远程 API
        if [ -x "$(type -p xxd)" ]; then
          local B64 MOD PREFIX_HEX PRIV_HEX PRIV_LEN
          B64=$(printf '%s' "$REALITY_PRIVATE" | tr '_-' '/+')
          MOD=$(( ${#B64} % 4 ))
          if [ "$MOD" -eq 2 ]; then
            B64="${B64}=="
          elif [ "$MOD" -eq 3 ]; then
            B64="${B64}="
          elif [ "$MOD" -ne 0 ]; then
            B64=''
          fi

          if [ -n "$B64" ] && echo "$B64" | base64 -d > "$TEMP_DIR/_X25519_PRIV_RAW" 2>/dev/null; then
            PRIV_LEN=$(stat -c%s "$TEMP_DIR/_X25519_PRIV_RAW" 2>/dev/null || stat -f%z "$TEMP_DIR/_X25519_PRIV_RAW")
            if [ "$PRIV_LEN" -eq 32 ]; then
              PREFIX_HEX="302e020100300506032b656e04220420"
              PRIV_HEX=$(xxd -p -c 256 "$TEMP_DIR/_X25519_PRIV_RAW" | tr -d '\n')
              printf "%s%s" "$PREFIX_HEX" "$PRIV_HEX" | xxd -r -p > "$TEMP_DIR/_X25519_PRIV_DER"
              if openssl pkcs8 -inform DER -in "$TEMP_DIR/_X25519_PRIV_DER" -nocrypt -out "$TEMP_DIR/_X25519_PRIV_PEM" 2>/dev/null && \
                 openssl pkey -in "$TEMP_DIR/_X25519_PRIV_PEM" -pubout -outform DER > "$TEMP_DIR/_X25519_PUB_DER" 2>/dev/null; then
                tail -c 32 "$TEMP_DIR/_X25519_PUB_DER" > "$TEMP_DIR/_X25519_PUB_RAW"
                REALITY_PUBLIC=$(base64 -w0 "$TEMP_DIR/_X25519_PUB_RAW" | tr '+/' '-_' | sed -E 's/=+$//')
              fi
            fi
          fi
        fi

        # 方法 1 失败，尝试方法 2：远程 API
        if [ -z "$REALITY_PUBLIC" ]; then
          REALITY_PUBLIC=$(wget --no-check-certificate -qO- --tries=3 --timeout=2 \
            "https://realitykey.cloudflare.now.cc/?privateKey=$REALITY_PRIVATE" \
            | awk -F '"' '/publicKey/{print $4}')
        fi

        # 都失败，生成随机密钥对
        if [ -z "$REALITY_PUBLIC" ]; then
          warning " $(text 99) "
          generate_reality_keypair
        fi
      fi
    fi
  fi

  local _HAS_WS_XHTTP=false _HAS_XHTTP_DIRECT=false
  for p in "${INSTALL_PROTOCOLS[@]}"; do
    [[ "$p" =~ ^[efghi]$ ]] && _HAS_WS_XHTTP=true && break
  done
  for p in "${INSTALL_PROTOCOLS[@]}"; do
    [[ "$p" == 'j' ]] && _HAS_XHTTP_DIRECT=true && break
  done

  if [ -z "$SERVER" ]; then
    if $_HAS_WS_XHTTP; then
      if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL"; then
        (( STEP_NUM++ )) || true
        echo ""
        for c in "${!CDN_DOMAIN[@]}"; do
          hint " $((c+1)). ${CDN_DOMAIN[c]} "
        done
        reading "\n $(text 42) " CUSTOM_CDN
      fi
      case "$CUSTOM_CDN" in
        [1-9]|[1-9][0-9] )
          [ "$CUSTOM_CDN" -le "${#CDN_DOMAIN[@]}" ] && SERVER="${CDN_DOMAIN[$((CUSTOM_CDN-1))]}" || SERVER="${CDN_DOMAIN[0]}"
          ;;
        ?????* )
          SERVER="$CUSTOM_CDN"
          ;;
        * )
          SERVER="${CDN_DOMAIN[0]}"
      esac
    else
      SERVER='__CDN_UNSET__'
    fi
  fi

  if [[ " ${INSTALL_PROTOCOLS[*]} " =~ " c " ]]; then
    if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL"; then
      (( STEP_NUM++ )) || true
      input_hopping_port
    elif [ -n "$PORT_HOPPING_RANGE" ]; then
      # 非交互模式：config.conf 填了 PORT_HOPPING_RANGE，直接解析
      local _R=${PORT_HOPPING_RANGE//-/:}
      PORT_HOPPING_RANGE=$_R
      PORT_HOPPING_START=${_R%:*}
      PORT_HOPPING_END=${_R#*:}
      IS_HOPPING=is_hopping
    fi
    IS_HOPPING=${IS_HOPPING:-no_hopping}
  fi

  if $_HAS_WS_XHTTP; then
    if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL" && [ -z "$WS_PATH" ]; then
      (( STEP_NUM++ )) || true
      reading "\n $(text 13) " WS_PATH
    fi
    local a=5
    until [[ -z "$WS_PATH" || "$WS_PATH" =~ ^[A-Za-z0-9_.@-]+$ ]]; do
      (( a-- )) || true
      [ "$a" = 0 ] && error " $(text 3) " || reading " $(text 14) " WS_PATH
    done
    WS_PATH=${WS_PATH:-"$WS_PATH_DEFAULT"}
  fi

  if $_HAS_XHTTP_DIRECT && [[ ! " ${INSTALL_PROTOCOLS[*]} " =~ " c " ]]; then
    info "\n XHTTP Direct TLS certificate: ${WORK_DIR}/cert/cert.pem \n"
  fi

  local _uuid_step_done=false
  local a=6
  until [[ "${UUID,,}" =~ ^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$ ]]; do
    (( a-- )) || true
    [ "$a" = 0 ] && error "\n $(text 3) \n"
    UUID_DEFAULT=$(cat /proc/sys/kernel/random/uuid)
    if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL"; then
      $_uuid_step_done || { (( STEP_NUM++ )) || true; _uuid_step_done=true; }
      reading "\n $(text 12) " UUID
    fi
    UUID=${UUID:-"$UUID_DEFAULT"}
    [[ ! "${UUID,,}" =~ ^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$ ]] && warning "\n $(text 4) "
  done

  local EMOJI_VAL="${EMOJI4:-$EMOJI6}"
  if [ -z "$NODE_NAME" ]; then
    if [ -x "$(type -p hostname)" ]; then
      local HOST_NAME=$(hostname)
    elif [ -s /etc/hostname ]; then
      local HOST_NAME=$(cat /etc/hostname)
    else
      local HOST_NAME="ArgoX"
    fi
    NODE_NAME_DEFAULT="$HOST_NAME"
    if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL"; then
      (( STEP_NUM++ )) || true
      reading "\n $(text 49) " NODE_NAME
    fi
    NODE_NAME=${NODE_NAME:-"$HOST_NAME"}
  fi
  grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL" || NODE_NAME="${EMOJI_VAL}${EMOJI_VAL:+ }${NODE_NAME}"
}

# Fast install preset variables
fast_install_variables() {
  local _all_protocol_letters=''
  local _idx
  for _idx in "${!PROTOCOL_LIST[@]}"; do
    _all_protocol_letters+="$(asc $((98 + _idx))) "
  done
  read -r -a INSTALL_PROTOCOLS <<< "${_all_protocol_letters% }"

  START_PORT=${START_PORT:-"$START_PORT_DEFAULT"}
  for i in "${!INSTALL_PROTOCOLS[@]}"; do
    local p="${INSTALL_PROTOCOLS[$i]}"
    case "$p" in
      b) REALITY_PORT=$(( START_PORT + i )) ;;
      c) HY2_PORT=$(( START_PORT + i )) ;;
      d) GRPC_PORT=$(( START_PORT + i )) ;;
      e) WS_PORT_e=$(( START_PORT + i )) ;;
      f) WS_PORT_f=$(( START_PORT + i )) ;;
      g) WS_PORT_g=$(( START_PORT + i )) ;;
      h) WS_PORT_h=$(( START_PORT + i )) ;;
      i) WS_PORT_i=$(( START_PORT + i )) ;;
      j) XHTTP_PORT_j=$(( START_PORT + i )) ;;
      k) TROJAN_PORT_k=$(( START_PORT + i )) ;;
      l) SS2022_PORT_l=$(( START_PORT + i )) ;;
    esac
  done

  # 极速安装模式：如果填了 PORT_HOPPING_RANGE，自动解析并启用端口跳跃
  if [ -z "$IS_HOPPING" ] && [ -n "$PORT_HOPPING_RANGE" ]; then
    local _R=${PORT_HOPPING_RANGE//-/:}
    PORT_HOPPING_RANGE=$_R
    PORT_HOPPING_START=${_R%:*}
    PORT_HOPPING_END=${_R#*:}
    IS_HOPPING=is_hopping
  fi
  IS_HOPPING=${IS_HOPPING:-no_hopping}

  SERVER=${SERVER:-"${CDN_DOMAIN[0]}"}
  UUID=${UUID:-$(cat /proc/sys/kernel/random/uuid)}
  WS_PATH=${WS_PATH:-"$WS_PATH_DEFAULT"}
  NGINX_PORT=${NGINX_PORT:-"$NGINX_PORT_DEFAULT"}

  check_system_ip
  SERVER_IP=${SERVER_IP:-$SERVER_IP_DEFAULT}
  local EMOJI_VAL="${EMOJI4:-$EMOJI6}"
  if [ -x "$(type -p hostname)" ]; then
    local HOST_NAME=$(hostname)
  elif [ -s /etc/hostname ]; then
    local HOST_NAME=$(cat /etc/hostname)
  else
    local HOST_NAME="ArgoX"
  fi
  NODE_NAME="${EMOJI_VAL}${EMOJI_VAL:+ }${HOST_NAME}"
}

check_dependencies() {
  if [ "$SYSTEM" = 'Alpine' ]; then
    local CHECK_WGET=$(wget 2>&1 | sed -n 1p)
    grep -qi 'busybox' <<< "$CHECK_WGET" && ${PACKAGE_INSTALL[int]} wget >/dev/null 2>&1

    local DEPS_CHECK=("bash" "rc-update" "iptables" "ip6tables" "nginx")
    local DEPS_INSTALL=("bash" "openrc" "iptables" "ip6tables" "nginx")
    for g in "${!DEPS_CHECK[@]}"; do
      [ ! -x "$(type -p ${DEPS_CHECK[g]})" ] && DEPS_ALPINE+=(${DEPS_INSTALL[g]})
    done
    if [ "${#DEPS_ALPINE[@]}" -ge 1 ]; then
      info "\n $(text 7) $(sed "s/ /,&/g" <<< ${DEPS_ALPINE[@]}) \n"
      ${PACKAGE_UPDATE[int]} >/dev/null 2>&1
      ${PACKAGE_INSTALL[int]} ${DEPS_ALPINE[@]} >/dev/null 2>&1
    fi
  fi

  local DEPS_CHECK=("wget" "ss" "unzip" "bash" "nginx" "openssl")
  local DEPS_INSTALL=("wget" "iproute2" "unzip" "bash" "nginx" "openssl")

  [ "$SYSTEM" != 'Alpine' ] && DEPS_CHECK+=("systemctl") && DEPS_INSTALL+=("systemctl")

  if [ "$SYSTEM" != 'Alpine' ]; then
    [ ! -x "$(type -p iptables)" ] && DEPS_CHECK+=("iptables") && DEPS_INSTALL+=("iptables")
    [ ! -x "$(type -p ip6tables)" ] && DEPS_CHECK+=("ip6tables") && DEPS_INSTALL+=("ip6tables")
  fi

  for g in "${!DEPS_CHECK[@]}"; do
    [ ! -x "$(type -p ${DEPS_CHECK[g]})" ] && DEPS+=(${DEPS_INSTALL[g]})
  done
  if [ "${#DEPS[@]}" -ge 1 ]; then
    info "\n $(text 7) $(sed "s/ /,&/g" <<< ${DEPS[@]}) \n"
    [ "$SYSTEM" != 'CentOS' ] && ${PACKAGE_UPDATE[int]} >/dev/null 2>&1
    ${PACKAGE_INSTALL[int]} ${DEPS[@]} >/dev/null 2>&1
  else
    info "\n $(text 8) \n"
  fi

  (type -p nginx >/dev/null 2>&1) && cmd_systemctl disable nginx >/dev/null 2>&1 || true
}

# 输入 WS/XHTTP 内部起始端口，连续 NUM 个端口逐一检测是否被占用
input_start_port() {
  local NUM=$1
  local PORT_ERROR_TIME=6
  while true; do
    [ "$PORT_ERROR_TIME" -lt 6 ] && unset IN_USED START_PORT
    (( PORT_ERROR_TIME-- )) || true
    if [ "$PORT_ERROR_TIME" = 0 ]; then
      error "\n $(text 3) \n"
    else
      [ -z "$START_PORT" ] && reading "\n $(text 56) " START_PORT
    fi
    START_PORT=${START_PORT:-"$START_PORT_DEFAULT"}
    if [[ "$START_PORT" =~ ^[1-9][0-9]{2,4}$ && "$START_PORT" -ge "$MIN_PORT" && "$START_PORT" -le "$MAX_PORT" ]]; then
      local IN_USED=()
      local port
      refresh_port_snapshot
      for ((port=START_PORT; port<START_PORT+NUM; port++)); do
        is_port_in_use "$port" && IN_USED+=("$port")
      done
      [ "${#IN_USED[@]}" -eq 0 ] && break || warning "\n $(text 61) ${IN_USED[*]} \n"
    fi
  done
}

# 输入 Nginx 端口
input_nginx_port() {
  local PORT_ERROR_TIME=6
  grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL" && NGINX_PORT=${NGINX_PORT:-"$NGINX_PORT_DEFAULT"}
  while true; do
    [ "$PORT_ERROR_TIME" -lt 6 ] && unset NGINX_PORT
    (( PORT_ERROR_TIME-- )) || true
    if [ "$PORT_ERROR_TIME" = 0 ]; then
      error "\n $(text 3) \n"
    else
      [ -z "$NGINX_PORT" ] && reading "\n $(text 68) " NGINX_PORT
    fi
    NGINX_PORT=${NGINX_PORT:-"$NGINX_PORT_DEFAULT"}
    if [[ "$NGINX_PORT" =~ ^[1-9][0-9]{1,4}$ && "$NGINX_PORT" -ge "$MIN_PORT" && "$NGINX_PORT" -le "$MAX_PORT" ]]; then
      refresh_port_snapshot
      is_port_in_use "$NGINX_PORT" && warning "\n $(text 61) $NGINX_PORT \n" || break
    fi
  done
}

# 从已安装的 inbound.json / protocols 等配置文件中读取各参数，供 export_list / change_protocols 复用
fetch_nodes_value() {
  unset SERVER_IP REALITY_PORT REALITY_PUBLIC REALITY_PRIVATE TLS_SERVER SERVER UUID WS_PATH NODE_NAME SS_METHOD SS2022_PASSWORD \
        GRPC_PORT HY2_PORT TROJAN_PORT SS2022_PORT SERVER_IP_1 SERVER_IP_2

  [ -s "$CUSTOM_FILE" ] && . "$CUSTOM_FILE"
  SERVER_IP="${serverIp:-}"
  REALITY_PRIVATE="${privateKey:-}"
  REALITY_PUBLIC="${publicKey:-}"
  SERVER="${cdn:-}"
  unset serverIp privateKey publicKey cdn language

  local JSON
  JSON=$(grep -v '^//' $WORK_DIR/inbound.json 2>/dev/null)
  [ -z "$JSON" ] && [ ! -s "$CUSTOM_FILE" ] && return 1
  [ -z "$JSON" ] && return 0

  REALITY_PORT=$(echo "$JSON" | $WORK_DIR/jq -r '.inbounds[0].port // empty')
  TLS_SERVER=$(echo "$JSON" | $WORK_DIR/jq -r '.inbounds[] | select(.streamSettings.security=="reality") | .streamSettings.realitySettings.serverNames[0]' 2>/dev/null | head -1)
  UUID=$(echo "$JSON" | $WORK_DIR/jq -r '.inbounds[0].settings.clients[0].id // .inbounds[0].settings.clients[0].password // .inbounds[0].settings.clients[0].auth // empty')
  WS_PATH=$(echo "$JSON" | $WORK_DIR/jq -r '.inbounds[] | select(.streamSettings.network=="ws") | .streamSettings.wsSettings.path' 2>/dev/null | head -1 | sed 's|/||; s|-vl$||; s|-vm$||; s|-tr$||; s|-sh$||; s|-xh$||')
  NODE_NAME=$(echo "$JSON" | $WORK_DIR/jq -r '.inbounds[0].tag // empty' | sed 's/ [^ ]*$//')
  SS_METHOD=$(echo "$JSON" | $WORK_DIR/jq -r '.inbounds[] | select(.tag | split(" ")[-1] == "ss-ws") | .settings.clients[0].method // empty' 2>/dev/null | head -1)
  SS2022_PASSWORD=$(echo "$JSON" | $WORK_DIR/jq -r '.inbounds[] | select(.tag | split(" ")[-1] == "ss2022-direct") | .settings.password // empty' 2>/dev/null | head -1)
  [ -z "$SS2022_PASSWORD" ] && SS2022_PASSWORD=$(echo "$JSON" | $WORK_DIR/jq -r '.inbounds[] | select(.tag | split(" ")[-1] == "ss2022-direct") | .settings.clients[0].password // empty' 2>/dev/null | head -1)
  [ -z "$SS_METHOD" ] && SS_METHOD=$(echo "$JSON" | $WORK_DIR/jq -r '.inbounds[] | select(.protocol=="shadowsocks") | .settings.clients[0].method // .settings.method // empty' 2>/dev/null | head -1)
  GRPC_PORT=$(echo "$JSON" | $WORK_DIR/jq -r '[.inbounds[] | select(.streamSettings.network=="grpc") | .port] | .[0] // empty' 2>/dev/null)
  HY2_PORT=$(echo "$JSON" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "hysteria2") | .port] | .[0] // empty' 2>/dev/null)
  [ -z "$TLS_SERVER" ] && TLS_SERVER=$(echo "$JSON" | $WORK_DIR/jq -r '[.inbounds[] | select(.streamSettings.network=="hysteria") | .streamSettings.tlsSettings.serverNames[0]] | .[0] // empty' 2>/dev/null)
  [ -z "$TLS_SERVER" ] && TLS_SERVER=$(echo "$JSON" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "trojan-direct") | .streamSettings.tlsSettings.serverName // .streamSettings.tlsSettings.serverNames[0]] | .[0] // empty' 2>/dev/null)
  [ -z "$TLS_SERVER" ] && [ -s "$WORK_DIR/cert/cert.pem" ] && TLS_SERVER=$(openssl x509 -noout -ext subjectAltName -in "$WORK_DIR/cert/cert.pem" 2>/dev/null | awk -F 'DNS:' '/DNS:/{gsub(/,.*/,"",$2);print $2; exit}')
  [ -z "$SS2022_PASSWORD" ] && SS2022_PASSWORD="$(openssl rand -base64 16)"
  TROJAN_PORT=$(echo "$JSON" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "trojan-direct") | .port] | .[0] // empty' 2>/dev/null)
  SS2022_PORT=$(echo "$JSON" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "ss2022-direct") | .port] | .[0] // empty' 2>/dev/null)

  [ -z "$WS_PATH" ] && WS_PATH="$WS_PATH_DEFAULT"
  [ -z "$NODE_NAME" ] && NODE_NAME="ArgoX"
  [[ -z "$SERVER" || "$SERVER" == '__CDN_UNSET__' ]] && SERVER='__CDN_UNSET__'

  if [[ "$SERVER_IP" =~ : ]]; then
    SERVER_IP_1="[$SERVER_IP]"
    SERVER_IP_2="[[$SERVER_IP]]"
  else
    SERVER_IP_1="$SERVER_IP"
    SERVER_IP_2="$SERVER_IP"
  fi

  [ -n "$HY2_PORT" ] && check_port_hopping_nat
  return 0
}

# 获取 Argo 隧道域名，通过传参选择获取方式：
#   quick  - 临时隧道，查询 cloudflared metrics /quicktunnel 端点
#   config - Json/Token 隧道，查询 /config 端点，同时解析出 NGINX_PORT
fetch_tunnel_domain() {
  local _MODE="${1:-quick}"
  local _CF_PID _METRICS_ADDR
  _CF_PID=$(ps -eo pid,args | awk -v d="$WORK_DIR" '$0~(d"/cloudflared"){print $1;exit}')
  [[ "$_CF_PID" =~ ^[0-9]+$ ]] && _METRICS_ADDR=$(ss -nltp | awk -v pid="$_CF_PID" '$0 ~ "pid="pid"," {print $4; exit}' | sed 's/^\*/127.0.0.1/; s/^0\.0\.0\.0/127.0.0.1/')

  if [ "$_MODE" = 'config' ]; then
    unset ARGO_DOMAIN
    [ -z "$_METRICS_ADDR" ] && return 1
    local _CONFIG_JSON
    _CONFIG_JSON=$(wget -qO- "http://${_METRICS_ADDR}/config" 2>/dev/null)
    [ -z "$_CONFIG_JSON" ] && return 1
    [ -z "$NGINX_PORT" ] && [ -s "$WORK_DIR/nginx.conf" ] && NGINX_PORT=$(awk '/listen[[:space:]]/{gsub(/;/,""); print $2; exit}' "$WORK_DIR/nginx.conf")
    ARGO_DOMAIN=$($WORK_DIR/jq -r --arg port "$NGINX_PORT" '.config.ingress[] | select(.service == ("http://localhost:" + $port)) | .hostname ' <<< "$_CONFIG_JSON")
    return 0
  else
    unset ARGO_DOMAIN
    local _ERROR_TIME=20
    until [ -n "$ARGO_DOMAIN" ]; do
      if [ -z "$_METRICS_ADDR" ]; then
        _CF_PID=$(ps -eo pid,args | awk -v d="$WORK_DIR" '$0~(d"/cloudflared"){print $1;exit}')
        [[ "$_CF_PID" =~ ^[0-9]+$ ]] && \
          _METRICS_ADDR=$(ss -nltp | awk -v pid="$_CF_PID" '$0 ~ "pid="pid"," {print $4; exit}' \
            | sed 's/^\*/127.0.0.1/; s/^0\.0\.0\.0/127.0.0.1/')
      fi
      [ -n "$_METRICS_ADDR" ] && ARGO_DOMAIN=$(wget -qO- "http://${_METRICS_ADDR}/quicktunnel" | awk -F '"' '{print $4}')
      if [[ ! "$ARGO_DOMAIN" =~ trycloudflare\.com$ ]]; then
        (( _ERROR_TIME-- )) || true
        [ "$_ERROR_TIME" = 0 ] && warning "\n $(text 102) \n" && unset ARGO_DOMAIN && return 1
        sleep 2
      else
        break
      fi
    done
  fi
}

# 检查并安装 nginx
check_nginx() {
  if [ ! -x "$(type -p nginx)" ]; then
    info "\n $(text 7) nginx \n"
    ${PACKAGE_INSTALL[int]} nginx >/dev/null 2>&1
    [ "$SYSTEM" != 'Alpine' ] && systemctl disable --now nginx >/dev/null 2>&1
  fi
}

# 生成100年自签证书（供 Hysteria2 使用）
ssl_certificate() {
  local TLS_SRV="${1:-$TLS_SERVER}"
  [ ! -d ${WORK_DIR}/cert ] && mkdir -p ${WORK_DIR}/cert
  openssl ecparam -genkey -name prime256v1 -out ${WORK_DIR}/cert/private.key 2>/dev/null
  cat > ${WORK_DIR}/cert/cert.conf << EOF
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
CN = $(awk -F . '{print $(NF-1)"."$NF}' <<< "$TLS_SRV")

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS = ${TLS_SRV}
EOF
  openssl req -new -x509 -days 36500 \
    -key ${WORK_DIR}/cert/private.key \
    -out ${WORK_DIR}/cert/cert.pem \
    -config ${WORK_DIR}/cert/cert.conf \
    -subj "/CN=${TLS_SRV}" \
    -extensions v3_req 2>/dev/null
  rm -f ${WORK_DIR}/cert/cert.conf
}

# 添加端口跳跃 NAT 规则
add_port_hopping_nat() {
  local HOP_START=$1 HOP_END=$2 HOP_TARGET=$3
  # 防止空参数写入残缺规则
  [[ -z "$HOP_START" || -z "$HOP_END" || -z "$HOP_TARGET" ]] && return 1
  local COMMENT="NAT ${HOP_START}:${HOP_END} to ${HOP_TARGET} (ArgoX)"
  if [ "$SYSTEM" = 'Alpine' ]; then
    iptables --table nat -A PREROUTING -p udp --dport ${HOP_START}:${HOP_END} -m comment --comment "$COMMENT" -j DNAT --to-destination :${HOP_TARGET} 2>/dev/null
    ip6tables --table nat -A PREROUTING -p udp --dport ${HOP_START}:${HOP_END} -m comment --comment "$COMMENT" -j DNAT --to-destination :${HOP_TARGET} 2>/dev/null
    rc-update show default | grep -q 'iptables' || rc-update add iptables >/dev/null 2>&1
    rc-update show default | grep -q 'ip6tables' || rc-update add ip6tables >/dev/null 2>&1
    rc-service iptables save >/dev/null 2>&1
    rc-service ip6tables save >/dev/null 2>&1
  elif [ -x "$(type -p firewalld)" ] && [ "$(systemctl is-active firewalld 2>/dev/null)" = 'active' ]; then
    [ "$(firewall-cmd --query-masquerade --permanent 2>/dev/null)" != 'yes' ] && \
      firewall-cmd --add-masquerade --permanent >/dev/null 2>&1 && firewall-cmd --reload >/dev/null 2>&1
    firewall-cmd --add-forward-port=port=${HOP_START}-${HOP_END}:proto=udp:toport=${HOP_TARGET} --permanent >/dev/null 2>&1
    firewall-cmd --reload >/dev/null 2>&1
  else
    [ ! -x "$(type -p netfilter-persistent)" ] && ${PACKAGE_INSTALL[int]} iptables-persistent >/dev/null 2>&1
    iptables --table nat -A PREROUTING -p udp --dport ${HOP_START}:${HOP_END} -m comment --comment "$COMMENT" -j DNAT --to-destination :${HOP_TARGET} 2>/dev/null
    ip6tables --table nat -A PREROUTING -p udp --dport ${HOP_START}:${HOP_END} -m comment --comment "$COMMENT" -j DNAT --to-destination :${HOP_TARGET} 2>/dev/null
    [ "$(systemctl is-active netfilter-persistent 2>/dev/null)" = 'active' ] && netfilter-persistent save 2>/dev/null
  fi
}

# 删除端口跳跃 NAT 规则
del_port_hopping_nat() {
  check_port_hopping_nat
  [ -z "$PORT_HOPPING_START" ] && return
  local COMMENT="NAT ${PORT_HOPPING_START}:${PORT_HOPPING_END} to ${PORT_HOPPING_TARGET} (ArgoX)"
  if [ "$SYSTEM" = 'Alpine' ]; then
    iptables --table nat -D PREROUTING -p udp --dport ${PORT_HOPPING_START}:${PORT_HOPPING_END} -m comment --comment "$COMMENT" -j DNAT --to-destination :${PORT_HOPPING_TARGET} 2>/dev/null
    ip6tables --table nat -D PREROUTING -p udp --dport ${PORT_HOPPING_START}:${PORT_HOPPING_END} -m comment --comment "$COMMENT" -j DNAT --to-destination :${PORT_HOPPING_TARGET} 2>/dev/null
  elif [ -x "$(type -p firewalld)" ] && [ "$(systemctl is-active firewalld 2>/dev/null)" = 'active' ]; then
    firewall-cmd --permanent --remove-forward-port=port=${PORT_HOPPING_START}-${PORT_HOPPING_END}:proto=udp:toport=${PORT_HOPPING_TARGET} >/dev/null 2>&1
    firewall-cmd --reload >/dev/null 2>&1
  else
    iptables --table nat -D PREROUTING -p udp --dport ${PORT_HOPPING_START}:${PORT_HOPPING_END} -m comment --comment "$COMMENT" -j DNAT --to-destination :${PORT_HOPPING_TARGET} 2>/dev/null
    ip6tables --table nat -D PREROUTING -p udp --dport ${PORT_HOPPING_START}:${PORT_HOPPING_END} -m comment --comment "$COMMENT" -j DNAT --to-destination :${PORT_HOPPING_TARGET} 2>/dev/null
    [ "$(systemctl is-active netfilter-persistent 2>/dev/null)" = 'active' ] && netfilter-persistent save 2>/dev/null
  fi
}

# 检查端口跳跃 NAT 规则（读取当前 iptables）
check_port_hopping_nat() {
  unset PORT_HOPPING_START PORT_HOPPING_END PORT_HOPPING_RANGE PORT_HOPPING_TARGET
  [ -s $WORK_DIR/inbound.json ] && PORT_HOPPING_TARGET=$($WORK_DIR/jq -r \
    '[.inbounds[] | select(.tag | split(" ")[-1] == "hysteria2") | .port] | .[0] // empty' \
    $WORK_DIR/inbound.json 2>/dev/null)
  [ -z "$PORT_HOPPING_TARGET" ] && return
  if [ "$SYSTEM" = 'Alpine' ]; then
    local LIST=$(iptables --table nat --list-rules PREROUTING 2>/dev/null | grep 'ArgoX')
    [ -n "$LIST" ] && PORT_HOPPING_RANGE=$(awk '{for(i=0;i<NF;i++) if($i=="--dport"){print $(i+1);exit}}' <<< "$LIST") && \
      PORT_HOPPING_TARGET=$(awk '{for(i=0;i<NF;i++) if($i=="to"){print $(i+1);exit}}' <<< "$LIST")
  elif [ -x "$(type -p firewalld)" ] && [ "$(systemctl is-active firewalld 2>/dev/null)" = 'active' ]; then
    local LIST=$(firewall-cmd --list-all --permanent 2>/dev/null | grep "toport=${PORT_HOPPING_TARGET}")
    [ -n "$LIST" ] && PORT_HOPPING_START=$(sed "s/.*port=\([^-]\+\)-.*toport.*/\1/" <<< "$LIST") && \
      PORT_HOPPING_END=$(sed "s/.*port=${PORT_HOPPING_START}-\([^:]\+\):.*/\1/" <<< "$LIST")
  else
    local LIST=$(iptables --table nat --list-rules PREROUTING 2>/dev/null | grep 'ArgoX')
    [ -n "$LIST" ] && PORT_HOPPING_RANGE=$(awk '{for(i=0;i<NF;i++) if($i=="--dport"){print $(i+1);exit}}' <<< "$LIST") && \
      PORT_HOPPING_TARGET=$(awk '{for(i=0;i<NF;i++) if($i=="to"){print $(i+1);exit}}' <<< "$LIST")
  fi
  [ -n "$PORT_HOPPING_RANGE" ] && PORT_HOPPING_START=${PORT_HOPPING_RANGE%:*} && PORT_HOPPING_END=${PORT_HOPPING_RANGE#*:}
}

# 输入 Hysteria2 端口跳跃范围
input_hopping_port() {
  local HOPPING_ERROR_TIME=6
  until [ -n "$IS_HOPPING" ]; do
    if [ -z "$PORT_HOPPING_RANGE" ]; then
      (( HOPPING_ERROR_TIME-- )) || true
      case "$HOPPING_ERROR_TIME" in
        0 ) error "\n $(text 3) \n" ;;
        5 ) hint "\n $(text 104) \n" && reading " $(text 105) " PORT_HOPPING_RANGE ;;
        * ) reading " $(text 105) " PORT_HOPPING_RANGE ;;
      esac
    fi
    # 预处理：全角冒号/破折号统一换半角，再过滤非法字符
    PORT_HOPPING_RANGE=$(echo "$PORT_HOPPING_RANGE" | sed 's/：/:/g; s/[－—]/-/g' | tr -cd '0-9:-')
    local _R=${PORT_HOPPING_RANGE//-/:}
    if [[ "$_R" =~ ^[0-9]{4,5}:[0-9]{4,5}$ ]]; then
      PORT_HOPPING_RANGE=$_R
      PORT_HOPPING_START=${_R%:*}
      PORT_HOPPING_END=${_R#*:}
      if [[ "$PORT_HOPPING_START" -lt "$PORT_HOPPING_END" && \
            "$PORT_HOPPING_START" -ge "$MIN_HOPPING_PORT" && \
            "$PORT_HOPPING_END" -le "$MAX_HOPPING_PORT" ]]; then
        IS_HOPPING=is_hopping
      else
        warning "\n $(text 114) " && unset PORT_HOPPING_RANGE
      fi
    elif [[ -z "$PORT_HOPPING_RANGE" || "${PORT_HOPPING_RANGE,,}" =~ ^(n|no)$ ]]; then
      IS_HOPPING=no_hopping
    else
      warning "\n $(text 36) " && unset PORT_HOPPING_RANGE
    fi
  done
}

# 处理防火墙规则
firewall_configuration() {
  local LISTEN_PORT=$(awk -F [:,] '/"port"/{print $2; exit}' $WORK_DIR/inbound.json)
  if grep -q "open" <<< "$1"; then
    firewall-cmd --zone=public --add-port=${LISTEN_PORT}/tcp --permanent >/dev/null 2>&1
  elif grep -q "close" <<< "$1"; then
    firewall-cmd --zone=public --remove-port=${LISTEN_PORT}/tcp --permanent >/dev/null 2>&1
  fi
  firewall-cmd --reload >/dev/null 2>&1

  if [[ -s /etc/selinux/config && -x "$(type -p getenforce)" && $(getenforce) = 'Enforcing' ]]; then
    hint "\n $(text 69) "
    setenforce 0
    grep -qs '^SELINUX=disabled$' /etc/selinux/config || sed -i 's/^SELINUX=[epd].*/# &/; /SELINUX=[epd]/a\SELINUX=disabled' /etc/selinux/config
  fi
}

# Nginx 配置文件（新架构：Nginx 作为唯一对外分流入口，按已安装协议动态生成 location）
json_nginx() {
  local PROTOCOLS_NOW
  PROTOCOLS_NOW=$(get_installed_protocols | tr '\n' ' ')
  if [ -z "$WS_PATH" ] && [ -s $WORK_DIR/inbound.json ]; then
    WS_PATH=$(grep -v '^//' $WORK_DIR/inbound.json | $WORK_DIR/jq -r '.inbounds[] | select(.streamSettings.network=="ws") | .streamSettings.wsSettings.path' | head -1 | sed 's|/||; s|-vl$||; s|-vm$||; s|-tr$||; s|-sh$||; s|-xh$||')
  fi
  [ -z "$WS_PATH" ] && WS_PATH="$WS_PATH_DEFAULT"
  if [ -z "$UUID" ] && [ -s $WORK_DIR/inbound.json ]; then
    UUID=$(grep -v '^//' $WORK_DIR/inbound.json | $WORK_DIR/jq -r '.inbounds[0].settings.clients[0].id // .inbounds[0].settings.clients[0].password // empty')
  fi
  if [ -z "$NGINX_PORT" ]; then
    if [ -s $WORK_DIR/nginx.conf ]; then
      NGINX_PORT=$(awk '/listen/{print $2; exit}' $WORK_DIR/nginx.conf | tr -d ';')
    fi
    NGINX_PORT=${NGINX_PORT:-"$NGINX_PORT_DEFAULT"}
  fi

  _ws_location() {
    local path=$1 port=$2
    printf '    location ~ ^%s {\n' "$path"
    printf '      proxy_pass          http://127.0.0.1:%s;\n' "$port"
    printf '      proxy_http_version  1.1;\n'
    printf '      proxy_set_header    Upgrade $http_upgrade;\n'
    printf '      proxy_set_header    Connection "upgrade";\n'
    printf '      proxy_set_header    X-Real-IP $remote_addr;\n'
    printf '      proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;\n'
    printf '      proxy_set_header    Host $host;\n'
    printf '      proxy_redirect      off;\n'
    printf '      proxy_buffering     off;\n'
    printf '      proxy_read_timeout  1h;\n'
    printf '      proxy_send_timeout  1h;\n'
    printf '    }\n'
  }

  _xhttp_location() {
    local path=$1 port=$2
    printf '    location ~ ^%s {\n' "$path"
    printf '      proxy_pass                  http://127.0.0.1:%s;\n' "$port"
    printf '      proxy_http_version          1.1;\n'
    printf '      proxy_set_header            Host $host;\n'
    printf '      proxy_set_header            X-Real-IP $remote_addr;\n'
    printf '      proxy_set_header            X-Forwarded-For $proxy_add_x_forwarded_for;\n'
    printf '      proxy_set_header            X-Forwarded-Proto $scheme;\n'
    printf '      proxy_redirect              off;\n'
    printf '      proxy_buffering             off;\n'
    printf '      proxy_request_buffering     off;\n'
    printf '      proxy_max_temp_file_size    0;\n'
    printf '      chunked_transfer_encoding   on;\n'
    printf '      tcp_nodelay                 on;\n'
    printf '      proxy_read_timeout          1h;\n'
    printf '      proxy_send_timeout          1h;\n'
    printf '      client_max_body_size        0;\n'
    printf '      client_body_timeout         1h;\n'
    printf '    }\n'
  }

  local SERVER_BLOCK=''

  local _PORT_VL _PORT_VM _PORT_TR _PORT_SH _PORT_XH
  if [ -s $WORK_DIR/inbound.json ] && [ -x $WORK_DIR/jq ]; then
    local JSON_CLEAN=$(grep -v '^//' $WORK_DIR/inbound.json)
    _PORT_VL=$(echo "$JSON_CLEAN" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "vless-ws") | .port] | .[0] // empty' 2>/dev/null)
    _PORT_VM=$(echo "$JSON_CLEAN" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "vmess-ws") | .port] | .[0] // empty' 2>/dev/null)
    _PORT_TR=$(echo "$JSON_CLEAN" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "trojan-ws") | .port] | .[0] // empty' 2>/dev/null)
    _PORT_SH=$(echo "$JSON_CLEAN" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "ss-ws") | .port] | .[0] // empty' 2>/dev/null)
    _PORT_XH=$(echo "$JSON_CLEAN" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "vless-xhttp") | .port] | .[0] // empty' 2>/dev/null)
  fi
  _PORT_VL=${_PORT_VL:-${WS_PORT_e:-30003}}
  _PORT_VM=${_PORT_VM:-${WS_PORT_f:-30004}}
  _PORT_TR=${_PORT_TR:-${WS_PORT_g:-30005}}
  _PORT_SH=${_PORT_SH:-${WS_PORT_h:-30006}}
  _PORT_XH=${_PORT_XH:-${WS_PORT_i:-30007}}

  _add_location() { SERVER_BLOCK+="$1"; SERVER_BLOCK+=$'\n\n'; }
  grep -q 'vless-ws' <<< "$PROTOCOLS_NOW" && _add_location "$(_ws_location "/${WS_PATH}-vl" "$_PORT_VL")"
  grep -q 'vmess-ws' <<< "$PROTOCOLS_NOW" && _add_location "$(_ws_location "/${WS_PATH}-vm" "$_PORT_VM")"
  grep -q 'trojan-ws' <<< "$PROTOCOLS_NOW" && _add_location "$(_ws_location "/${WS_PATH}-tr" "$_PORT_TR")"
  grep -qw 'ss-ws' <<< "$PROTOCOLS_NOW" && _add_location "$(_ws_location "/${WS_PATH}-sh" "$_PORT_SH")"
  grep -q 'vless-xhttp' <<< "$PROTOCOLS_NOW" && _add_location "$(_xhttp_location "/${WS_PATH}-xh" "${_PORT_XH}")"
  local SUB_BLOCK
  SUB_BLOCK=$(printf '    location ~ ^/%s/auto {
      default_type  text/plain;
      alias         %s/subscribe/$path;
    }

    location ~ ^/%s/(.*) {
      autoindex     on;
      default_type  text/plain;
      alias         %s/subscribe/$1;
    }\n' "$UUID" "$WORK_DIR" "$UUID" "$WORK_DIR")
  SERVER_BLOCK+="$SUB_BLOCK"

  cat > $WORK_DIR/nginx.conf << EOF
user  root;
worker_processes  auto;

error_log  /dev/null;
pid        /var/run/nginx.pid;

events {
  worker_connections  1024;
}

http {
  map \$http_user_agent \$path {
    default               /;
    ~*v2rayN|Neko|Throne  /base64;
    ~*clash               /clash;
    ~*ShadowRocket        /shadowrocket;
    ~*SFM|SFI|SFA        /sing-box;
  }

  include           /etc/nginx/mime.types;
  default_type      application/octet-stream;
  access_log        /dev/null;
  sendfile          on;
  keepalive_timeout 65;

  server {
    listen      ${NGINX_PORT};
    server_name localhost;

${SERVER_BLOCK}
  }
}
EOF
}

# Json 生成两个配置文件
json_argo() {
  [ ! -s $WORK_DIR/tunnel.json ] && echo $ARGO_JSON > $WORK_DIR/tunnel.json
  [ ! -s $WORK_DIR/tunnel.yml ] && cat > $WORK_DIR/tunnel.yml << EOF
tunnel: $(cut -d\" -f12 <<< $ARGO_JSON)
credentials-file: $WORK_DIR/tunnel.json

ingress:
  - hostname: ${ARGO_DOMAIN}
    service: http://localhost:${NGINX_PORT}
  - service: http_status:404
EOF
}

# 创建 Argo Tunnel API
create_argo_tunnel() {
  local CLOUDFLARE_API_TOKEN="$1"
  local ARGO_DOMAIN="$2"
  local SERVICE_PORT="$3"
  local TUNNEL_NAME=${ARGO_DOMAIN%%.*}
  local ROOT_DOMAIN=${ARGO_DOMAIN#*.}

  api_error() {
    local RESPONSE="$1"
    local CHECK_ZONE_ID="$2"

    if grep -q '"code":9109,' <<< "$RESPONSE"; then
      warning " $(text 81) " && sleep 2 && return 2
    elif grep -q '"code":7003,' <<< "$RESPONSE"; then
      warning " $(text 82) " && sleep 2 && return 3
    elif grep -q 'check_zone_id' <<< "$CHECK_ZONE_ID" && grep -q '"count":0,' <<< "$RESPONSE"; then
      warning " $(text 83) " && sleep 2 && return 4
    elif grep -q '"code":10000,' <<< "$RESPONSE"; then
      warning " $(text 85) " && sleep 2 && return 1
    elif grep -q '"success":true' <<< "$RESPONSE"; then
      return 0
    else
      warning " $(text 84) " && sleep 2 && return 5
    fi
  }

  local ZONE_RESPONSE=$(wget --no-check-certificate -qO- --content-on-error \
    --header="Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
    --header="Content-Type: application/json" \
    "https://api.cloudflare.com/client/v4/zones?name=${ROOT_DOMAIN}")

  api_error "$ZONE_RESPONSE" 'check_zone_id' || return $?

  [[ "$ZONE_RESPONSE" =~ \"id\":\"([^\"]+)\".*\"account\":\{\"id\":\"([^\"]+)\" ]] && local ZONE_ID="${BASH_REMATCH[1]}" ACCOUNT_ID="${BASH_REMATCH[2]}" || \
  return 5

  local TUNNEL_LIST=$(wget --no-check-certificate -qO- --content-on-error \
    --header="Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
    --header="Content-Type: application/json" \
    "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/cfd_tunnel?is_deleted=false")

  api_error "$TUNNEL_LIST" || return $?

  local TUNNEL_LIST_SPLIT=$(awk 'BEGIN{RS="";FS=""}{s=substr($0,index($0,"\"result\":[")+10);d=0;b="";for(i=1;i<=length(s);i++){c=substr(s,i,1);if(c=="{")d++;if(d>0)b=b c;if(c=="}"){d--;if(d==0){print b;b=""}}}}' <<< "$TUNNEL_LIST")

  while true; do
    unset TUNNEL_CHECK EXISTING_TUNNEL_ID EXISTING_TUNNEL_STATUS
    local TUNNEL_CHECK=$(grep '\"name\":\"'$TUNNEL_NAME'\"' <<< "$TUNNEL_LIST_SPLIT")
    if [[ "$TUNNEL_CHECK" =~ \"id\":\"([^\"]+)\".*\"status\":\"([^\"]+)\" ]]; then
      local EXISTING_TUNNEL_ID=${BASH_REMATCH[1]} EXISTING_TUNNEL_STATUS=${BASH_REMATCH[2]}
      grep -qw 'C' <<< "$L" && EXISTING_TUNNEL_STATUS=$(sed 's/inactive/停用（未激活）/; s/down/离线/; s/healthy/连接中/; s/degraded/降级/ ' <<< "$EXISTING_TUNNEL_STATUS")
      reading "\n $(text 79) " OVERWRITE
      if grep -qw 'n' <<< "${OVERWRITE,,}"; then
        unset ARGO_DOMAIN
        reading "\n $(text 10) " ARGO_DOMAIN
        ! grep -q '\.' <<< "$ARGO_DOMAIN" && return 5
        TUNNEL_NAME=${ARGO_DOMAIN%%.*}
        ROOT_DOMAIN=${ARGO_DOMAIN#*.}
      else
        break
      fi
    else
      unset TUNNEL_CHECK EXISTING_TUNNEL_ID EXISTING_TUNNEL_STATUS
      break
    fi
  done

  if [ -z "$EXISTING_TUNNEL_ID" ]; then
    local TUNNEL_SECRET=$(openssl rand -base64 32)

    local CREATE_RESPONSE=$(wget --no-check-certificate -qO- --content-on-error \
      --header="Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
      --header="Content-Type: application/json" \
      --post-data="{
        \"name\": \"$TUNNEL_NAME\",
        \"config_src\": \"cloudflare\",
        \"tunnel_secret\": \"$TUNNEL_SECRET\"
      }" \
      "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/cfd_tunnel")

    api_error "$CREATE_RESPONSE" || return $?

    [[ $CREATE_RESPONSE =~ \"id\":\"([^\"]+)\".*\"token\":\"([^\"]+)\" ]] && \
    local TUNNEL_ID=${BASH_REMATCH[1]} TUNNEL_TOKEN=${BASH_REMATCH[2]} || \
    return 5
  else
    local EXISTING_TUNNEL_TOKEN=$(wget -qO- --content-on-error \
      --header="Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
      --header="Content-Type: application/json" \
      "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/cfd_tunnel/${EXISTING_TUNNEL_ID}/token")

    api_error "$EXISTING_TUNNEL_TOKEN" || return $?

    local TUNNEL_ID=$EXISTING_TUNNEL_ID \
    TUNNEL_TOKEN=$(sed -n 's/.*"result":"\([^"]\+\)".*/\1/p' <<< "$EXISTING_TUNNEL_TOKEN") && \
    TUNNEL_SECRET=$(base64 -d <<< "$TUNNEL_TOKEN" | sed 's/.*"s":"\([^"]\+\)".*/\1/') || \
    return 5
  fi

  local CONFIG_RESPONSE=$(wget --no-check-certificate -qO- --content-on-error \
  --method=PUT \
  --header="Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  --header="Content-Type: application/json" \
  --body-data="{
    \"config\": {
      \"ingress\": [
        {
          \"service\": \"http://localhost:${SERVICE_PORT}\",
          \"hostname\": \"${ARGO_DOMAIN}\"
        },
        {
          \"service\": \"http_status:404\"
        }
      ],
      \"warp-routing\": {
        \"enabled\": false
      }
    }
  }" \
  "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/cfd_tunnel/${TUNNEL_ID}/configurations")

  api_error "$CONFIG_RESPONSE" || return $?

  local DNS_PAYLOAD="{
    \"name\": \"${ARGO_DOMAIN}\",
    \"type\": \"CNAME\",
    \"content\": \"${TUNNEL_ID}.cfargotunnel.com\",
    \"proxied\": true,
    \"settings\": {
      \"flatten_cname\": false
    }
  }"

  local DNS_LIST=$(wget --no-check-certificate -qO- --content-on-error \
    --header="Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
    --header="Content-Type: application/json" \
    "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?type=CNAME&name=${ARGO_DOMAIN}")

  api_error "$DNS_LIST" || return $?

  if [[ "$DNS_LIST" =~ \"id\":\"([^\"]+)\".*\"$ARGO_DOMAIN\".*\"content\":\"([^\"]+)\" ]]; then
    local EXISTING_DNS_ID="${BASH_REMATCH[1]}" EXISTED_DNS_CONTENT="${BASH_REMATCH[2]}"

    if ! grep -qw "$EXISTING_TUNNEL_ID" <<< "${EXISTED_DNS_CONTENT%%.*}"; then
      local DNS_RESPONSE=$(wget --no-check-certificate -qO- --content-on-error \
        --method=PATCH \
        --header="Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
        --header="Content-Type: application/json" \
        --body-data="$DNS_PAYLOAD" \
        "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${EXISTING_DNS_ID}")

      api_error "$DNS_RESPONSE" || return $?
    fi
  else
    local DNS_RESPONSE=$(wget --no-check-certificate -qO- --content-on-error \
      --method=POST \
      --header="Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
      --header="Content-Type: application/json" \
      --body-data="$DNS_PAYLOAD" \
      "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records")

    api_error "$DNS_RESPONSE" || return $?
  fi

  ARGO_JSON="{\"AccountTag\":\"$ACCOUNT_ID\",\"TunnelSecret\":\"$TUNNEL_SECRET\",\"TunnelID\":\"$TUNNEL_ID\",\"Endpoint\":\"\"}"
}

install_argox() {
  xray_variable
  argo_variable

  wait
  local _HAS_REALITY_INSTALL=false
  for _p in "${INSTALL_PROTOCOLS[@]}"; do [[ "$_p" =~ ^[bd]$ ]] && _HAS_REALITY_INSTALL=true && break; done
  if $_HAS_REALITY_INSTALL; then
    if [ -n "$REALITY_PRIVATE" ] && [ -z "$REALITY_PUBLIC" ]; then
      # 有私钥无公钥（如 config.conf 只填了私钥）→ xray 已就位，从私钥推导公钥
      REALITY_PUBLIC=$($TEMP_DIR/xray x25519 -i "$REALITY_PRIVATE" | awk '/Public/{print $NF}')
      if [ -z "$REALITY_PUBLIC" ]; then
        warning " $(text 99) "
        REALITY_KEYPAIR=$($TEMP_DIR/xray x25519)
        REALITY_PRIVATE=$(awk '/Private/{print $NF}' <<< "$REALITY_KEYPAIR")
        REALITY_PUBLIC=$(awk '/Public|Password/{print $NF}' <<< "$REALITY_KEYPAIR")
      fi
    elif [ -z "$REALITY_PRIVATE" ]; then
      # 私钥也为空 → 随机生成一对
      REALITY_KEYPAIR=$($TEMP_DIR/xray x25519)
      REALITY_PRIVATE=$(awk '/Private/{print $NF}' <<< "$REALITY_KEYPAIR")
      REALITY_PUBLIC=$(awk '/Public|Password/{print $NF}' <<< "$REALITY_KEYPAIR")
    fi
  fi

  [ ! -d /etc/systemd/system ] && mkdir -p /etc/systemd/system
  mkdir -p $WORK_DIR/subscribe
  [ "$L" = 'C' ] && write_custom 'language' 'Chinese' || write_custom 'language' 'English'
  write_custom 'serverIp' "${SERVER_IP}"
  write_custom 'privateKey' "${REALITY_PRIVATE:-__KEY_UNSET__}"
  write_custom 'publicKey' "${REALITY_PUBLIC:-__KEY_UNSET__}"
  write_custom 'cdn' "${SERVER:-__CDN_UNSET__}"
  [ -s "$VARIABLE_FILE" ] && cp $VARIABLE_FILE $WORK_DIR/

  wait
  [[ ! -s $WORK_DIR/cloudflared && -x $TEMP_DIR/cloudflared ]] && mv $TEMP_DIR/cloudflared $WORK_DIR
  [[ ! -s $WORK_DIR/jq && -x $TEMP_DIR/jq ]] && mv $TEMP_DIR/jq $WORK_DIR
  [[ "$INSTALL_NGINX" != 'n' && ! -s $WORK_DIR/qrencode && -x $TEMP_DIR/qrencode ]] && mv $TEMP_DIR/qrencode $WORK_DIR
  if [[ -n "${ARGO_JSON}" && -n "${ARGO_DOMAIN}" ]]; then
    ARGO_RUNS="$WORK_DIR/cloudflared tunnel --edge-ip-version auto --config $WORK_DIR/tunnel.yml run"
    json_argo
  elif [[ -n "${ARGO_TOKEN}" && -n "${ARGO_DOMAIN}" ]]; then
    ARGO_RUNS="$WORK_DIR/cloudflared tunnel --edge-ip-version auto run --token ${ARGO_TOKEN}"
  else
    ARGO_RUNS="$WORK_DIR/cloudflared tunnel --edge-ip-version auto --no-autoupdate --url http://localhost:${NGINX_PORT}"
  fi

  if [ "$SYSTEM" = 'Alpine' ]; then
    local COMMAND=${ARGO_RUNS%% --*}
    local ARGS=${ARGO_RUNS#$COMMAND }

    cat > ${ARGO_DAEMON_FILE} << EOF
#!/sbin/openrc-run

name="argo"
description="Cloudflare Tunnel"

command="${COMMAND}"
command_args="${ARGS}"

pidfile="/run/\${RC_SVCNAME}.pid"
command_background="yes"

output_log="${WORK_DIR}/argo.log"
error_log="${WORK_DIR}/argo.log"

depend() {
    need net
    after firewall
}

start_pre() {
    mkdir -p ${WORK_DIR} /run
    rm -f "\$pidfile"
}

stop() {
    ebegin "Stopping \${RC_SVCNAME}"
    start-stop-daemon --stop --quiet --pidfile "\$pidfile" --retry 5
    local CF_PIDS
    CF_PIDS="\$(ps -eo pid,args | awk '\$0~/\/etc\/argox\/cloudflared/{print \$1}')"
    if [ -n "\$CF_PIDS" ]; then
        einfo "Force killing cloudflared: \$CF_PIDS"
        kill -9 \$CF_PIDS 2>/dev/null
    fi
    rm -f "\$pidfile"
    eend 0
    return 0
}
EOF
    chmod +x ${ARGO_DAEMON_FILE}

    cat > ${XRAY_DAEMON_FILE} << EOF
#!/sbin/openrc-run

name="xray"
description="Xray Service"

command="${WORK_DIR}/xray"
command_args="run -c ${WORK_DIR}/inbound.json -c ${WORK_DIR}/outbound.json"

pidfile="/run/\${RC_SVCNAME}.pid"
command_background="yes"

output_log="${WORK_DIR}/xray.log"
error_log="${WORK_DIR}/xray.log"

depend() {
    need net
    after firewall
}

start_pre() {
    mkdir -p ${WORK_DIR} /run
    chmod 755 ${WORK_DIR}
    rm -f "\$pidfile"
    if [ -s ${WORK_DIR}/nginx.conf ] && command -v /usr/sbin/nginx >/dev/null 2>&1; then
        pgrep -f "nginx.*${WORK_DIR}/nginx.conf" >/dev/null 2>&1 || /usr/sbin/nginx -c ${WORK_DIR}/nginx.conf
    fi
    return 0
}

stop() {
    ebegin "Stopping \${RC_SVCNAME}"
    start-stop-daemon --stop --quiet --pidfile "\$pidfile" --retry 5
    local RETVAL=\$?
    if [ \$RETVAL -ne 0 ]; then
        local XRAY_PIDS
        XRAY_PIDS="\$(ps -eo pid,args | awk -v work_dir="\$WORK_DIR" '\$0~(work_dir"/xray run"){print \$1;exit}')"
        if [ -n "\$XRAY_PIDS" ]; then
            for pid in \$XRAY_PIDS; do
                kill -9 "\$pid" 2>/dev/null
            done
        fi
    fi
    if [ -s ${WORK_DIR}/nginx.conf ] && command -v /usr/sbin/nginx >/dev/null 2>&1; then
        /usr/sbin/nginx -c ${WORK_DIR}/nginx.conf -s stop 2>/dev/null
        sleep 1
        local NGINX_REMAINING
        NGINX_REMAINING="\$(ps -eo pid,args | awk '\$0~/nginx.*\/etc\/argox\/nginx.conf/{print \$1}')"
        [ -n "\$NGINX_REMAINING" ] && kill -9 \$NGINX_REMAINING 2>/dev/null
    fi
    rm -f "\$pidfile"
    eend 0
}
EOF
    chmod +x ${XRAY_DAEMON_FILE}
  else
    local ARGO_SERVER="[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
Type=simple
NoNewPrivileges=yes
TimeoutStartSec=0"
    ARGO_SERVER+="
ExecStart=$ARGO_RUNS
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target"

    echo "$ARGO_SERVER" > ${ARGO_DAEMON_FILE}

    local XRAY_SERVICE="[Unit]
Description=Xray Service
Documentation=https://github.com/XTLS/Xray-core
After=network.target

[Service]
User=root"
    [[ "$INSTALL_NGINX" != 'n' && "$IS_CENTOS" != 'CentOS7' ]] && XRAY_SERVICE+="
ExecStartPre=/bin/bash -c 'nginx -c $WORK_DIR/nginx.conf -s reload 2>/dev/null || nginx -c $WORK_DIR/nginx.conf'"
    XRAY_SERVICE+="
ExecStart=$WORK_DIR/xray run -c $WORK_DIR/inbound.json -c $WORK_DIR/outbound.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target"
    echo "$XRAY_SERVICE" > ${XRAY_DAEMON_FILE}
  fi

  local i=1
  [ ! -s $WORK_DIR/xray ] && wait && while [ "$i" -le 20 ]; do [[ -s $TEMP_DIR/xray && -s $TEMP_DIR/geoip.dat && -s $TEMP_DIR/geosite.dat ]] && mv $TEMP_DIR/xray $TEMP_DIR/geo*.dat $WORK_DIR && break; ((i++)); sleep 2; done
  [ "$i" -ge 20 ] && local APP=Xray && error "\n $(text 48) "

  if [[ " ${INSTALL_PROTOCOLS[*]} " =~ " c " ]] || [[ " ${INSTALL_PROTOCOLS[*]} " =~ " j " ]] || [[ " ${INSTALL_PROTOCOLS[*]} " =~ " k " ]]; then
    ssl_certificate "${TLS_SERVER}"
  fi
  if [[ " ${INSTALL_PROTOCOLS[*]} " =~ " c " ]]; then
    [ "$IS_HOPPING" = 'is_hopping' ] && add_port_hopping_nat "$PORT_HOPPING_START" "$PORT_HOPPING_END" "$HY2_PORT"
  fi

  local INBOUNDS_JSON=''
  local FIRST=true

  local SIP022_PASSWORD=${SIP022_PASSWORD:-"$(openssl rand -base64 16)"}
  for proto in "${INSTALL_PROTOCOLS[@]}"; do
    local BLOCK=''
    case "$proto" in
      b)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} reality-vision",
      "protocol": "vless",
      "port": ${REALITY_PORT},
      "settings": {
        "clients": [
          {
            "id": "${UUID}",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "${TLS_SERVER}:443",
          "serverNames": [ "${TLS_SERVER}" ],
          "privateKey": "${REALITY_PRIVATE}",
          "publicKey": "${REALITY_PUBLIC}",
          "maxTimeDiff": 70000,
          "shortIds": [ "" ]
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [ "http", "tls" ]
      }
    }
JSONEOF
)
        ;;
      c)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} hysteria2",
      "protocol": "hysteria",
      "port": ${HY2_PORT},
      "settings": {
        "version": 2,
        "clients": [ { "auth": "${UUID}" } ]
      },
      "streamSettings": {
        "network": "hysteria",
        "security": "tls",
        "tlsSettings": {
          "serverNames": [ "${TLS_SERVER}" ],
          "alpn": [ "h3" ],
          "certificates": [ { "certificateFile": "${WORK_DIR}/cert/cert.pem", "keyFile": "${WORK_DIR}/cert/private.key" } ]
        }
      }
    }
JSONEOF
)
        ;;
      d)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} reality-grpc",
      "protocol": "vless",
      "port": ${GRPC_PORT},
      "settings": {
        "clients": [
          {
            "id": "${UUID}",
            "flow": ""
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "grpc",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "${TLS_SERVER}:443",
          "xver": 0,
          "serverNames": [ "${TLS_SERVER}" ],
          "privateKey": "${REALITY_PRIVATE}",
          "publicKey": "${REALITY_PUBLIC}",
          "maxTimeDiff": 70000,
          "shortIds": [ "" ]
        },
        "grpcSettings": {
          "serviceName": "grpc",
          "multiMode": true
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [ "http", "tls" ]
      }
    }
JSONEOF
)
        ;;
      e)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} vless-ws",
      "protocol": "vless",
      "port": ${WS_PORT_e:-30003},
      "listen": "127.0.0.1",
      "settings": {
        "clients": [
          {
            "id": "${UUID}",
            "level": 0
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/${WS_PATH}-vl"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [ "http", "tls", "quic" ],
        "metadataOnly": false
      }
    }
JSONEOF
)
        ;;
      f)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} vmess-ws",
      "protocol": "vmess",
      "port": ${WS_PORT_f:-30004},
      "listen": "127.0.0.1",
      "settings": {
        "clients": [
          {
            "id": "${UUID}",
            "alterId": 0
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/${WS_PATH}-vm"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [ "http", "tls", "quic" ],
        "metadataOnly": false
      }
    }
JSONEOF
)
        ;;
      g)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} trojan-ws",
      "protocol": "trojan",
      "port": ${WS_PORT_g:-30005},
      "listen": "127.0.0.1",
      "settings": {
        "clients": [
          {
            "password": "${UUID}"
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/${WS_PATH}-tr"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [ "http", "tls", "quic" ],
        "metadataOnly": false
      }
    }
JSONEOF
)
        ;;
      h)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} ss-ws",
      "protocol": "shadowsocks",
      "port": ${WS_PORT_h:-30006},
      "listen": "127.0.0.1",
      "settings": {
        "clients": [
          {
            "method": "chacha20-ietf-poly1305",
            "password": "${UUID}"
          }
        ],
        "network": "tcp,udp"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/${WS_PATH}-sh"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [ "http", "tls", "quic" ],
        "metadataOnly": false
      }
    }
JSONEOF
)
        ;;
      i)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} vless-xhttp",
      "protocol": "vless",
      "port": ${WS_PORT_i:-30007},
      "listen": "127.0.0.1",
      "settings": {
        "clients": [
          {
            "id": "${UUID}"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "xhttp",
        "xhttpSettings": {
          "mode": "auto",
          "path": "/${WS_PATH}-xh"
        }
      }
    }
JSONEOF
)
        ;;
      j)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} xhttp-h3-direct",
      "port": ${XHTTP_PORT_j:-30008},
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${UUID}"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "xhttp",
        "security": "tls",
        "xhttpSettings": {
          "mode": "stream-up",
          "extra": {
            "alpn": [
              "h3"
            ]
          },
          "path": "/${WS_PATH}-xh3"
        },
        "tlsSettings": {
          "alpn": [
            "h3"
          ],
          "certificates": [
            {
              "certificateFile": "${WORK_DIR}/cert/cert.pem",
              "keyFile": "${WORK_DIR}/cert/private.key"
            }
          ]
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls",
          "quic"
        ]
      }
    }
JSONEOF
)
        ;;
      k)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} trojan-direct",
      "protocol": "trojan",
      "port": ${TROJAN_PORT_k:-30009},
      "settings": {
        "clients": [
          {
            "password": "${UUID}"
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "serverName": "${TLS_SERVER}",
          "certificates": [
            {
              "certificateFile": "${WORK_DIR}/cert/cert.pem",
              "keyFile": "${WORK_DIR}/cert/private.key"
            }
          ]
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [ "http", "tls", "quic" ],
        "metadataOnly": false
      }
    }
JSONEOF
)
        ;;
      l)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} ss2022-direct",
      "protocol": "shadowsocks",
      "port": ${SS2022_PORT_l:-30010},
      "settings": {
        "method": "2022-blake3-aes-128-gcm",
        "password": "${SIP022_PASSWORD}",
        "network": "tcp,udp"
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [ "http", "tls", "quic" ],
        "metadataOnly": false
      }
    }
JSONEOF
)
        ;;
    esac
    if [ -n "$BLOCK" ]; then
      $FIRST || INBOUNDS_JSON+=$',\n'
      INBOUNDS_JSON+="$BLOCK"
      FIRST=false
    fi
  done

  cat > $WORK_DIR/inbound.json << EOF
{
  "log": {
    "access": "/dev/null",
    "error": "/dev/null",
    "loglevel": "none"
  },
  "inbounds": [
${INBOUNDS_JSON}
  ],
  "dns": {
    "servers": [
      "https+local://8.8.8.8/dns-query"
    ]
  }
}
EOF

  cat > $WORK_DIR/outbound.json << EOF
{
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        },
        {
            "protocol": "blackhole",
            "settings": {

            },
            "tag": "block"
        },
        {
            "protocol": "wireguard",
            "tag": "wireguard",
            "settings": {
                "secretKey": "YFYOAdbw1bKTHlNNi+aEjBM3BO7unuFC5rOkMRAz9XY=",
                "address": [
                    "172.16.0.2/32",
                    "2606:4700:110:8a36:df92:102a:9602:fa18/128"
                ],
                "peers": [
                    {
                        "publicKey": "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
                        "allowedIPs": [
                            "0.0.0.0/0",
                            "::/0"
                        ],
                        "endpoint": "engage.cloudflareclient.com:2408"
                    }
                ],
                "reserved": [
                    78,
                    135,
                    76
                ],
                "mtu": 1280
            }
        },
        {
            "protocol": "freedom",
            "tag": "warp-IPv4",
            "settings": {
                "domainStrategy": "UseIPv4"
            },
            "proxySettings": {
                "tag": "wireguard"
            }
        },
        {
            "protocol": "freedom",
            "tag": "warp-IPv6",
            "settings": {
                "domainStrategy": "UseIPv6"
            },
            "proxySettings": {
                "tag": "wireguard"
            }
        }
    ],
    "routing": {
        "domainStrategy": "AsIs",
        "rules": [
            {
                "type": "field",
                "domain": [
                    "api.openai.com"
                ],
                "outboundTag": "${CHAT_GPT_OUT_V4}"
            },
            {
                "type": "field",
                "domain": [
                    "geosite:openai"
                ],
                "outboundTag": "${CHAT_GPT_OUT_V6}"
            }
        ]
    }
}
EOF

  [ "$INSTALL_NGINX" != 'n' ] && json_nginx

  check_install
  case "${STATUS[0]}" in
    "$(text 26)" )
      warning "\n Argo $(text 28) $(text 38) \n"
      ;;
    "$(text 27)" )
      cmd_systemctl enable argo
      cmd_systemctl status argo &>/dev/null && info "\n Argo $(text 28) $(text 37) \n" || warning "\n Argo $(text 28) $(text 38) \n"
      ;;
    "$(text 28)" )
      info "\n Argo $(text 28) $(text 37) \n"
  esac

  case "${STATUS[1]}" in
    "$(text 26)" )
      warning "\n Xray $(text 28) $(text 38) \n"
      ;;
    "$(text 27)" )
      cmd_systemctl enable xray
      cmd_systemctl status xray &>/dev/null && info "\n Xray $(text 28) $(text 37) \n" || warning "\n Xray $(text 28) $(text 38) \n"
      ;;
    "$(text 28)" )
      info "\n Xray $(text 28) $(text 37) \n"
  esac
}

# 创建快捷方式
create_shortcut() {
  cat > $WORK_DIR/ax.sh << EOF
#!/usr/bin/env bash

bash <(wget --no-check-certificate -qO- ${GH_PROXY}https://raw.githubusercontent.com/fscarmen/argox/main/argox.sh) \$1
EOF
  chmod +x $WORK_DIR/ax.sh
  ln -sf $WORK_DIR/ax.sh /usr/bin/argox

  if [[ ! ":$PATH:" == *":/usr/bin:"* ]]; then
    echo 'export PATH=$PATH:/usr/bin' >> ~/.bashrc
    source ~/.bashrc
  fi

  [ -s /usr/bin/argox ] && hint "\n $(text 62) "
}

export_list() {
  check_arch
  check_system_info
  check_system_ip
  check_install

  local ARGO_MEM='' XRAY_MEM='' NGINX_MEM=''
  local ARGO_PID=$(pgrep -f "$WORK_DIR/cloudflared")
  [ -n "$ARGO_PID" ] && ARGO_MEM="$(awk '/VmRSS/{printf "%.1f", $2/1024}' /proc/${ARGO_PID%% *}/status 2>/dev/null) MB"
  local XRAY_PID=$(pgrep -f "$WORK_DIR/xray")
  [ -n "$XRAY_PID" ] && XRAY_MEM="$(awk '/VmRSS/{printf "%.1f", $2/1024}' /proc/${XRAY_PID%% *}/status 2>/dev/null) MB"
  if [ "$IS_NGINX" = 'is_nginx' ]; then
    local NGINX_PID=$(pgrep -f "nginx: master process")
    [ -n "$NGINX_PID" ] && NGINX_MEM="$(awk '/VmRSS/{printf "%.1f", $2/1024}' /proc/${NGINX_PID%% *}/status 2>/dev/null) MB"
  fi

  local APP
  [ "${STATUS[0]}" != "$(text 28)" ] && APP+=(Argo)
  [ "${STATUS[1]}" != "$(text 28)" ] && APP+=(Xray)
  if [ "${#APP[@]}" -gt 0 ]; then
    reading "\n $(text 50) " OPEN_APP
    if [ "${OPEN_APP,,}" = 'y' ]; then
      [ "${STATUS[0]}" != "$(text 28)" ] && cmd_systemctl enable argo
      [ "${STATUS[1]}" != "$(text 28)" ] && cmd_systemctl enable xray
      sleep 2
      check_install
      ARGO_PID=$(pgrep -f "$WORK_DIR/cloudflared")
      [ -n "$ARGO_PID" ] && ARGO_MEM="$(awk '/VmRSS/{printf "%.1f", $2/1024}' /proc/${ARGO_PID%% *}/status) MB"
      XRAY_PID=$(pgrep -f "$WORK_DIR/xray")
      [ -n "$XRAY_PID" ] && XRAY_MEM="$(awk '/VmRSS/{printf "%.1f", $2/1024}' /proc/${XRAY_PID%% *}/status) MB"
    else
      exit
    fi
  fi

  if grep -qs "^${DAEMON_RUN_PATTERN}.*--url" ${ARGO_DAEMON_FILE}; then
    fetch_tunnel_domain quick || true
  else
    ARGO_DOMAIN=${ARGO_DOMAIN:-"$(grep -m1 '^vless.*host=.*' $WORK_DIR/list | sed "s@.*host=\(.*\)&.*@\1@g")"}
  fi
  fetch_nodes_value

  local _SUB_SCHEME='https'

  local PROTOS_NOW
  PROTOS_NOW=$(get_installed_protocols | tr '\n' ' ')

  local HY2_FP_SHA256='' HY2_FP_BASE64='' CERT_SNI="${TLS_SERVER:-addons.mozilla.org}"
  if grep -Eq 'hysteria2|xhttp-h3-direct|trojan-direct' <<< "$PROTOS_NOW" && [ -s ${WORK_DIR}/cert/cert.pem ]; then
    HY2_FP_SHA256=$(openssl x509 -fingerprint -noout -sha256 -in ${WORK_DIR}/cert/cert.pem 2>/dev/null | awk -F= '{print $NF}')
    HY2_FP_BASE64=$(openssl x509 -in ${WORK_DIR}/cert/cert.pem -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64 2>/dev/null)
    local _csni=$(openssl x509 -noout -ext subjectAltName -in ${WORK_DIR}/cert/cert.pem 2>/dev/null | awk -F 'DNS:' '/DNS:/{gsub(/,.*/,"",$2);print $2}')
    [ -n "$_csni" ] && CERT_SNI="$_csni"
  fi

  VMESS="{ \"v\": \"2\", \"ps\": \"${NODE_NAME} vmess-ws\", \"add\": \"${SERVER}\", \"port\": \"443\", \"id\": \"${UUID}\", \"aid\": \"0\", \"scy\": \"none\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"${ARGO_DOMAIN}\", \"path\": \"/${WS_PATH}-vm?ed=2560\", \"tls\": \"tls\", \"sni\": \"${ARGO_DOMAIN}\", \"alpn\": \"\" }"

  # 统一生成所有客户端订阅
  local CLASH='proxies:' SR_SUBSCRIBE='' V2N_SUBSCRIBE='' SR_DISPLAY='' V2N_DISPLAY=''
  local SB_OUTBOUNDS='' SB_TAGS='' SB_SEP=''
  _sb_add() { SB_OUTBOUNDS+="${SB_SEP}$1"; SB_TAGS+="${SB_SEP}$2"; SB_SEP=', '; }
  _add() {
    local clash="$1" sr="$2" v2n="$3" sb="$4" tag="$5"
    [ -n "$clash" ] && CLASH+="\n  - $clash"
    [ -n "$sr" ] && { SR_SUBSCRIBE+="$sr"$'\n'; SR_DISPLAY+="$sr\n\n"; }
    [ -n "$v2n" ] && { V2N_SUBSCRIBE+="$v2n"$'\n'; V2N_DISPLAY+="$v2n\n\n"; }
    [ -n "$sb" ] && _sb_add "$sb" "\"$tag\""
  }

  # reality-vision
  grep -q 'reality-vision' <<< "$PROTOS_NOW" && _add \
    "{name: \"${NODE_NAME} reality-vision\", type: vless, server: ${SERVER_IP}, port: ${REALITY_PORT}, uuid: ${UUID}, network: tcp, udp: true, tls: true, servername: ${TLS_SERVER}, flow: xtls-rprx-vision, client-fingerprint: chrome, reality-opts: {public-key: ${REALITY_PUBLIC}, short-id: \"\"} }" \
    "vless://$(echo -n "auto:${UUID}@${SERVER_IP_2}:${REALITY_PORT}" | base64 -w0)?remarks=${NODE_NAME// /%20}%20reality-vision&obfs=none&tls=1&peer=${TLS_SERVER}&xtls=2&pbk=${REALITY_PUBLIC}" \
    "vless://${UUID}@${SERVER_IP_1}:${REALITY_PORT}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${TLS_SERVER}&fp=chrome&pbk=${REALITY_PUBLIC}&type=tcp&headerType=none#${NODE_NAME// /%20}%20reality-vision" \
    "{ \"type\":\"vless\", \"tag\":\"${NODE_NAME} reality-vision\", \"server\":\"${SERVER_IP}\", \"server_port\": ${REALITY_PORT}, \"uuid\":\"${UUID}\", \"flow\":\"xtls-rprx-vision\", \"packet_encoding\":\"xudp\", \"tls\":{ \"enabled\":true, \"server_name\":\"${TLS_SERVER}\", \"utls\":{ \"enabled\":true, \"fingerprint\":\"chrome\" }, \"reality\":{ \"enabled\":true, \"public_key\":\"${REALITY_PUBLIC}\", \"short_id\":\"\" } } }" \
    "${NODE_NAME} reality-vision"

  # hysteria2
  if grep -q 'hysteria2' <<< "$PROTOS_NOW"; then
    local _h2h=''; [[ -n "$PORT_HOPPING_START" && -n "$PORT_HOPPING_END" ]] && _h2h="&mport=${HY2_PORT},${PORT_HOPPING_START}-${PORT_HOPPING_END}"
    local _sbhp=''; [[ -n "$PORT_HOPPING_START" && -n "$PORT_HOPPING_END" ]] && _sbhp=",\"server_ports\":[\"${PORT_HOPPING_START}:${PORT_HOPPING_END}\"]"
    local _chop=''; [[ -n "$PORT_HOPPING_START" && -n "$PORT_HOPPING_END" ]] && _chop="ports: ${PORT_HOPPING_START}-${PORT_HOPPING_END}, HopInterval: 60, "
    _add \
      "{name: \"${NODE_NAME} hysteria2\", type: hysteria2, server: ${SERVER_IP}, port: ${HY2_PORT}, ${_chop}up: \"200 Mbps\", down: \"1000 Mbps\", password: ${UUID}, sni: ${CERT_SNI}, skip-cert-verify: false, fingerprint: ${HY2_FP_SHA256}}" \
      "hysteria2://${UUID}@${SERVER_IP_1}:${HY2_PORT}?peer=${CERT_SNI}&hpkp=${HY2_FP_SHA256}&obfs=none${_h2h}#${NODE_NAME// /%20}%20hysteria2" \
      "hysteria2://${UUID}@${SERVER_IP_1}:${HY2_PORT}?sni=${CERT_SNI}&alpn=h3&insecure=1&pinSHA256=${HY2_FP_SHA256//:/}${_h2h}#${NODE_NAME// /%20}%20hysteria2" \
      "{ \"type\": \"hysteria2\", \"tag\": \"${NODE_NAME} hysteria2\", \"server\": \"${SERVER_IP}\", \"server_port\": ${HY2_PORT}${_sbhp}, \"up_mbps\": 200, \"down_mbps\": 1000, \"password\": \"${UUID}\", \"tls\": { \"enabled\": true, \"server_name\": \"${CERT_SNI}\", \"certificate_public_key_sha256\": [\"${HY2_FP_BASE64}\"], \"alpn\": [ \"h3\" ] } }" \
      "${NODE_NAME} hysteria2"
  fi

  # reality-grpc
  grep -q 'reality-grpc' <<< "$PROTOS_NOW" && _add \
    "{name: \"${NODE_NAME} reality-grpc\", type: vless, server: ${SERVER_IP}, port: ${GRPC_PORT}, uuid: ${UUID}, network: grpc, udp: true, tls: true, servername: ${TLS_SERVER}, flow: , client-fingerprint: chrome, reality-opts: {public-key: ${REALITY_PUBLIC}, short-id: \"\"}, grpc-opts: {grpc-service-name: \"grpc\"} }" \
    "vless://$(echo -n "auto:${UUID}@${SERVER_IP_2}:${GRPC_PORT}" | base64 -w0)?remarks=${NODE_NAME// /%20}%20reality-grpc&path=grpc&obfs=grpc&tls=1&peer=${TLS_SERVER}&pbk=${REALITY_PUBLIC}" \
    "vless://${UUID}@${SERVER_IP_1}:${GRPC_PORT}?security=reality&sni=${TLS_SERVER}&fp=chrome&pbk=${REALITY_PUBLIC}&type=grpc&serviceName=grpc&encryption=none#${NODE_NAME// /%20}%20reality-grpc" \
    "{ \"type\": \"vless\", \"tag\":\"${NODE_NAME} reality-grpc\", \"server\": \"${SERVER_IP}\", \"server_port\": ${GRPC_PORT}, \"uuid\": \"${UUID}\", \"packet_encoding\":\"xudp\", \"tls\": { \"enabled\": true, \"server_name\": \"${TLS_SERVER}\", \"utls\": { \"enabled\": true, \"fingerprint\": \"chrome\" }, \"reality\": { \"enabled\": true, \"public_key\": \"${REALITY_PUBLIC}\", \"short_id\": \"\" } }, \"transport\": { \"type\": \"grpc\", \"service_name\": \"grpc\" } }" \
    "${NODE_NAME} reality-grpc"

  # vless-ws
  grep -q 'vless-ws' <<< "$PROTOS_NOW" && _add \
    "{name: \"${NODE_NAME} vless-ws\", type: vless, server: ${SERVER}, port: 443, uuid: ${UUID}, udp: true, tls: true, servername: ${ARGO_DOMAIN}, skip-cert-verify: false, network: ws, ws-opts: {path: \"/${WS_PATH}-vl\", headers: {Host: ${ARGO_DOMAIN}}, \"max_early_data\":2560, \"early_data_header_name\":\"Sec-WebSocket-Protocol\"} }" \
    "vless://${UUID}@${SERVER}:443?encryption=none&security=tls&type=ws&host=${ARGO_DOMAIN}&path=/${WS_PATH}-vl?ed=2560&sni=${ARGO_DOMAIN}#${NODE_NAME// /%20}%20vless-ws" \
    "vless://${UUID}@${SERVER}:443?encryption=none&security=tls&sni=${ARGO_DOMAIN}&type=ws&host=${ARGO_DOMAIN}&path=%2F${WS_PATH}-vl%3Fed%3D2560#${NODE_NAME// /%20}%20vless-ws" \
    "{ \"type\":\"vless\", \"tag\":\"${NODE_NAME} vless-ws\", \"server\":\"${SERVER}\", \"server_port\":443, \"uuid\":\"${UUID}\", \"tls\": { \"enabled\":true, \"server_name\":\"${ARGO_DOMAIN}\", \"utls\": { \"enabled\":true, \"fingerprint\":\"chrome\" } }, \"transport\": { \"type\":\"ws\", \"path\":\"/${WS_PATH}-vl\", \"headers\": { \"Host\": \"${ARGO_DOMAIN}\" }, \"max_early_data\":2560, \"early_data_header_name\":\"Sec-WebSocket-Protocol\" } }" \
    "${NODE_NAME} vless-ws"

  # vmess-ws
  grep -q 'vmess-ws' <<< "$PROTOS_NOW" && _add \
    "{name: \"${NODE_NAME} vmess-ws\", type: vmess, server: ${SERVER}, port: 443, uuid: ${UUID}, udp: true, alterId: 0, cipher: none, tls: true, servername: ${ARGO_DOMAIN}, skip-cert-verify: false, network: ws, ws-opts: {path: \"/${WS_PATH}-vm\", headers: {Host: ${ARGO_DOMAIN}}, \"max_early_data\":2560, \"early_data_header_name\":\"Sec-WebSocket-Protocol\"}}" \
    "vmess://$(echo -n "none:${UUID}@${SERVER}:443" | base64 -w0)?remarks=${NODE_NAME// /%20}%20vmess-ws&obfsParam=${ARGO_DOMAIN}&path=/${WS_PATH}-vm?ed=2560&obfs=websocket&tls=1&peer=${ARGO_DOMAIN}&alterId=0" \
    "vmess://$(echo -n "$VMESS" | base64 -w0)" \
    "{ \"type\":\"vmess\", \"tag\":\"${NODE_NAME} vmess-ws\", \"server\":\"${SERVER}\", \"server_port\":443, \"uuid\":\"${UUID}\", \"tls\": { \"enabled\":true, \"server_name\":\"${ARGO_DOMAIN}\", \"utls\": { \"enabled\":true, \"fingerprint\":\"chrome\" } }, \"transport\": { \"type\":\"ws\", \"path\":\"/${WS_PATH}-vm\", \"headers\": { \"Host\": \"${ARGO_DOMAIN}\" }, \"max_early_data\":2560, \"early_data_header_name\":\"Sec-WebSocket-Protocol\" } }" \
    "${NODE_NAME} vmess-ws"

  # trojan-ws
  grep -q 'trojan-ws' <<< "$PROTOS_NOW" && _add \
    "{name: \"${NODE_NAME} trojan-ws\", type: trojan, server: ${SERVER}, port: 443, password: ${UUID}, udp: true, tls: true, servername: ${ARGO_DOMAIN}, sni: ${ARGO_DOMAIN}, skip-cert-verify: false, network: ws, ws-opts: {path: \"/${WS_PATH}-tr\", headers: {Host: ${ARGO_DOMAIN}}, \"max_early_data\":2560, \"early_data_header_name\":\"Sec-WebSocket-Protocol\" } }" \
    "trojan://${UUID}@${SERVER}:443?peer=${ARGO_DOMAIN}&plugin=obfs-local;obfs=websocket;obfs-host=${ARGO_DOMAIN};obfs-uri=/${WS_PATH}-tr?ed=2560#${NODE_NAME// /%20}%20trojan-ws" \
    "trojan://${UUID}@${SERVER}:443?security=tls&sni=${ARGO_DOMAIN}&type=ws&host=${ARGO_DOMAIN}&path=/${WS_PATH}-tr?ed%3D2560#${NODE_NAME// /%20}%20trojan-ws" \
    "{ \"type\":\"trojan\", \"tag\":\"${NODE_NAME} trojan-ws\", \"server\": \"${SERVER}\", \"server_port\": 443, \"password\": \"${UUID}\", \"tls\": { \"enabled\":true, \"server_name\":\"${ARGO_DOMAIN}\", \"utls\": { \"enabled\":true, \"fingerprint\":\"chrome\" } }, \"transport\": { \"type\":\"ws\", \"path\":\"/${WS_PATH}-tr\", \"headers\": { \"Host\": \"${ARGO_DOMAIN}\" }, \"max_early_data\":2560, \"early_data_header_name\":\"Sec-WebSocket-Protocol\" } }" \
    "${NODE_NAME} trojan-ws"

  # ss-ws
  grep -qw 'ss-ws' <<< "$PROTOS_NOW" && _add \
    "{name: \"${NODE_NAME} ss-ws\", type: ss, server: ${SERVER}, port: 443, cipher: ${SS_METHOD}, password: ${UUID}, udp: true, plugin: v2ray-plugin, plugin-opts: { mode: websocket, host: ${ARGO_DOMAIN}, path: \"/${WS_PATH}-sh\", tls: true, servername: ${ARGO_DOMAIN}, skip-cert-verify: false, mux: false } }" \
    "ss://$(echo -n "chacha20-ietf-poly1305:${UUID}@${SERVER}:443" | base64 -w0)?uot=2&v2ray-plugin=$(echo -n "{\"peer\":\"${ARGO_DOMAIN}\",\"mux\":false,\"path\":\"\\/${WS_PATH}-sh\",\"host\":\"${ARGO_DOMAIN}\",\"mode\":\"websocket\",\"tls\":true}" | base64 -w0)#${NODE_NAME// /%20}%20ss-ws" \
    "ss://$(echo -n "${SS_METHOD}:${UUID}" | base64 -w0)@${SERVER}:443?plugin=v2ray-plugin%3Bmode%3Dwebsocket%3Bhost%3D${ARGO_DOMAIN}%3Bpath%3D%2F${WS_PATH}-sh%3Btls%3Dtrue%3Bservername%3D${ARGO_DOMAIN}%3Bskip-cert-verify%3Dfalse%3Bmux%3D0#${NODE_NAME// /%20}%20ss-ws" \
    "{ \"type\": \"shadowsocks\", \"tag\": \"${NODE_NAME} ss-ws\", \"server\": \"${SERVER}\", \"server_port\": 443, \"method\": \"chacha20-ietf-poly1305\", \"password\": \"${UUID}\", \"udp_over_tcp\": {\"enabled\": true,\"version\": 2}, \"plugin\": \"v2ray-plugin\", \"plugin_opts\": \"mode=websocket;host=${ARGO_DOMAIN};path=/${WS_PATH}-sh;tls=true;servername=${ARGO_DOMAIN};skip-cert-verify=false;mux=0\"}" \
    "${NODE_NAME} ss-ws"

  # vless-xhttp
  grep -q 'vless-xhttp' <<< "$PROTOS_NOW" && _add \
    "" \
    "vless://${UUID}@${SERVER}:443?encryption=none&security=tls&type=xhttp&host=${ARGO_DOMAIN}&path=/${WS_PATH}-xh&sni=${ARGO_DOMAIN}#${NODE_NAME// /%20}%20vless-xhttp" \
    "vless://${UUID}@${SERVER}:443?encryption=none&security=tls&sni=${ARGO_DOMAIN}&type=xhttp&host=${ARGO_DOMAIN}&path=/${WS_PATH}-xh#${NODE_NAME// /%20}%20vless-xhttp" \
    "" ""

  # xhttp-h3-direct (修复跨行问题)
  grep -q 'xhttp-h3-direct' <<< "$PROTOS_NOW" && _add \
    "" \
    "vless://$(echo -n "auto:${UUID}@${SERVER_IP_1}:${XHTTP_PORT_j:-30008}" | base64 -w0)?path=/${WS_PATH}-xh3&remarks=${NODE_NAME// /%20}%20xhttp-h3-direct&obfs=xhttp&tls=1&peer=${CERT_SNI}&alpn=h3&mode=stream-up&hpkp=${HY2_FP_SHA256}" \
    "vless://${UUID}@${SERVER_IP_1}:${XHTTP_PORT_j:-30008}?encryption=none&security=tls&sni=${CERT_SNI}&fp=chrome&alpn=h3&insecure=1&allowInsecure=1&pcs=${HY2_FP_SHA256//:/}&type=xhttp&path=%2F${WS_PATH}-xh3&mode=stream-up#${NODE_NAME// /%20}%20xhttp-h3-direct" \
    "" ""

  # trojan-direct
  grep -q 'trojan-direct' <<< "$PROTOS_NOW" && _add \
    "{name: \"${NODE_NAME} trojan-direct\", type: trojan, server: ${SERVER_IP}, port: ${TROJAN_PORT}, password: ${UUID}, udp: true, tls: true, sni: ${CERT_SNI}, servername: ${CERT_SNI}, skip-cert-verify: false, fingerprint: ${HY2_FP_SHA256} }" \
    "trojan://${UUID}@${SERVER_IP_1}:${TROJAN_PORT}?peer=${CERT_SNI}&tls=1&allowInsecure=0&sni=${CERT_SNI}&hpkp=${HY2_FP_SHA256}#${NODE_NAME// /%20}%20trojan-direct" \
    "trojan://${UUID}@${SERVER_IP_1}:${TROJAN_PORT}?security=tls&sni=${CERT_SNI}&fp=chrome&allowInsecure=0&insecure=0&peer=${CERT_SNI}&pinSHA256=${HY2_FP_SHA256//:/}#${NODE_NAME// /%20}%20trojan-direct" \
    "{ \"type\":\"trojan\", \"tag\":\"${NODE_NAME} trojan-direct\", \"server\": \"${SERVER_IP}\", \"server_port\": ${TROJAN_PORT}, \"password\": \"${UUID}\", \"tls\": { \"enabled\": true, \"server_name\": \"${CERT_SNI}\", \"certificate_public_key_sha256\": [\"${HY2_FP_BASE64}\"] } }" \
    "${NODE_NAME} trojan-direct"

  # ss2022-direct
  grep -q 'ss2022-direct' <<< "$PROTOS_NOW" && _add \
    "{name: \"${NODE_NAME} ss2022-direct\", type: ss, server: ${SERVER_IP}, port: ${SS2022_PORT}, cipher: 2022-blake3-aes-128-gcm, password: ${SS2022_PASSWORD}, udp: true }" \
    "ss://$(echo -n "2022-blake3-aes-128-gcm:${SS2022_PASSWORD}@${SERVER_IP_1}:${SS2022_PORT}" | base64 -w0)#$(echo -n "${NODE_NAME# }" | sed 's/ /%20/g')%20ss2022-direct" \
    "ss://$(echo -n "2022-blake3-aes-128-gcm:${SS2022_PASSWORD}" | base64 -w0)@${SERVER_IP_1}:${SS2022_PORT}#${NODE_NAME// /%20}%20ss2022-direct" \
    "{ \"type\": \"shadowsocks\", \"tag\": \"${NODE_NAME} ss2022-direct\", \"server\": \"${SERVER_IP}\", \"server_port\": ${SS2022_PORT}, \"method\": \"2022-blake3-aes-128-gcm\", \"password\": \"${SS2022_PASSWORD}\" }" \
    "${NODE_NAME} ss2022-direct"

  # 写入订阅文件
  echo -e "$CLASH" > $WORK_DIR/subscribe/proxies
  wget --no-check-certificate -qO- --tries=3 --timeout=2 ${SUBSCRIBE_TEMPLATE}/clash | sed "s#NODE_NAME#${NODE_NAME}#g; s#PROXY_PROVIDERS_URL#http://${ARGO_DOMAIN}/${UUID}/proxies#" > $WORK_DIR/subscribe/clash
  echo -n "$SR_SUBSCRIBE" | sed -E '/^[ ]*#|^--/d' | sed '/^$/d' | base64 -w0 > $WORK_DIR/subscribe/shadowrocket
  echo -n "$V2N_SUBSCRIBE" | sed -E '/^[ ]*#|^--/d' | sed '/^$/d' | base64 -w0 > $WORK_DIR/subscribe/base64

  # sing-box 订阅
  local SING_BOX_JSON=$(wget --no-check-certificate -qO- --tries=3 --timeout=2 ${SUBSCRIBE_TEMPLATE}/sing-box)
  echo "$SING_BOX_JSON" | sed "s#\"<OUTBOUND_REPLACE>\"#${SB_OUTBOUNDS}#; s#\"<NODE_REPLACE>\"#${SB_TAGS}#g" | $WORK_DIR/jq > $WORK_DIR/subscribe/sing-box

  # 显示用变量
  local CLASH_DISPLAY=$(echo -e "$CLASH" | sed '1d')
  local SB_DISPLAY=$(echo "{ \"outbounds\":[ ${SB_OUTBOUNDS} ] }" | $WORK_DIR/jq 2>/dev/null)

  check_system_info
  local ARGO_V=$($WORK_DIR/cloudflared -v | awk '{print $3}')
  local XRAY_V=$($WORK_DIR/xray version | awk 'NR==1 {print $2}')
  local NGINX_V=$(nginx -v 2>&1 | sed "s#.*/##")
  local SYS_INFO=" $(text 19):\n\t $(text 20): $SYS\n\t $(text 21): $(uname -r)\n\t $(text 22): $ARGO_ARCH\n\t $(text 23): $VIRT\n\t IPv4: $WAN4 $COUNTRY4 $ASNORG4\n\t IPv6: $WAN6 $COUNTRY6 $ASNORG6\n\t Argo: ${STATUS[0]}\t Version: ${ARGO_V}\t $(text 52): ${ARGO_MEM}\n\t Xray: ${STATUS[1]}\t Version: ${XRAY_V}\t $(text 52): ${XRAY_MEM}"
  [ "$IS_NGINX" = 'is_nginx' ] && SYS_INFO+="\n\t Nginx: ${STATUS[2]}\t Version: ${NGINX_V}\t $(text 52): ${NGINX_MEM}"

  EXPORT_LIST_FILE="*******************************************
┌────────────────┐  ┌────────────────┐
│                │  │                │
│     $(warning "V2rayN")     │  │    $(warning "NekoBox")     │
│                │  │                │
└────────────────┘  └────────────────┘
----------------------------
$(info "$(echo -e "${V2N_DISPLAY}")")
$(grep -qw 'ss-ws' <<< "$PROTOS_NOW" && info "\n$(text 75)")

*******************************************
┌────────────────┐
│                │
│  $(warning "Shadowrocket")  │
│                │
└────────────────┘
----------------------------

$(hint "$(echo -e "${SR_DISPLAY}")")

*******************************************
┌────────────────┐
│                │
│  $(warning "Clash Verge")   │
│                │
└────────────────┘
----------------------------

$(info "${CLASH_DISPLAY}")

*******************************************
┌────────────────┐
│                │
│    $(warning "Sing-box")    │
│                │
└────────────────┘
----------------------------

$(hint "${SB_DISPLAY}")

$(info "$(text 63)")

*******************************************

$(hint "Index:
${_SUB_SCHEME}://${ARGO_DOMAIN}/${UUID}/

QR code:
${_SUB_SCHEME}://${ARGO_DOMAIN}/${UUID}/qr

V2rayN / Nekoray $(text 66):
${_SUB_SCHEME}://${ARGO_DOMAIN}/${UUID}/base64")

$(hint "Clash $(text 66):
${_SUB_SCHEME}://${ARGO_DOMAIN}/${UUID}/clash

sing-box $(text 66):
${_SUB_SCHEME}://${ARGO_DOMAIN}/${UUID}/sing-box

Shadowrocket $(text 66):
${_SUB_SCHEME}://${ARGO_DOMAIN}/${UUID}/shadowrocket")

*******************************************

$(info " $(text 66):
${_SUB_SCHEME}://${ARGO_DOMAIN}/${UUID}/auto

 $(text 64) QRcode:
https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${_SUB_SCHEME}://${ARGO_DOMAIN}/${UUID}/auto")

$($WORK_DIR/qrencode ${_SUB_SCHEME}://${ARGO_DOMAIN}/${UUID}/auto)
"

  echo "$EXPORT_LIST_FILE" > $WORK_DIR/list
  cat $WORK_DIR/list

  statistics_of_run-times get
}


# 增加或删除协议
change_protocols() {
  check_install
  [ "${STATUS[1]}" = "$(text 26)" ] && error "\n $(text 39) \n"

  check_system_ip

  local EXISTED_PROTOCOLS=() NOT_EXISTED_PROTOCOLS=()
  for tag in "${CURRENT_PROTOCOLS[@]}"; do
    for idx in "${!NODE_TAG[@]}"; do
      if [ "${NODE_TAG[$idx]}" = "$tag" ]; then
        local p_name="${PROTOCOL_LIST[$idx]}"
        [ "${NODE_TAG[$idx]}" = "vless-xhttp" ] && p_name=$(text 101)
        [ "${NODE_TAG[$idx]}" = "xhttp-h3-direct" ] && p_name="VLESS + XHTTP Direct (h3)"
        [ "${NODE_TAG[$idx]}" = "trojan-direct" ] && p_name="Trojan Direct"
        [ "${NODE_TAG[$idx]}" = "ss2022-direct" ] && p_name="Shadowsocks 2022 Direct"
        EXISTED_PROTOCOLS+=("${p_name}")
        break
      fi
    done
  done
  for idx in "${!PROTOCOL_LIST[@]}"; do
    local found=false
    for tag in "${CURRENT_PROTOCOLS[@]}"; do
      [ "${NODE_TAG[$idx]}" = "$tag" ] && found=true && break
    done
    if ! $found; then
      local p_name="${PROTOCOL_LIST[$idx]}"
      [ "${NODE_TAG[$idx]}" = "vless-xhttp" ] && p_name=$(text 101)
      [ "${NODE_TAG[$idx]}" = "xhttp-h3-direct" ] && p_name="VLESS + XHTTP Direct (h3)"
      [ "${NODE_TAG[$idx]}" = "trojan-direct" ] && p_name="Trojan Direct"
      [ "${NODE_TAG[$idx]}" = "ss2022-direct" ] && p_name="Shadowsocks 2022 Direct"
      NOT_EXISTED_PROTOCOLS+=("${p_name}")
    fi
  done

  hint "\n $(text 88) (${#EXISTED_PROTOCOLS[@]})"
  for h in "${!EXISTED_PROTOCOLS[@]}"; do
    hint " $(printf "\\$(printf '%03o' $((h+97)))"). ${EXISTED_PROTOCOLS[h]}"
  done
  reading "\n $(text 89) " REMOVE_SELECT

  local REMOVE_PROTOCOLS=() KEEP_PROTOCOLS=()
  REMOVE_SELECT=$(echo "${REMOVE_SELECT,,}" | grep -o . | grep -E "^[a-z]$" | awk '!seen[$0]++' | tr -d '\n')
  for ((j=0; j<${#REMOVE_SELECT}; j++)); do
    local ch="${REMOVE_SELECT:$j:1}"
    local ridx=$(( $(printf "%d" "'$ch") - 97 ))
    [ $ridx -lt ${#EXISTED_PROTOCOLS[@]} ] && REMOVE_PROTOCOLS+=("${EXISTED_PROTOCOLS[$ridx]}")
  done
  for p in "${EXISTED_PROTOCOLS[@]}"; do
    local in_remove=false
    for r in "${REMOVE_PROTOCOLS[@]}"; do [ "$p" = "$r" ] && in_remove=true && break; done
    $in_remove || KEEP_PROTOCOLS+=("$p")
  done

  local ADD_PROTOCOLS=()
  if [ "${#NOT_EXISTED_PROTOCOLS[@]}" -gt 0 ]; then
    hint "\n $(text 90) (${#NOT_EXISTED_PROTOCOLS[@]})"
    for i in "${!NOT_EXISTED_PROTOCOLS[@]}"; do
      hint " $(printf "\\$(printf '%03o' $((i+97)))"). ${NOT_EXISTED_PROTOCOLS[i]}"
    done
    reading "\n $(text 91) " ADD_SELECT
    ADD_SELECT=$(echo "${ADD_SELECT,,}" | grep -o . | grep -E "^[a-z]$" | awk '!seen[$0]++' | tr -d '\n')
    for ((l=0; l<${#ADD_SELECT}; l++)); do
      local ch="${ADD_SELECT:$l:1}"
      local aidx=$(( $(printf "%d" "'$ch") - 97 ))
      [ $aidx -lt ${#NOT_EXISTED_PROTOCOLS[@]} ] && ADD_PROTOCOLS+=("${NOT_EXISTED_PROTOCOLS[$aidx]}")
    done
  fi

  local REINSTALL_PROTOCOLS=("${KEEP_PROTOCOLS[@]}" "${ADD_PROTOCOLS[@]}")
  [ "${#REINSTALL_PROTOCOLS[@]}" = 0 ] && error "\n $(text 94) \n"

  hint "\n $(text 92) (${#REINSTALL_PROTOCOLS[@]})"
  [ "${#KEEP_PROTOCOLS[@]}" -gt 0 ] && hint "\n $(text 96) (${#KEEP_PROTOCOLS[@]})"
  for r in "${!KEEP_PROTOCOLS[@]}"; do hint "  $((r+1)). ${KEEP_PROTOCOLS[r]}"; done
  [ "${#ADD_PROTOCOLS[@]}" -gt 0 ] && hint "\n $(text 97) (${#ADD_PROTOCOLS[@]})"
  for r in "${!ADD_PROTOCOLS[@]}"; do hint "  $((r+1)). ${ADD_PROTOCOLS[r]}"; done
  reading "\n $(text 93) " CONFIRM
  [ "${CONFIRM,,}" = 'n' ] && exit 0

  local REINSTALL_TAGS=() REMOVE_TAGS=() ADD_TAGS=()
  for idx in "${!NODE_TAG[@]}"; do
    local tag="${NODE_TAG[$idx]}"
    local pname="${PROTOCOL_LIST[$idx]}"
    for p in "${REINSTALL_PROTOCOLS[@]}"; do
      if [ "$p" = "$pname" ] || [ "$tag" = "vless-xhttp" -a "$p" = "$(text 101)" ] || [ "$tag" = "xhttp-h3-direct" -a "$p" = "VLESS + XHTTP Direct (h3)" ] || [ "$tag" = "trojan-direct" -a "$p" = "Trojan Direct" ] || [ "$tag" = "ss2022-direct" -a "$p" = "Shadowsocks 2022 Direct" ]; then
        REINSTALL_TAGS+=("$tag")
        break
      fi
    done
  done

  for pname in "${REMOVE_PROTOCOLS[@]}"; do
    for idx in "${!PROTOCOL_LIST[@]}"; do
      [[ "${PROTOCOL_LIST[$idx]}" = "$pname" || ( "${NODE_TAG[$idx]}" = "vless-xhttp" && "$pname" = "$(text 101)" ) || ( "${NODE_TAG[$idx]}" = "xhttp-h3-direct" && "$pname" = "VLESS + XHTTP Direct (h3)" ) || ( "${NODE_TAG[$idx]}" = "trojan-direct" && "$pname" = "Trojan Direct" ) || ( "${NODE_TAG[$idx]}" = "ss2022-direct" && "$pname" = "Shadowsocks 2022 Direct" ) ]] && REMOVE_TAGS+=("${NODE_TAG[$idx]}") && break
    done
  done
  for pname in "${ADD_PROTOCOLS[@]}"; do
    for idx in "${!PROTOCOL_LIST[@]}"; do
      [[ "${PROTOCOL_LIST[$idx]}" = "$pname" || ( "${NODE_TAG[$idx]}" = "vless-xhttp" && "$pname" = "$(text 101)" ) || ( "${NODE_TAG[$idx]}" = "xhttp-h3-direct" && "$pname" = "VLESS + XHTTP Direct (h3)" ) || ( "${NODE_TAG[$idx]}" = "trojan-direct" && "$pname" = "Trojan Direct" ) || ( "${NODE_TAG[$idx]}" = "ss2022-direct" && "$pname" = "Shadowsocks 2022 Direct" ) ]] && ADD_TAGS+=("${NODE_TAG[$idx]}") && break
    done
  done

  cmd_systemctl disable xray

  local _HAS_HY2_ADD=false _HAS_HY2_KEEP=false
  for t in "${ADD_TAGS[@]}"; do [ "$t" = 'hysteria2' ] && _HAS_HY2_ADD=true && break; done
  for t in "${REINSTALL_TAGS[@]}"; do [ "$t" = 'hysteria2' ] && _HAS_HY2_KEEP=true && break; done
  if $_HAS_HY2_ADD; then
    ssl_certificate "${TLS_SERVER}"
    # 先收集端口跳跃范围，再写 NAT 规则（原逻辑顺序颠倒，NAT 参数为空）
    unset IS_HOPPING PORT_HOPPING_RANGE PORT_HOPPING_START PORT_HOPPING_END
    input_hopping_port
  fi

  local _HAS_XHTTP_DIRECT_ADD=false
  for _t in "${ADD_TAGS[@]}"; do [ "$_t" = 'xhttp-h3-direct' ] && _HAS_XHTTP_DIRECT_ADD=true && break; done
  if $_HAS_XHTTP_DIRECT_ADD; then
    ssl_certificate "${TLS_SERVER}"
  fi

  local _HAS_TROJAN_DIRECT_ADD=false
  for _t in "${ADD_TAGS[@]}"; do [ "$_t" = 'trojan-direct' ] && _HAS_TROJAN_DIRECT_ADD=true && break; done
  if $_HAS_TROJAN_DIRECT_ADD; then
    ssl_certificate "${TLS_SERVER}"
  fi

  local _HAS_REALITY_ADD=false
  for _t in "${ADD_TAGS[@]}"; do [[ "$_t" =~ ^(reality-vision|reality-grpc)$ ]] && _HAS_REALITY_ADD=true && break; done
  if $_HAS_REALITY_ADD; then
    if [ -z "$REALITY_PRIVATE" ] && [ -s "$CUSTOM_FILE" ]; then
      local _pk_cp
      _pk_cp=$(awk -F= '/^privateKey=/{print $2}' "$CUSTOM_FILE")
      [[ -n "$_pk_cp" && "$_pk_cp" != '__KEY_UNSET__' ]] && REALITY_PRIVATE="$_pk_cp"
      [[ -n "$REALITY_PRIVATE" && "$REALITY_PRIVATE" != '__KEY_UNSET__' ]] && REALITY_PUBLIC=$(awk -F= '/^publicKey=/{print $2}' "$CUSTOM_FILE")
    fi
    [[ "$REALITY_PRIVATE" == '__KEY_UNSET__' ]] && REALITY_PRIVATE=''
    [[ "$REALITY_PUBLIC" == '__KEY_UNSET__' ]] && REALITY_PUBLIC=''
    if [ -z "$REALITY_PRIVATE" ]; then
      reading "\n $(text 98) " REALITY_PRIVATE
      if [ -z "$REALITY_PRIVATE" ]; then
        generate_reality_keypair
      else
        REALITY_PUBLIC=$($WORK_DIR/xray x25519 -i "$REALITY_PRIVATE" | awk '/Public/{print $NF}')
        if [ -z "$REALITY_PUBLIC" ]; then
          warning " $(text 99) "
          generate_reality_keypair
        fi
      fi
    fi
  fi

  for tag in "${REMOVE_TAGS[@]}"; do
    [ "$tag" = 'hysteria2' ] && del_port_hopping_nat
    if [ -x "$WORK_DIR/jq" ]; then
      grep -v '^//' $WORK_DIR/inbound.json > $TEMP_DIR/inbound_clean.json
      $WORK_DIR/jq "del(.inbounds[] | select(.tag | split(\" \")[-1] == \"$tag\"))" \
        $TEMP_DIR/inbound_clean.json > $TEMP_DIR/inbound_tmp.json \
      && mv $TEMP_DIR/inbound_tmp.json $WORK_DIR/inbound.json
    fi
  done

  local _SAVED_PRIVATE="$REALITY_PRIVATE" _SAVED_PUBLIC="$REALITY_PUBLIC"
  # 保存 HY2 端口跳跃状态，防止 fetch_nodes_value 内的 check_port_hopping_nat 清空
  local _SAVED_IS_HOPPING="$IS_HOPPING" _SAVED_HOP_START="$PORT_HOPPING_START" _SAVED_HOP_END="$PORT_HOPPING_END"
  fetch_nodes_value
  # 恢复端口跳跃状态（仅当新增 HY2 时有效）
  if $_HAS_HY2_ADD; then
    IS_HOPPING="$_SAVED_IS_HOPPING"
    PORT_HOPPING_START="$_SAVED_HOP_START"
    PORT_HOPPING_END="$_SAVED_HOP_END"
  fi
  [[ -n "$_SAVED_PRIVATE" && "$_SAVED_PRIVATE" != '__KEY_UNSET__' ]] && REALITY_PRIVATE="$_SAVED_PRIVATE"
  [[ -n "$_SAVED_PUBLIC" && "$_SAVED_PUBLIC" != '__KEY_UNSET__' ]] && REALITY_PUBLIC="$_SAVED_PUBLIC"
  [[ "$REALITY_PRIVATE" == '__KEY_UNSET__' ]] && REALITY_PRIVATE=''
  [[ "$REALITY_PUBLIC" == '__KEY_UNSET__' ]] && REALITY_PUBLIC=''
  [ -z "$UUID" ] && UUID=$(cat /proc/sys/kernel/random/uuid)

  local _JSON_CLEAN
  _JSON_CLEAN=$(grep -v '^//' $WORK_DIR/inbound.json 2>/dev/null)

  local _USED_PORTS=()
  for tag in "${REINSTALL_TAGS[@]}"; do
    local _EXIST_PORT
    _EXIST_PORT=$(echo "$_JSON_CLEAN" | $WORK_DIR/jq -r "[.inbounds[] | select(.tag | split(\" \")[-1] == \"$tag\") | .port] | .[0] // empty" 2>/dev/null)
    if [ -n "$_EXIST_PORT" ]; then
      _USED_PORTS+=("$_EXIST_PORT")
      case "$tag" in
        reality-vision) REALITY_PORT=$_EXIST_PORT ;;
        hysteria2) HY2_PORT=$_EXIST_PORT ;;
        reality-grpc) GRPC_PORT=$_EXIST_PORT ;;
        vless-ws) WS_PORT_e=$_EXIST_PORT ;;
        vmess-ws) WS_PORT_f=$_EXIST_PORT ;;
        trojan-ws) WS_PORT_g=$_EXIST_PORT ;;
        ss-ws) WS_PORT_h=$_EXIST_PORT ;;
        vless-xhttp) WS_PORT_i=$_EXIST_PORT ;;
        xhttp-h3-direct) XHTTP_PORT_j=$_EXIST_PORT ;;
        trojan-direct) TROJAN_PORT=$_EXIST_PORT ;;
        ss2022-direct) SS2022_PORT=$_EXIST_PORT ;;
      esac
    fi
  done

  local _SCAN_PORT
  _SCAN_PORT=$(echo "$_JSON_CLEAN" | $WORK_DIR/jq -r '[.inbounds[].port] | min // empty' 2>/dev/null)
  _SCAN_PORT=${_SCAN_PORT:-$START_PORT_DEFAULT}

  for tag in "${REINSTALL_TAGS[@]}"; do
    local _EXIST_PORT
    _EXIST_PORT=$(echo "$_JSON_CLEAN" | $WORK_DIR/jq -r "[.inbounds[] | select(.tag | split(\" \")[-1] == \"$tag\") | .port] | .[0] // empty" 2>/dev/null)
    if [ -z "$_EXIST_PORT" ]; then
      while printf '%s\n' "${_USED_PORTS[@]}" | grep -qx "$_SCAN_PORT"; do
        (( _SCAN_PORT++ ))
      done
      local _NEW_PORT=$_SCAN_PORT
      _USED_PORTS+=("$_SCAN_PORT")
      (( _SCAN_PORT++ ))
      case "$tag" in
        reality-vision) REALITY_PORT=$_NEW_PORT ;;
        hysteria2) HY2_PORT=$_NEW_PORT ;;
        reality-grpc) GRPC_PORT=$_NEW_PORT ;;
        vless-ws) WS_PORT_e=$_NEW_PORT ;;
        vmess-ws) WS_PORT_f=$_NEW_PORT ;;
        trojan-ws) WS_PORT_g=$_NEW_PORT ;;
        ss-ws) WS_PORT_h=$_NEW_PORT ;;
        vless-xhttp) WS_PORT_i=$_NEW_PORT ;;
        xhttp-h3-direct) XHTTP_PORT_j=$_NEW_PORT ;;
        trojan-direct) TROJAN_PORT=$_NEW_PORT ;;
        ss2022-direct) SS2022_PORT=$_NEW_PORT ;;
      esac
    fi
  done

  # 新增 HY2：input_hopping_port 已在上方 ssl_certificate 之后调用，此处直接写 NAT
  if $_HAS_HY2_ADD; then
    [ "$IS_HOPPING" = 'is_hopping' ] && add_port_hopping_nat "$PORT_HOPPING_START" "$PORT_HOPPING_END" "$HY2_PORT"
  elif $_HAS_HY2_KEEP; then
    # 保留 HY2：只检查现有规则状态，不重复写入，避免 iptables 规则叠加
    check_port_hopping_nat
  fi

  local _HAS_WS_XHTTP_ADD=false
  for _t in "${ADD_TAGS[@]}"; do
    [[ "$_t" =~ ^(vless-ws|vmess-ws|trojan-ws|ss-ws|vless-xhttp)$ ]] && _HAS_WS_XHTTP_ADD=true && break
  done

  if $_HAS_WS_XHTTP_ADD && [[ -z "$SERVER" || "$SERVER" == '__CDN_UNSET__' ]]; then
    echo ""
    for _c in "${!CDN_DOMAIN[@]}"; do
      hint " $((_c+1)). ${CDN_DOMAIN[_c]} "
    done
    reading "\n $(text 42) " CUSTOM_CDN
    case "$CUSTOM_CDN" in
      [1-9]|[1-9][0-9] )
        [ "$CUSTOM_CDN" -le "${#CDN_DOMAIN[@]}" ] && SERVER="${CDN_DOMAIN[$((CUSTOM_CDN-1))]}" || SERVER="${CDN_DOMAIN[0]}"
        ;;
      ?????* )
        SERVER="$CUSTOM_CDN"
        ;;
      * )
        SERVER="${CDN_DOMAIN[0]}"
    esac
  fi

  # 若最终协议列表中不含任何 Reality 协议，清除公私钥
  local _HAS_REALITY_FINAL=false
  for _t in "${REINSTALL_TAGS[@]}"; do
    [[ "$_t" =~ ^(reality-vision|reality-grpc)$ ]] && _HAS_REALITY_FINAL=true && break
  done
  $_HAS_REALITY_FINAL || { REALITY_PRIVATE='__KEY_UNSET__'; REALITY_PUBLIC='__KEY_UNSET__'; }

  # 若最终协议列表中不含任何 WS/XHTTP 协议，清除 CDN
  local _HAS_WS_XHTTP_FINAL=false
  for _t in "${REINSTALL_TAGS[@]}"; do
    [[ "$_t" =~ ^(vless-ws|vmess-ws|trojan-ws|ss-ws|vless-xhttp)$ ]] && _HAS_WS_XHTTP_FINAL=true && break
  done
  $_HAS_WS_XHTTP_FINAL || SERVER='__CDN_UNSET__'

  write_custom 'serverIp' "${SERVER_IP}"
  write_custom 'privateKey' "${REALITY_PRIVATE:-__KEY_UNSET__}"
  write_custom 'publicKey' "${REALITY_PUBLIC:-__KEY_UNSET__}"
  write_custom 'cdn' "${SERVER:-__CDN_UNSET__}"

  cat > $WORK_DIR/inbound.json << EOF
{
  "log": {
    "access": "/dev/null",
    "error": "/dev/null",
    "loglevel": "none"
  },
  "inbounds": [],
  "dns": {
    "servers": [
      "https+local://8.8.8.8/dns-query"
    ]
  }
}
EOF

  for tag in "${REINSTALL_TAGS[@]}"; do
    local NEW_BLOCK=''
    case "$tag" in
      hysteria2) NEW_BLOCK="{\"tag\":\"${NODE_NAME} hysteria2\",\"protocol\":\"hysteria\",\"port\":${HY2_PORT},\"settings\":{\"version\":2,\"clients\":[{\"auth\":\"${UUID}\"}]},\"streamSettings\":{\"network\":\"hysteria\",\"security\":\"tls\",\"tlsSettings\":{\"serverNames\":[\"${TLS_SERVER}\"],\"alpn\":[\"h3\"],\"certificates\":[{\"certificateFile\":\"${WORK_DIR}/cert/cert.pem\",\"keyFile\":\"${WORK_DIR}/cert/private.key\"}]}}}" ;;
      vless-ws) NEW_BLOCK="{\"port\":${WS_PORT_e},\"listen\":\"127.0.0.1\",\"protocol\":\"vless\",\"tag\":\"${NODE_NAME} vless-ws\",\"settings\":{\"clients\":[{\"id\":\"${UUID}\",\"level\":0}],\"decryption\":\"none\"},\"streamSettings\":{\"network\":\"ws\",\"security\":\"none\",\"wsSettings\":{\"path\":\"/${WS_PATH}-vl\"}},\"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\",\"quic\"],\"metadataOnly\":false}}" ;;
      vmess-ws) NEW_BLOCK="{\"port\":${WS_PORT_f},\"listen\":\"127.0.0.1\",\"protocol\":\"vmess\",\"tag\":\"${NODE_NAME} vmess-ws\",\"settings\":{\"clients\":[{\"id\":\"${UUID}\",\"alterId\":0}]},\"streamSettings\":{\"network\":\"ws\",\"wsSettings\":{\"path\":\"/${WS_PATH}-vm\"}},\"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\",\"quic\"],\"metadataOnly\":false}}" ;;
      trojan-ws) NEW_BLOCK="{\"port\":${WS_PORT_g},\"listen\":\"127.0.0.1\",\"protocol\":\"trojan\",\"tag\":\"${NODE_NAME} trojan-ws\",\"settings\":{\"clients\":[{\"password\":\"${UUID}\"}]},\"streamSettings\":{\"network\":\"ws\",\"security\":\"none\",\"wsSettings\":{\"path\":\"/${WS_PATH}-tr\"}},\"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\",\"quic\"],\"metadataOnly\":false}}" ;;
      ss-ws) NEW_BLOCK="{\"port\":${WS_PORT_h},\"listen\":\"127.0.0.1\",\"protocol\":\"shadowsocks\",\"tag\":\"${NODE_NAME} ss-ws\",\"settings\":{\"clients\":[{\"method\":\"chacha20-ietf-poly1305\",\"password\":\"${UUID}\"}],\"network\":\"tcp,udp\"},\"streamSettings\":{\"network\":\"ws\",\"wsSettings\":{\"path\":\"/${WS_PATH}-sh\"}},\"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\",\"quic\"],\"metadataOnly\":false}}" ;;
      vless-xhttp) NEW_BLOCK="{\"port\":${WS_PORT_i},\"listen\":\"127.0.0.1\",\"protocol\":\"vless\",\"tag\":\"${NODE_NAME} vless-xhttp\",\"settings\":{\"clients\":[{\"id\":\"${UUID}\",\"level\":0}],\"decryption\":\"none\"},\"streamSettings\":{\"network\":\"xhttp\",\"xhttpSettings\":{\"path\":\"/${WS_PATH}-xh\",\"mode\":\"auto\"}}}" ;;
      xhttp-h3-direct) NEW_BLOCK="{\"tag\":\"${NODE_NAME} xhttp-h3-direct\",\"port\":${XHTTP_PORT_j},\"protocol\":\"vless\",\"settings\":{\"clients\":[{\"id\":\"${UUID}\"}],\"decryption\":\"none\"},\"streamSettings\":{\"network\":\"xhttp\",\"security\":\"tls\",\"xhttpSettings\":{\"mode\":\"stream-up\",\"extra\":{\"alpn\":[\"h3\"]},\"path\":\"/${WS_PATH}-xh3\"},\"tlsSettings\":{\"alpn\":[\"h3\"],\"certificates\":[{\"certificateFile\":\"${WORK_DIR}/cert/cert.pem\",\"keyFile\":\"${WORK_DIR}/cert/private.key\"}]}},\"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\",\"quic\"]}}" ;;
      trojan-direct) NEW_BLOCK="{\"port\":${TROJAN_PORT},\"protocol\":\"trojan\",\"tag\":\"${NODE_NAME} trojan-direct\",\"settings\":{\"clients\":[{\"password\":\"${UUID}\"}]},\"streamSettings\":{\"network\":\"tcp\",\"security\":\"tls\",\"tlsSettings\":{\"serverName\":\"${TLS_SERVER}\",\"certificates\":[{\"certificateFile\":\"${WORK_DIR}/cert/cert.pem\",\"keyFile\":\"${WORK_DIR}/cert/private.key\"}]}},\"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\",\"quic\"],\"metadataOnly\":false}}" ;;
      ss2022-direct) NEW_BLOCK="{\"port\":${SS2022_PORT},\"protocol\":\"shadowsocks\",\"tag\":\"${NODE_NAME} ss2022-direct\",\"settings\":{\"method\":\"2022-blake3-aes-128-gcm\",\"password\":\"${SS2022_PASSWORD}\",\"network\":\"tcp,udp\"},\"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\",\"quic\"],\"metadataOnly\":false}}" ;;
      reality-vision) NEW_BLOCK="{\"tag\":\"${NODE_NAME} reality-vision\",\"protocol\":\"vless\",\"port\":${REALITY_PORT},\"settings\":{\"clients\":[{\"id\":\"${UUID}\",\"flow\":\"xtls-rprx-vision\"}],\"decryption\":\"none\"},\"streamSettings\":{\"network\":\"tcp\",\"security\":\"reality\",\"realitySettings\":{\"show\":false,\"dest\":\"${TLS_SERVER}:443\",\"xver\":0,\"serverNames\":[\"${TLS_SERVER}\"],\"privateKey\":\"${REALITY_PRIVATE}\",\"publicKey\":\"${REALITY_PUBLIC}\",\"maxTimeDiff\":70000,\"shortIds\":[\"\"]}},\"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\"]}}" ;;
      reality-grpc) NEW_BLOCK="{\"port\":${GRPC_PORT},\"protocol\":\"vless\",\"tag\":\"${NODE_NAME} reality-grpc\",\"settings\":{\"clients\":[{\"id\":\"${UUID}\",\"flow\":\"\"}],\"decryption\":\"none\"},\"streamSettings\":{\"network\":\"grpc\",\"security\":\"reality\",\"realitySettings\":{\"show\":false,\"dest\":\"${TLS_SERVER}:443\",\"xver\":0,\"serverNames\":[\"${TLS_SERVER}\"],\"privateKey\":\"${REALITY_PRIVATE}\",\"publicKey\":\"${REALITY_PUBLIC}\",\"maxTimeDiff\":70000,\"shortIds\":[\"\"]},\"grpcSettings\":{\"serviceName\":\"grpc\",\"multiMode\":true}},\"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\"]}}" ;;
    esac
    if [ -n "$NEW_BLOCK" ] && [ -x "$WORK_DIR/jq" ]; then
      $WORK_DIR/jq --argjson block "$NEW_BLOCK" '.inbounds += [$block]' \
        $WORK_DIR/inbound.json > $TEMP_DIR/inbound_tmp.json \
        && mv $TEMP_DIR/inbound_tmp.json $WORK_DIR/inbound.json
    fi
  
  done

  mapfile -t CURRENT_PROTOCOLS < <(get_installed_protocols)

  json_nginx
  local _NGINX_PID=$(pgrep -f "nginx: master process" 2>/dev/null)
  if [ -n "$_NGINX_PID" ]; then
    nginx -c $WORK_DIR/nginx.conf -s reload >/dev/null 2>&1 || true
  else
    $(type -p nginx) -c $WORK_DIR/nginx.conf >/dev/null 2>&1 || true
  fi

  if [ ! -s "${ARGO_DAEMON_FILE}" ]; then
    argo_variable
  fi

  cmd_systemctl enable xray
  sleep 2
  check_install
  cmd_systemctl status xray &>/dev/null \
    && info "\n Xray $(text 28) $(text 37) \n" \
    || warning "\n Xray $(text 28) $(text 38) \n"
  export_list
}

# 更换 Argo 隧道类型
change_argo() {
  check_install
  [[ ${STATUS[0]} = "$(text 26)" ]] && error " $(text 39) "

  case $(grep "${DAEMON_RUN_PATTERN}" ${ARGO_DAEMON_FILE}) in
    *--config* )
      ARGO_TYPE='Json'
      ;;
    *--token* )
      ARGO_TYPE='Token'
      ;;
    * )
      ARGO_TYPE='Try'
      cmd_systemctl enable argo && sleep 2 && cmd_systemctl status argo &>/dev/null && fetch_tunnel_domain quick
  esac

  # 若 Try 隧道且已安装 vless-xhttp，在类型后附加提示
  local ARGO_TYPE="$ARGO_TYPE"
  if [ "$ARGO_TYPE" = 'Try' ] && get_installed_protocols | grep -q 'vless-xhttp'; then
    ARGO_TYPE="Try $(text 113)"
  fi

  # 获取当前隧道域名用于显示（Json/Token 走 /config，Try 已在上方获取）
  [ -z "$NGINX_PORT" ] && [ -s "$WORK_DIR/nginx.conf" ] && NGINX_PORT=$(awk '/listen[[:space:]]/{gsub(/;/,""); print $2; exit}' "$WORK_DIR/nginx.conf")
  [ -z "$ARGO_DOMAIN" ] && { [[ "$ARGO_TYPE" =~ ^Try ]] && fetch_tunnel_domain quick || fetch_tunnel_domain config; }
  hint "\n $(text 40) \n"
  unset ARGO_DOMAIN
  hint " $(text 41) \n" && reading " $(text 24) " CHANGE_TO
  # 切换前确保 NGINX_PORT 有值（优先从 nginx.conf 读取，兜底默认值）
  case "$CHANGE_TO" in
    1 )
      cmd_systemctl disable argo
      [ -s $WORK_DIR/tunnel.json ] && rm -f $WORK_DIR/tunnel.{json,yml}
      if [ "$SYSTEM" = 'Alpine' ]; then
        local ARGS="--edge-ip-version auto --no-autoupdate --url http://localhost:${NGINX_PORT}"
        sed -i "s@^command_args=.*@command_args=\"$ARGS\"@g" ${ARGO_DAEMON_FILE}
      else
        sed -i "s@ExecStart=.*@ExecStart=$WORK_DIR/cloudflared tunnel --edge-ip-version auto --no-autoupdate --url http://localhost:${NGINX_PORT}@g" ${ARGO_DAEMON_FILE}
      fi
      ;;
    2 )
      SERVER_IP=$(awk -F= '/^serverIp=/{print $2}' "$CUSTOM_FILE" 2>/dev/null)
      local TOTAL_STEPS=''
      [ -z "$ARGO_DOMAIN" ] && reading "\n $(text 10) " ARGO_DOMAIN
      if [[ -n "$ARGO_DOMAIN" && ! "$ARGO_DOMAIN" =~ trycloudflare\.com$ && -z "$ARGO_AUTH" ]]; then
        hint "\n $(text 11)"
        reading "\n $(text 86) " ARGO_AUTH
      fi
      argo_variable
      cmd_systemctl disable argo
      if [ -n "$ARGO_TOKEN" ]; then
        [ -s $WORK_DIR/tunnel.json ] && rm -f $WORK_DIR/tunnel.{json,yml}
        if [ "$SYSTEM" = 'Alpine' ]; then
          local ARGS="--edge-ip-version auto run --token ${ARGO_TOKEN}"
          sed -i "s@^command_args=.*@command_args=\"$ARGS\"@g" ${ARGO_DAEMON_FILE}
        else
          sed -i "s@ExecStart=.*@ExecStart=$WORK_DIR/cloudflared tunnel --edge-ip-version auto run --token ${ARGO_TOKEN}@g" ${ARGO_DAEMON_FILE}
        fi
      elif [ -n "$ARGO_JSON" ]; then
        [ -s $WORK_DIR/tunnel.json ] && rm -f $WORK_DIR/tunnel.{json,yml}
        json_argo
        if [ "$SYSTEM" = 'Alpine' ]; then
          local ARGS="--edge-ip-version auto --config $WORK_DIR/tunnel.yml run"
          sed -i "s@^command_args=.*@command_args=\"$ARGS\"@g" ${ARGO_DAEMON_FILE}
        else
          sed -i "s@ExecStart=.*@ExecStart=$WORK_DIR/cloudflared tunnel --edge-ip-version auto --config $WORK_DIR/tunnel.yml run@g" ${ARGO_DAEMON_FILE}
        fi
      fi
      ;;
    * )
      exit 0
  esac

  [ "$IS_NGINX" = 'is_nginx' ] && json_nginx
  cmd_systemctl enable argo
  export_list
}

# 更换优选域名 / Reality SNI / 节点信息
change_config() {
  [ ! -d "${WORK_DIR}" ] && error " $(text 70) "

  fetch_nodes_value || error " $(text 70) "

  local MENU_IDX=() MENU_KEY=() MENU_VAL=()

  [[ -n "$SERVER" && "$SERVER" != '__CDN_UNSET__' ]] && MENU_IDX+=(107) && MENU_KEY+=(cdn) && MENU_VAL+=("$SERVER")
  [ -n "$TLS_SERVER" ] && MENU_IDX+=(108) && MENU_KEY+=(sni) && MENU_VAL+=("$TLS_SERVER")
  [ -n "$NODE_NAME" ] && MENU_IDX+=(109) && MENU_KEY+=(name) && MENU_VAL+=("$NODE_NAME")
  [ -n "$UUID" ] && MENU_IDX+=(110) && MENU_KEY+=(uuid) && MENU_VAL+=("$UUID")
  [ -n "$SERVER_IP" ] && MENU_IDX+=(111) && MENU_KEY+=(serverip) && MENU_VAL+=("$SERVER_IP")
  # 仅当 hysteria2 已安装（PORT_HOPPING_TARGET 非空）时才显示端口跳跃选项
  if [ -n "$PORT_HOPPING_TARGET" ]; then
    MENU_IDX+=(6); MENU_KEY+=(hopping)
    if [ -n "$PORT_HOPPING_START" ]; then
      MENU_VAL+=("${PORT_HOPPING_START}:${PORT_HOPPING_END}")
    else
      MENU_VAL+=("$(text 67)")
    fi
  fi

  [ "${#MENU_IDX[@]}" -eq 0 ] && error " $(text 70) "

  hint "\n $(text 106)\n"
  for _i in "${!MENU_IDX[@]}"; do
    local _val="${MENU_VAL[_i]}"
    local _raw
    eval "_raw=\"\${${L}[${MENU_IDX[_i]}]}\""
    eval "hint \" $(( _i+1 )). ${_raw}\""
  done
  hint ""
  reading " $(text 24) " CHOOSE_NODE_INFO

  if ! [[ "$CHOOSE_NODE_INFO" =~ ^[0-9]+$ ]] || \
     [ "$CHOOSE_NODE_INFO" -lt 1 ] || \
     [ "$CHOOSE_NODE_INFO" -gt "${#MENU_IDX[@]}" ]; then
    info " $(text 103) " && return
  fi

  local IDX=$(( CHOOSE_NODE_INFO - 1 ))
  local KEY="${MENU_KEY[IDX]}"
  local OLD="${MENU_VAL[IDX]}"

  # 端口跳跃：走独立交互流程，不走通用 reading/sed 替换
  if [ "$KEY" = "hopping" ]; then
    # 提前保存 TARGET，del_port_hopping_nat 内会调用 check_port_hopping_nat 清空它
    local _HOP_TARGET="$PORT_HOPPING_TARGET"
    unset IS_HOPPING PORT_HOPPING_RANGE PORT_HOPPING_START PORT_HOPPING_END
    input_hopping_port
    # 保存用户输入的起止端口，del_port_hopping_nat 内 check_port_hopping_nat 会 unset 它们
    local _HOP_START="$PORT_HOPPING_START" _HOP_END="$PORT_HOPPING_END"
    # 先删除旧规则（无论原来是否有）
    del_port_hopping_nat
    if [ "$IS_HOPPING" = 'is_hopping' ]; then
      add_port_hopping_nat "$_HOP_START" "$_HOP_END" "$_HOP_TARGET"
      info "\n $(text 37) \n"
    else
      info "\n $(text 103) \n"
    fi
    export_list
    return
  fi

  hint ""
  reading " $(text 60) " NEW_VAL
  [ -z "$NEW_VAL" ] && info " $(text 103) " && return

  if [ "$KEY" = "uuid" ]; then
    [[ ! "${NEW_VAL,,}" =~ ^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$ ]] && error " $(text 3) "
  elif [ "$KEY" = "sni" ]; then
    ssl_certificate "$NEW_VAL"
  elif [ "$KEY" = "serverip" ]; then
    [[ ! "$NEW_VAL" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] && [[ ! "$NEW_VAL" =~ ^[0-9a-fA-F:]+$ ]] && error " $(text 112) "
  fi

  # 按字段定点更新，不再全目录暴力 sed 替换
  local _IB="$WORK_DIR/inbound.json"
  local _IB_TMP="$TEMP_DIR/inbound_tmp.json"
  case "$KEY" in
    cdn)
      write_custom 'cdn' "${NEW_VAL}"
      ;;
    serverip)
      write_custom 'serverIp' "${NEW_VAL}"
      ;;
    name)
      # 更新 inbound.json 所有 inbound 的 tag（"OLD_NAME proto" → "NEW_NAME proto"）
      if [ -s "$_IB" ] && [ -x "$WORK_DIR/jq" ]; then
        grep -v '^//' "$_IB" \
          | $WORK_DIR/jq --arg old "$OLD" --arg new "$NEW_VAL" \
              '(.inbounds[].tag) |= if startswith($old + " ") then ($new + " " + (ltrimstr($old + " "))) else . end' \
          > "$_IB_TMP" && mv "$_IB_TMP" "$_IB"
      fi
      ;;
    uuid)
      # 精确更新 inbound.json 中各协议的认证字段
      if [ -s "$_IB" ] && [ -x "$WORK_DIR/jq" ]; then
        grep -v '^//' "$_IB" \
          | $WORK_DIR/jq --arg old "$OLD" --arg new "$NEW_VAL" \
              '(.inbounds[].settings.clients[]? | (.id, .password, .auth) | select(. == $old)) = $new' \
          > "$_IB_TMP" && mv "$_IB_TMP" "$_IB"
      fi
      # UUID 用于 nginx.conf 的 location 路径，需重新生成 nginx.conf
      UUID="$NEW_VAL"
      json_nginx
      local _NGINX_PID
      _NGINX_PID=$(ps -eo pid,args | awk -v d="$WORK_DIR" '$0~(d"/nginx.conf"){print $1;exit}')
      if [ -n "$_NGINX_PID" ]; then
        nginx -c "$WORK_DIR/nginx.conf" -s reload >/dev/null 2>&1 || true
      fi
      ;;
    sni)
      # TLS_SERVER 存储在 inbound.json，精确更新所有 serverNames/serverName 字段
      if [ -s "$_IB" ] && [ -x "$WORK_DIR/jq" ]; then
        grep -v '^//' "$_IB" \
          | $WORK_DIR/jq --arg old "$OLD" --arg new "$NEW_VAL" \
              'walk(if type == "object" then
                (if has("serverNames") then .serverNames |= map(if . == $old then $new else . end) else . end) |
                (if has("serverName")  then .serverName  |= if . == $old then $new else . end else . end)
              else . end)' \
          > "$_IB_TMP" && mv "$_IB_TMP" "$_IB"
      fi
      ;;
  esac

  cmd_systemctl disable xray
  cmd_systemctl enable xray
  sleep 2
  cmd_systemctl status xray &>/dev/null && \
    info "\n Xray $(text 28) $(text 37) \n" || \
    warning "\n Xray $(text 27) $(text 38) \n"

  export_list
}

# 卸载 ArgoX
uninstall() {
  if [ -d $WORK_DIR ]; then
    cmd_systemctl disable argo
    cmd_systemctl disable xray
    get_installed_protocols | grep -q 'hysteria2' && del_port_hopping_nat
    local _NGINX_MASTER
    _NGINX_MASTER=$(ps -eo pid,args | awk '/nginx: master process.*\/etc\/argox\/nginx.conf/{print $1;exit}')
    if [ -n "$_NGINX_MASTER" ]; then
      kill -QUIT "$_NGINX_MASTER" 2>/dev/null
      sleep 1
      kill -9 "$_NGINX_MASTER" 2>/dev/null || true
    fi
    reading "\n $(text 65) " REMOVE_NGINX
    [ "${REMOVE_NGINX,,}" = 'y' ] && ${PACKAGE_UNINSTALL[int]} nginx >/dev/null 2>&1
    [ "$SYSTEM" = 'Alpine' ] && rm -rf $WORK_DIR $TEMP_DIR /etc/init.d/{xray,argo} /usr/bin/argox || rm -rf $WORK_DIR $TEMP_DIR /etc/systemd/system/{xray,argo}.service /usr/bin/argox
    info "\n $(text 16) \n"
  else
    error "\n $(text 15) \n"
  fi
}

# Argo 与 Xray 的最新版本
version() {
  local ONLINE=$(wget --no-check-certificate -qO- "${GH_PROXY}https://api.github.com/repos/cloudflare/cloudflared/releases/latest" | grep "tag_name" | cut -d \" -f4)
  [ -z "$ONLINE" ] && error " $(text 74) "
  local LOCAL=$($WORK_DIR/cloudflared -v | awk '{for (i=0; i<NF; i++) if ($i=="version") {print $(i+1)}}')
  local APP=ARGO && info "\n $(text 43) "
  [[ -n "$ONLINE" && "$ONLINE" != "$LOCAL" ]] && reading "\n $(text 9) " UPDATE[0] || info " $(text 44) "

  ONLINE=$(wget --no-check-certificate -qO- "${GH_PROXY}https://api.github.com/repos/XTLS/Xray-core/releases/latest" | grep "tag_name" | sed "s@.*\"v\(.*\)\",@\1@g")
  [ -z "$ONLINE" ] && error " $(text 74) "
  LOCAL=$($WORK_DIR/xray version | awk '{for (i=0; i<NF; i++) if ($i=="Xray") {print $(i+1)}}')
  local APP=Xray && info "\n $(text 43) "
  [[ -n "$ONLINE" && "$ONLINE" != "$LOCAL" ]] && reading "\n $(text 9) " UPDATE[1] || info " $(text 44) "

  [[ "${UPDATE[*],,}" =~ y ]] && check_system_info
  if [ "${UPDATE[0],,}" = 'y' ]; then
    wget --no-check-certificate -O $TEMP_DIR/cloudflared ${GH_PROXY}https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$ARGO_ARCH
    if [ -s $TEMP_DIR/cloudflared ]; then
      cmd_systemctl disable argo
      chmod +x $TEMP_DIR/cloudflared && mv $TEMP_DIR/cloudflared $WORK_DIR/cloudflared
      cmd_systemctl enable argo
      cmd_systemctl status argo &>/dev/null && info " Argo $(text 28) $(text 37)" || error " Argo $(text 28) $(text 38) "
    else
      local APP=ARGO && error "\n $(text 48) "
    fi
  fi
  if [ "${UPDATE[1],,}" = 'y' ]; then
    wget --no-check-certificate -O $TEMP_DIR/Xray-linux-$XRAY_ARCH.zip ${GH_PROXY}https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-$XRAY_ARCH.zip
    if [ -s $TEMP_DIR/Xray-linux-$XRAY_ARCH.zip ]; then
      cmd_systemctl disable xray
      unzip -qo $TEMP_DIR/Xray-linux-$XRAY_ARCH.zip xray *.dat -d $WORK_DIR; rm -f $TEMP_DIR/Xray*.zip
      cmd_systemctl enable xray
      cmd_systemctl status xray &>/dev/null && info " Xray $(text 28) $(text 37)" || error " Xray $(text 28) $(text 38) "
    else
      local APP=Xray && error "\n $(text 48) "
    fi
  fi
}

# 判断当前 Argo-X 的运行状态，并对应的给菜单和动作赋值
menu_setting() {
  local PS_LIST=$(ps -eo pid,args | grep -E "$WORK_DIR.*([x]ray|[c]loudflared|[n]ginx)" | sed 's/^[ ]\+//g')
  if [[ "${STATUS[*]}" =~ $(text 27)|$(text 28) ]]; then
    if [ -s $WORK_DIR/cloudflared ]; then
      ARGO_VERSION=$($WORK_DIR/cloudflared -v | awk '{print $3}' | sed "s@^@Version: &@g")
      local ARGO_PID=$(awk '/cloudflared/{print $1}' <<< "$PS_LIST")
      local REALTIME_METRICS_PORT=$(ss -nltp | awk -v pid=${ARGO_PID} '$0 ~ "pid="pid"," {split($4, a, ":"); print a[length(a)]}')
      ss -nltp | grep -q "cloudflared.*pid=${ARGO_PID}," && ARGO_CHECKHEALTH="$(text 46): $(wget -qO- http://localhost:${REALTIME_METRICS_PORT}/healthcheck | sed "s/OK/$(text 37)/")"
    fi
    [ -s $WORK_DIR/xray ] && XRAY_VERSION=$($WORK_DIR/xray version | awk 'NR==1 {print $2}' | sed "s@^@Version: &@g")
    [ "$IS_NGINX" = 'is_nginx' ] && NGINX_VERSION=$(nginx -v 2>&1 | sed "s#.*/##; s/ (.*)//" | sed "s@^@Version: &@g")

    OPTION[1]="1 .  $(text 29)"
    if [ "${STATUS[0]}" = "$(text 28)" ]; then
      local ARGO_PID=$(pgrep -f "$WORK_DIR/cloudflared")
      [ -n "$ARGO_PID" ] && ARGO_MEMORY="$(text 52): $(awk '/VmRSS/{printf "%.1f", $2/1024}' /proc/${ARGO_PID%% *}/status 2>/dev/null) MB"
      OPTION[2]="2 .  $(text 27) Argo (argox -a)"
    else
      OPTION[2]="2 .  $(text 28) Argo (argox -a)"
    fi
    if [ "$IS_NGINX" = 'is_nginx' ]; then
      local NGINX_PID=$(pgrep -f "nginx: master process")
      [ -n "$NGINX_PID" ] && NGINX_MEMORY="$(text 52): $(awk '/VmRSS/{printf "%.1f", $2/1024}' /proc/${NGINX_PID%% *}/status 2>/dev/null) MB"
    fi
    if [ "${STATUS[1]}" = "$(text 28)" ]; then
      local XRAY_PID=$(pgrep -f "$WORK_DIR/xray")
      [ -n "$XRAY_PID" ] && XRAY_MEMORY="$(text 52): $(awk '/VmRSS/{printf "%.1f", $2/1024}' /proc/${XRAY_PID%% *}/status 2>/dev/null) MB"
      OPTION[3]="3 .  $(text 27) Xray (argox -x)"
    else
      OPTION[3]="3 .  $(text 28) Xray (argox -x)"
    fi
    OPTION[4]="4 .  $(text 30)"
    OPTION[5]="5 .  $(text 76)"
    OPTION[6]="6 .  $(text 95)"
    OPTION[7]="7 .  $(text 31)"
    OPTION[8]="8 .  $(text 32)"
    OPTION[9]="9 .  $(text 33)"
    OPTION[10]="10.  $(text 51)"
    OPTION[11]="11.  $(text 57)"

    ACTION[1]() { export_list; exit 0; }
    [[ ${STATUS[0]} = "$(text 28)" ]] &&
    ACTION[2]() {
      cmd_systemctl disable argo
      cmd_systemctl status argo &>/dev/null && error " Argo $(text 27) $(text 38) " || info "\n Argo $(text 27) $(text 37)"
    } ||
    ACTION[2]() {
      cmd_systemctl enable argo
      sleep 2
      cmd_systemctl status argo &>/dev/null && info "\n Argo $(text 28) $(text 37)" || error " Argo $(text 28) $(text 38) "
      grep -qs "^${DAEMON_RUN_PATTERN}.*--url" ${ARGO_DAEMON_FILE} && fetch_tunnel_domain quick && export_list
    }

    [[ ${STATUS[1]} = "$(text 28)" ]] &&
    ACTION[3]() {
      cmd_systemctl disable xray
      cmd_systemctl status xray &>/dev/null && error " Xray $(text 27) $(text 38) " || info "\n Xray $(text 27) $(text 37)"
    } ||
    ACTION[3]() {
      cmd_systemctl enable xray
      sleep 2
      cmd_systemctl status xray &>/dev/null && info "\n Xray $(text 28) $(text 37)" || error " Xray $(text 28) $(text 38) "
    }
    ACTION[4]() { change_argo; exit; }
    ACTION[5]() { change_config; exit; }
    ACTION[6]() { change_protocols; exit; }
    ACTION[7]() { version; exit; }
    ACTION[8]() { bash <(wget --no-check-certificate -qO- ${GH_PROXY}https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh); exit; }
    ACTION[9]() { uninstall; exit; }
    ACTION[10]() { bash <(wget --no-check-certificate -qO- ${GH_PROXY}https://raw.githubusercontent.com/fscarmen/sing-box/main/sing-box.sh) -$L; exit; }
    ACTION[11]() { bash <(wget --no-check-certificate -qO- ${GH_PROXY}https://raw.githubusercontent.com/fscarmen/sba/main/sba.sh) -$L; exit; }

  else
    OPTION[1]="1.  $(text 77)"
    OPTION[2]="2.  $(text 34)"
    OPTION[3]="3.  $(text 32)"
    OPTION[4]="4.  $(text 51)"
    OPTION[5]="5.  $(text 57)"

    ACTION[1]() { NONINTERACTIVE_INSTALL='noninteractive_install'; fast_install_variables; install_argox; export_list; create_shortcut; exit;}
    ACTION[2]() { install_argox; export_list; create_shortcut; exit; }
    ACTION[3]() { bash <(wget --no-check-certificate -qO- ${GH_PROXY}https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh); exit; }
    ACTION[4]() { bash <(wget --no-check-certificate -qO- ${GH_PROXY}https://raw.githubusercontent.com/fscarmen/sing-box/main/sing-box.sh) -$L; exit; }
    ACTION[5]() { bash <(wget --no-check-certificate -qO- ${GH_PROXY}https://raw.githubusercontent.com/fscarmen/sba/main/sba.sh) -$L; exit; }
  fi

  [ "${#OPTION[@]}" -ge '10' ] && OPTION[0]="0 .  $(text 35)" || OPTION[0]="0.  $(text 35)"
  ACTION[0]() { exit; }
}

menu() {
  clear
  echo -e "======================================================================================================================\n"
  info " $(text 17): $VERSION\n $(text 18): $(text 1)\n $(text 19):\n\t $(text 20): $SYS\n\t $(text 21): $(uname -r)\n\t $(text 22): $ARGO_ARCH\n\t $(text 23): $VIRT "
  info "\t IPv4:  $WAN4 $COUNTRY4 $ASNORG4 "
  info "\t IPv6:  $WAN6 $COUNTRY6 $ASNORG6 "
  _sv() {
    local s="$1"
    if [ "$L" = 'C' ]; then
      [ "${#s}" -le 2 ] && printf '%s  ' "$s" || printf '%s' "$s"
    else
      printf '%-11s' "$s"
    fi
  }
  local _AV; printf -v _AV '%-26s' "$ARGO_VERSION"
  local _XV; printf -v _XV '%-26s' "$XRAY_VERSION"
  local _NV; printf -v _NV '%-26s' "$NGINX_VERSION"
  info "\t Argo:  $(_sv "${STATUS[0]}")  ${_AV}${ARGO_MEMORY}\t ${ARGO_CHECKHEALTH}\n\t Xray:  $(_sv "${STATUS[1]}")  ${_XV}${XRAY_MEMORY}"
  [ "$IS_NGINX" = 'is_nginx' ] && info "\t Nginx: $(_sv "${STATUS[2]}")  ${_NV}${NGINX_MEMORY}"
  echo -e "\n======================================================================================================================\n"
  for ((b=1;b<${#OPTION[*]};b++)); do hint " ${OPTION[b]} "; done
  hint " ${OPTION[0]} "
  reading "\n $(text 24) " CHOOSE

  if grep -qE "^[0-9]+$" <<< "$CHOOSE" && [ "$CHOOSE" -lt "${#OPTION[*]}" ]; then
    ACTION[$CHOOSE]
  else
    warning " $(text 36) [0-$((${#OPTION[*]}-1))] " && sleep 1 && menu
  fi
}

check_cdn
statistics_of_run-times update argox.sh 2>/dev/null

# 传参
[[ "${*,,}" =~ '-e'|'-k' ]] && L=E
[[ "${*,,}" =~ '-c'|'-b'|'-l' ]] && L=C

while getopts ":AaXxTtDdUuNnVvBbRrF:f:KkLl" OPTNAME; do
  case "${OPTNAME,,}" in
    a ) select_language; check_system_info; check_install
        [ "${STATUS[0]}" = "$(text 28)" ] && {
          cmd_systemctl disable argo
          cmd_systemctl status argo &>/dev/null && error " Argo $(text 27) $(text 38) " || info "\n Argo $(text 27) $(text 37)"
        } || {
          cmd_systemctl enable argo
          sleep 2
          if cmd_systemctl status argo &>/dev/null; then
            info "\n Argo $(text 28) $(text 37)"
            grep -qs "^${DAEMON_RUN_PATTERN}.*--url" ${ARGO_DAEMON_FILE} && fetch_tunnel_domain quick && export_list
          else
            error " Argo $(text 28) $(text 38) "
          fi
        }; exit 0 ;;

    x ) select_language; check_system_info; check_install
        [ "${STATUS[1]}" = "$(text 28)" ] && {
          cmd_systemctl disable xray
          cmd_systemctl status xray &>/dev/null && error " Xray $(text 27) $(text 38) " || info "\n Xray $(text 27) $(text 37)"
        } || {
          cmd_systemctl enable xray
          sleep 2
          cmd_systemctl status xray &>/dev/null && info "\n Xray $(text 28) $(text 37)" || error " Xray $(text 28) $(text 38) "
        }; exit 0 ;;
    t ) select_language; check_system_info; check_arch; change_argo; exit 0 ;;
    d ) select_language; check_system_info; change_config; exit 0 ;;
    r ) select_language; check_system_info; check_install; change_protocols; exit 0 ;;
    u ) select_language; check_system_info; uninstall; exit 0;;
    n ) select_language; check_system_info; export_list; exit 0 ;;
    v ) select_language; check_system_info; check_arch; version; exit 0;;
    b ) select_language; bash <(wget --no-check-certificate -qO- "${GH_PROXY}https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh"); exit ;;
    f ) NONINTERACTIVE_INSTALL='noninteractive_install'; VARIABLE_FILE=$OPTARG; . $VARIABLE_FILE ;;
    k|l ) NONINTERACTIVE_INSTALL='noninteractive_install'; fast_install_variables ;;
  esac
done

# 旧版本兼容过渡（将于 2026年9月30日移除）：$WORK_DIR 已存在但 custom 文件不存在，说明是旧版本安装，降级运行旧版脚本
if [ -d "$WORK_DIR" ] && [ ! -s "$CUSTOM_FILE" ] && [[ "$(date +%Y%m%d)" < "20260930" ]]; then
  # 读取旧版语言标记（E=英文，C=中文），决定提示语言
  _compat_lang=$(cat "$WORK_DIR/language" 2>/dev/null | tr -d '[:space:]')
  if [ "${_compat_lang^^}" = 'C' ]; then
    warning "[兼容模式] 检测到旧版本安装，将自动切换到旧版脚本运行"
    warning "          此兼容过渡将于 2026年9月30日移除，10秒后自动跳转，按任意键立即跳转"
  else
    warning "[Compatibility Mode] Old installation detected. Switching to legacy script automatically."
    warning "                     This bridge will be removed on 2026-09-30. Auto-switching in 10s, or press any key to skip now."
  fi
exit 2
  for _i in 10 9 8 7 6 5 4 3 2 1; do
    if [ "${_compat_lang^^}" = 'C' ]; then
      echo -ne "\033[33m\033[01m  ${_i} 秒后自动跳转...\033[0m\r"
    else
      echo -ne "\033[33m\033[01m  Auto-switching in ${_i}s...\033[0m\r"
    fi
    read -t 1 -s -r -n1 _compat_key && break
  done
  echo ""
  bash <(wget -qO- https://raw.githubusercontent.com/fscarmen/ArgoX/70ad14d282d63c6b8359e9d75224ab5012d2785a/argox.sh) "$@"
  exit $?
fi

select_language
check_root
check_arch
check_system_info
check_dependencies
[ "$NONINTERACTIVE_INSTALL" != 'noninteractive_install' ] && check_system_ip
check_install
menu_setting
[ "$NONINTERACTIVE_INSTALL" = 'noninteractive_install' ] && ACTION[2] || menu