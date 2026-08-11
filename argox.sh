#!/usr/bin/env bash

# 当前脚本版本号
VERSION='2.1.4 (2026.08.11)'

# Github 反代加速代理
GITHUB_PROXY=('https://hub.glowp.xyz/' 'https://proxy.vvvv.ee/')

# 协议列表和对应的节点标签，顺序必须一一对应
PROTOCOL_LIST=("VLESS + Reality Vision" "Hysteria2" "VLESS + Reality gRPC" "VLESS + WS" "VMess + WS" "Trojan + WS" "Shadowsocks + WS" "VLESS + XHTTP HTTP/1.1 CDN" "VLESS + XHTTP HTTP/2 Reality" "VLESS + XHTTP HTTP/3 Direct" "Trojan Direct" "Shadowsocks 2022 Direct")
NODE_TAG=(     "reality-vision"         "hysteria2" "reality-grpc"         "vless-ws"   "vmess-ws"   "trojan-ws"   "ss-ws"            "xhttp-h1.1-cdn"             "xhttp-h2-reality"             "xhttp-h3-direct"             "trojan-direct" "ss2022-direct")

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
FIREWALL_STATE_DIR="${WORK_DIR}/firewall"
SERVICE_FIREWALL_STATE_FILE="${FIREWALL_STATE_DIR}/service_ports.list"
TLS_SERVER='addons.mozilla.org'
START_PORT_DEFAULT='30000'  # WS/XHTTP 内部端口起始值，各协议在此基础上顺数
NGINX_PORT_DEFAULT='8080'   # Nginx 默认端口，可交互修改
CDN_DOMAIN=("skk.moe" "ip.sb" "time.is" "cfip.xxxxxxxx.tk" "bestcf.top" "cdn.2020111.xyz" "xn--b6gac.eu.org" "cf.090227.xyz")
SUBSCRIBE_TEMPLATE="https://raw.githubusercontent.com/fscarmen/client_template/main"
DEFAULT_XRAY_VERSION='26.7.28'
IS_SUB=${IS_SUB:-'no_sub'}  # IS_SUB:  根据菜单选项设置 (is_sub / no_sub)
IS_ARGO=${IS_ARGO:-'no_argo'}  # IS_ARGO: 根据是否安装 WS/XHTTP 协议自动推导 (is_argo / no_argo)

export DEBIAN_FRONTEND=noninteractive

cleanup_temp() {
  rm -rf "$TEMP_DIR"
}

trap cleanup_temp EXIT
trap 'cleanup_temp; echo -e '\''\n'\''; exit 1' INT QUIT TERM

mkdir -p "$TEMP_DIR"

E[0]="Language:\n 1. English (default) \n 2. 简体中文"
C[0]="${E[0]}"
E[1]="1. Pre-register a fresh WARP account during install with shared-key fallback; 2. [argox -d] Change WARP account with register / manual input; 3. Make Hysteria2 Realm and port hopping mutually exclusive with confirm prompts in install and [argox -d]"
C[1]="1. 安装期后台预注册 WARP 账户，失败回退共享密钥; 2. [argox -d] 菜单新增「更换 WARP 账户」，支持重新注册 / 手动输入; 3. Hysteria2 Realm 与端口跳跃互斥，安装与 [argox -d] 均先提示确认再切换"
E[2]="No network interfaces found."
C[2]="未找到网络接口"
E[3]="Input errors up to 5 times.The script is aborted."
C[3]="输入错误达5次,脚本退出"
E[4]="UUID should be 36 characters, please re-enter (\${a} times remaining): "
C[4]="UUID 应为36位字符,请重新输入 (剩余\${a}次): "
E[5]="The script supports Debian, Ubuntu, CentOS, Alpine, Armbian or Arch systems only. Feedback: [https://github.com/fscarmen/argox/issues]"
C[5]="本脚本只支持 Debian、Ubuntu、CentOS、Alpine、Armbian 或 Arch 系统，问题反馈:[https://github.com/fscarmen/argox/issues]"
E[6]="Port Hopping range (current: \${_val}) [leave blank to disable]"
C[6]="端口跳跃范围 (当前：\${_val}) [留空则禁用]"
E[7]="Install dependence-list:"
C[7]="安装依赖列表:"
E[8]="All dependencies already exist and do not need to be installed additionally."
C[8]="所有依赖已存在，不需要额外安装"
E[9]="To upgrade, press [y]. No upgrade by default:"
C[9]="升级请按 [y]，默认不升级:"
E[10]="Please enter Argo Domain (Default is temporary domain if left blank):"
C[10]="请输入 Argo 域名 (如果没有，可以跳过以使用 Argo 临时域名):"
E[11]="Please enter Argo Token, Argo Json or Cloudflare API\n\n [*] Token: Visit https://dash.cloudflare.com/ , Zero Trust > Networks > Connectors > Create a tunnel > Select Cloudflared\n\n [*] Json: Users can easily obtain it through the following website: https://fscarmen.cloudflare.now.cc\n\n [*] Cloudflare API: Visit https://dash.cloudflare.com/profile/api-tokens > Create Token > Create Custom Token > Add the following permissions:\n - Account > Cloudflare One Connectors: cloudflared > Edit\n - Zone > DNS > Edit\n\n - Account Resources: Include > Required Account\n - Zone Resources: Include > Specific zone > Argo Root Domain"
C[11]="请输入 Argo Token, Argo Json 或者 Cloudflare API\n\n [*] Token: 访问 https://dash.cloudflare.com/ ，Zero Trust > 网络 > 连接器 > 创建隧道 > 选择 Cloudflared\n\n [*] Json: 用户通过以下网站轻松获取: https://fscarmen.cloudflare.now.cc\n\n [*] Cloudflare API: 访问 https://dash.cloudflare.com/profile/api-tokens > 创建令牌 > 创建自定义令牌 > 添加以下权限:\n - 帐户 > Cloudflare One连接器: Cloudflared > 编辑\n - 区域 > DNS > 编辑\n\n - 帐户资源: 包括 > 所需账户\n - 区域资源: 包括 > 特定区域 > 所需域名"
E[12]="\${TOTAL_STEPS:+(\${STEP_NUM}/\${TOTAL_STEPS}) }Please enter Xray UUID (Default is \${UUID_DEFAULT}):"
C[12]="\${TOTAL_STEPS:+(\${STEP_NUM}/\${TOTAL_STEPS}) }请输入 Xray UUID (默认为 \${UUID_DEFAULT}):"
E[13]="Please enter Xray WS Path (Default is \${WS_PATH_DEFAULT}):"
C[13]="请输入 Xray WS 路径 (默认为 \${WS_PATH_DEFAULT}):"
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
E[34]="Install ArgoX script"
C[34]="安装 ArgoX 脚本"
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
E[42]="Please select or enter the preferred address (domain / IPv4 / [IPv6], optional :port), the default is \${CDN_DOMAIN[0]}:"
C[42]="请选择或者填入优选地址（域名 / IPv4 / [IPv6]，可选 :端口），默认为 \${CDN_DOMAIN[0]}:"
E[43]="\${APP} local version: \${LOCAL}.\\\t The newest version: \${ONLINE}"
C[43]="\${APP} 本地版本: \${LOCAL}.\\\t 最新版本: \${ONLINE}"
E[44]="No upgrade required."
C[44]="不需要升级"
E[45]="Bound interface updated to: "
C[45]="绑定接口已更新为: "
E[46]="Connect"
C[46]="连接"
E[47]="The script must be run as root, you can enter sudo -i and then download and run again. Feedback:[https://github.com/fscarmen/argox/issues]"
C[47]="必须以root方式运行脚本，可以输入 sudo -i 后重新下载运行，问题反馈:[https://github.com/fscarmen/argox/issues]"
E[48]="Downloading the latest version \${APP} failed, script exits. Feedback:[https://github.com/fscarmen/argox/issues]"
C[48]="下载最新版本 \${APP} 失败，脚本退出，问题反馈:[https://github.com/fscarmen/argox/issues]"
E[49]="\${TOTAL_STEPS:+(\${STEP_NUM}/\${TOTAL_STEPS}) }Please enter the node name. (Default is \${NODE_NAME_DEFAULT}):"
C[49]="\${TOTAL_STEPS:+(\${STEP_NUM}/\${TOTAL_STEPS}) }请输入节点名称 (默认为 \${NODE_NAME_DEFAULT}):"
E[50]="\${APP[*]} services are not enabled, node information cannot be output. Press [y] if you want to open."
C[50]="\${APP[*]} 服务未开启，不能输出节点信息。如需打开请按 [y]: "
E[51]="Install Sing-box multi-protocol scripts [https://github.com/fscarmen/sing-box]"
C[51]="安装 Sing-box 协议全家桶脚本 [https://github.com/fscarmen/sing-box]"
E[52]="Memory Usage"
C[52]="内存占用"
E[53]="The xray service is detected to be installed. Script exits."
C[53]="检测到已安装 xray 服务，脚本退出!"
E[54]="Warp / warp-go was detected to be running. Please enter the correct server address (IP or domain):"
C[54]="检测到 warp / warp-go 正在运行，请输入确认的服务器地址（IP 或域名）:"
E[55]="The script runs today: \${TODAY}. Total: \${TOTAL}"
C[55]="脚本当天运行次数: \${TODAY}，累计运行次数: \${TOTAL}"
E[56]="\${TOTAL_STEPS:+(\${STEP_NUM}/\${TOTAL_STEPS}) }Please enter the starting port for all protocols. Must be \${MIN_PORT}-\${MAX_PORT}, need \${NUM} consecutive free ports (Default: \${START_PORT_DEFAULT}):"
C[56]="\${TOTAL_STEPS:+(\${STEP_NUM}/\${TOTAL_STEPS}) }请输入所有协议的起始端口，必须是 \${MIN_PORT}-\${MAX_PORT}，需要 \${NUM} 个连续空闲端口(默认为 \${START_PORT_DEFAULT}):"
E[57]="Install sba scripts (argo + sing-box) [https://github.com/fscarmen/sba]"
C[57]="安装 sba 脚本 (argo + sing-box) [https://github.com/fscarmen/sba]"
E[58]="Xray config syntax check failed, details:"
C[58]="Xray 配置文件语法错误，详情："
E[59]="\${TOTAL_STEPS:+(\${STEP_NUM}/\${TOTAL_STEPS}) }Please enter server address, IP or domain (Default is: \${SERVER_IP_DEFAULT}):"
C[59]="\${TOTAL_STEPS:+(\${STEP_NUM}/\${TOTAL_STEPS}) }请输入服务器地址（IP 或域名）(默认为: \${SERVER_IP_DEFAULT}):"
E[60]="Please enter new value (press Enter to skip):"
C[60]="请输入新值 (回车跳过):"
E[61]="Port already in use:"
C[61]="端口已被占用:"
E[62]="Create shortcut [ argox ] successfully."
C[62]="创建快捷 [ argox ] 指令成功!"
E[63]="XHTTP Direct TLS certificate: \${WORK_DIR}/cert/cert.pem"
C[63]="XHTTP Direct TLS 证书: \${WORK_DIR}/cert/cert.pem"
E[64]="subscribe"
C[64]="订阅"
E[65]="To uninstall Nginx press [y], it is not uninstalled by default:"
C[65]="如要卸载 Nginx 请按 [y]，默认不卸载:"
E[66]="Adaptive Clash / V2rayN / NekoBox / ShadowRocket / SFI / SFA / SFM Clients"
C[66]="自适应 Clash / V2rayN / NekoBox / ShadowRocket / SFI / SFA / SFM 客户端"
E[67]="not set"
C[67]="未设置"
E[68]="\${TOTAL_STEPS:+(\${STEP_NUM}/\${TOTAL_STEPS}) }Nginx is used for subscription, QR code output, and WS/XHTTP protocol proxying. Please enter the port number, must be \${MIN_PORT}-\${MAX_PORT} (Default: \${NGINX_PORT_DEFAULT}):"
C[68]="\${TOTAL_STEPS:+(\${STEP_NUM}/\${TOTAL_STEPS}) }Nginx 用于订阅输出、二维码生成以及 WS/XHTTP 协议的反代分流，请输入端口号，必须是 \${MIN_PORT}-\${MAX_PORT}(默认为 \${NGINX_PORT_DEFAULT}):"
E[69]="1. Default (not specified)"
C[69]="1. 默认（不指定）"
E[70]="ArgoX is not installed and cannot change the CDN."
C[70]="ArgoX 未安装，不能更换 CDN"
E[71]="Port \$_p occupied by non-xray processes, force killing: \$_bad_pids"
C[71]="端口 \$_p 被非 Xray 进程占用，强制清理: \$_bad_pids"
E[72]="Please select or enter a new preferred address (domain / IPv4 / [IPv6], optional :port; press Enter to keep the current one):"
C[72]="请选择或输入新的优选地址（域名 / IPv4 / [IPv6]，可选 :端口；回车保持当前值）:"
E[73]="Please select network interface:"
C[73]="请选择网络接口:"
E[74]="Unable to access api.github.com. This may be due to IP restrictions (HTTP/1.1 403 Rate Limit Exceeded). Please try again later"
C[74]="无法访问 api.github.com，可能是由于 IP 限制导致的（HTTP/1.1 403 Rate Limit Exceeded），请稍后重试"
E[75]="Bind network interface  (current: \${_val:-default})"
C[75]="指定网络出口  (当前: \${_val:-默认})"
E[76]="Change node configuration (argox -d)"
C[76]="修改节点配置 (argox -d)"
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
E[94]="Xray hot reload failed, please check the error above."
C[94]="Xray 热更新失败，请检查上方错误信息"
E[95]="Add / Remove protocols (argox -r)"
C[95]="增加 / 删除协议 (argox -r)"
E[96]="Keep protocols"
C[96]="保留协议"
E[97]="Add protocols"
C[97]="新增协议"
E[98]="Please enter the Reality privateKey, skip to generate randomly (Default is random):"
C[98]="请输入 Reality 的密钥(privateKey)，跳过则随机生成 (默认为随机生成):"
E[99]="Invalid Reality privateKey, generating randomly..."
C[99]="Reality 私钥无效，随机生成中..."
E[100]="a. all (default)"
C[100]="a. 全部（默认）"
E[101]="${PROTOCOL_LIST[7]} (Temporary tunnel NOT supported)"
C[101]="${PROTOCOL_LIST[7]}（临时隧道不支持）"
E[102]="Cannot get quicktunnel domain."
C[102]="获取临时隧道域名失败"
E[103]="No change was made."
C[103]="未做任何修改"
E[104]="Port Hopping: ISPs sometimes block or throttle persistent UDP on a single port. Port hopping works around this by forwarding a range of ports to the Hysteria2 listen port via iptables NAT.\n Tip1: Recommended ~1000 ports, min: \$MIN_HOPPING_PORT, max: \$MAX_HOPPING_PORT.\n Tip2: NAT machines have very few open ports (20-30); use with caution.\n Leave blank to disable."
C[104]="端口跳跃介绍：运营商有时会阻断或限速单个 UDP 端口的持续连接，端口跳跃通过 iptables NAT 将端口段转发到 Hysteria2 监听端口来解决这个问题。\n Tip1: 推荐约 1000 个端口，最小值：\$MIN_HOPPING_PORT，最大值：\$MAX_HOPPING_PORT。\n Tip2: NAT 机器可开放端口很少（20-30 个），请谨慎使用。\n 留空则禁用该功能。"
E[105]="Enter port range for Hysteria2 port hopping (e.g. 50000:51000). Leave blank to disable:"
C[105]="请输入 Hysteria2 端口跳跃范围（如 50000:51000），留空禁用:"
E[106]="Please select what to modify:"
C[106]="请选择修改项目:"
E[107]="Preferred address (current: \${_val})"
C[107]="优选地址 (当前：\${_val})"
E[108]="SNI / TLS domain (current: \${_val})"
C[108]="SNI / TLS 域名 (当前：\${_val})"
E[109]="Node name (current: \${_val})"
C[109]="节点名称 (当前：\${_val})"
E[110]="UUID / Password (current: \${_val})"
C[110]="UUID / 密码 (当前：\${_val})"
E[111]="Server address (current: \${_val})"
C[111]="服务器地址 (当前：\${_val})"
E[112]="Invalid server address (IPv4 / IPv6 / domain)"
C[112]="服务器地址格式错误（IPv4 / IPv6 / 域名）"
E[113]="(VLESS + XHTTP not supported)"
C[113]="（不支持 VLESS + XHTTP）"
E[114]="Port range out of bounds. Start must be \${MIN_HOPPING_PORT}–\${MAX_HOPPING_PORT}, end must be \${MIN_HOPPING_PORT}–\${MAX_HOPPING_PORT}, and start < end."
C[114]="端口范围超界。起始端口必须在 \${MIN_HOPPING_PORT}–\${MAX_HOPPING_PORT} 之间，结束端口同理，且起始 < 结束。"
E[115]="UFW was detected. Firewall rules will be managed by UFW, and iptables / netfilter-persistent will not be installed."
C[115]="检测到 UFW。防火墙规则将由 UFW 管理，不再安装 iptables / netfilter-persistent"
E[116]="UFW is not active. Firewall rules were written, but you should manually enable UFW to make sure the policy is applied."
C[116]="UFW 未处于激活状态。防火墙规则已写入，但建议手动启用 UFW 以确保策略生效"
E[117]="Failed to update UFW firewall rules. Please check UFW configuration files manually."
C[117]="更新 UFW 防火墙规则失败，请手动检查 UFW 配置文件"
E[118]="Invalid preferred address format. Please enter a domain, IPv4, or [IPv6], optionally with :port."
C[118]="优选地址格式错误。请输入域名、IPv4 或 [IPv6]，并可选附带 :端口。"
E[119]="xray listen ports  (current: \${_val})"
C[119]="xray 监听端口  (当前：\${_val})"
E[120]="Hysteria2 bandwidth  (current: up \${HY2_UP_NOW} Mbps, down \${HY2_DOWN_NOW} Mbps)"
C[120]="Hysteria2 带宽  (当前: 上行 \${HY2_UP_NOW} Mbps, 下行 \${HY2_DOWN_NOW} Mbps)"
E[121]="Please enter Hysteria2 client upload speed in Mbps (e.g. 200):"
C[121]="请输入 Hysteria2 客户端上行速率 Mbps（纯数字，如 200）:"
E[122]="Please enter Hysteria2 client download speed in Mbps (e.g. 1000):"
C[122]="请输入 Hysteria2 客户端下行速率 Mbps（纯数字，如 1000）:"
E[123]="Invalid input, please enter a positive integer."
C[123]="输入无效，请输入正整数。"
E[124]="The order of the selected protocols and ports is as follows:"
C[124]="选择的协议及端口次序如下:"
E[125]="Hysteria2 Realm is suitable for NAT VPS or machines without public inbound. It is NOT recommended when the machine has a public IP. Enable? [y/N] (default N):"
C[125]="Hysteria2 Realm 适用于回国或者没有公网入口的机器；有公网入口时不建议使用。是否启用？[y/N] (默认为 N):"
E[126]="Hysteria2 WARP-assisted hole punching (for strict NAT environments). Enable? [y/N] (default N):"
C[126]="Hysteria2 WARP 辅助打洞（适用于 NAT 严格环境）。是否启用？[y/N] (默认为 N):"
E[127]="Close Realm"
C[127]="关闭 Realm"
E[128]="Hot reload successful via Xray API"
C[128]="Xray API 热加载成功"
E[129]="Open Realm"
C[129]="开启 Realm"
E[130]="No change was made."
C[130]="未做任何修改"
E[131]="Custom warp outbound routing rules  (rules: \${CUSTOM_ROUTE_COUNT:-0})"
C[131]="自定义 warp 出站路由规则  (规则数: \${CUSTOM_ROUTE_COUNT:-0})"
E[132]="1. Add rule\n 2. View rules\n 3. Delete rule\n 0. Back"
C[132]="1. 添加规则\n 2. 查看规则\n 3. 删除规则\n 0. 返回"
E[133]="Select rule type:\n 1. domain (domain suffix match)\n 2. geosite (site category)"
C[133]="选择规则类型:\n 1. domain (域名匹配)\n 2. geosite (站点分类)"
E[134]="Enter domain suffix (separators: , 、 ; or |, e.g. google.com,telegram.org):"
C[134]="输入域名后缀（分隔：, 、 ; 或 |，如 google.com,telegram.org）:"
E[135]="Enter geosite name (separators: , 、 ; or |, e.g. google,telegram):"
C[135]="输入 geosite 分类名称（分隔：, 、 ; 或 |，如 google,telegram）:"
E[136]="Select outbound:\n 1. warp-IPv4\n 2. warp-IPv6"
C[136]="选择出站:\n 1. warp-IPv4\n 2. warp-IPv6"
E[137]="Custom route rule added successfully."
C[137]="自定义路由规则添加成功。"
E[138]="No custom route rules configured."
C[138]="未配置自定义路由规则。"
E[139]="Enter rule number(s) to delete (separators: , 、 ; or |; range: 2-4, e.g. 1,3,5 or 2-4):"
C[139]="输入要删除的规则编号（分隔：, 、 ; 或 |；范围：2-4，如 1,3,5 或 2-4）:"
E[140]="Custom route rule(s) deleted."
C[140]="自定义路由规则已删除。"
E[141]="Invalid domain format."
C[141]="无效的域名格式"
E[142]="Current custom route rules:"
C[142]="当前自定义路由规则:"
E[143]="Client Fingerprint  (current: \${_val})"
C[143]="客户端指纹  (当前: \${_val})"
E[144]="Please select or input client fingerprint:\n 1. chrome (default)\n 2. firefox\n Or input custom value:"
C[144]="请选择或输入客户端指纹:\n 1. chrome (默认)\n 2. firefox\n 或直接输入自定义值:"
E[145]="Invalid fingerprint format."
C[145]="无效的指纹格式"
E[146]="Install ArgoX script + subscription"
C[146]="安装 ArgoX 脚本 + 订阅"
E[147]="All WS/XHTTP protocols have been removed, Argo tunnel service has been stopped and cleaned up."
C[147]="已移除所有 WS/XHTTP 协议，Argo 隧道服务已停止并清理。"
E[148]="Installing nginx in the background..."
C[148]="正在后台安装 nginx..."
E[149]="Enable subscription"
C[149]="开启订阅"
E[150]="Disable subscription"
C[150]="关闭订阅"
E[151]="Xray API unavailable, downgrading to restart Xray"
C[151]="Xray API 不可用，降级为重启 Xray"
E[152]="API batch delete inbounds failed, some may not exist"
C[152]="API 批量删除入站失败，可能是部分不存在"
E[153]="API batch add inbounds failed"
C[153]="API 批量添加入站失败"
E[154]="API add outbound failed: \${_tag}"
C[154]="API 添加出站失败: \${_tag}"
E[155]="API replace routing rules failed"
C[155]="API 替换路由规则失败"
E[156]="Routing rules file is empty"
C[156]="路由规则文件为空"
E[157]="Port modification mode:\n 1. Modify start port (protocols occupy sequential ports, default)\n 2. Set an independent port for each protocol"
C[157]="端口修改方式:\n 1. 修改开始端口（各协议按顺序占用，默认）\n 2. 修改为各协议独立端口"
E[158]="Select the protocols whose ports to change (multi-select, e.g. bcf; asked in the same order as typed; blank = nothing to change):\n a. all (default)"
C[158]="多选需要修改端口的协议（如 bcf，询问顺序与输入顺序一致，留空表示不修改）:\n a. all (默认)"
E[159]="Enter the new port for \${PROTO} (current: \${PORT}, leave blank to keep):"
C[159]="请输入「\${PROTO}」的新端口 (当前: \${PORT}，留空保持不变):"
E[160]="Listening ports (current: \${PORTS})"
C[160]="监听端口 (当前: \${PORTS})"
E[161]="Ports unchanged, nothing to modify."
C[161]="端口未变化，未做任何修改。"
E[162]="Port \${PORT} is occupied by another protocol or service."
C[162]="端口 \${PORT} 已被其他协议或服务占用。"
E[163]="Port change preview:"
C[163]="端口变更预览:"
E[164]="Apply the changes [y/N] (default N):"
C[164]="是否应用以上修改 [y/N] (默认为 N):"
E[165]="\${PROTO}: \${OLD} -> \${NEW}"
C[165]="\${PROTO}: \${OLD} -> \${NEW}"
E[166]="Ports updated and hot-reloaded."
C[166]="端口已更新并已热加载。"
E[167]="Port \${PORT} is already in use by \${PROTO}."
C[167]="端口 \${PORT} 已被 \${PROTO} 使用。"
E[168]="\${LETTER}. \${PROTO} (\${PORT})"
C[168]="\${LETTER}. \${PROTO} (\${PORT})"
E[169]="Start port \${OLD_START} -> \${NEW_START}: \${NUM} protocol ports will become \${NEW_START} - \${NEW_END}."
C[169]="起始端口 \${OLD_START} -> \${NEW_START}: \${NUM} 个协议端口将变为 \${NEW_START} - \${NEW_END}。"
E[170]="Change WARP account"
C[170]="更换 WARP 账户"
E[171]="Select WARP account operation:\n 1. Register a new free account\n 2. Enter account info manually\n 0. Back"
C[171]="请选择 WARP 账户操作:\n 1. 重新注册免费账户\n 2. 手动输入信息\n 0. 返回"
E[172]="New account registration failed. Please try again later. The existing account is kept."
C[172]="注册新账户失败，请稍后再试。已保留原有账户。"
E[173]="Enter the WARP IPv6 address:"
C[173]="请输入 WARP IPv6 地址:"
E[174]="Enter the WARP private key:"
C[174]="请输入 WARP Private Key:"
E[175]="Enter WARP reserved values (format: 123,456,789):"
C[175]="请输入 WARP reserved 保留值（格式: 123,456,789）:"
E[176]="Invalid reserved format. Please enter 3 numbers like 123,456,789"
C[176]="reserved 格式错误，请输入 3 个数字，如 123,456,789"
E[177]="Checking configuration..."
C[177]="正在校验配置..."
E[178]="Change WARP endpoint"
C[178]="更换 warp endpoint"
E[179]="Invalid private key format. Please enter a 43-character base64 key ending with \"=\"."
C[179]="Private Key 格式错误，请输入 43 位 base64 密钥且以 \"=\" 结尾"
E[180]="Invalid IPv6 address format."
C[180]="IPv6 地址格式错误"
E[181]="New WARP endpoint:\n IPv6: \${ADDRESS6}\n Private Key: \${PRIVATE_KEY}\n Reserved: [\${R1}, \${R2}, \${R3}]"
C[181]="新 WARP 端点:\n IPv6: \${ADDRESS6}\n Private Key: \${PRIVATE_KEY}\n Reserved: [\${R1}, \${R2}, \${R3}]"
E[182]="Hysteria2 Realm and port hopping cannot be used together (choose one). Realm is for NAT VPS without public inbound access. If you enable Realm, port hopping will be skipped."
C[182]="Hysteria2 Realm 与端口跳跃不能同时使用（二选一）。Realm 适用于没有公网入站的 NAT 机器；启用 Realm 后将跳过端口跳跃。"
E[183]="Port hopping is enabled. Enabling Realm will disable port hopping. Continue? [y/N] (default N):"
C[183]="端口跳跃已开启，启用 Realm 将关闭端口跳跃。是否继续？[y/N]（默认 N）:"
E[184]="Realm is enabled. Enabling port hopping will disable Realm. Continue? [y/N] (default N):"
C[184]="Realm 已开启，启用端口跳跃将关闭 Realm。是否继续？[y/N]（默认 N）:"

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

# 校验服务器地址：IPv4 / IPv6 / 域名（域名须含至少一个点，NAT 场景可用 DDNS 域名）
is_valid_server_addr() {
  local _ADDR="$1"
  [[ "$_ADDR" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] && return 0
  [[ "$_ADDR" =~ ^[0-9a-fA-F:]+$ && "$_ADDR" =~ : ]] && return 0
  [[ "$_ADDR" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$ ]] && return 0
  return 1
}

# 查找空闲端口（复用 refresh_port_snapshot + is_port_in_use）
find_free_port() {
  local min=${1:-10000} max=${2:-65535} port
  refresh_port_snapshot
  while true; do
    port=$((RANDOM % (max - min + 1) + min))
    is_port_in_use "$port" || { echo "$port"; return 0; }
  done
}

# 检测是否启用 Github CDN
check_cdn() {
  local PROXY CODE PID CMD
  local _WAIT_COUNT=120
  local PIDS=()
  local RAW_URL='https://raw.githubusercontent.com/fscarmen/argox/main/argox.sh'

  # 确定下载工具：优先 wget，次选 curl
  if command -v wget >/dev/null 2>&1; then
    CMD='wget'
  elif command -v curl >/dev/null 2>&1; then
    CMD='curl'
  else
    GH_PROXY=''
    return
  fi

  # 获取 HTTP 状态码（HEAD 探测：只取响应头，不下载 body；--tries=1 避免被墙时 wget 默认 20 次重试放大延迟）
  get_code() {
    local url=$1
    if [ "$CMD" = 'wget' ]; then
      wget -q --spider --tries=1 -T5 -O /dev/null --server-response "$url" 2>&1 | awk '/HTTP\//{code=$2} END{print code}'
    else
      curl -skL -I --connect-timeout 3 --max-time 5 -o /dev/null -w '%{http_code}' "$url"
    fi
  }

  # 直连检测
  CODE=$(get_code "$RAW_URL")
  if [ "$CODE" = '200' ]; then
    GH_PROXY=''
    return
  fi

  # 并发探测代理
  for PROXY in "${GITHUB_PROXY[@]}"; do
    {
      CODE=$(get_code "${PROXY}${RAW_URL}")
      [ "$CODE" = '200' ] && [ ! -e "${TEMP_DIR}/cdn_proxy" ] && printf '%s' "$PROXY" > "${TEMP_DIR}/cdn_proxy"
    } &
    PIDS+=("$!")
  done

  # 等待探测结果或超时
  while [ ! -e "${TEMP_DIR}/cdn_proxy" ] && [ "$_WAIT_COUNT" -gt 0 ]; do
    sleep 0.05
    (( _WAIT_COUNT-- )) || true
  done

  [ -e "${TEMP_DIR}/cdn_proxy" ] && GH_PROXY=$(cat "${TEMP_DIR}/cdn_proxy") || GH_PROXY=''

  # 清理后台任务和临时文件
  for PID in "${PIDS[@]}"; do kill "$PID" >/dev/null 2>&1 || true; done
  for PID in "${PIDS[@]}"; do wait "$PID" 2>/dev/null || true; done
  rm -f "${TEMP_DIR}/cdn_proxy"
}

# 检测是否解锁 chatGPT，以决定是否使用 warp 链式代理或者是 direct out，此处判断改编自 https://github.com/lmc999/RegionRestrictionCheck
check_chatgpt() {
  local CHECK_STACK=$1
  local UA_BROWSER="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"
  local UA_SEC_CH_UA='"Google Chrome";v="125", "Chromium";v="125", "Not.A/Brand";v="24"'
  wget --help | grep -q -- '--ciphers' && local IS_CIPHERS=is_ciphers

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
    { wget --no-check-certificate -qO- --timeout=3 "https://stat.cloudflare.now.cc/updateStats?script=${SCRIPT}" > $TEMP_DIR/statistics 2>/dev/null || true; }&
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

# ============================================================
# _should_use_supervise_daemon() - 判断 Alpine OpenRC 是否启用 supervise-daemon
#
# 根据环境兼容性选择服务管理方式：
#   - 容器环境且支持 supervise-daemon 时启用，以获得自动 respawn 和更可靠的进程管理。
#   - 其他环境保持 command_background 模式，确保旧版本兼容和稳定运行。
#
# 返回值: echo "yes" / "no"
# ============================================================
_should_use_supervise_daemon() {
  # ---- 前置条件硬校验：任何一条不满足直接 no，比「强制全用」安全得多 ----
  # 1) 必须是 Alpine
  [ "$SYSTEM" != 'Alpine' ] && { echo no; return; }
  # 2) supervise-daemon 二进制真实存在（精简 openrc 包可能被 strip 掉）
  if ! command -v supervise-daemon >/dev/null 2>&1 && [ ! -x /sbin/supervise-daemon ] && [ ! -x /usr/sbin/supervise-daemon ]; then
    echo no; return
  fi
  # 3) openrc 版本 >= 0.43（supervise-daemon 首次被引入到 openrc 主线）
  local _openrc_ver=""
  if command -v openrc >/dev/null 2>&1; then
    _openrc_ver=$(openrc --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -n1)
  fi
  [ -z "$_openrc_ver" ] && [ -s /etc/os-release ] && \
    _openrc_ver=$(awk -F'["=]' '/^VERSION_ID=/{gsub(/[^0-9.]/,"",$2); print $2}' /etc/os-release 2>/dev/null)
  if [ -n "$_openrc_ver" ]; then
    # 主版本 < 0 或者 (主==0 && 次<43) → no
    local _maj="${_openrc_ver%%.*}" _min="${_openrc_ver#*.}"
    _min="${_min%%.*}"
    if [ "$_maj" -lt 1 ] 2>/dev/null; then
      if [ "${_min:-0}" -lt 43 ] 2>/dev/null; then
        echo no; return
      fi
    fi
  fi

  # ---- 容器检测（命中任意一条即 yes）----
  local _lxc_env="" _cgroup=""
  [ -r /proc/1/environ ]    && _lxc_env+=" $(tr '\0' '\n' </proc/1/environ 2>/dev/null | tr '\n' ' ')"
  [ -r /proc/self/environ ] && _lxc_env+=" $(tr '\0' '\n' </proc/self/environ 2>/dev/null | tr '\n' ' ')"
  [ -r /proc/1/cgroup ]     && _cgroup="$(cat /proc/1/cgroup 2>/dev/null)"

  # 1) 容器环境变量（container= 是 systemd / LXC / Docker / podman 约定）
  case " $_lxc_env " in
    *"container=lxc"*|*"container=docker"*|*"container=podman"*|*"container=systemd-nspawn"*|*"container=libvirt-lxc"*)
      echo yes; return ;;
  esac

  # 2) cgroupv1/v2 路径线索（比只看 /proc/1/cgroup 里的 lxc/docker 关键字更宽）
  if echo "$_cgroup" | grep -Eq 'lxc|docker|kubepods|containerd|podman|systemd\.nspawn|libpod'; then
    echo yes; return
  fi

  # 3) systemd-detect-virt（如果系统里凑巧有）
  if command -v systemd-detect-virt >/dev/null 2>&1; then
    case "$(systemd-detect-virt 2>/dev/null)" in
      lxc|systemd-nspawn|docker|podman|container|wsl) echo yes; return ;;
    esac
  fi

  # 4) machinectl 可见的容器（systemd-nspawn / LXC 通过 machined 注册）
  if command -v machinectl >/dev/null 2>&1; then
    local _self_mid=""
    _self_mid=$(cat /proc/self/mountinfo 2>/dev/null | awk '/machine-id/{print $NF; exit}')
    if [ -n "$_self_mid" ] && machinectl list --no-legend 2>/dev/null | awk '{print $1}' | grep -qF "$_self_mid"; then
      echo yes; return
    fi
  fi

  # 5) PID namespace 非初始 ns：KVM/物理机通常 ns 号最小，容器都 > 初始 ns。这是一个弱信号，
  #    仅当 /proc/1/ns/pid 符号链接目标不为 4026531836（init ns 固定号）时提示容器。
  if [ -L /proc/self/ns/pid ]; then
    local _pidns_link
    _pidns_link=$(readlink /proc/self/ns/pid 2>/dev/null)
    if [ -n "$_pidns_link" ] && [ "$_pidns_link" != "pid:[4026531836]" ]; then
      # 命中 pid ns 非 init，但这一条太泛（Chrome sandbox / firejail / flatpak 也会命中），
      # 只在同时发现 /dev/.lxc / .dockerenv 等容器指纹文件时才判 yes
      if [ -f /.dockerenv ] || [ -d /dev/.lxc ] || [ -f /run/.containerenv ]; then
        echo yes; return
      fi
    fi
  fi

  echo no
}

# ============================================================
# write_argo_daemon() - 统一写入 Argo / cloudflared 守护进程文件
#   依赖调用方作用域的变量: $SYSTEM $WORK_DIR $ARGO_RUNS $ARGO_DAEMON_FILE
#   自动处理 Alpine OpenRC vs 其他 systemd，OpenRC 模板仅此一份
# ============================================================
write_argo_daemon() {
  if [ "$SYSTEM" = 'Alpine' ]; then
    local COMMAND=${ARGO_RUNS%% --*}
    local ARGS=${ARGO_RUNS#$COMMAND }
    local _USE_SD="no"
    [ "$(_should_use_supervise_daemon)" = 'yes' ] && _USE_SD="yes"

    cat > ${ARGO_DAEMON_FILE} << EOF
#!/sbin/openrc-run

name="argo"
description="Cloudflare Tunnel"

command="${COMMAND}"
command_args="${ARGS}"

pidfile="/run/\${RC_SVCNAME}.pid"
EOF
    if [ "$_USE_SD" = 'yes' ]; then
      # 容器环境：让 openrc 自带的 supervise-daemon 托管进程，比 start-stop-daemon --background 拿 pid 更准
      cat >> ${ARGO_DAEMON_FILE} << EOF
supervisor="supervise-daemon"
respawn_max=10
respawn_period=10
EOF
    else
      cat >> ${ARGO_DAEMON_FILE} << EOF
command_background="yes"
EOF
    fi
    cat >> ${ARGO_DAEMON_FILE} << EOF

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
  else
    local ARGO_SERVER="[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
Type=simple
NoNewPrivileges=yes
TimeoutStartSec=0
ExecStart=$ARGO_RUNS
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target"
    echo "$ARGO_SERVER" > ${ARGO_DAEMON_FILE}
  fi
}

# ============================================================
# write_xray_daemon() - 统一写入 Xray 守护进程文件
#   依赖调用方作用域的变量: $SYSTEM $WORK_DIR $INSTALL_NGINX $XRAY_DAEMON_FILE
#   OpenRC 模板仅此一份，通过 start_pre 处理 nginx；systemd 按 $INSTALL_NGINX 写 ExecStartPre
# ============================================================
write_xray_daemon() {
  if [ "$SYSTEM" = 'Alpine' ]; then
    local _USE_SD="no"
    [ "$(_should_use_supervise_daemon)" = 'yes' ] && _USE_SD="yes"

    cat > ${XRAY_DAEMON_FILE} << EOF
#!/sbin/openrc-run

name="xray"
description="Xray Service"

command="${WORK_DIR}/xray"
command_args="run -c ${WORK_DIR}/inbound.json -c ${WORK_DIR}/outbound.json"

pidfile="/run/\${RC_SVCNAME}.pid"
EOF
    if [ "$_USE_SD" = 'yes' ]; then
      cat >> ${XRAY_DAEMON_FILE} << EOF
supervisor="supervise-daemon"
respawn_max=10
respawn_period=10
EOF
    else
      cat >> ${XRAY_DAEMON_FILE} << EOF
command_background="yes"
EOF
    fi
    cat >> ${XRAY_DAEMON_FILE} << EOF

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
        XRAY_PIDS="\$(ps -eo pid,args | awk -v work_dir="$WORK_DIR" '\$0~(work_dir"/xray run"){print \$1;exit}')"
        if [ -n "\$XRAY_PIDS" ]; then
            for pid in \$XRAY_PIDS; do
                kill -9 "\$pid" 2>/dev/null
            done
        fi
    fi
    if [ -s ${WORK_DIR}/nginx.conf ] && command -v /usr/sbin/nginx >/dev/null 2>&1; then
        local NGINX_MASTER
        NGINX_MASTER="\$(ps -eo pid,args | awk -v d='${WORK_DIR}' '\$0~(d\"/nginx.conf\") && /nginx: master process/{print \$1;exit}')"
        if [ -n "\$NGINX_MASTER" ]; then
            kill -QUIT \$NGINX_MASTER 2>/dev/null
            sleep 1
            kill -9 \$NGINX_MASTER 2>/dev/null || true
        fi
    fi
    rm -f "\$pidfile"
    eend 0
}
EOF
    chmod +x ${XRAY_DAEMON_FILE}
  else
    local XRAY_SERVICE="[Unit]
Description=Xray Service
Documentation=https://github.com/XTLS/Xray-core
After=network.target

[Service]
User=root"
    [[ "$INSTALL_NGINX" != 'n' ]] && XRAY_SERVICE+="
ExecStartPre=/bin/bash -c 'nginx -c $WORK_DIR/nginx.conf -s reload 2>/dev/null || nginx -c $WORK_DIR/nginx.conf'"
    XRAY_SERVICE+="
ExecStart=$WORK_DIR/xray run -c $WORK_DIR/inbound.json -c $WORK_DIR/outbound.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target"
    echo "$XRAY_SERVICE" > ${XRAY_DAEMON_FILE}
  fi
}

# ============================================================
# api_hot_reload() - 统一的 Xray API 热更新入口
# 用法:
#   api_hot_reload inbounds [tag...]       # 增量更新入站（可指定强制更新的 tag）
#   api_hot_reload outbound <tag> [force]  # 热更新单个出站；force 时无条件 rmo + ado（适用于密钥类字段变更）
#   api_hot_reload custom_routes           # 全量替换路由规则（来自 outbound.json）
#   api_hot_reload routing_rules [file]    # 全量替换路由规则（备选）
# ============================================================
api_hot_reload() {
  local action="$1" _tag="$2"
  local _ib="$WORK_DIR/inbound.json" _ob="$WORK_DIR/outbound.json"
  local _tmp_dir="$TEMP_DIR/api_hot_reload"
  local _ret=0 _api_port _api_addr

  # API 端口完全以配置文件 inbound.json 的 api.listen 为准（custom 不再保存该字段）
  _api_port=$(grep -v '^//' "$_ib" | $WORK_DIR/jq -r '.api.listen // empty' 2>/dev/null | awk -F: '{print $2}')
  _api_addr="127.0.0.1:${_api_port}"

  # ---- 前置校验：所有操作都需要 API 可用 ----
  if ! $WORK_DIR/xray api lsi --server="$_api_addr" --isOnlyTags=true &>/dev/null; then
    # 配置文件端口与运行中 xray 实际端口不一致时（如之前热更/重启失败留下错位），
    # 逐个探测 xray 监听在 127.0.0.1 的端口，直到 API 响应，避免 API 永久失联
    local _lp
    for _lp in $(ss -tlnp 2>/dev/null | grep '"xray"' | grep -oE '127\.0\.0\.1:[0-9]+' | awk -F: '{print $2}' | sort -un); do
      if $WORK_DIR/xray api lsi --server="127.0.0.1:${_lp}" --isOnlyTags=true &>/dev/null; then
        _api_addr="127.0.0.1:${_lp}"
        _api_port="$_lp"
        break
      fi
    done
    $WORK_DIR/xray api lsi --server="$_api_addr" --isOnlyTags=true &>/dev/null || {
      # 失败时 3 行分类兜底，避免一律 restart 掩盖根本原因
      # 1) 配置语法错误：先 xray -test 打出具体错，不盲目重启
      # 2) 端口占用：逐个找 inbound 监听端口冲突的旧进程，清掉再启动
      # 3) 其它（进程未起、权限、cgroup 等）→ 走标准 restart
      warning "\n $(text 151) "

      local _cfg_ok=true
      if [ -x "$WORK_DIR/xray" ] && [ -s "$_ib" ] && [ -s "$_ob" ]; then
        # xray 的 -test 错误输出到 stdout，必须一并捕获，否则报错被吞掉
        if ! $WORK_DIR/xray run -test -c "$_ib" -c "$_ob" >"$TEMP_DIR/xray_test.err" 2>&1; then
          _cfg_ok=false
          warning " $(text 58) "
          head -n 30 "$TEMP_DIR/xray_test.err" >&2 || true
        fi
      fi

      # 端口占用扫描：读取 inbound.json 的所有 listen port，逐个查冲突
      local _killed_any=false
      if [ -s "$_ib" ] && [ -x "$WORK_DIR/jq" ]; then
        local _ports
        _ports=$($WORK_DIR/jq -r '.inbounds[] | select(.port != null) | .port' "$_ib" 2>/dev/null)
        if command -v ss >/dev/null 2>&1; then
          local _ss_tool="ss -nltp"
        elif command -v netstat >/dev/null 2>&1; then
          local _ss_tool="netstat -nltp"
        else
          local _ss_tool=""
        fi
        if [ -n "$_ports" ] && [ -n "$_ss_tool" ]; then
          local _p
          while IFS= read -r _p; do
            [ -z "$_p" ] && continue
            # 找监听该端口且不是 xray 的进程 PID
            local _bad_pids
            _bad_pids=$(eval "$_ss_tool" 2>/dev/null \
              | awk -v p=":$_p" '$4 ~ p && $0 ~ /pid=/ {print $0}' \
              | tr ',' '\n' \
              | awk -F= '/^pid=/ {print $2}' \
              | sort -u \
              | while read -r _pid; do
                  [ -z "$_pid" ] && continue
                  local _cmd
                  _cmd=$(ps -p "$_pid" -o args= 2>/dev/null || true)
                  case "$_cmd" in
                    *"$WORK_DIR/xray"*) ;;
                    *) echo "$_pid" ;;
                  esac
                done)
            if [ -n "$_bad_pids" ]; then
              warning " $(text 71) "
              kill -9 $_bad_pids 2>/dev/null || true
              _killed_any=true
            fi
          done <<< "$_ports"
        fi
      fi

      if [ "$_cfg_ok" = 'true' ]; then
        # 清掉端口占用的进程时，先 stop 再 start 比 restart 更稳
        if [ "$_killed_any" = 'true' ]; then
          cmd_systemctl disable xray 2>/dev/null || true
          sleep 1
        fi
        if cmd_systemctl enable xray 2>/dev/null || cmd_systemctl restart xray 2>/dev/null; then
          return 0
        fi
      fi
      return 1
    }
  fi

  case "$action" in

  # ========== 全量替换所有入站 ==========
  inbounds)
    local _live_tags=() _config_tags=() _tags_to_delete=() _tags_to_add=() _files_to_add=()
    local _count _i _tag _f

    # 1. 获取当前所有运行中的入站 Tag（排除 "api"）
    local _raw_tags _tag_line
    _raw_tags=$($WORK_DIR/xray api lsi --server="$_api_addr" --isOnlyTags=true 2>/dev/null)
    if echo "$_raw_tags" | $WORK_DIR/jq -e '.' &>/dev/null 2>&1; then
      while IFS= read -r _tag_line; do
        [ -n "$_tag_line" ] && [ "$_tag_line" != "api" ] && _live_tags+=("$_tag_line")
      done < <(echo "$_raw_tags" | $WORK_DIR/jq -r '.inbounds[].tag' 2>/dev/null)
    else
      while IFS= read -r _tag_line; do
        _tag_line="${_tag_line%\"}"
        _tag_line="${_tag_line#\"}"
        [ -n "$_tag_line" ] && [ "$_tag_line" != "api" ] && _live_tags+=("$_tag_line")
      done <<< "$_raw_tags"
    fi

    # 2. 读取 inbound.json 提取每个 inbound 到临时文件
    rm -rf "$_tmp_dir" && mkdir -p "$_tmp_dir"
    _count=$(grep -v '^//' "$_ib" | $WORK_DIR/jq -r '.inbounds | length' 2>/dev/null)
    for ((_i=0; _i<_count; _i++)); do
      local _cfg_tag
      _cfg_tag=$(grep -v '^//' "$_ib" | $WORK_DIR/jq -r ".inbounds[$_i].tag" 2>/dev/null)
      [ -n "$_cfg_tag" ] && _config_tags+=("$_cfg_tag")

      grep -v '^//' "$_ib" | $WORK_DIR/jq -c "{inbounds: [.inbounds[$_i]]}" > "$_tmp_dir/inbound_$_i.json" 2>/dev/null
    done

    # 3. 如果我们调用时带了额外的 tag（要强制更新的），加入待删除
    local _force_tags
    shift  # 去掉 $1(inbounds)，保留后续 force tags
    _force_tags=("$@")

    # 4. 计算差异 (增量策略)
    # _tags_to_delete: 存在于 live 但不在 config，或者在 _force_tags 中
    for _ltag in "${_live_tags[@]}"; do
      local _found=0
      for _ctag in "${_config_tags[@]}"; do
        if [ "$_ltag" = "$_ctag" ]; then
          _found=1
          break
        fi
      done

      # 检查是否强制更新
      for _ftag in "${_force_tags[@]}"; do
        if [ "$_ltag" = "$_ftag" ]; then
          _found=0 # 假装没在 config 里，以便强制 rmi
        fi
      done

      if [ $_found -eq 0 ]; then
        _tags_to_delete+=("$_ltag")
      fi
    done

    # _tags_to_add: 存在于 config 但不在 live，或者需要强制更新的
    for ((_i=0; _i<_count; _i++)); do
      local _ctag="${_config_tags[$_i]}"
      local _found=0
      for _ltag in "${_live_tags[@]}"; do
        if [ "$_ctag" = "$_ltag" ]; then
          _found=1
          break
        fi
      done

      for _ftag in "${_force_tags[@]}"; do
        if [ "$_ctag" = "$_ftag" ]; then
           _found=0 # 强制加入
        fi
      done

      if [ $_found -eq 0 ]; then
        _tags_to_add+=("$_ctag")
        _files_to_add+=("$_tmp_dir/inbound_$_i.json")
      fi
    done

    # 5. 批量执行 rmi
    if [ "${#_tags_to_delete[@]}" -gt 0 ]; then
      $WORK_DIR/xray api rmi --server="$_api_addr" "${_tags_to_delete[@]}" &>/dev/null || {
        warning " $(text 152) "
      }
    fi

    # 6. 批量执行 adi
    if [ "${#_files_to_add[@]}" -gt 0 ]; then
      $WORK_DIR/xray api adi --server="$_api_addr" "${_files_to_add[@]}" &>/dev/null || {
        warning " $(text 153) "
        _ret=1
      }
    fi

    rm -rf "$_tmp_dir"
    return $_ret
    ;;

  # ========== 增量更新出站 ==========
  outbound)
    local _in_config=0 _in_live=0 _ret=0
    local _live_full _live_iface _cfg_iface _need_update=0
    local _live_tags_str _live_tag _tmp

    # 1. 检查配置文件中有没有这个 tag
    [ -s "$_ob" ] && grep -v '^//' "$_ob" | $WORK_DIR/jq -e ".outbounds[] | select(.tag == \"$_tag\")" &>/dev/null && _in_config=1

    # 第 3 个参数为 force 时强制更新（如更换 WARP 账户，secretKey/address/reserved 变更无法通过 interface 比对发现）
    [ "${3:-}" = 'force' ] && [ "$_in_config" = 1 ] && _need_update=1

    # 2. 检查运行中有没有这个 tag
    _live_full=$($WORK_DIR/xray api lso --server="$_api_addr" 2>/dev/null)
    _live_tags_str=$(echo "$_live_full" | $WORK_DIR/jq -r '.outbounds[].tag' 2>/dev/null)
    while IFS= read -r _live_tag; do
      [ "$_live_tag" = "$_tag" ] && { _in_live=1; break; }
    done <<< "$_live_tags_str"

    # 3. 两者都存在且非强制时，比较 interface 是否一致
    if [ "$_need_update" = 0 ] && [ $_in_config -eq 1 ] && [ $_in_live -eq 1 ]; then
      # 配置文件的路径：streamSettings.sockopt.interface
      _cfg_iface=$(grep -v '^//' "$_ob" | $WORK_DIR/jq -r ".outbounds[] | select(.tag == \"$_tag\") | .streamSettings.sockopt.interface // empty" 2>/dev/null)
      # API lso 的路径：senderSettings.streamSettings.socketSettings.interface
      _live_iface=$(echo "$_live_full" | $WORK_DIR/jq -r ".outbounds[] | select(.tag == \"$_tag\") | .senderSettings.streamSettings.socketSettings.interface // empty" 2>/dev/null)

      if [ "$_cfg_iface" != "$_live_iface" ]; then
        # interface 不同 → 需要更新
        _need_update=1
      fi
      # interface 相同 → 不操作，保留原状
    fi

    # 4. 判断操作类型
    if [ $_need_update -eq 1 ]; then
      # 更新：rmo + ado
      _tmp="$_tmp_dir.json"
      rm -rf "$_tmp_dir" && mkdir -p "$_tmp_dir"
      grep -v '^//' "$_ob" | $WORK_DIR/jq -c "{outbounds: [.outbounds[] | select(.tag == \"$_tag\")]}" > "$_tmp" 2>/dev/null
      $WORK_DIR/xray api rmo --server="$_api_addr" "$_tag" &>/dev/null || true
      $WORK_DIR/xray api ado --server="$_api_addr" "$_tmp" &>/dev/null || { warning " $(text 154) "; _ret=1; }
      rm -rf "$_tmp_dir"
    elif [ $_in_config -eq 1 ] && [ $_in_live -eq 0 ]; then
      # 新增：直接 ado
      _tmp="$_tmp_dir.json"
      rm -rf "$_tmp_dir" && mkdir -p "$_tmp_dir"
      grep -v '^//' "$_ob" | $WORK_DIR/jq -c "{outbounds: [.outbounds[] | select(.tag == \"$_tag\")]}" > "$_tmp" 2>/dev/null
      $WORK_DIR/xray api ado --server="$_api_addr" "$_tmp" &>/dev/null || { warning " $(text 154) "; _ret=1; }
      rm -rf "$_tmp_dir"
    elif [ $_in_config -eq 0 ] && [ $_in_live -eq 1 ]; then
      # 删除：直接 rmo
      $WORK_DIR/xray api rmo --server="$_api_addr" "$_tag" &>/dev/null || true
    fi
    # 场景4：都没有 / interface 一致 → 无事可做

    return $_ret
    ;;

  # ========== 全量替换路由规则（来自 outbound.json，自定义规则已在最前面）==========
  custom_routes)
    local _file="$_tmp_dir-routing.json"
    rm -rf "$_tmp_dir" && mkdir -p "$_tmp_dir"

    # 从 outbound.json 提取完整路由规则进行全量替换（custom_route_sync 已确保顺序正确）
    grep -v '^//' "$_ob" | $WORK_DIR/jq '{ routing: .routing }' > "$_file" 2>/dev/null
    [ ! -s "$_file" ] && { warning " $(text 156) "; rm -rf "$_tmp_dir"; return 1; }

    $WORK_DIR/xray api adrules --server="$_api_addr" "$_file" &>/dev/null || {
      warning " $(text 155) "
      rm -rf "$_tmp_dir"
      return 1
    }
    rm -rf "$_tmp_dir"
    return 0
    ;;

  # ========== 全量替换路由规则（方案 B 备选）==========
  routing_rules)
    local _file="$2"
    [ -z "$_file" ] && {
      _file="$_tmp_dir-routing.json"
      rm -rf "$_tmp_dir" && mkdir -p "$_tmp_dir"
      grep -v '^//' "$_ob" | $WORK_DIR/jq '{ routing: .routing }' > "$_file" 2>/dev/null
    }
    [ ! -s "$_file" ] && { warning " $(text 156) "; rm -rf "$_tmp_dir"; return 1; }

    $WORK_DIR/xray api adrules --server="$_api_addr" "$_file" &>/dev/null || {
      warning " $(text 155) "
      rm -rf "$_tmp_dir"
      return 1
    }
    rm -rf "$_tmp_dir"
    return 0
    ;;

  esac
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
  # 从 custom 文件读取 IS_SUB/IS_ARGO
  # 如果用户通过 --ARGO 显式设置了 IS_ARGO，则不从 custom 文件覆盖
  [ -s "$CUSTOM_FILE" ] && {
    IS_SUB=$(awk -F= '/^isSub=/{print $2; exit}' "$CUSTOM_FILE")
    [ "${IS_ARGO_EXPLICIT:-false}" != 'true' ] && IS_ARGO=$(awk -F= '/^isArgo=/{print $2; exit}' "$CUSTOM_FILE")
  }
  IS_SUB=${IS_SUB:-no_sub}
  IS_ARGO=${IS_ARGO:-no_argo}

  STATUS[0]=$(text 26)

  [ -s ${ARGO_DAEMON_FILE} ] && STATUS[0]=$(text 27) && cmd_systemctl status argo &>/dev/null && STATUS[0]=$(text 28)
  STATUS[1]=$(text 26)
  if [ -s ${XRAY_DAEMON_FILE} ]; then
    ! grep -q "$WORK_DIR" ${XRAY_DAEMON_FILE} && error " $(text 53)\n $(grep "${DAEMON_RUN_PATTERN}" ${XRAY_DAEMON_FILE}) "
    STATUS[1]=$(text 27) && cmd_systemctl status xray &>/dev/null && STATUS[1]=$(text 28)
  fi
  STATUS[2]=$(text 26)
  if [ -s $WORK_DIR/nginx.conf ]; then
    local _NGINX_PID=$(nginx_pid)
    [ -n "$_NGINX_PID" ] && STATUS[2]=$(text 28) || STATUS[2]=$(text 27)
  fi

  {
    wget --no-check-certificate --continue -qO $TEMP_DIR/clash ${GH_PROXY}${SUBSCRIBE_TEMPLATE}/clash 2>/dev/null &
    wget --no-check-certificate --continue -qO $TEMP_DIR/sing-box ${GH_PROXY}${SUBSCRIBE_TEMPLATE}/sing-box 2>/dev/null &
    wait
  } &

  mapfile -t CURRENT_PROTOCOLS < <(get_installed_protocols)

  # 后台下载 cloudflared 到 TEMP_DIR（只要 WORK_DIR 还没有就行），
  # 后续如果 IS_ARGO=is_argo 再复制到工作目录，减少交互等待时间
  [ ! -s $WORK_DIR/cloudflared ] && { wget --no-check-certificate -qO $TEMP_DIR/cloudflared ${GH_PROXY}https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$ARGO_ARCH >/dev/null 2>&1 && chmod +x $TEMP_DIR/cloudflared >/dev/null 2>&1; }&
  [[ ${STATUS[1]} = "$(text 26)" ]] && [ ! -s $WORK_DIR/xray ] && {
    local XRAY_LATEST=$(wget --no-check-certificate -qO- "${GH_PROXY}https://api.github.com/repos/XTLS/Xray-core/releases" | awk -F '["v]' '/tag_name/{print $5}' | sort -rV | sed -n 1p)
    XRAY_LATEST=${XRAY_LATEST:-$DEFAULT_XRAY_VERSION}
    wget --no-check-certificate -qO $TEMP_DIR/Xray.zip ${GH_PROXY}https://github.com/XTLS/Xray-core/releases/download/v${XRAY_LATEST}/Xray-linux-${XRAY_ARCH}.zip >/dev/null 2>&1
    unzip -qo $TEMP_DIR/Xray.zip xray *.dat -d $TEMP_DIR >/dev/null 2>&1
  }&
  [ ! -s $WORK_DIR/jq ] && { wget --no-check-certificate --continue -qO $TEMP_DIR/jq ${GH_PROXY}https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-$JQ_ARCH >/dev/null 2>&1 && chmod +x $TEMP_DIR/jq >/dev/null 2>&1; }&
  [ ! -s $WORK_DIR/qrencode ] && { wget --no-check-certificate --continue -qO $TEMP_DIR/qrencode ${GH_PROXY}https://github.com/fscarmen/client_template/raw/main/qrencode-go/qrencode-go-linux-$QRENCODE_ARCH >/dev/null 2>&1 && chmod +x $TEMP_DIR/qrencode >/dev/null 2>&1; }&

  # 任务 4: 注册 warp 账号
  {
    wget -qO- --tries=10 --waitretry=1 --timeout=2 "https://warp.cloudflare.nyc.mn/?run=register" > $TEMP_DIR/warp_account.json 2>/dev/null
  } &
}

# 为了适配 alpine，定义 cmd_systemctl 的函数
cmd_systemctl() {
  local ENABLE_DISABLE=$1
  local APP=$2
  if [ "$ENABLE_DISABLE" = 'enable' ]; then
    if [ "$SYSTEM" = 'Alpine' ]; then
      rc-service $APP start >/dev/null 2>&1
      rc-update add $APP default >/dev/null 2>&1
    else
      systemctl daemon-reload
      systemctl enable --now $APP >/dev/null 2>&1
    fi

  elif [ "$ENABLE_DISABLE" = 'disable' ]; then
    if [ "$SYSTEM" = 'Alpine' ]; then
      rc-service $APP stop >/dev/null 2>&1
      rc-update del $APP default >/dev/null 2>&1
    else
      systemctl daemon-reload
      systemctl disable --now $APP >/dev/null 2>&1
    fi
  elif [ "$ENABLE_DISABLE" = 'restart' ]; then
    if [ "$SYSTEM" = 'Alpine' ]; then
      rc-service $APP restart >/dev/null 2>&1
    else
      systemctl daemon-reload
      systemctl restart $APP >/dev/null 2>&1
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
  [ -s /etc/os-release ] && OS_ID="$(awk -F '=' 'tolower($1) == "id" {gsub(/"/, "", $2); print tolower($2)}' /etc/os-release)"
  [ -s /etc/os-release ] && OS_LIKE="$(awk -F '=' 'tolower($1) == "id_like" {gsub(/"/, "", $2); print tolower($2)}' /etc/os-release)"
  [[ -z "$SYS" ]] && command -v hostnamectl >/dev/null 2>&1 && SYS="$(hostnamectl | awk -F ': ' 'tolower($0) ~ /operating system/{print $2}')"
  [[ -z "$SYS" ]] && command -v lsb_release >/dev/null 2>&1 && SYS="$(lsb_release -sd)"
  [[ -z "$SYS" && -s /etc/lsb-release ]] && SYS="$(awk -F '"' 'tolower($0) ~ /distrib_description/{print $2}' /etc/lsb-release)"
  [[ -z "$SYS" && -s /etc/redhat-release ]] && SYS="$(cat /etc/redhat-release)"
  [[ -z "$SYS" && -s /etc/issue ]] && SYS="$(sed -E '/^$|^\\/d' /etc/issue | awk -F '\\' '{print $1}' | sed 's/[ ]*$//g')"

  REGEX=("debian" "ubuntu" "centos|red hat|kernel|alma|rocky" "arch linux" "alpine" "fedora")
  RELEASE=("Debian" "Ubuntu" "CentOS" "Arch" "Alpine" "Fedora")
  PACKAGE_UPDATE=("apt -y update" "apt -y update" "yum -y update" "pacman -Sy" "apk update -f" "dnf -y update")
  PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "pacman -S --noconfirm" "apk add --no-cache" "dnf -y install")
  PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove" "pacman -Rcnsu --noconfirm" "apk del -f" "dnf -y autoremove")

  if [ "$OS_ID" = 'armbian' ]; then
    if [[ "$OS_LIKE" =~ ubuntu ]]; then
      SYSTEM='Ubuntu'
      int=1
    else
      SYSTEM='Debian'
      int=0
    fi
    SYS="${SYS:-Armbian}"
  else
    for int in "${!REGEX[@]}"; do
      [[ "${SYS,,}" =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && break
    done
  fi
  if [ -z "$SYSTEM" ]; then
    command -v yum >/dev/null 2>&1 && int=2 && SYSTEM='CentOS' || error " $(text 5) "
  fi

  ARGO_DAEMON_FILE='/etc/systemd/system/argo.service'; XRAY_DAEMON_FILE='/etc/systemd/system/xray.service'; DAEMON_RUN_PATTERN="ExecStart="
  if [ "$SYSTEM" = 'Alpine' ]; then
    ARGO_DAEMON_FILE='/etc/init.d/argo'; XRAY_DAEMON_FILE='/etc/init.d/xray'; DAEMON_RUN_PATTERN="command_args="
  fi

  if command -v systemd-detect-virt >/dev/null 2>&1; then
    VIRT=$(systemd-detect-virt)
  elif grep -qa container= /proc/1/environ 2>/dev/null; then
    VIRT=$(tr '\0' '\n' </proc/1/environ | awk -F= '/container=/{print $2; exit}')
  elif grep -Eq '(lxc|docker|kubepods|containerd)' /proc/1/cgroup 2>/dev/null; then
    VIRT=$(grep -Eo '(lxc|docker|kubepods|containerd)' /proc/1/cgroup | sed -n 1p)
  elif command -v hostnamectl >/dev/null 2>&1; then
    VIRT=$(hostnamectl | awk '/Virtualization/{print $NF}')
  else
    command -v virt-what >/dev/null 2>&1 && ${PACKAGE_INSTALL[int]} virt-what >/dev/null 2>&1
    command -v virt-what >/dev/null 2>&1 && VIRT=$(virt-what | sed -n 1p) || VIRT=unknown
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
    grep -q '"ip"' <<< "$IP4_JSON" && echo "$IP4_JSON" > $TEMP_DIR/ip4.json
  }&

  {
    local IP6_JSON=$(wget $BIND_ADDRESS6 -6 -qO- --no-check-certificate --tries=2 --timeout=2 https://ip.cloudflare.now.cc${IS_CHINESE})
    grep -q '"ip"' <<< "$IP6_JSON" && echo "$IP6_JSON" > $TEMP_DIR/ip6.json
  }&

  wait

  if [ -s $TEMP_DIR/ip4.json ]; then
    local IP4_DATA=$(< "$TEMP_DIR/ip4.json")
    WAN4=$(awk -F '"' '/"ip"/{print $4}' <<< "$IP4_DATA")
    COUNTRY4=$(awk -F '"' '/"country"/{print $4}' <<< "$IP4_DATA")
    EMOJI4=$(awk -F '"' '/"emoji"/{print $4}' <<< "$IP4_DATA")
    ASNORG4=$(awk -F '"' '/"isp"/{print $4}' <<< "$IP4_DATA")
    rm -f $TEMP_DIR/ip4.json
  fi

  if [ -s $TEMP_DIR/ip6.json ]; then
    local IP6_DATA=$(< "$TEMP_DIR/ip6.json")
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
    elif [ -s "$CUSTOM_FILE" ]; then
      local a=6
      until [ -n "$SERVER_IP" ] && is_valid_server_addr "$SERVER_IP"; do
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
  # IS_ARGO=no_argo 时不需要 cloudflared，跳过
  [ "$IS_ARGO" = 'no_argo' ] && return

  NGINX_PORT=${NGINX_PORT:-"$NGINX_PORT_DEFAULT"}

  if [ -z "$SERVER_IP" ]; then
    check_system_ip
    SERVER_IP="$SERVER_IP_DEFAULT"
  fi

  ARGO_DOMAIN=$(sed 's/[ ]*//g; s/:[ ]*//' <<< "$ARGO_DOMAIN")

  if [[ "$ARGO_AUTH" =~ TunnelSecret ]]; then
    ARGO_JSON=${ARGO_AUTH//[ ]/}
  elif [[ "$ARGO_AUTH" =~ [A-Z0-9a-z=]{120,250}$ ]]; then
    ARGO_TOKEN=$(awk '{print $NF}' <<< "$ARGO_AUTH")
  elif [[ "${#ARGO_AUTH}" =~ ^[3-6][0-9]$ ]]; then
    hint "\n $(text 78) \n "
    create_argo_tunnel "${ARGO_AUTH}" "${ARGO_DOMAIN}" "${NGINX_PORT}"
    if [[ ! "$ARGO_JSON" =~ TunnelSecret ]]; then
      hint "\n $(text 80) \n "
      unset ARGO_DOMAIN
    fi
  fi
}

# 根据 INSTALL_PROTOCOLS 计算安装流程总步骤数
# Hysteria2 Realm / WARP / Port Hopping 属于协议子选项，不计入安装步骤
calc_install_steps() {
  local _total=5  # 固定步骤：协议选择、起始端口、VPS IP、UUID、节点名
  local _has_ws_xhttp=false
  for _p in "${INSTALL_PROTOCOLS[@]}"; do
    [[ "$_p" =~ ^[efghi]$ ]] && _has_ws_xhttp=true
  done
  # Nginx 端口：需要订阅 OR WS/XHTTP 协议时需要
  if [ "$IS_SUB" = 'is_sub' ] || $_has_ws_xhttp; then
    (( _total++ ))
  fi
  grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL" && (( _total-- ))  # 非交互安装时不单独询问 VPS IP
  # Argo 域名、Reality 密钥、CDN 优选地址、WS 路径等属于协议子参数，不计入安装步骤
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
    ! command -v openssl >/dev/null 2>&1 && return
    REALITY_PRIVATE=$(openssl genpkey -algorithm x25519 -outform DER 2>/dev/null | tail -c 32 | base64 | tr '/+' '_-' | tr -d '=')
    REALITY_PUBLIC=''
  fi
}

# 输入节点名称（与全新安装一致；已有节点名称则沿用）
input_node_name() {
  [ -n "$NODE_NAME" ] && return 0
  local EMOJI_VAL="${EMOJI4:-$EMOJI6}"
  local HOST_NAME
  if command -v hostname >/dev/null 2>&1; then
    HOST_NAME=$(hostname)
  elif [ -s /etc/hostname ]; then
    HOST_NAME=$(cat /etc/hostname)
  else
    HOST_NAME="ArgoX"
  fi
  NODE_NAME_DEFAULT="${EMOJI_VAL}${EMOJI_VAL:+ }${HOST_NAME}"
  if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL"; then
    (( STEP_NUM++ )) || true
    reading "\n $(text 49) " NODE_NAME
  fi
  NODE_NAME=${NODE_NAME:-"$HOST_NAME"}
  grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL" || NODE_NAME="${EMOJI_VAL}${EMOJI_VAL:+ }${NODE_NAME}"
}

# 定义 Xray 相关变量，包含协议选择交互和相关配置
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

  # 如果用户通过 --ARGO 显式设置为 no_argo，协议选择列表中过滤掉 WS/XHTTP 协议
  local _WS_XHTTP_LETTERS='[efghi]'
  if [ "${IS_ARGO_EXPLICIT:-false}" = 'true' ] && [ "$IS_ARGO" = 'no_argo' ]; then
    # WS/XHTTP 协议在菜单中隐藏
    local _FILTERED_LETTERS=''
    local _IDX
    for _IDX in "${!PROTOCOL_LIST[@]}"; do
      local _LETTER=$(asc $((98 + _IDX)))
      [[ "$_LETTER" =~ $_WS_XHTTP_LETTERS ]] || _FILTERED_LETTERS+="$_LETTER "
    done
    _all_protocol_letters="$_FILTERED_LETTERS"
  fi

  if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL" && [ -z "${INSTALL_PROTOCOLS[*]}" ] && [ -z "$CHOOSE_PROTOCOLS" ]; then
    hint "\n $(text 87)"
    hint " $(text 100) "
    for p in "${!PROTOCOL_LIST[@]}"; do
      local letter=$(asc $((p + 98)))
      # IS_ARGO=no_argo 时隐藏 WS/XHTTP 协议
      if [ "${IS_ARGO_EXPLICIT:-false}" = 'true' ] && [ "$IS_ARGO" = 'no_argo' ] && [[ "$letter" =~ $_WS_XHTTP_LETTERS ]]; then
        continue
      fi
      local p_name="${PROTOCOL_LIST[p]}"
      [ "$letter" = "i" ] && p_name=$(text 101)
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
      # 如果 IS_ARGO=no_argo，自动过滤掉 WS/XHTTP 协议（efghi）
      if [ "${IS_ARGO_EXPLICIT:-false}" = 'true' ] && [ "$IS_ARGO" = 'no_argo' ]; then
        filtered=$(grep -o . <<< "$filtered" | grep -v "$_WS_XHTTP_LETTERS" | tr -d '\n')
      fi
      [ -z "$filtered" ] && read -r -a INSTALL_PROTOCOLS <<< "${_all_protocol_letters% }" || {
        INSTALL_PROTOCOLS=()
        while IFS= read -r -n1 ch; do
          [ -n "$ch" ] && INSTALL_PROTOCOLS+=("$ch")
        done <<< "$filtered"
      }
    fi
  fi

  # 协议已确定，从这里推导 IS_ARGO：有 WS/XHTTP (efghi) 时需要 Argo
  # 如果用户通过 --ARGO 或 config.conf 显式设置了 IS_ARGO，则不覆盖
  [ "${IS_ARGO_EXPLICIT:-false}" != 'true' ] && IS_ARGO=no_argo
  if [ "${IS_ARGO_EXPLICIT:-false}" != 'true' ]; then
    for _p in "${INSTALL_PROTOCOLS[@]}"; do
      [[ "$_p" =~ ^[efghi]$ ]] && { IS_ARGO=is_argo; break; }
    done
  fi

  # 根据 IS_SUB / IS_ARGO 决定是否需要 nginx，按需安装
  INSTALL_NGINX="n"
  if [ "$IS_SUB" = 'is_sub' ] || [ "$IS_ARGO" = 'is_argo' ]; then
    INSTALL_NGINX="y"
    if ! command -v nginx >/dev/null 2>&1; then
      hint "\n $(text 148) "
      # 后台安装，用户可继续交互，首次使用 nginx 前会 wait 等待完成
      ( ${PACKAGE_UPDATE[int]} >/dev/null 2>&1; ${PACKAGE_INSTALL[int]} nginx >/dev/null 2>&1; [ "$SYSTEM" != 'Alpine' ] && systemctl disable --now nginx >/dev/null 2>&1; ) &
    fi
  fi

  # 计算总步骤数
  calc_install_steps

  # 显示选择协议及其次序，输入开始端口号
  if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL" && [ -z "$START_PORT" ]; then
    hint "\n $(text 124) "
    for w in "${!INSTALL_PROTOCOLS[@]}"; do
      local _proto_idx=$(($(asc ${INSTALL_PROTOCOLS[w]}) - 98))
      local _proto_name="${PROTOCOL_LIST[$_proto_idx]}"
      hint " $(printf '%3d.' $(( w+1 ))) ${_proto_name} "
    done
  fi

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
      e) VLESS_WS_PORT=$(( START_PORT + i )) ;;
      f) VMESS_WS_PORT=$(( START_PORT + i )) ;;
      g) TROJAN_WS_PORT=$(( START_PORT + i )) ;;
      h) SS_WS_PORT=$(( START_PORT + i )) ;;
      i) VLESS_XHTTP_PORT=$(( START_PORT + i )) ;;
      j) XHTTP_H2_PORT=$(( START_PORT + i )) ;;
      k) XHTTP_PORT=$(( START_PORT + i )) ;;
      l) TROJAN_PORT=$(( START_PORT + i )) ;;
      m) SS2022_PORT=$(( START_PORT + i )) ;;
    esac
  done

  # Nginx 端口：仅在需要 nginx 时询问
  if [ "$INSTALL_NGINX" = 'y' ]; then
    if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL"; then
      if [ "$SKIP_MENU" != 'skip_menu' ] || [ -z "$NGINX_PORT" ]; then
        (( STEP_NUM++ )) || true
        input_nginx_port
      fi
    fi
    NGINX_PORT=${NGINX_PORT:-"$NGINX_PORT_DEFAULT"}
  fi

  if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL"; then
    if [ "$SKIP_MENU" != 'skip_menu' ] || [ -z "$SERVER_IP" ]; then
      (( STEP_NUM++ )) || true
      local IP_ERROR_TIME=6
      while true; do
        reading "\n $(text 59) " SERVER_IP
        [ -z "$SERVER_IP" ] && break
        is_valid_server_addr "$SERVER_IP" && break
        (( IP_ERROR_TIME-- )) || true
        [ "$IP_ERROR_TIME" = 0 ] && error "\n $(text 3) \n"
        warning " $(text 112) "
      done
    fi
  fi
  SERVER_IP=${SERVER_IP:-"$SERVER_IP_DEFAULT"}

  # Argo 域名：仅在 IS_ARGO=is_argo 时询问（协议子参数，不计入安装步骤）
  if [ "$IS_ARGO" = 'is_argo' ] && ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL"; then
    if [ -z "$ARGO_DOMAIN" ]; then
      if [ "$SKIP_MENU" != 'skip_menu' ]; then
        reading "\n $(text 10) " ARGO_DOMAIN
      fi
    fi
    if [[ -n "$ARGO_DOMAIN" && ! "$ARGO_DOMAIN" =~ trycloudflare\.com$ && -z "$ARGO_AUTH" ]]; then
      hint "\n $(text 11)"
      reading "\n $(text 86) " ARGO_AUTH
    fi
  fi

  local HAS_REALITY=false
  for p in "${INSTALL_PROTOCOLS[@]}"; do [[ "$p" =~ ^[bdj]$ ]] && HAS_REALITY=true && break; done
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
        reading "\n $(text 98) " REALITY_PRIVATE
      fi
      if [ -z "$REALITY_PRIVATE" ]; then
        generate_reality_keypair
      else
        # 从私钥生成公钥：优先使用 OpenSSL 本地生成，回退使用远程 API
        if command -v xxd >/dev/null 2>&1; then
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
    [[ "$p" == 'k' ]] && _HAS_XHTTP_DIRECT=true && break
  done

  if [ -z "$SERVER" ]; then
    if [ "$SKIP_MENU" = 'skip_menu' ] && [ -n "$CDN" ]; then
      # 长参数模式：使用 --CDN 传入的值
      # 如果 CDN 已包含端口（如 192.168.1.1:50000），直接使用；否则追加默认 443
      if [[ "$CDN" == *:* ]]; then
        parse_preferred_addr "$CDN" || error " $(text 118) "
      else
        parse_preferred_addr "${CDN}:443" || error " $(text 118) "
      fi
      SERVER="$PREFERRED_ADDR"
      SERVER_PORT="$PREFERRED_PORT"
    elif $_HAS_WS_XHTTP; then
      if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL"; then
        echo ""
        for c in "${!CDN_DOMAIN[@]}"; do
          hint " $((c+1)). ${CDN_DOMAIN[c]} "
        done
        reading "\n $(text 42) " CUSTOM_CDN
      fi
      case "$CUSTOM_CDN" in
        [1-9]|[1-9][0-9] )
          [ "$CUSTOM_CDN" -le "${#CDN_DOMAIN[@]}" ] && SERVER="${CDN_DOMAIN[$((CUSTOM_CDN-1))]}" || SERVER="${CDN_DOMAIN[0]}"
          SERVER_PORT=443
          ;;
        ?????* )
          parse_preferred_addr "$CUSTOM_CDN" || error " $(text 118) "
          SERVER="$PREFERRED_ADDR"
          SERVER_PORT="$PREFERRED_PORT"
          ;;
        * )
          SERVER="${CDN_DOMAIN[0]}"
          SERVER_PORT=443
      esac
    else
      SERVER='__CDN_UNSET__'
      SERVER_PORT=443
    fi
  fi

  if [[ -n "$SERVER" && "$SERVER" != '__CDN_UNSET__' ]]; then
    parse_preferred_addr "${SERVER}:${SERVER_PORT:-443}" || error " $(text 118) "
    SERVER="$PREFERRED_ADDR"
    SERVER_PORT="$PREFERRED_PORT"
    SERVER_DISPLAY="$PREFERRED_DISPLAY"
  fi

  if [[ " ${INSTALL_PROTOCOLS[*]} " =~ " c " ]]; then
    # Realm 与端口跳跃互斥：先提示；开启 Realm 后跳过端口跳跃交互
    hint "\n $(text 182) \n"
    # Hysteria2 Realm 交互（在端口跳跃之前询问，需要先 Realm 再端口跳跃）
    input_hy2_realm
    input_hy2_warp
    # Realm ID 默认使用 UUID
    [ "$IS_HY2_REALM" = 'is_hy2_realm' ] && HY2_REALM_ID="$UUID"

    if [ "$SKIP_MENU" = 'skip_menu' ] && [ -z "$PORT_HOPPING_RANGE" ]; then
      # 长参数模式：未传 --PORT_HOPPING_RANGE，视为禁用端口跳跃
      IS_HOPPING=no_hopping
    elif ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL"; then
      [ "$IS_HY2_REALM" != 'is_hy2_realm' ] && input_hopping_port
    elif [ -n "$PORT_HOPPING_RANGE" ]; then
      # 非交互模式：config.conf 填了 PORT_HOPPING_RANGE，直接解析；Realm 开启时强制忽略
      if [ "$IS_HY2_REALM" != 'is_hy2_realm' ]; then
        local _R=${PORT_HOPPING_RANGE//-/:}
        PORT_HOPPING_RANGE=$_R
        PORT_HOPPING_START=${_R%:*}
        PORT_HOPPING_END=${_R#*:}
        IS_HOPPING=is_hopping
      else
        IS_HOPPING=no_hopping
      fi
    fi
    IS_HOPPING=${IS_HOPPING:-no_hopping}
  fi

  if $_HAS_WS_XHTTP; then
    if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL" && [ -z "$WS_PATH" ]; then
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
    info "\n $(text 63) \n"
  fi

  input_uuid

  input_node_name
}

# 快速安装变量初始化
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
      e) VLESS_WS_PORT=$(( START_PORT + i )) ;;
      f) VMESS_WS_PORT=$(( START_PORT + i )) ;;
      g) TROJAN_WS_PORT=$(( START_PORT + i )) ;;
      h) SS_WS_PORT=$(( START_PORT + i )) ;;
      i) VLESS_XHTTP_PORT=$(( START_PORT + i )) ;;
      j) XHTTP_H2_PORT=$(( START_PORT + i )) ;;
      k) XHTTP_PORT=$(( START_PORT + i )) ;;
      l) TROJAN_PORT=$(( START_PORT + i )) ;;
      m) SS2022_PORT=$(( START_PORT + i )) ;;
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

  # 非交互模式：从环境变量读取 Realm 设置
  if [[ "${HY2_REALM,,}" =~ ^(true|yes|y)$ ]] || [[ "${IS_HY2_REALM,,}" =~ ^(true|yes|y|is_hy2_realm)$ ]]; then
    IS_HY2_REALM=is_hy2_realm
  fi
  if [[ "${HY2_WARP,,}" =~ ^(true|yes|y)$ ]] || [[ "${IS_HY2_WARP,,}" =~ ^(true|yes|y|is_hy2_warp)$ ]]; then
    IS_HY2_WARP=is_hy2_warp
  fi
  [ "$IS_HY2_REALM" = 'is_hy2_realm' ] && HY2_REALM_ID="${HY2_REALM_ID:-$UUID}"

  SERVER=${SERVER:-"${CDN_DOMAIN[0]}"}
  SERVER_PORT=${SERVER_PORT:-${cdnPort:-443}}
  if [ "$SERVER" != '__CDN_UNSET__' ]; then
    parse_preferred_addr "${SERVER}:${SERVER_PORT}" || error " $(text 118) "
    SERVER="$PREFERRED_ADDR"
    SERVER_PORT="$PREFERRED_PORT"
    SERVER_DISPLAY="$PREFERRED_DISPLAY"
  fi
  UUID=${UUID:-$(cat /proc/sys/kernel/random/uuid)}
  WS_PATH=${WS_PATH:-"$WS_PATH_DEFAULT"}
  NGINX_PORT=${NGINX_PORT:-"$NGINX_PORT_DEFAULT"}

  check_system_ip
  SERVER_IP=${SERVER_IP:-$SERVER_IP_DEFAULT}
  local EMOJI_VAL="${EMOJI4:-$EMOJI6}"
  if command -v hostname >/dev/null 2>&1; then
    local HOST_NAME=$(hostname)
  elif [ -s /etc/hostname ]; then
    local HOST_NAME=$(cat /etc/hostname)
  else
    local HOST_NAME="ArgoX"
  fi
  NODE_NAME="${EMOJI_VAL}${EMOJI_VAL:+ }${HOST_NAME}"
}

# 检测并安装依赖，Alpine 额外处理 BusyBox wget 和 openrc，其他系统补充 iproute2 和 systemctl
check_dependencies() {
  local DEPS_CHECK=() DEPS_INSTALL=() TO_INSTALL=()

  # 1. 基础通用依赖 (所有系统都需要，nginx 在选协议后按需安装)
  DEPS_CHECK=(  "wget" "bash" "ss"       "unzip" "openssl")
  DEPS_INSTALL=("wget" "bash" "iproute2" "unzip" "openssl")

  # 2. 根据系统差异补充初始化系统依赖（不含防火墙，防火墙仅端口跳跃时按需安装）
  if [ "$SYSTEM" = 'Alpine' ]; then
    # Alpine 特有处理：检查 BusyBox wget
    local CHECK_WGET=$(wget 2>&1 | sed -n 1p)
    grep -qi 'busybox' <<< "$CHECK_WGET" && TO_INSTALL+=("wget")

    DEPS_CHECK+=("rc-update")
    DEPS_INSTALL+=("openrc")
  else
    DEPS_CHECK+=("systemctl")
    DEPS_INSTALL+=("systemctl")
  fi

  # 3. 统一循环检查
  for i in "${!DEPS_CHECK[@]}"; do
    ! command -v "${DEPS_CHECK[i]}" >/dev/null 2>&1 && TO_INSTALL+=("${DEPS_INSTALL[i]}")
  done

  # 4. 数组去重并执行安装
  if [ "${#TO_INSTALL[@]}" -gt 0 ]; then
    # 去重处理
    TO_INSTALL=($(printf "%s\n" "${TO_INSTALL[@]}" | sort -u))

    info "\n $(text 7) $(sed "s/ /,&/g" <<< "${TO_INSTALL[*]}") \n"

    # CentOS 通常不需要频繁 update，节省时间
    [ "$SYSTEM" != 'CentOS' ] && ${PACKAGE_UPDATE[int]} >/dev/null 2>&1
    ${PACKAGE_INSTALL[int]} "${TO_INSTALL[@]}" >/dev/null 2>&1
  else
    info "\n $(text 8) \n"
  fi
}

# 输入 uuid
input_uuid() {
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
    [[ ! "${UUID,,}" =~ ^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$ ]] && warning " $(text 4) "
  done
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

parse_preferred_addr() {
  local _raw="$1" _host='' _port='443'
  _raw=$(printf '%s' "$_raw" | sed 's/[[:space:]]//g; s/：/:/g; s/。/./g; s/【/[/g; s/】/]/g')
  [ -z "$_raw" ] && return 1

  if [[ "$_raw" =~ ^\[([0-9A-Fa-f:]+)\](:([0-9]{1,5}))?$ ]]; then
    _host="${BASH_REMATCH[1]}"
    [ -n "${BASH_REMATCH[3]}" ] && _port="${BASH_REMATCH[3]}"
  elif [[ "$_raw" =~ ^((([0-9]{1,3})\.){3}([0-9]{1,3}))(:([0-9]{1,5}))?$ ]]; then
    _host="${BASH_REMATCH[1]}"
    [ -n "${BASH_REMATCH[6]}" ] && _port="${BASH_REMATCH[6]}"
    IFS='.' read -r _o1 _o2 _o3 _o4 <<< "$_host"
    for _oct in "$_o1" "$_o2" "$_o3" "$_o4"; do
      [[ "$_oct" =~ ^[0-9]+$ ]] || return 1
      [ "$_oct" -gt 255 ] && return 1
    done
  elif [[ "$_raw" =~ ^([A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?(\.([A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?))+)(:([0-9]{1,5}))?$ ]]; then
    _host="${BASH_REMATCH[1]}"
    [ -n "${BASH_REMATCH[7]}" ] && _port="${BASH_REMATCH[7]}"
  else
    return 1
  fi

  [[ "$_port" =~ ^[0-9]+$ ]] || return 1
  [ "$_port" -lt 1 ] || [ "$_port" -gt 65535 ] && return 1

  PREFERRED_ADDR="$_host"
  PREFERRED_PORT="$_port"
  if [[ "$_host" == *:* ]]; then
    PREFERRED_DISPLAY="[$_host]:$_port"
  else
    PREFERRED_DISPLAY="$_host:$_port"
  fi
  return 0
}

# 从已安装的 inbound.json / protocols 等配置文件中读取各参数，供 export_list / change_protocols 复用
fetch_nodes_value() {
  unset IS_SUB IS_ARGO SERVER_IP REALITY_PORT REALITY_PUBLIC REALITY_PRIVATE TLS_SERVER SERVER SERVER_PORT SERVER_DISPLAY UUID WS_PATH NODE_NAME SS_WS_METHOD SS_DIRECT_METHOD SS2022_PASSWORD GRPC_PORT HY2_PORT VLESS_WS_PORT VMESS_WS_PORT TROJAN_WS_PORT SS_WS_PORT VLESS_XHTTP_PORT XHTTP_H2_PORT XHTTP_PORT TROJAN_PORT SS2022_PORT SERVER_IP_1 SERVER_IP_2 HY2_UP_NOW HY2_DOWN_NOW

  [ -s "$CUSTOM_FILE" ] && . "$CUSTOM_FILE"
  SERVER_IP="${serverIp:-}"
  REALITY_PRIVATE="${privateKey:-}"
  REALITY_PUBLIC="${publicKey:-}"
  SERVER="${cdn:-}"
  SERVER_PORT="${cdnPort:-443}"
  FINGER_PRINT="${fingerprint:-chrome}"
  BIND_IFACE="${bind_interface:-}"
  IS_SUB="${isSub:-no_sub}"
  IS_ARGO="${isArgo:-no_argo}"
  unset serverIp privateKey publicKey cdn cdnPort language fingerprint bind_interface isSub isArgo

  local JSON
  JSON=$(grep -v '^//' $WORK_DIR/inbound.json 2>/dev/null)
  [ -z "$JSON" ] && [ ! -s "$CUSTOM_FILE" ] && return 1
  [ -z "$JSON" ] && return 0

  REALITY_PORT=$(echo "$JSON" | $WORK_DIR/jq -r '.inbounds[0].port // empty')
  TLS_SERVER=$(echo "$JSON" | $WORK_DIR/jq -r '.inbounds[] | select(.streamSettings.security=="reality") | .streamSettings.realitySettings.serverNames[0]' 2>/dev/null | head -1)
  UUID=$(echo "$JSON" | $WORK_DIR/jq -r '.inbounds[0].settings.clients[0].id // .inbounds[0].settings.clients[0].password // .inbounds[0].settings.clients[0].auth // empty')
  WS_PATH=$(echo "$JSON" | $WORK_DIR/jq -r '.inbounds[] | select(.streamSettings.network=="ws") | .streamSettings.wsSettings.path' 2>/dev/null | head -1 | sed 's|/||; s|-vl$||; s|-vm$||; s|-tr$||; s|-sh$||; s|-xh$||')
  NODE_NAME=$(echo "$JSON" | $WORK_DIR/jq -r '.inbounds[0].tag // empty' | sed 's/ [^ ]*$//')
  SS_WS_METHOD=$(echo "$JSON" | $WORK_DIR/jq -r '.inbounds[] | select(.tag | split(" ")[-1] == "ss-ws") | .settings.clients[0].method // empty' 2>/dev/null | head -1)
  SS2022_PASSWORD=$(echo "$JSON" | $WORK_DIR/jq -r '.inbounds[] | select(.tag | split(" ")[-1] == "ss2022-direct") | .settings.password // empty' 2>/dev/null | head -1)
  [ -z "$SS2022_PASSWORD" ] && SS2022_PASSWORD=$(echo "$JSON" | $WORK_DIR/jq -r '.inbounds[] | select(.tag | split(" ")[-1] == "ss2022-direct") | .settings.clients[0].password // empty' 2>/dev/null | head -1)
  SS_DIRECT_METHOD=$(echo "$JSON" | $WORK_DIR/jq -r --arg tag "${NODE_TAG[11]}" '.inbounds[] | select(.tag | endswith($tag)) | .settings.method | select(. != null)')
  GRPC_PORT=$(echo "$JSON" | $WORK_DIR/jq -r '[.inbounds[] | select(.streamSettings.network=="grpc") | .port] | .[0] // empty' 2>/dev/null)
  HY2_PORT=$(echo "$JSON" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "hysteria2") | .port] | .[0] // empty' 2>/dev/null)
  # 检测 Hysteria2 Realm 状态
  if [ -n "$HY2_PORT" ]; then
    local _hy2_fm
    _hy2_fm=$(echo "$JSON" | $WORK_DIR/jq -r '.inbounds[] | select(.tag | endswith("hysteria2")) | .streamSettings.finalmask // empty' 2>/dev/null)
    if [ -n "$_hy2_fm" ]; then
      IS_HY2_REALM=is_hy2_realm
      HY2_REALM_ID=$(echo "$_hy2_fm" | $WORK_DIR/jq -r '.udp[0].settings.url' 2>/dev/null | sed 's|realm://public@realm.hy2.io:443/||')
      [ -z "$HY2_REALM_ID" ] && HY2_REALM_ID="$UUID"
      # 检测 WARP 路由规则（从 outbound.json 读取，因为 Xray 多配置合并时
      # outbound.json 的 routing 覆盖 inbound.json 的 routing）
      # WARP 打洞需要同时存在 v4 和 v6 两条规则，检测时匹配任一即可
      local _warp_rule
      if [ -s "$WORK_DIR/outbound.json" ]; then
        local _ob_json
        _ob_json=$(grep -v '^//' "$WORK_DIR/outbound.json" 2>/dev/null)
        _warp_rule=$(echo "$_ob_json" | $WORK_DIR/jq -r '.routing.rules // [] | any((.inboundTag // [] | any(endswith("hysteria2"))) and (.outboundTag == "warp-IPv4" or .outboundTag == "warp-IPv6"))' 2>/dev/null)
      fi
      [ "$_warp_rule" = 'true' ] && IS_HY2_WARP=is_hy2_warp
    else
      unset IS_HY2_REALM IS_HY2_WARP HY2_REALM_ID
    fi
  else
    unset IS_HY2_REALM IS_HY2_WARP HY2_REALM_ID
  fi
  VLESS_WS_PORT=$(echo "$JSON" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "vless-ws") | .port] | .[0] // empty' 2>/dev/null)
  VMESS_WS_PORT=$(echo "$JSON" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "vmess-ws") | .port] | .[0] // empty' 2>/dev/null)
  TROJAN_WS_PORT=$(echo "$JSON" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "trojan-ws") | .port] | .[0] // empty' 2>/dev/null)
  SS_WS_PORT=$(echo "$JSON" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "ss-ws") | .port] | .[0] // empty' 2>/dev/null)
  VLESS_XHTTP_PORT=$(echo "$JSON" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "xhttp-h1.1-cdn") | .port] | .[0] // empty' 2>/dev/null)
  XHTTP_H2_PORT=$(echo "$JSON" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "xhttp-h2-reality") | .port] | .[0] // empty' 2>/dev/null)
  XHTTP_PORT=$(echo "$JSON" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "xhttp-h3-direct") | .port] | .[0] // empty' 2>/dev/null)
  [ -z "$TLS_SERVER" ] && TLS_SERVER=$(echo "$JSON" | $WORK_DIR/jq -r '[.inbounds[] | select(.streamSettings.network=="hysteria") | .streamSettings.tlsSettings.serverNames[0]] | .[0] // empty' 2>/dev/null)
  [ -z "$TLS_SERVER" ] && TLS_SERVER=$(echo "$JSON" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "trojan-direct") | .streamSettings.tlsSettings.serverName // .streamSettings.tlsSettings.serverNames[0]] | .[0] // empty' 2>/dev/null)
  [ -z "$TLS_SERVER" ] && [ -s "$WORK_DIR/cert/cert.pem" ] && TLS_SERVER=$(openssl x509 -noout -ext subjectAltName -in "$WORK_DIR/cert/cert.pem" 2>/dev/null | awk -F 'DNS:' '/DNS:/{gsub(/,.*/,"",$2);print $2; exit}')
  [ -z "$SS2022_PASSWORD" ] && SS2022_PASSWORD="$(openssl rand -base64 16)"
  TROJAN_PORT=$(echo "$JSON" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "trojan-direct") | .port] | .[0] // empty' 2>/dev/null)
  SS2022_PORT=$(echo "$JSON" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "ss2022-direct") | .port] | .[0] // empty' 2>/dev/null)

  [ -z "$WS_PATH" ] && WS_PATH="$WS_PATH_DEFAULT"
  [ -z "$NODE_NAME" ] && NODE_NAME="ArgoX"
  if [[ -z "$SERVER" || "$SERVER" == '__CDN_UNSET__' ]]; then
    SERVER='__CDN_UNSET__'
    SERVER_PORT=443
    SERVER_DISPLAY='__CDN_UNSET__'
  elif parse_preferred_addr "${SERVER}:${SERVER_PORT}"; then
    SERVER="$PREFERRED_ADDR"
    SERVER_PORT="$PREFERRED_PORT"
    SERVER_DISPLAY="$PREFERRED_DISPLAY"
  else
    SERVER_PORT=443
    SERVER_DISPLAY="$SERVER"
  fi

  if [[ "$SERVER_IP" =~ : ]]; then
    SERVER_IP_1="[$SERVER_IP]"
    SERVER_IP_2="[[$SERVER_IP]]"
  else
    SERVER_IP_1="$SERVER_IP"
    SERVER_IP_2="$SERVER_IP"
  fi

  # 读取 Hysteria2 带宽参数（从订阅文件 proxies 中解析）
  if [ -n "$HY2_PORT" ] && [ -s "${WORK_DIR}/subscribe/proxies" ]; then
    local HY2_LINE=$(grep 'type: hysteria2' ${WORK_DIR}/subscribe/proxies)
    if [[ "$HY2_LINE" =~ up:[[:space:]]*\"([0-9]+)[[:space:]]*Mbps\".*down:[[:space:]]*\"([0-9]+)[[:space:]]*Mbps\" ]]; then
      HY2_UP_NOW="${BASH_REMATCH[1]}"
      HY2_DOWN_NOW="${BASH_REMATCH[2]}"
    elif [[ "$HY2_LINE" =~ down:[[:space:]]*\"([0-9]+)[[:space:]]*Mbps\".*up:[[:space:]]*\"([0-9]+)[[:space:]]*Mbps\" ]]; then
      HY2_DOWN_NOW="${BASH_REMATCH[1]}"
      HY2_UP_NOW="${BASH_REMATCH[2]}"
    fi
    HY2_UP_NOW=${HY2_UP_NOW:-200}
    HY2_DOWN_NOW=${HY2_DOWN_NOW:-1000}
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

# 生成 UFW PortHopping 备注
# 向指定的 UFW 规则文件写入 PortHopping NAT 规则块
add_port_hopping_ufw_block() {
  local RULES_FILE="$1" BLOCK_BEGIN="$2" BLOCK_END="$3" PORT_HOPPING_START="$4" PORT_HOPPING_END="$5" PORT_HOPPING_TARGET="$6" COMMENT="$7"
  [ ! -e "$RULES_FILE" ] && return 0
  [ -z "$PORT_HOPPING_START" ] || [ -z "$PORT_HOPPING_END" ] || [ -z "$PORT_HOPPING_TARGET" ] || [ -z "$COMMENT" ] && return 1
  awk -v begin="$BLOCK_BEGIN" -v end="$BLOCK_END" -v start="$PORT_HOPPING_START" -v finish="$PORT_HOPPING_END" -v target="$PORT_HOPPING_TARGET" -v comment="$COMMENT" '
    BEGIN { inserted=0 }
    {
      if ($0 ~ /^\*filter/ && inserted==0) {
        print begin
        print "*nat"
        print ":PREROUTING ACCEPT [0:0]"
        print "-A PREROUTING -p udp --dport " start ":" finish " -m comment --comment \"" comment "\" -j DNAT --to-destination :" target
        print "COMMIT"
        print end
        inserted=1
      }
      print
    }
    END {
      if (inserted==0) {
        print begin
        print "*nat"
        print ":PREROUTING ACCEPT [0:0]"
        print "-A PREROUTING -p udp --dport " start ":" finish " -m comment --comment \"" comment "\" -j DNAT --to-destination :" target
        print "COMMIT"
        print end
      }
    }
  ' "$RULES_FILE" > "${TEMP_DIR}/$(basename "$RULES_FILE")" && mv "${TEMP_DIR}/$(basename "$RULES_FILE")" "$RULES_FILE"
}

# 删除指定 UFW 规则文件中的 PortHopping NAT 规则块
del_port_hopping_ufw_block() {
  local RULES_FILE=$1
  local IP_VERSION=$2
  local TEMP_RULES_FILE

  [ ! -e "$RULES_FILE" ] && return 0

  TEMP_RULES_FILE="${TEMP_DIR}/$(basename "$RULES_FILE")"

  awk -v ip_version="$IP_VERSION" '
    BEGIN { in_block=0 }
    {
      if ($0 ~ "^# ArgoX UFW NAT .* " ip_version " BEGIN$") {
        in_block=1
        next
      }
      if (in_block==1 && $0 ~ "^# ArgoX UFW NAT .* " ip_version " END$") {
        in_block=0
        next
      }
      if (in_block==0) print
    }
  ' "$RULES_FILE" > "$TEMP_RULES_FILE" && mv "$TEMP_RULES_FILE" "$RULES_FILE"
}

# 写入 UFW PortHopping NAT 规则
add_port_hopping_ufw_rules() {
  local PH_START=$1 PH_END=$2 TARGET_PORT=$3 COMMENT
  COMMENT="ArgoX UFW NAT ${PH_START}:${PH_END} -> ${TARGET_PORT}"
  [ -z "$PH_START" ] || [ -z "$PH_END" ] || [ -z "$TARGET_PORT" ] && return 1
  local UFW_BEFORE_RULES='/etc/ufw/before.rules'
  local UFW_BEFORE6_RULES='/etc/ufw/before6.rules'
  local UFW_IPV4_BLOCK_BEGIN="# ${COMMENT} IPv4 BEGIN"
  local UFW_IPV4_BLOCK_END="# ${COMMENT} IPv4 END"
  local UFW_IPV6_BLOCK_BEGIN="# ${COMMENT} IPv6 BEGIN"
  local UFW_IPV6_BLOCK_END="# ${COMMENT} IPv6 END"

  del_port_hopping_ufw_rules >/dev/null 2>&1
  add_port_hopping_ufw_block "$UFW_BEFORE_RULES" "$UFW_IPV4_BLOCK_BEGIN" "$UFW_IPV4_BLOCK_END" "$PH_START" "$PH_END" "$TARGET_PORT" "$COMMENT" || return 1
  add_port_hopping_ufw_block "$UFW_BEFORE6_RULES" "$UFW_IPV6_BLOCK_BEGIN" "$UFW_IPV6_BLOCK_END" "$PH_START" "$PH_END" "$TARGET_PORT" "$COMMENT" || return 1
  ufw delete allow ${PH_START}:${PH_END}/udp >/dev/null 2>&1 || true
  ufw allow ${PH_START}:${PH_END}/udp comment "$COMMENT" >/dev/null 2>&1 || return 1
  ufw reload >/dev/null 2>&1 || return 1
  [ "$(ufw status 2>/dev/null | awk '/^Status/{print $NF; exit}')" != 'active' ] && warning "\n $(text 116) \n"
  return 0
}

# 删除 UFW PortHopping NAT 规则
# 同时清理 allow 与 numbered 规则，避免重复残留
del_port_hopping_ufw_rules() {
  local UFW_BEFORE_RULES='/etc/ufw/before.rules'
  local UFW_BEFORE6_RULES='/etc/ufw/before6.rules'
  local COMMENT_PREFIX='ArgoX UFW NAT'
  local RULE_NUM OLD_START OLD_END
  check_port_hopping_ufw_rules
  OLD_START="$PORT_HOPPING_START"
  OLD_END="$PORT_HOPPING_END"
  del_port_hopping_ufw_block "$UFW_BEFORE_RULES" "IPv4" >/dev/null 2>&1
  del_port_hopping_ufw_block "$UFW_BEFORE6_RULES" "IPv6" >/dev/null 2>&1
  if [ -n "$OLD_START" ] && [ -n "$OLD_END" ]; then
    ufw delete allow ${OLD_START}:${OLD_END}/udp >/dev/null 2>&1 || true
  fi
  while read -r RULE_NUM; do
    [ -n "$RULE_NUM" ] && ufw --force delete "$RULE_NUM" >/dev/null 2>&1 || true
  done < <(ufw status numbered 2>/dev/null | grep "$COMMENT_PREFIX" | awk -F'[][]' '{print $2}' | sort -rn)
  ufw reload >/dev/null 2>&1 || return 1
  unset PORT_HOPPING_START PORT_HOPPING_END PORT_HOPPING_RANGE
  return 0
}

# 检查 UFW PortHopping NAT 规则
check_port_hopping_ufw_rules() {
  unset PORT_HOPPING_START PORT_HOPPING_END PORT_HOPPING_RANGE
  local DETECTED_TARGET
  local UFW_BEFORE_RULES='/etc/ufw/before.rules'
  local UFW_BEFORE6_RULES='/etc/ufw/before6.rules'
  local UFW_RULE=''

  [ -s $WORK_DIR/inbound.json ] && DETECTED_TARGET=$($WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "hysteria2") | .port] | .[0] // empty' $WORK_DIR/inbound.json 2>/dev/null)

  if [ -s "$UFW_BEFORE_RULES" ]; then
    UFW_RULE=$(awk '/ArgoX UFW NAT .* IPv4 BEGIN/ { in_block=1; next } /ArgoX UFW NAT .* IPv4 END/ { in_block=0 } in_block && /-A PREROUTING -p udp/ { print; exit }' "$UFW_BEFORE_RULES")
  fi
  if [ -z "$UFW_RULE" ] && [ -s "$UFW_BEFORE6_RULES" ]; then
    UFW_RULE=$(awk '/ArgoX UFW NAT .* IPv6 BEGIN/ { in_block=1; next } /ArgoX UFW NAT .* IPv6 END/ { in_block=0 } in_block && /-A PREROUTING -p udp/ { print; exit }' "$UFW_BEFORE6_RULES")
  fi

  [ -z "$UFW_RULE" ] && {
    PORT_HOPPING_TARGET="$DETECTED_TARGET"
    return 0
  }

  if [[ "$UFW_RULE" =~ --dport[[:space:]]+([0-9]+):([0-9]+) ]]; then
    PORT_HOPPING_START="${BASH_REMATCH[1]}"
    PORT_HOPPING_END="${BASH_REMATCH[2]}"
    PORT_HOPPING_RANGE="${PORT_HOPPING_START}:${PORT_HOPPING_END}"
  fi
  if [[ "$UFW_RULE" =~ --to-destination[[:space:]]+:([0-9]+) ]]; then
    PORT_HOPPING_TARGET="${BASH_REMATCH[1]}"
  else
    PORT_HOPPING_TARGET="$DETECTED_TARGET"
  fi
}

# 检测防火墙后端
check_firewall_backend() {
  local UFW_STATUS
  if command -v ufw >/dev/null 2>&1; then
    UFW_STATUS=$(ufw status 2>/dev/null | awk '/^Status/{print $NF; exit}')
    [ "$UFW_STATUS" = 'active' ] && { echo 'ufw'; return; }
  fi
  if [ "$SYSTEM" = 'Alpine' ]; then
    echo 'alpine-iptables'
  elif command -v firewall-cmd >/dev/null 2>&1 || [ "$SYSTEM" = 'CentOS' ]; then
    echo 'firewalld'
  else
    echo 'iptables'
  fi
}

# 初始化防火墙状态目录
init_firewall_state_dir() {
  [ ! -d "$FIREWALL_STATE_DIR" ] && mkdir -p "$FIREWALL_STATE_DIR"
}

# 读取上一次由脚本管理的普通端口规则
# 写入本次由脚本管理的普通端口规则
# 端口数组去重追加
append_unique_port() {
  local ARRAY_NAME=$1 PORT=$2
  local -n ARRAY_REF="$ARRAY_NAME"
  [ -z "$PORT" ] && return 0
  [[ ! "$PORT" =~ ^[0-9]+$ ]] && return 0
  local ITEM
  for ITEM in "${ARRAY_REF[@]}"; do [ "$ITEM" = "$PORT" ] && return 0; done
  ARRAY_REF+=("$PORT")
}

# 收集当前应该对外开放的普通端口
add_service_port_rule_ufw() { local COMMENT="ArgoX UFW PORT $1 $2"; [ -z "$1" ] || [ -z "$2" ] && return 1; ufw allow $2/$1 comment "$COMMENT" >/dev/null 2>&1; }
add_service_port_rule_firewalld() { [ -z "$1" ] || [ -z "$2" ] && return 1; firewall-cmd --zone=public --add-port=$2/$1 --permanent >/dev/null 2>&1; }
del_service_port_rule_firewalld() { [ -z "$1" ] || [ -z "$2" ] && return 0; firewall-cmd --zone=public --remove-port=$2/$1 --permanent >/dev/null 2>&1; }
service_port_iptables_comment() { echo "ArgoX PORT $1 $2"; }
add_service_port_rule_iptables() {
  local COMMENT; COMMENT=$(service_port_iptables_comment "$1" "$2")
  [ -z "$1" ] || [ -z "$2" ] && return 1
  iptables -C INPUT -p $1 --dport $2 -m comment --comment "$COMMENT" -j ACCEPT >/dev/null 2>&1 || iptables -A INPUT -p $1 --dport $2 -m comment --comment "$COMMENT" -j ACCEPT >/dev/null 2>&1
  ip6tables -C INPUT -p $1 --dport $2 -m comment --comment "$COMMENT" -j ACCEPT >/dev/null 2>&1 || ip6tables -A INPUT -p $1 --dport $2 -m comment --comment "$COMMENT" -j ACCEPT >/dev/null 2>&1
}
del_service_port_rule_iptables() {
  local COMMENT; COMMENT=$(service_port_iptables_comment "$1" "$2")
  [ -z "$1" ] || [ -z "$2" ] && return 0
  iptables -D INPUT -p $1 --dport $2 -m comment --comment "$COMMENT" -j ACCEPT >/dev/null 2>&1 || true
  ip6tables -D INPUT -p $1 --dport $2 -m comment --comment "$COMMENT" -j ACCEPT >/dev/null 2>&1 || true
}

# 将 iptables/ip6tables 规则持久化到文件，并创建多路径恢复钩子（兼容 OpenVZ）
# 调用顺序：1) 直接 iptables-save 写文件（最可靠）2) netfilter-persistent save（如果有）
save_iptables_rules() {
  # 确保目录存在
  mkdir -p /etc/iptables 2>/dev/null || true
  # 直接写文件——这是最可靠的持久化方式，不依赖 netfilter-persistent 是否正常工作
  iptables-save  > /etc/iptables/rules.v4  2>/dev/null || true
  ip6tables-save > /etc/iptables/rules.v6  2>/dev/null || true
  # 额外调用 netfilter-persistent save（如果可用）
  command -v netfilter-persistent >/dev/null 2>&1 && netfilter-persistent save >/dev/null 2>&1 || true
  # 安装 if-pre-up.d 钩子（OpenVZ / 无 systemd-networkd 场景的 fallback）
  install_iptables_restore_hooks
}

# 安装 iptables 规则恢复钩子，兼容 OpenVZ / 普通 Debian-Ubuntu 环境
# 路径优先级：/etc/network/if-pre-up.d > /etc/rc.local > systemd oneshot service
install_iptables_restore_hooks() {
  local HOOK_DIR='/etc/network/if-pre-up.d'
  local HOOK_FILE="${HOOK_DIR}/argox-iptables-restore"
  local RC_LOCAL='/etc/rc.local'

  # 1) if-pre-up.d 钩子（网络接口 UP 之前执行，OpenVZ 下最可靠）
  if [ -d "$HOOK_DIR" ]; then
    cat > "$HOOK_FILE" << 'EOF'
#!/bin/sh
# ArgoX iptables 规则恢复钩子（由 argox 脚本自动写入，勿手动删除）
[ -f /etc/iptables/rules.v4 ] && iptables-restore  < /etc/iptables/rules.v4  2>/dev/null || true
[ -f /etc/iptables/rules.v6 ] && ip6tables-restore < /etc/iptables/rules.v6  2>/dev/null || true
exit 0
EOF
    chmod +x "$HOOK_FILE" 2>/dev/null || true
  fi

  # 2) /etc/rc.local fallback（OpenVZ 常见引导方式）
  if [ -f "$RC_LOCAL" ]; then
    # 如果 rc.local 里已有 argox restore 行，不重复写
    if ! grep -q 'argox-iptables-restore\|argox iptables restore' "$RC_LOCAL" 2>/dev/null; then
      # 在 exit 0 之前插入恢复命令
      sed -i '/^exit 0/i # ArgoX iptables restore\n[ -f /etc/iptables/rules.v4 ] \&\& iptables-restore  < /etc/iptables/rules.v4  2>\/dev\/null || true\n[ -f /etc/iptables/rules.v6 ] \&\& ip6tables-restore < /etc/iptables/rules.v6  2>\/dev\/null || true' "$RC_LOCAL" 2>/dev/null || true
    fi
  else
    # rc.local 不存在时创建
    cat > "$RC_LOCAL" << 'EOF'
#!/bin/sh -e
# ArgoX iptables restore (auto-generated, do not remove)
[ -f /etc/iptables/rules.v4 ] && iptables-restore  < /etc/iptables/rules.v4  2>/dev/null || true
[ -f /etc/iptables/rules.v6 ] && ip6tables-restore < /etc/iptables/rules.v6  2>/dev/null || true
exit 0
EOF
    chmod +x "$RC_LOCAL" 2>/dev/null || true
    # 让 systemd 知道 rc.local 可执行
    systemctl enable rc-local >/dev/null 2>&1 || true
  fi
}

# 按后端保存 / 重载防火墙规则
reload_or_save_firewall_rules() {
  local FW_BACKEND
  FW_BACKEND=$(check_firewall_backend)
  case "$FW_BACKEND" in
    ufw ) ufw reload >/dev/null 2>&1 || true ;;
    firewalld ) firewall-cmd --reload >/dev/null 2>&1 || true ;;
    alpine-iptables ) rc-service iptables save >/dev/null 2>&1 || true; rc-service ip6tables save >/dev/null 2>&1 || true ;;
    * ) save_iptables_rules ;;
  esac
}

# 清理上一次由脚本管理的普通端口规则
purge_service_firewall_rules() {
  local FW_BACKEND PORT
  FW_BACKEND=$(check_firewall_backend)
  init_firewall_state_dir
  MANAGED_TCP_PORTS=()
  MANAGED_UDP_PORTS=()
  if [ -s "$SERVICE_FIREWALL_STATE_FILE" ]; then
    while read -r PROTO PORT; do
      case "$PROTO" in
        tcp ) MANAGED_TCP_PORTS+=("$PORT") ;;
        udp ) MANAGED_UDP_PORTS+=("$PORT") ;;
      esac
    done < "$SERVICE_FIREWALL_STATE_FILE"
  fi
  case "$FW_BACKEND" in
    ufw )
      while read -r RULE_NUM; do [ -n "$RULE_NUM" ] && ufw --force delete "$RULE_NUM" >/dev/null 2>&1 || true; done < <(ufw status numbered 2>/dev/null | grep 'ArgoX UFW PORT' | awk -F'[][]' '{print $2}' | sort -rn)
      ufw reload >/dev/null 2>&1 || true
      ;;
    firewalld )
      for PORT in "${MANAGED_TCP_PORTS[@]}"; do del_service_port_rule_firewalld tcp "$PORT"; done
      for PORT in "${MANAGED_UDP_PORTS[@]}"; do del_service_port_rule_firewalld udp "$PORT"; done
      ;;
    alpine-iptables|iptables )
      for PORT in "${MANAGED_TCP_PORTS[@]}"; do del_service_port_rule_iptables tcp "$PORT"; done
      for PORT in "${MANAGED_UDP_PORTS[@]}"; do del_service_port_rule_iptables udp "$PORT"; done
      ;;
  esac
  : > "$SERVICE_FIREWALL_STATE_FILE"
  reload_or_save_firewall_rules
}

# 同步普通服务端口规则
sync_service_firewall_rules() {
  local FW_BACKEND PORT TAG NGINX_PORT_NOW HAS_NGINX=false
  EXPOSED_TCP_PORTS=()
  EXPOSED_UDP_PORTS=()
  if [ -s "$WORK_DIR/inbound.json" ]; then
    [ -s "$WORK_DIR/nginx.conf" ] && HAS_NGINX=true
    while IFS=$'	' read -r TAG PORT; do
      [ -z "$TAG" ] || [ -z "$PORT" ] && continue
      TAG=${TAG##* }
      case "$TAG" in
        hysteria2) append_unique_port EXPOSED_UDP_PORTS "$PORT" ;;
        vless-ws|vmess-ws|trojan-ws|ss-ws|xhttp-h1.1-cdn) [ "$HAS_NGINX" = false ] && append_unique_port EXPOSED_TCP_PORTS "$PORT" ;;
        xhttp-h2-reality) append_unique_port EXPOSED_TCP_PORTS "$PORT" ;;
        xhttp-h3-direct) append_unique_port EXPOSED_UDP_PORTS "$PORT" ;;
        ss2022-direct) append_unique_port EXPOSED_TCP_PORTS "$PORT"; append_unique_port EXPOSED_UDP_PORTS "$PORT" ;;
        *) append_unique_port EXPOSED_TCP_PORTS "$PORT" ;;
      esac
    done < <($WORK_DIR/jq -r '.inbounds[] | [.tag, .port] | @tsv' "$WORK_DIR/inbound.json" 2>/dev/null)
    if [ "$HAS_NGINX" = true ]; then
      NGINX_PORT_NOW=$(awk '/listen[[:space:]]+[0-9]+[[:space:]]*;/{gsub(/;/, "", $2); print $2; exit}' "$WORK_DIR/nginx.conf")
      append_unique_port EXPOSED_TCP_PORTS "$NGINX_PORT_NOW"
    fi
  fi
  FW_BACKEND=$(check_firewall_backend)
  purge_service_firewall_rules
  case "$FW_BACKEND" in
    ufw )
      for PORT in "${EXPOSED_TCP_PORTS[@]}"; do add_service_port_rule_ufw tcp "$PORT"; done
      for PORT in "${EXPOSED_UDP_PORTS[@]}"; do add_service_port_rule_ufw udp "$PORT"; done
      ;;
    firewalld )
      for PORT in "${EXPOSED_TCP_PORTS[@]}"; do add_service_port_rule_firewalld tcp "$PORT"; done
      for PORT in "${EXPOSED_UDP_PORTS[@]}"; do add_service_port_rule_firewalld udp "$PORT"; done
      ;;
    alpine-iptables|iptables )
      for PORT in "${EXPOSED_TCP_PORTS[@]}"; do add_service_port_rule_iptables tcp "$PORT"; done
      for PORT in "${EXPOSED_UDP_PORTS[@]}"; do add_service_port_rule_iptables udp "$PORT"; done
      ;;
  esac
  init_firewall_state_dir
  : > "$SERVICE_FIREWALL_STATE_FILE"
  for PORT in "${EXPOSED_TCP_PORTS[@]}"; do [ -n "$PORT" ] && echo "tcp $PORT" >> "$SERVICE_FIREWALL_STATE_FILE"; done
  for PORT in "${EXPOSED_UDP_PORTS[@]}"; do [ -n "$PORT" ] && echo "udp $PORT" >> "$SERVICE_FIREWALL_STATE_FILE"; done
  reload_or_save_firewall_rules
}

# 同步 Hysteria2 端口跳跃规则
sync_port_hopping_firewall_rules() {
  local HY2_TARGET DESIRED_START DESIRED_END EXISTING_START EXISTING_END EXISTING_TARGET
  HY2_TARGET=$($WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "hysteria2") | .port] | .[0] // empty' "$WORK_DIR/inbound.json" 2>/dev/null)
  check_port_hopping_nat
  EXISTING_START="$PORT_HOPPING_START"
  EXISTING_END="$PORT_HOPPING_END"
  EXISTING_TARGET="$PORT_HOPPING_TARGET"
  DESIRED_START="${PORT_HOPPING_START:-$EXISTING_START}"
  DESIRED_END="${PORT_HOPPING_END:-$EXISTING_END}"
  if [ -z "$HY2_TARGET" ]; then
    [ -n "$EXISTING_START" ] && [ -n "$EXISTING_END" ] && del_port_hopping_nat
    unset PORT_HOPPING_START PORT_HOPPING_END PORT_HOPPING_RANGE PORT_HOPPING_TARGET
    return 0
  fi
  if [ -z "$DESIRED_START" ] || [ -z "$DESIRED_END" ]; then
    [ -n "$EXISTING_START" ] && [ -n "$EXISTING_END" ] && del_port_hopping_nat
    unset PORT_HOPPING_START PORT_HOPPING_END PORT_HOPPING_RANGE
    PORT_HOPPING_TARGET="$HY2_TARGET"
    return 0
  fi
  if [ "$EXISTING_START" != "$DESIRED_START" ] || [ "$EXISTING_END" != "$DESIRED_END" ] || [ "$EXISTING_TARGET" != "$HY2_TARGET" ]; then
    [ -n "$EXISTING_START" ] && [ -n "$EXISTING_END" ] && del_port_hopping_nat
    PORT_HOPPING_START="$DESIRED_START"
    PORT_HOPPING_END="$DESIRED_END"
    PORT_HOPPING_RANGE="${DESIRED_START}:${DESIRED_END}"
    PORT_HOPPING_TARGET="$HY2_TARGET"
    add_port_hopping_nat "$PORT_HOPPING_START" "$PORT_HOPPING_END" "$PORT_HOPPING_TARGET"
  fi
}

# 同步所有防火墙规则
sync_firewall_rules() {
  sync_service_firewall_rules
  sync_port_hopping_firewall_rules
}

# 清理所有由脚本管理的防火墙规则
purge_managed_firewall_rules() {
  local FW_BACKEND
  FW_BACKEND=$(check_firewall_backend)
  purge_service_firewall_rules
  case "$FW_BACKEND" in
    ufw )
      del_port_hopping_ufw_rules >/dev/null 2>&1 || true
      ;;
    * )
      del_port_hopping_nat >/dev/null 2>&1 || true
      ;;
  esac
}

# 按需安装端口跳跃所需的防火墙依赖
# 策略：UFW → 不安装 iptables / netfilter-persistent；Alpine → iptables；CentOS 或已装 firewalld → firewalld；其他 → iptables + netfilter-persistent
install_firewall_deps() {
  local FW_BACKEND FW_CHECK=() FW_INSTALL=() FW_TO_INSTALL=()
  FW_BACKEND=$(check_firewall_backend)
  case "$FW_BACKEND" in
    ufw )
      [ "$FIREWALL_SILENT" = '1' ] || info "\n $(text 115) \n"
      return 0
      ;;
    alpine-iptables )
      command -v iptables >/dev/null 2>&1 || FW_TO_INSTALL+=("iptables")
      ;;
    firewalld )
      command -v firewall-cmd >/dev/null 2>&1 || FW_TO_INSTALL+=("firewalld")
      ;;
    * )
      command -v iptables >/dev/null 2>&1 || FW_TO_INSTALL+=("iptables")
      if ! command -v netfilter-persistent >/dev/null 2>&1 ||
         ! dpkg -s iptables-persistent >/dev/null 2>&1; then
        FW_TO_INSTALL+=("iptables-persistent")
      fi
      ;;
  esac

  if [ "${#FW_TO_INSTALL[@]}" -gt 0 ]; then
    FW_TO_INSTALL=($(printf "%s\n" "${FW_TO_INSTALL[@]}" | sort -u))
    info "\n $(text 7) $(sed "s/ /,&/g" <<< "${FW_TO_INSTALL[*]}") \n"
    [ "$SYSTEM" != 'CentOS' ] && ${PACKAGE_UPDATE[int]} >/dev/null 2>&1
    ${PACKAGE_INSTALL[int]} "${FW_TO_INSTALL[@]}" >/dev/null 2>&1
  fi
  if [ "$FW_BACKEND" = 'firewalld' ]; then
    [ "$(systemctl is-active firewalld 2>/dev/null)" != 'active' ] && cmd_systemctl enable firewalld >/dev/null 2>&1
    [ "$(firewall-cmd --zone=public --get-target 2>/dev/null)" != 'ACCEPT' ] && firewall-cmd --zone=public --set-target=ACCEPT --permanent >/dev/null 2>&1
    firewall-cmd --reload >/dev/null 2>&1
  elif [ "$FW_BACKEND" != 'ufw' ] && [ "$FW_BACKEND" != 'alpine-iptables' ]; then
    # 普通 iptables 后端：
    # 1) 确保 netfilter-persistent 开机自启（主路径）
    # 2) 安装 if-pre-up.d / rc.local 恢复钩子（OpenVZ fallback）
    if command -v netfilter-persistent >/dev/null 2>&1; then
      systemctl enable netfilter-persistent >/dev/null 2>&1 || true
    fi
    install_iptables_restore_hooks
  fi
}

# 添加端口跳跃 NAT 规则
add_port_hopping_nat() {
  local HOP_START=$1 HOP_END=$2 HOP_TARGET=$3 FW_BACKEND COMMENT
  [[ -z "$HOP_START" || -z "$HOP_END" || -z "$HOP_TARGET" ]] && return 1
  install_firewall_deps
  FW_BACKEND=$(check_firewall_backend)
  COMMENT="NAT ${HOP_START}:${HOP_END} to ${HOP_TARGET} (ArgoX)"
  case "$FW_BACKEND" in
    ufw )
      add_port_hopping_ufw_rules "$HOP_START" "$HOP_END" "$HOP_TARGET" || warning "\n $(text 117) \n"
      ;;
    alpine-iptables )
      iptables --table nat -A PREROUTING -p udp --dport ${HOP_START}:${HOP_END} -m comment --comment "$COMMENT" -j DNAT --to-destination :${HOP_TARGET} 2>/dev/null
      ip6tables --table nat -A PREROUTING -p udp --dport ${HOP_START}:${HOP_END} -m comment --comment "$COMMENT" -j DNAT --to-destination :${HOP_TARGET} 2>/dev/null
      rc-update show default | grep -q 'iptables' || rc-update add iptables >/dev/null 2>&1
      rc-update show default | grep -q 'ip6tables' || rc-update add ip6tables >/dev/null 2>&1
      rc-service iptables save >/dev/null 2>&1
      rc-service ip6tables save >/dev/null 2>&1
      ;;
    firewalld )
      [ "$(firewall-cmd --zone=public --query-masquerade --permanent 2>/dev/null)" != 'yes' ] && firewall-cmd --zone=public --add-masquerade --permanent >/dev/null 2>&1
      firewall-cmd --zone=public --add-forward-port=port=${HOP_START}-${HOP_END}:proto=udp:toport=${HOP_TARGET} --permanent >/dev/null 2>&1
      firewall-cmd --reload >/dev/null 2>&1
      ;;
    * )
      iptables --table nat -A PREROUTING -p udp --dport ${HOP_START}:${HOP_END} -m comment --comment "$COMMENT" -j DNAT --to-destination :${HOP_TARGET} 2>/dev/null
      ip6tables --table nat -A PREROUTING -p udp --dport ${HOP_START}:${HOP_END} -m comment --comment "$COMMENT" -j DNAT --to-destination :${HOP_TARGET} 2>/dev/null
      save_iptables_rules
      ;;
  esac
}

# 删除端口跳跃 NAT 规则
del_port_hopping_nat() {
  check_port_hopping_nat
  [ -z "$PORT_HOPPING_START" ] && return
  local FW_BACKEND COMMENT
  FW_BACKEND=$(check_firewall_backend)
  COMMENT="NAT ${PORT_HOPPING_START}:${PORT_HOPPING_END} to ${PORT_HOPPING_TARGET} (ArgoX)"
  case "$FW_BACKEND" in
    ufw )
      del_port_hopping_ufw_rules || warning "\n $(text 117) \n"
      ;;
    alpine-iptables )
      iptables --table nat -D PREROUTING -p udp --dport ${PORT_HOPPING_START}:${PORT_HOPPING_END} -m comment --comment "$COMMENT" -j DNAT --to-destination :${PORT_HOPPING_TARGET} 2>/dev/null
      ip6tables --table nat -D PREROUTING -p udp --dport ${PORT_HOPPING_START}:${PORT_HOPPING_END} -m comment --comment "$COMMENT" -j DNAT --to-destination :${PORT_HOPPING_TARGET} 2>/dev/null
      rc-service iptables save >/dev/null 2>&1
      rc-service ip6tables save >/dev/null 2>&1
      ;;
    firewalld )
      firewall-cmd --zone=public --permanent --remove-forward-port=port=${PORT_HOPPING_START}-${PORT_HOPPING_END}:proto=udp:toport=${PORT_HOPPING_TARGET} >/dev/null 2>&1
      firewall-cmd --reload >/dev/null 2>&1
      ;;
    * )
      iptables --table nat -D PREROUTING -p udp --dport ${PORT_HOPPING_START}:${PORT_HOPPING_END} -m comment --comment "$COMMENT" -j DNAT --to-destination :${PORT_HOPPING_TARGET} 2>/dev/null
      ip6tables --table nat -D PREROUTING -p udp --dport ${PORT_HOPPING_START}:${PORT_HOPPING_END} -m comment --comment "$COMMENT" -j DNAT --to-destination :${PORT_HOPPING_TARGET} 2>/dev/null
      save_iptables_rules
      ;;
  esac
}

# 检查端口跳跃 NAT 规则（读取当前 UFW / iptables / firewalld）
check_port_hopping_nat() {
  local FW_BACKEND LIST
  FW_BACKEND=$(check_firewall_backend)
  unset PORT_HOPPING_START PORT_HOPPING_END PORT_HOPPING_RANGE PORT_HOPPING_TARGET
  [ -s $WORK_DIR/inbound.json ] && PORT_HOPPING_TARGET=$($WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "hysteria2") | .port] | .[0] // empty' $WORK_DIR/inbound.json 2>/dev/null)
  [ -z "$PORT_HOPPING_TARGET" ] && return
  case "$FW_BACKEND" in
    ufw )
      check_port_hopping_ufw_rules
      # 若 UFW 规则已被清空，仍保留当前 Hysteria2 监听端口，方便后续重新启用端口跳跃
      [ -z "$PORT_HOPPING_TARGET" ] && PORT_HOPPING_TARGET=$($WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "hysteria2") | .port] | .[0] // empty' $WORK_DIR/inbound.json 2>/dev/null)
      ;;
    alpine-iptables|iptables )
      LIST=$(iptables --table nat --list-rules PREROUTING 2>/dev/null | grep 'ArgoX')
      [ -n "$LIST" ] && PORT_HOPPING_RANGE=$(awk '{for(i=0;i<NF;i++) if($i=="--dport"){print $(i+1);exit}}' <<< "$LIST") && PORT_HOPPING_TARGET=$(awk '{for(i=0;i<NF;i++) if($i=="to"){print $(i+1);exit}}' <<< "$LIST")
      ;;
    firewalld )
      LIST=$(firewall-cmd --zone=public --list-all --permanent 2>/dev/null | grep "toport=${PORT_HOPPING_TARGET}")
      [ -n "$LIST" ] && PORT_HOPPING_START=$(sed "s/.*port=\([^-]\+\)-.*toport.*/\1/" <<< "$LIST") && PORT_HOPPING_END=$(sed "s/.*port=${PORT_HOPPING_START}-\([^:]\+\):.*/\1/" <<< "$LIST")
      ;;
  esac
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

# ===== Hysteria2 Realm 函数 =====

# 检测当前 Hysteria2 Realm 状态
# 通过检查 inbound.json 中 hysteria2 inbound 的 streamSettings 是否包含 finalmask
detect_hy2_realm_status() {
  [ -s "$WORK_DIR/inbound.json" ] || return 1
  local _json
  _json=$(grep -v '^//' "$WORK_DIR/inbound.json" 2>/dev/null)
  [ -z "$_json" ] && return 1
  local _has_finalmask
  _has_finalmask=$(echo "$_json" | $WORK_DIR/jq -r '.inbounds[] | select(.tag | endswith("hysteria2")) | .streamSettings.finalmask // empty' 2>/dev/null)
  [ -n "$_has_finalmask" ] && return 0 || return 1
}

# 构造 finalmask JSON 块（不带逗号前缀，用于 cat << JSONEOF 嵌入）
# 参数 $1: realm_id（UUID）
# 输出到 stdout
build_finalmask_block() {
  local _realm_id="$1"
  cat << JSONEOF
,
        "finalmask": {
          "udp": [
            {
              "type": "realm",
              "settings": {
                "url": "realm://public@realm.hy2.io:443/${_realm_id}",
                "stunServers": [
                  "stun.nextcloud.com:3478",
                  "stun.sip.us:3478",
                  "turn.cloudflare.com:3478",
                  "global.stun.twilio.com:3478"
                ]
              }
            }
          ],
          "quicParams": {
            "congestion": "bbr"
          }
        }
JSONEOF
}

# 构造 finalmask JSON 字符串（紧凑格式，用于 change_protocols 的 jq --argjson 注入）
# 参数 $1: realm_id（UUID）
# 输出 finalmask 对象的 JSON 字符串
build_finalmask_json_str() {
  local _realm_id="$1"
  printf '{"udp":[{"type":"realm","settings":{"url":"realm://public@realm.hy2.io:443/%s","stunServers":["stun.nextcloud.com:3478","stun.sip.us:3478","turn.cloudflare.com:3478","global.stun.twilio.com:3478"]}}],"quicParams":{"congestion":"bbr"}}' "$_realm_id"
}

# 交互输入是否启用 Hysteria2 Realm
input_hy2_realm() {
  # 长参数模式：--HY2_REALM 已传参（无论 true/false），跳过交互
  [ "$SKIP_MENU" = 'skip_menu' ] && [ -n "$HY2_REALM_SET" ] && return
  if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL"; then
    reading "\n $(text 125) " HY2_REALM_ANSWER
  fi
  if [[ "${HY2_REALM_ANSWER,,}" =~ ^(y|yes)$ ]]; then
    IS_HY2_REALM=is_hy2_realm
  else
    unset IS_HY2_REALM
  fi
}

# 交互输入是否启用 WARP 辅助打洞
input_hy2_warp() {
  # 仅在 Realm 已启用且非交互模式下询问
  [ "$IS_HY2_REALM" != 'is_hy2_realm' ] && return
  # 长参数模式：--HY2_WARP 已传参（无论 true/false），跳过交互
  [ "$SKIP_MENU" = 'skip_menu' ] && [ -n "$HY2_WARP_SET" ] && return
  if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL"; then
    reading "\n $(text 126) " HY2_WARP_ANSWER
  fi
  if [[ "${HY2_WARP_ANSWER,,}" =~ ^(y|yes)$ ]]; then
    IS_HY2_WARP=is_hy2_warp
  else
    unset IS_HY2_WARP
  fi
}

# 注入/删除 finalmask（服务端配置）
# 参数 $1: enable 或 disable
set_hy2_realm_config() {
  local _action="$1"
  local _json _ib="$WORK_DIR/inbound.json" _ib_tmp="$TEMP_DIR/inbound_tmp.json"
  [ -s "$_ib" ] || return 1
  _json=$(grep -v '^//' "$_ib" 2>/dev/null) || return 1

  if [ "$_action" = 'enable' ]; then
    # 注入 finalmask
    local _realm_id="${HY2_REALM_ID:-$UUID}"
    local _finalmask_json
    _finalmask_json=$(build_finalmask_json_str "$_realm_id")
    echo "$_json" | $WORK_DIR/jq --argjson fm "$_finalmask_json" \
      '(.inbounds[] | select(.tag | endswith("hysteria2")) | .streamSettings.finalmask) |= $fm' \
      > "$_ib_tmp" && mv "$_ib_tmp" "$_ib"
  elif [ "$_action" = 'disable' ]; then
    # 删除 finalmask
    echo "$_json" | $WORK_DIR/jq \
      'del(.inbounds[] | select(.tag | endswith("hysteria2")) | .streamSettings.finalmask)' \
      > "$_ib_tmp" && mv "$_ib_tmp" "$_ib"
  fi
}

# 增删 WARP 路由规则
# 参数 $1: enable 或 disable
# WARP 规则格式：{"type":"field","inboundTag":["MyNode hysteria2"],"outboundTag":"warp-IPv4"}
# 注意 1：WARP 路由规则写入 outbound.json 而非 inbound.json，原因：
# Xray 以 xray run -c inbound.json -c outbound.json 启动时，对于 object 类型顶级键（如 routing），
# 后加载的 outbound.json 会覆盖 inbound.json。若 WARP 规则写入 inbound.json，会被 outbound.json
# 的 routing（ChatGPT 规则）覆盖，导致 WARP 路由永不生效。
# 注意 2：WARP 打洞需要同时添加 warp-IPv4 和 warp-IPv6 两条规则，否则 UDP 打洞可能失败
sync_hy2_warp_route() {
  local _action="$1"
  # inbound.json 用于获取 hysteria2 的 inboundTag 名称
  local _ib="$WORK_DIR/inbound.json"
  # outbound.json 用于读写 WARP 路由规则
  local _ob="$WORK_DIR/outbound.json" _ob_tmp="$TEMP_DIR/outbound_tmp.json"
  [ -s "$_ob" ] || return 1
  local _json
  _json=$(grep -v '^//' "$_ob" 2>/dev/null) || return 1

  if [ "$_action" = 'enable' ]; then
    # 从 inbound.json 获取 inboundTag 名称
    [ -s "$_ib" ] || return 1
    local _ib_json
    _ib_json=$(grep -v '^//' "$_ib" 2>/dev/null) || return 1
    local _hy2_tag
    _hy2_tag=$(echo "$_ib_json" | $WORK_DIR/jq -r '.inbounds[] | select(.tag | endswith("hysteria2")) | .tag // empty' 2>/dev/null)
    [ -z "$_hy2_tag" ] && return 1

    # 检查是否已存在 v4 或 v6 规则（注意：| 比 and 优先级高，需用括号包裹 pipe 表达式）
    local _exists
    _exists=$(echo "$_json" | $WORK_DIR/jq -r --arg tag "$_hy2_tag" \
      '.routing.rules // [] | any((.inboundTag // [] | contains([$tag])) and (.outboundTag == "warp-IPv4" or .outboundTag == "warp-IPv6"))' 2>/dev/null)
    [ "$_exists" = 'true' ] && return 0

    # 构建 v4 + v6 两条规则
    local _warp_rules
    _warp_rules=$(printf '[{"type":"field","inboundTag":["%s"],"outboundTag":"warp-IPv4"},{"type":"field","inboundTag":["%s"],"outboundTag":"warp-IPv6"}]' "$_hy2_tag" "$_hy2_tag")

    # 在 routing 最前面插入 WARP 路由规则（优先级高于 ChatGPT 兜底规则）
    echo "$_json" | $WORK_DIR/jq --argjson rules "$_warp_rules" \
      '.routing.rules = $rules + .routing.rules' \
      > "$_ob_tmp" && mv "$_ob_tmp" "$_ob"
  elif [ "$_action" = 'disable' ]; then
    # 删除匹配 inboundTag 的 WARP v4 和 v6 路由规则（从 outbound.json 操作）
    echo "$_json" | $WORK_DIR/jq \
      'if .routing then del(.routing.rules[] | select((.inboundTag // [] | any(endswith("hysteria2"))) and (.outboundTag == "warp-IPv4" or .outboundTag == "warp-IPv6"))) else . end' \
      > "$_ob_tmp" && mv "$_ob_tmp" "$_ob"
  fi
}

# 处理 Hysteria2 Realm 开关（统一入口，被菜单和安装流程调用）
# 参数 $1: enable 或 disable
# 无参数时根据 IS_HY2_REALM 和 IS_HY2_WARP 自动执行
handle_hy2_realm() {
  local _action="${1:-}" _hy2_tag
  [ -z "$_action" ] && _action="$([ "$IS_HY2_REALM" = 'is_hy2_realm' ] && echo 'enable' || echo 'disable')"

  if [ "$_action" = 'enable' ]; then
    set_hy2_realm_config enable
    [ "$IS_HY2_WARP" = 'is_hy2_warp' ] && sync_hy2_warp_route enable
  else
    set_hy2_realm_config disable
    sync_hy2_warp_route disable
  fi

  # 提取受影响的 hysteria2 inbound tag，强制热更新（因增量 diff 只对比 tag，不对比内容）
  _hy2_tag=$(grep -v '^//' "$WORK_DIR/inbound.json" | $WORK_DIR/jq -r '.inbounds[] | select(.tag | endswith("hysteria2")) | .tag // empty' 2>/dev/null)
  api_hot_reload inbounds ${_hy2_tag:+"$_hy2_tag"}
  api_hot_reload routing_rules
  info "\n $(text 128) \n"
  export_list
}

# 处理防火墙规则

# ===================== nginx 进程管理（统一 WORK_DIR 限定检测）=====================
# 获取本脚本管理的 nginx master PID（限定 $WORK_DIR/nginx.conf）
nginx_pid() {
  ps -eo pid,args | awk -v d="$WORK_DIR" '$0~(d"/nginx.conf") && /nginx: master process/{print $1;exit}'
}

# 同步脚本 nginx：需要则启动/热重载，不需要则停止（状态收敛）
# - nginx.conf 存在：已在运行则 reload，未运行则启动（失败不阻塞）
# - nginx.conf 不存在：停止可能残留的脚本 nginx
nginx_sync() {
  [ -s $WORK_DIR/nginx.conf ] || { nginx_stop; return; }
  local _NGINX_PID=$(nginx_pid) _NGINX_BIN
  if [ -n "$_NGINX_PID" ]; then
    nginx -c $WORK_DIR/nginx.conf -s reload >/dev/null 2>&1 || true
  else
    _NGINX_BIN=$(command -v nginx)
    [ -n "$_NGINX_BIN" ] && $_NGINX_BIN -c $WORK_DIR/nginx.conf >/dev/null 2>&1 || true
  fi
}

# 停止脚本管理的 nginx（优雅退出后强杀兜底）
nginx_stop() {
  local _NGINX_PID=$(nginx_pid)
  if [ -n "$_NGINX_PID" ]; then
    kill -QUIT "$_NGINX_PID" 2>/dev/null
    sleep 1
    kill -9 "$_NGINX_PID" 2>/dev/null || true
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
    _PORT_XH=$(echo "$JSON_CLEAN" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "xhttp-h1.1-cdn") | .port] | .[0] // empty' 2>/dev/null)
  fi
  _PORT_VL=${_PORT_VL:-${VLESS_WS_PORT}}
  _PORT_VM=${_PORT_VM:-${VMESS_WS_PORT}}
  _PORT_TR=${_PORT_TR:-${TROJAN_WS_PORT}}
  _PORT_SH=${_PORT_SH:-${SS_WS_PORT}}
  _PORT_XH=${_PORT_XH:-${VLESS_XHTTP_PORT}}

  _add_location() { SERVER_BLOCK+="$1"; SERVER_BLOCK+=$'\n\n'; }
  grep -q 'vless-ws' <<< "$PROTOCOLS_NOW" && _add_location "$(_ws_location "/${WS_PATH}-vl" "$_PORT_VL")"
  grep -q 'vmess-ws' <<< "$PROTOCOLS_NOW" && _add_location "$(_ws_location "/${WS_PATH}-vm" "$_PORT_VM")"
  grep -q 'trojan-ws' <<< "$PROTOCOLS_NOW" && _add_location "$(_ws_location "/${WS_PATH}-tr" "$_PORT_TR")"
  grep -qw 'ss-ws' <<< "$PROTOCOLS_NOW" && _add_location "$(_ws_location "/${WS_PATH}-sh" "$_PORT_SH")"
  grep -q 'xhttp-h1.1-cdn' <<< "$PROTOCOLS_NOW" && _add_location "$(_xhttp_location "/${WS_PATH}-xh" "${_PORT_XH}")"
  # 订阅路由：仅 IS_SUB=is_sub 时生成
  local SUB_BLOCK=''
  if [ "$IS_SUB" = 'is_sub' ]; then
    SUB_BLOCK=$(printf '    location ~ ^/%s/auto {
      default_type  text/plain;
      alias         %s/subscribe/$path;
    }

    location ~ ^/%s/(.*) {
      autoindex     on;
      default_type  text/plain;
      alias         %s/subscribe/$1;
    }\n' "$UUID" "$WORK_DIR" "$UUID" "$WORK_DIR")
  fi
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
    ~*v2rayN              /v2rayn;
    ~*Throne|Neko         /throne;
    ~*clash               /clash;
    ~*ShadowRocket        /shadowrocket;
    ~*SFM|SFI|SFA         /sing-box;
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
  [ -z "$ARGO_JSON" ] && [ -s "$WORK_DIR/tunnel.json" ] && ARGO_JSON=$(tr -d '
' < "$WORK_DIR/tunnel.json")
  [ ! -s "$WORK_DIR/tunnel.json" ] && [ -n "$ARGO_JSON" ] && echo "$ARGO_JSON" > "$WORK_DIR/tunnel.json"

  [ -z "$ARGO_DOMAIN" ] && [ -s "$WORK_DIR/tunnel.yml" ] && ARGO_DOMAIN=$(awk '/^[[:space:]]*- hostname:/{print $3; exit}' "$WORK_DIR/tunnel.yml" 2>/dev/null)
  [ -z "$ARGO_DOMAIN" ] && fetch_tunnel_domain config >/dev/null 2>&1 || true
  [ -z "$ARGO_DOMAIN" ] && [ -s "$WORK_DIR/list" ] && ARGO_DOMAIN=$(grep -m1 '^vless.*host=.*' "$WORK_DIR/list" | sed 's@.*host=\([^&]*\).*@@')
  [ -z "$ARGO_DOMAIN" ] && return 1

  [ -z "$NGINX_PORT" ] && [ -s "$WORK_DIR/nginx.conf" ] && NGINX_PORT=$(awk '/listen[[:space:]]/{gsub(/;/, "", $2); print $2; exit}' "$WORK_DIR/nginx.conf")
  NGINX_PORT="${NGINX_PORT:-$NGINX_PORT_DEFAULT}"

  cat > $WORK_DIR/tunnel.yml << EOF
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
  [ -s "$WORK_DIR/inbound.json" ] && [ -x "$WORK_DIR/jq" ] && WS_PATH=$(grep -v '^//' "$WORK_DIR/inbound.json" | $WORK_DIR/jq -r '[.inbounds[] | select((.tag | split(" ")[-1]) == "xhttp-h1.1-cdn") | .streamSettings.xhttpSettings.path] | .[0] // empty' 2>/dev/null | sed 's|^/||; s|-xh$||')
  WS_PATH="${WS_PATH:-$WS_PATH_DEFAULT}"
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
  for _p in "${INSTALL_PROTOCOLS[@]}"; do [[ "$_p" =~ ^[bdj]$ ]] && _HAS_REALITY_INSTALL=true && break; done
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

  # ChatGPT 解锁检测，决定 OpenAI 路由的 outboundTag（direct / warp-IPv4 / warp-IPv6）
  if [[ "$SERVER_IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    CHATGPT_STACK='-4'
  elif [[ "$SERVER_IP" =~ ^[0-9a-fA-F:]+$ && "$SERVER_IP" =~ : ]]; then
    CHATGPT_STACK='-6'
  else
    # 域名为 NAT 场景的动态地址，交由 wget 按系统默认栈解析
    CHATGPT_STACK=''
  fi
  if [ "$(check_chatgpt ${CHATGPT_STACK})" = 'unlock' ]; then
    CHAT_GPT_OUT_V4=direct && CHAT_GPT_OUT_V6=direct
  else
    CHAT_GPT_OUT_V4=warp-IPv4 && CHAT_GPT_OUT_V6=warp-IPv6
  fi

  [ ! -d /etc/systemd/system ] && mkdir -p /etc/systemd/system
  mkdir -p $WORK_DIR/subscribe
  [ "$L" = 'C' ] && write_custom 'language' 'Chinese' || write_custom 'language' 'English'
  write_custom 'serverIp' "${SERVER_IP}"
  write_custom 'privateKey' "${REALITY_PRIVATE:-__KEY_UNSET__}"
  write_custom 'publicKey' "${REALITY_PUBLIC:-__KEY_UNSET__}"
  write_custom 'cdn' "${SERVER:-__CDN_UNSET__}"
  write_custom 'cdnPort' "${SERVER_PORT:-443}"
  write_custom 'isSub' "${IS_SUB}"
  write_custom 'isArgo' "${IS_ARGO}"
  [ -s "$VARIABLE_FILE" ] && cp $VARIABLE_FILE $WORK_DIR/

  wait
  # 通用工具复制
  [[ ! -s $WORK_DIR/jq && -x $TEMP_DIR/jq ]] && mv $TEMP_DIR/jq $WORK_DIR
  [[ "$INSTALL_NGINX" != 'n' && ! -s $WORK_DIR/qrencode && -x $TEMP_DIR/qrencode ]] && mv $TEMP_DIR/qrencode $WORK_DIR
  # cloudflared：后台已下载到 TEMP_DIR，需要时才复制到 WORK_DIR
  if [ "$IS_ARGO" = 'is_argo' ]; then
    [[ ! -s $WORK_DIR/cloudflared && -x $TEMP_DIR/cloudflared ]] && mv $TEMP_DIR/cloudflared $WORK_DIR
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
    fi
  else
    # 没有 Argo 需要的协议，清理已存在的二进制和守护进程
    rm -f $WORK_DIR/cloudflared
    if [ -s "${ARGO_DAEMON_FILE}" ]; then
      cmd_systemctl disable argo 2>/dev/null
      if [ "$SYSTEM" = 'Alpine' ]; then
        rm -f /etc/init.d/argo
      else
        rm -f ${ARGO_DAEMON_FILE}
      fi
    fi
    rm -f $WORK_DIR/tunnel.json $WORK_DIR/tunnel.yml
  fi  # end IS_ARGO=is_argo

  # 写 xray 守护进程文件：Alpine → OpenRC init.d；其他 → systemd unit
  # 注意：放 IS_ARGO fi 块外统一处理，确保 IS_ARGO=false（直连协议）时 Alpine 也能正确生成 xray 守护脚本
  if [ "$SYSTEM" = 'Alpine' ]; then
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
        XRAY_PIDS="\$(ps -eo pid,args | awk -v work_dir="$WORK_DIR" '\$0~(work_dir"/xray run"){print \$1;exit}')"
        if [ -n "\$XRAY_PIDS" ]; then
            for pid in \$XRAY_PIDS; do
                kill -9 "\$pid" 2>/dev/null
            done
        fi
    fi
    if [ -s ${WORK_DIR}/nginx.conf ] && command -v /usr/sbin/nginx >/dev/null 2>&1; then
        local NGINX_MASTER
        NGINX_MASTER="\$(ps -eo pid,args | awk -v d='${WORK_DIR}' '\$0~(d\"/nginx.conf\") && /nginx: master process/{print \$1;exit}')"
        if [ -n "\$NGINX_MASTER" ]; then
            kill -QUIT \$NGINX_MASTER 2>/dev/null
            sleep 1
            kill -9 \$NGINX_MASTER 2>/dev/null || true
        fi
    fi
    rm -f "\$pidfile"
    eend 0
}
EOF
    chmod +x ${XRAY_DAEMON_FILE}
  else
    local XRAY_SERVICE="[Unit]
Description=Xray Service
Documentation=https://github.com/XTLS/Xray-core
After=network.target

[Service]
User=root"
    [[ "$INSTALL_NGINX" != 'n' ]] && XRAY_SERVICE+="
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

  if [[ " ${INSTALL_PROTOCOLS[*]} " =~ " c " ]] || [[ " ${INSTALL_PROTOCOLS[*]} " =~ " k " ]] || [[ " ${INSTALL_PROTOCOLS[*]} " =~ " l " ]]; then
    ssl_certificate "${TLS_SERVER}"
  fi
  if [[ " ${INSTALL_PROTOCOLS[*]} " =~ " c " ]]; then
    [ "$IS_HOPPING" = 'is_hopping' ] && add_port_hopping_nat "$PORT_HOPPING_START" "$PORT_HOPPING_END" "$HY2_PORT"
  fi

  local INBOUNDS_JSON=''
  local FIRST=true

  # Hysteria2 Realm: 预生成 finalmask JSON 块（用于 HERE-doc 注入）
  local HY2_FINALMASK_BLOCK=''
  if [[ " ${INSTALL_PROTOCOLS[*]} " =~ " c " ]] && [ "$IS_HY2_REALM" = 'is_hy2_realm' ]; then
    HY2_FINALMASK_BLOCK=$(build_finalmask_block "${HY2_REALM_ID:-$UUID}")
  fi

  local SS2022_PASSWORD=${SS2022_PASSWORD:-"$(openssl rand -base64 16)"}
  for proto in "${INSTALL_PROTOCOLS[@]}"; do
    local BLOCK=''
    case "$proto" in
      b)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} ${NODE_TAG[0]}",
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
          "minClientVer": "1.0.0",
          "dest": "${TLS_SERVER}:443",
          "serverNames": [
            "${TLS_SERVER}"
          ],
          "privateKey": "${REALITY_PRIVATE}",
          "publicKey": "${REALITY_PUBLIC}",
          "shortIds": [
            ""
          ]
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
JSONEOF
)
        ;;
      c)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} ${NODE_TAG[1]}",
      "protocol": "hysteria",
      "port": ${HY2_PORT},
      "settings": {
        "version": 2,
        "clients": [
          {
            "auth": "${UUID}"
          }
        ]
      },
      "streamSettings": {
        "network": "hysteria",
        "security": "tls",
        "tlsSettings": {
          "serverNames": [
            "${TLS_SERVER}"
          ],
          "alpn": [
            "h3"
          ],
          "certificates": [
            {
              "certificateFile": "${WORK_DIR}/cert/cert.pem",
              "keyFile": "${WORK_DIR}/cert/private.key"
            }
          ]
        }${HY2_FINALMASK_BLOCK}
      }
    }
JSONEOF
)
        ;;
      d)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} ${NODE_TAG[2]}",
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
          "minClientVer": "1.0.0",
          "dest": "${TLS_SERVER}:443",
          "xver": 0,
          "serverNames": [
            "${TLS_SERVER}"
          ],
          "privateKey": "${REALITY_PRIVATE}",
          "publicKey": "${REALITY_PUBLIC}",
          "shortIds": [
            ""
          ]
        },
        "grpcSettings": {
          "serviceName": "grpc",
          "multiMode": true
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
JSONEOF
)
        ;;
      e)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} ${NODE_TAG[3]}",
      "protocol": "vless",
      "port": ${VLESS_WS_PORT},
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
        "destOverride": [
          "http",
          "tls",
          "quic"
        ],
        "metadataOnly": false
      }
    }
JSONEOF
)
        ;;
      f)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} ${NODE_TAG[4]}",
      "protocol": "vmess",
      "port": ${VMESS_WS_PORT},
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
        "destOverride": [
          "http",
          "tls",
          "quic"
        ],
        "metadataOnly": false
      }
    }
JSONEOF
)
        ;;
      g)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} ${NODE_TAG[5]}",
      "protocol": "trojan",
      "port": ${TROJAN_WS_PORT},
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
        "destOverride": [
          "http",
          "tls",
          "quic"
        ],
        "metadataOnly": false
      }
    }
JSONEOF
)
        ;;
      h)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} ${NODE_TAG[6]}",
      "protocol": "shadowsocks",
      "port": ${SS_WS_PORT},
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
        "destOverride": [
          "http",
          "tls",
          "quic"
        ],
        "metadataOnly": false
      }
    }
JSONEOF
)
        ;;
      i)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} ${NODE_TAG[7]}",
      "protocol": "vless",
      "port": ${VLESS_XHTTP_PORT},
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
        "security": "none",
        "xhttpSettings": {
          "mode": "auto",
          "path": "/${WS_PATH}-xh"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls",
          "quic"
        ],
        "metadataOnly": false
      }
    }
JSONEOF
)
        ;;
      j)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} ${NODE_TAG[8]}",
      "port": ${XHTTP_H2_PORT},
      "protocol": "vless",
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
        "network": "xhttp",
        "xhttpSettings": {
          "mode": "auto",
          "path": "/${WS_PATH}-xh2"
        },
        "security": "reality",
        "realitySettings": {
          "show": false,
          "minClientVer": "1.0.0",
          "dest": "${TLS_SERVER}:443",
          "xver": 0,
          "serverNames": [
            "${TLS_SERVER}"
          ],
          "privateKey": "${REALITY_PRIVATE}",
          "publicKey": "${REALITY_PUBLIC}",
          "shortIds": [
            ""
          ],
          "alpn": [
            "h2"
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
      "tag": "${NODE_NAME} ${NODE_TAG[9]}",
      "port": ${XHTTP_PORT},
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
          "serverName": "${TLS_SERVER}",
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
      l)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} ${NODE_TAG[10]}",
      "protocol": "trojan",
      "port": ${TROJAN_PORT},
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
        "destOverride": [
          "http",
          "tls",
          "quic"
        ],
        "metadataOnly": false
      }
    }
JSONEOF
)
        ;;
      m)
        BLOCK=$(cat << JSONEOF
    {
      "tag": "${NODE_NAME} ${NODE_TAG[11]}",
      "protocol": "shadowsocks",
      "port": ${SS2022_PORT},
      "settings": {
        "method": "2022-blake3-aes-128-gcm",
        "password": "${SS2022_PASSWORD}",
        "network": "tcp,udp"
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls",
          "quic"
        ],
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

  # 为 API 分配端口（写入 inbound.json 的 api.listen，custom 不保存该字段）
  local _api_port
  _api_port=$(find_free_port 10000 65535)

  cat > $WORK_DIR/inbound.json << EOF
{
  "api": {
    "tag": "api",
    "listen": "127.0.0.1:${_api_port}",
    "services": [
      "HandlerService",
      "LoggerService",
      "StatsService",
      "RoutingService"
    ]
  },
  "stats": {},
  "policy": {
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink": true,
      "statsOutboundDownlink": true
    }
  },
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

  # 生成 outbound 配置：优先使用已注册的 WARP 账户（后台任务 4 预注册），否则现场注册；失败回退内置共享密钥
  if [ -s $TEMP_DIR/warp_account.json ] && grep -q '"id"' $TEMP_DIR/warp_account.json; then
    local WARP_ACCOUNT=$(< "$TEMP_DIR/warp_account.json")
    rm -f "$TEMP_DIR/warp_account.json"
  else
    local WARP_ACCOUNT=$(wget -qO- --tries=10 --waitretry=1 --timeout=2 "https://warp.cloudflare.nyc.mn/?run=register")
  fi

  if grep -q '"id"' <<< "$WARP_ACCOUNT"; then
    local WARP_PRIVATE=$(awk -F'"' '/"private_key"/{print $4}' <<< "$WARP_ACCOUNT")
    local WARP_V6=$(awk -F'"' '/"v6":/ && $4 !~ /^\[/ {print $4}' <<< "$WARP_ACCOUNT")
    local WARP_R1=$(awk '/"reserved":/ {getline; gsub(/[^0-9]/, ""); print}' <<< "$WARP_ACCOUNT")
    local WARP_R2=$(awk '/"reserved":/ {getline; getline; gsub(/[^0-9]/, ""); print}' <<< "$WARP_ACCOUNT")
    local WARP_R3=$(awk '/"reserved":/ {getline; getline; getline; gsub(/[^0-9]/, ""); print}' <<< "$WARP_ACCOUNT")
  fi

  # 兜底：注册失败或接口返回格式异常导致提取为空时，回退内置共享密钥
  if [ -z "${WARP_PRIVATE:-}" ] || [ -z "${WARP_V6:-}" ] || [ -z "${WARP_R1:-}" ] || [ -z "${WARP_R2:-}" ] || [ -z "${WARP_R3:-}" ]; then
    local WARP_PRIVATE="YFYOAdbw1bKTHlNNi+aEjBM3BO7unuFC5rOkMRAz9XY="
    local WARP_V6="2606:4700:110:8a36:df92:102a:9602:fa18"
    local WARP_R1=78
    local WARP_R2=135
    local WARP_R3=76
  fi

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
                "secretKey": "${WARP_PRIVATE}",
                "address": [
                    "172.16.0.2/32",
                    "${WARP_V6}/128"
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
                    ${WARP_R1},
                    ${WARP_R2},
                    ${WARP_R3}
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

  # 需要 nginx 时，等待后台安装完成后再生成 nginx 配置
  [ "$INSTALL_NGINX" != 'n' ] && { wait; json_nginx; }

  check_install
  if [ "$IS_ARGO" = 'is_argo' ]; then
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
  fi

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
  sync_firewall_rules
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

# ── 流量统计：单位换算（B/KB/MB/GB/TB，四舍五入保留 1 位小数） ──
format_traffic() {
  local bytes=$1
  [ "$bytes" -lt 1024 ] && { echo "${bytes} B"; return; }
  local _div _unit
  if [ "$bytes" -lt $((1024 * 1024)) ]; then
    _div=1024; _unit=KB
  elif [ "$bytes" -lt $((1024 * 1024 * 1024)) ]; then
    _div=$((1024 * 1024)); _unit=MB
  elif [ "$bytes" -lt $((1024 * 1024 * 1024 * 1024)) ]; then
    _div=$((1024 * 1024 * 1024)); _unit=GB
  else
    _div=$((1024 * 1024 * 1024 * 1024)); _unit=TB
  fi
  local _i=$((bytes / _div))
  local _r=$(( ((bytes % _div) * 10 + _div / 2) / _div ))
  [ "$_r" -ge 10 ] && { _i=$((_i + 1)); _r=0; }
  echo "${_i}.${_r} ${_unit}"
}

# ── 流量统计：获取 statsquery 数据并缓存到全局（同一次执行只查一次） ──
STATS_JSON=''
ensure_stats_data() {
  [ -n "$STATS_JSON" ] && return 0
  [ "${STATUS[1]}" != "$(text 28)" ] && return 1
  [ ! -x "$WORK_DIR/xray" ] && return 1
  local _api_addr
  # API 地址完全以配置文件 inbound.json 的 api.listen 为准（custom 不再保存该字段）
  _api_addr=$(grep -v '^//' "$WORK_DIR/inbound.json" | $WORK_DIR/jq -r '.api.listen // empty' 2>/dev/null)
  [ -z "$_api_addr" ] && return 1
  STATS_JSON=$($WORK_DIR/xray api statsquery --server="$_api_addr" 2>/dev/null)
  if [ -z "$STATS_JSON" ]; then
    # 配置文件端口与运行中 xray 实际端口不一致时，逐个探测监听端口（与 api_hot_reload 一致）
    local _lp
    for _lp in $(ss -tlnp 2>/dev/null | grep '"xray"' | grep -oE '127\.0\.0\.1:[0-9]+' | awk -F: '{print $2}' | sort -un); do
      _api_addr="127.0.0.1:${_lp}"
      STATS_JSON=$($WORK_DIR/xray api statsquery --server="$_api_addr" 2>/dev/null)
      [ -n "$STATS_JSON" ] && break
    done
  fi
  [ -z "$STATS_JSON" ] && return 1
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
  if [ -s $WORK_DIR/nginx.conf ]; then
    local NGINX_PID=$(nginx_pid)
    [ -n "$NGINX_PID" ] && NGINX_MEM="$(awk '/VmRSS/{printf "%.1f", $2/1024}' /proc/${NGINX_PID%% *}/status 2>/dev/null) MB"
  fi

  local APP
  [ "$IS_ARGO" = 'is_argo' ] && [ "${STATUS[0]}" != "$(text 28)" ] && APP+=(Argo)
  [ "${STATUS[1]}" != "$(text 28)" ] && APP+=(Xray)
  if [ "${#APP[@]}" -gt 0 ]; then
    reading "\n $(text 50) " OPEN_APP
    if [ "${OPEN_APP,,}" = 'y' ]; then
      [ "$IS_ARGO" = 'is_argo' ] && [ "${STATUS[0]}" != "$(text 28)" ] && cmd_systemctl enable argo
      [ "${STATUS[1]}" != "$(text 28)" ] && cmd_systemctl enable xray
      sleep 2
      check_install
      [ "$IS_ARGO" = 'is_argo' ] && ARGO_PID=$(pgrep -f "$WORK_DIR/cloudflared")
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
    fetch_tunnel_domain config >/dev/null 2>&1 || true
    [ -z "$ARGO_DOMAIN" ] && [ -s "$WORK_DIR/tunnel.yml" ] && ARGO_DOMAIN=$(awk '/^[[:space:]]*-[[:space:]]*hostname:/{print $3; exit}' "$WORK_DIR/tunnel.yml" 2>/dev/null)
    [ -z "$ARGO_DOMAIN" ] && ARGO_DOMAIN=$(grep -m1 '^vless.*host=.*' $WORK_DIR/list 2>/dev/null | sed "s@.*host=\(.*\)&.*@\1@g")
  fi
  fetch_nodes_value

  # 确定订阅 URL 的 scheme 和 domain：有 Argo 隧道域名就用 HTTPS+域名，否则用 HTTP+IP:端口
  if [ -n "$ARGO_DOMAIN" ]; then
    local _SUB_SCHEME='https'
    local _SUB_DOMAIN="${ARGO_DOMAIN}"
  else
    local _SUB_SCHEME='http'
    [ -z "$NGINX_PORT" ] && NGINX_PORT="$NGINX_PORT_DEFAULT"
    local _SUB_DOMAIN="${SERVER_IP_1}:${NGINX_PORT}"
  fi

  local PROTOS_NOW
  PROTOS_NOW=$(get_installed_protocols | tr '
' ' ')

  local FP_SHA256='' FP_BASE64='' CERT_SNI="${TLS_SERVER:-addons.mozilla.org}" CERT_URL_1="" CERT_URL_2=""
  if grep -Eq 'hysteria2|xhttp-h3-direct|trojan-direct' <<< "$PROTOS_NOW" && [ -s ${WORK_DIR}/cert/cert.pem ]; then
    FP_SHA256=$(openssl x509 -fingerprint -noout -sha256 -in ${WORK_DIR}/cert/cert.pem 2>/dev/null | awk -F= '{print $NF}')
    FP_BASE64=$(openssl x509 -in ${WORK_DIR}/cert/cert.pem -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64 2>/dev/null)
    CERT_URL_1=$(awk '{printf "%s,", $0}' ${WORK_DIR}/cert/cert.pem | sed 's/ /%20/g; s/,$//')
    CERT_URL_2=$(awk '{printf "%s\\r\\n", $0}' ${WORK_DIR}/cert/cert.pem)
    local _csni=$(openssl x509 -noout -ext subjectAltName -in ${WORK_DIR}/cert/cert.pem 2>/dev/null | awk -F 'DNS:' '/DNS:/{gsub(/,.*/,"",$2);print $2}')
    [ -n "$_csni" ] && CERT_SNI="$_csni"
  fi

  # 统一生成所有客户端订阅
  local SERVER_PORT_NOW=${SERVER_PORT:-443}
  local CLASH='proxies:' SHADOWROCKET_SUBSCRIBE='' V2RAYN_SUBSCRIBE='' SHADOWROCKET_DISPLAY='' V2RAYN_DISPLAY=''
  local SINGBOX_OUTBOUNDS='' SINGBOX_TAGS='' SINGBOX_SEP=''
  _sb_add() { SINGBOX_OUTBOUNDS+="${SINGBOX_SEP}$1"; SINGBOX_TAGS+="${SINGBOX_SEP}$2"; SINGBOX_SEP=', '; }
  _add() {
    local clash="$1" shadowrocket="$2" v2rayn="$3" singbox="$4" throne="$5" tag="$6"
    [ -n "$clash" ] && CLASH+="\n  - $clash"
    [ -n "$shadowrocket" ] && { SHADOWROCKET_SUBSCRIBE+="$shadowrocket"$'\n'; SHADOWROCKET_DISPLAY+="$shadowrocket\n\n"; }
    [ -n "$v2rayn" ] && { V2RAYN_SUBSCRIBE+="$v2rayn"$'\n'; V2RAYN_DISPLAY+="$v2rayn\n\n"; }
    [ -n "$throne" ] && { THRONE_SUBSCRIBE+="$throne"$'\n'; THRONE_DISPLAY+="$throne\n\n"; }
    [ -n "$singbox" ] && _sb_add "$singbox" "\"$tag\""
  }

  # reality-vision
  grep -q 'reality-vision' <<< "$PROTOS_NOW" && _add \
    "{name: \"${NODE_NAME} ${NODE_TAG[0]}\", type: vless, server: ${SERVER_IP}, port: ${REALITY_PORT}, uuid: ${UUID}, network: tcp, udp: true, tls: true, servername: ${TLS_SERVER}, flow: xtls-rprx-vision, client-fingerprint: ${FINGER_PRINT:-chrome}, reality-opts: {public-key: ${REALITY_PUBLIC}, short-id: \"\"} }" \
    "vless://$(echo -n "auto:${UUID}@${SERVER_IP_2}:${REALITY_PORT}" | base64 -w0)?remarks=${NODE_NAME// /%20}%20${NODE_TAG[0]}&obfs=none&tls=1&peer=${TLS_SERVER}&xtls=2&pbk=${REALITY_PUBLIC}" \
    "vless://${UUID}@${SERVER_IP_1}:${REALITY_PORT}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${TLS_SERVER}&fp=${FINGER_PRINT:-chrome}&pbk=${REALITY_PUBLIC}&type=tcp&headerType=none#${NODE_NAME// /%20}%20${NODE_TAG[0]}" \
    "{ \"type\":\"vless\", \"tag\":\"${NODE_NAME} ${NODE_TAG[0]}\", \"server\":\"${SERVER_IP}\", \"server_port\": ${REALITY_PORT}, \"uuid\":\"${UUID}\", \"flow\":\"xtls-rprx-vision\", \"packet_encoding\":\"xudp\", \"tls\":{ \"enabled\":true, \"server_name\":\"${TLS_SERVER}\", \"utls\":{ \"enabled\":true, \"fingerprint\":\"${FINGER_PRINT:-chrome}\" }, \"reality\":{ \"enabled\":true, \"public_key\":\"${REALITY_PUBLIC}\", \"short_id\":\"\" } } }" \
    "vless://${UUID}@${SERVER_IP_1}:${REALITY_PORT}?security=reality&sni=${TLS_SERVER}&fp=firefox&pbk=${REALITY_PUBLIC}&type=tcp&flow=xtls-rprx-vision&encryption=none#${NODE_NAME// /%20}%20${NODE_TAG[0]}" \
    "${NODE_NAME} ${NODE_TAG[0]}"

  # hysteria2
  if grep -q 'hysteria2' <<< "$PROTOS_NOW"; then
    local _chop='' _srhop='' _v2hop='' _sbhp='' _thop=''
    if [[ -n "$PORT_HOPPING_START" && -n "$PORT_HOPPING_END" ]]; then
      _srhop="&keepalive=30&mport=${HY2_PORT},${PORT_HOPPING_START}-${PORT_HOPPING_END}"
      _v2hop=",\"Ports\":\"${PORT_HOPPING_START}-${PORT_HOPPING_END}\",\"HopInterval\":\"30s\""
      _sbhp=",\"server_ports\":[\"${PORT_HOPPING_START}:${PORT_HOPPING_END}\"], \"hop_interval\": \"30s\", \"hop_interval_max\": \"60s\""
      _chop="ports: ${PORT_HOPPING_START}-${PORT_HOPPING_END}, hop-interval: 30, "
      _thop="&mport=${PORT_HOPPING_START}-${PORT_HOPPING_END}&hop_interval=30s"
    fi
    # 使用动态带宽参数，默认为 200/1000
    local _hy2_up="${HY2_UP_NOW:-200}"
    local _hy2_down="${HY2_DOWN_NOW:-1000}"
    # Hysteria2 Realm 客户端输出参数
    local _clash_realm='' _v2realm='' _sbrealm=''
    if [ "$IS_HY2_REALM" = 'is_hy2_realm' ]; then
      local _realm_id="${HY2_REALM_ID:-$UUID}"
      local _realm_url="realm://public@realm.hy2.io:443/${_realm_id}?stun=stun.nextcloud.com:3478&stun=stun.sip.us:3478&stun=turn.cloudflare.com:3478&stun=global.stun.twilio.com:3478"
      _clash_realm=", realm-opts: {enable: true, server-url: \"https://realm.hy2.io\", token: public, realm-id: \"${_realm_id}\", stun-servers: [turn.cloudflare.com:3478, stun.nextcloud.com:3478, stun.sip.us:3478, global.stun.twilio.com:3478]}"
      _v2realm="\"Hy2RealmUrl\":\"${_realm_url}\","
      _sbrealm=", \"realm\": { \"server_url\": \"https://realm.hy2.io\", \"token\": \"public\", \"realm_id\": \"${_realm_id}\", \"stun_servers\": [ \"turn.cloudflare.com:3478\", \"stun.nextcloud.com:3478\", \"stun.sip.us:3478\", \"global.stun.twilio.com:3478\" ] }"
    fi
    _add \
      "{name: \"${NODE_NAME} ${NODE_TAG[1]}\", type: hysteria2, server: ${SERVER_IP}, port: ${HY2_PORT}, ${_chop}up: \"${_hy2_up} Mbps\", down: \"${_hy2_down} Mbps\", password: ${UUID}, sni: ${CERT_SNI}, skip-cert-verify: false, fingerprint: ${FP_SHA256}${_clash_realm}}" \
      "hysteria2://${UUID}@${SERVER_IP_1}:${HY2_PORT}?peer=${CERT_SNI}&hpkp=${FP_SHA256}&obfs=none&upmbps=${_hy2_up}&downmbps=${_hy2_down}${_srhop}#${NODE_NAME// /%20}%20${NODE_TAG[1]}" \
      "v2rayn://hysteria2/$(echo -n "{\"ConfigType\":7,\"ConfigVersion\":4,\"Remarks\":\"${NODE_NAME} ${NODE_TAG[1]}\",\"Address\":\"${SERVER_IP}\",\"Port\":${HY2_PORT},\"Password\":\"${UUID}\",\"StreamSecurity\":\"tls\",\"AllowInsecure\":\"false\",\"Sni\":\"${TLS_SERVER}\",\"Cert\":\"${CERT_URL_2}\",\"ProtoExtraObj\":{${_v2realm}\"UpMbps\":${_hy2_up},\"DownMbps\":${_hy2_down}${_v2hop}}}" | base64 -w0 | tr '+/' '-_' | tr -d '=')" \
      "{ \"type\": \"hysteria2\", \"tag\": \"${NODE_NAME} ${NODE_TAG[1]}\", \"server\": \"${SERVER_IP}\", \"server_port\": ${HY2_PORT}${_sbhp}, \"up_mbps\": ${_hy2_up}, \"down_mbps\": ${_hy2_down}, \"password\": \"${UUID}\", \"tls\": { \"enabled\": true, \"server_name\": \"${CERT_SNI}\", \"certificate_public_key_sha256\": [\"${FP_BASE64}\"], \"alpn\": [ \"h3\" ] }${_sbrealm} }" \
      "hysteria2://${UUID}@${SERVER_IP_1}:${HY2_PORT}?allowInsecure=false&alpn&security=tls&sni=${TLS_SERVER}&upmbps=${_hy2_up}&downmbps=${_hy2_down}&security=tls&tls_certificate=${CERT_URL_1}${_thop}&fp=${FINGER_PRINT:-chrome}#${NODE_NAME// /%20}%20${NODE_TAG[1]}" \
      "${NODE_NAME} ${NODE_TAG[1]}"
  fi

  # reality-grpc
  grep -q 'reality-grpc' <<< "$PROTOS_NOW" && _add \
    "{name: \"${NODE_NAME} ${NODE_TAG[2]}\", type: vless, server: ${SERVER_IP}, port: ${GRPC_PORT}, uuid: ${UUID}, network: grpc, udp: true, tls: true, servername: ${TLS_SERVER}, flow: , client-fingerprint: ${FINGER_PRINT:-chrome}, reality-opts: {public-key: ${REALITY_PUBLIC}, short-id: \"\"}, grpc-opts: {grpc-service-name: \"grpc\"} }" \
    "vless://$(echo -n "auto:${UUID}@${SERVER_IP_2}:${GRPC_PORT}" | base64 -w0)?remarks=${NODE_NAME// /%20}%20${NODE_TAG[2]}&path=grpc&obfs=grpc&tls=1&peer=${TLS_SERVER}&pbk=${REALITY_PUBLIC}" \
    "vless://${UUID}@${SERVER_IP_1}:${GRPC_PORT}?security=reality&sni=${TLS_SERVER}&fp=${FINGER_PRINT:-chrome}&pbk=${REALITY_PUBLIC}&type=grpc&serviceName=grpc&encryption=none#${NODE_NAME// /%20}%20${NODE_TAG[2]}" \
    "{ \"type\": \"vless\", \"tag\":\"${NODE_NAME} ${NODE_TAG[2]}\", \"server\": \"${SERVER_IP}\", \"server_port\": ${GRPC_PORT}, \"uuid\": \"${UUID}\", \"packet_encoding\":\"xudp\", \"tls\": { \"enabled\": true, \"server_name\": \"${TLS_SERVER}\", \"utls\": { \"enabled\": true, \"fingerprint\": \"${FINGER_PRINT:-chrome}\" }, \"reality\": { \"enabled\": true, \"public_key\": \"${REALITY_PUBLIC}\", \"short_id\": \"\" } }, \"transport\": { \"type\": \"grpc\", \"service_name\": \"grpc\" } }" \
    "vless://${UUID}@${SERVER_IP_1}:${GRPC_PORT}?encryption=none&security=reality&sni=${TLS_SERVER}&fp=${FINGER_PRINT:-chrome}&pbk=${REALITY_PUBLIC}&sid&type=grpc&serviceName=grpc&packetEncoding=xudp#${NODE_NAME// /%20}%20${NODE_TAG[2]}" \
    "${NODE_NAME} ${NODE_TAG[2]}"

  # vless-ws
  grep -q 'vless-ws' <<< "$PROTOS_NOW" && _add \
    "{name: \"${NODE_NAME} ${NODE_TAG[3]}\", type: vless, server: ${SERVER}, port: ${SERVER_PORT_NOW}, uuid: ${UUID}, udp: true, tls: true, servername: ${ARGO_DOMAIN}, skip-cert-verify: false, network: ws, ws-opts: {path: \"/${WS_PATH}-vl\", headers: {Host: ${ARGO_DOMAIN}}, \"max_early_data\":2560, \"early_data_header_name\":\"Sec-WebSocket-Protocol\"} }" \
    "vless://${UUID}@${SERVER}:${SERVER_PORT_NOW}?encryption=none&security=tls&type=ws&host=${ARGO_DOMAIN}&path=/${WS_PATH}-vl?ed=2560&sni=${ARGO_DOMAIN}#${NODE_NAME// /%20}%20${NODE_TAG[3]}" \
    "vless://${UUID}@${SERVER}:${SERVER_PORT_NOW}?encryption=none&security=tls&sni=${ARGO_DOMAIN}&type=ws&host=${ARGO_DOMAIN}&path=%2F${WS_PATH}-vl%3Fed%3D2560#${NODE_NAME// /%20}%20${NODE_TAG[3]}" \
    "{ \"type\":\"vless\", \"tag\":\"${NODE_NAME} ${NODE_TAG[3]}\", \"server\":\"${SERVER}\", \"server_port\":${SERVER_PORT_NOW}, \"uuid\":\"${UUID}\", \"tls\": { \"enabled\":true, \"server_name\":\"${ARGO_DOMAIN}\", \"utls\": { \"enabled\":true, \"fingerprint\":\"${FINGER_PRINT:-chrome}\" } }, \"transport\": { \"type\":\"ws\", \"path\":\"/${WS_PATH}-vl\", \"headers\": { \"Host\": \"${ARGO_DOMAIN}\" }, \"max_early_data\":2560, \"early_data_header_name\":\"Sec-WebSocket-Protocol\" } }" \
    "vless://${UUID}@${SERVER}:${SERVER_PORT_NOW}?encryption=none&security=tls&sni=${ARGO_DOMAIN}&alpn&fp=${FINGER_PRINT:-chrome}&type=ws&host=${ARGO_DOMAIN}&path=/${WS_PATH}-vl&max_early_data=2560&early_data_header_name=Sec-WebSocket-Protocol&packetEncoding=xudp#${NODE_NAME// /%20}%20${NODE_TAG[3]}" \
    "${NODE_NAME} ${NODE_TAG[3]}"

  # vmess-ws
  grep -q 'vmess-ws' <<< "$PROTOS_NOW" && _add \
    "{name: \"${NODE_NAME} ${NODE_TAG[4]}\", type: vmess, server: ${SERVER}, port: ${SERVER_PORT_NOW}, uuid: ${UUID}, udp: true, alterId: 0, cipher: none, tls: true, servername: ${ARGO_DOMAIN}, skip-cert-verify: false, network: ws, ws-opts: {path: \"/${WS_PATH}-vm\", headers: {Host: ${ARGO_DOMAIN}}, \"max_early_data\":2560, \"early_data_header_name\":\"Sec-WebSocket-Protocol\"}}" \
    "vmess://$(echo -n "none:${UUID}@${SERVER}:${SERVER_PORT_NOW}" | base64 -w0)?remarks=${NODE_NAME// /%20}%20${NODE_TAG[4]}&obfsParam=${ARGO_DOMAIN}&path=/${WS_PATH}-vm?ed=2560&obfs=websocket&tls=1&peer=${ARGO_DOMAIN}&alterId=0" \
    "vmess://$(echo -n "{ \"v\": \"2\", \"ps\": \"${NODE_NAME} ${NODE_TAG[4]}\", \"add\": \"${SERVER}\", \"port\": \"443\", \"id\": \"${UUID}\", \"aid\": \"0\", \"scy\": \"none\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"${ARGO_DOMAIN}\", \"path\": \"/${WS_PATH}-vm?ed=2560\", \"tls\": \"tls\", \"sni\": \"${ARGO_DOMAIN}\", \"alpn\": \"\" }" | base64 -w0)" \
    "{ \"type\":\"vmess\", \"tag\":\"${NODE_NAME} ${NODE_TAG[4]}\", \"server\":\"${SERVER}\", \"server_port\":${SERVER_PORT_NOW}, \"uuid\":\"${UUID}\", \"tls\": { \"enabled\":true, \"server_name\":\"${ARGO_DOMAIN}\", \"utls\": { \"enabled\":true, \"fingerprint\":\"${FINGER_PRINT:-chrome}\" } }, \"transport\": { \"type\":\"ws\", \"path\":\"/${WS_PATH}-vm\", \"headers\": { \"Host\": \"${ARGO_DOMAIN}\" }, \"max_early_data\":2560, \"early_data_header_name\":\"Sec-WebSocket-Protocol\" } }" \
    "vmess://${UUID}@${SERVER}:${SERVER_PORT_NOW}?encryption=none&security=tls&sni=${ARGO_DOMAIN}&type=ws&host=${ARGO_DOMAIN}&path=/${WS_PATH}-vm&max_early_data=2560&early_data_header_name=Sec-WebSocket-Protocol#${NODE_NAME// /%20}%20${NODE_TAG[4]}" \
    "${NODE_NAME} ${NODE_TAG[4]}"

  # trojan-ws
  grep -q 'trojan-ws' <<< "$PROTOS_NOW" && _add \
    "{name: \"${NODE_NAME} ${NODE_TAG[5]}\", type: trojan, server: ${SERVER}, port: ${SERVER_PORT_NOW}, password: ${UUID}, udp: true, tls: true, servername: ${ARGO_DOMAIN}, sni: ${ARGO_DOMAIN}, skip-cert-verify: false, network: ws, ws-opts: {path: \"/${WS_PATH}-tr\", headers: {Host: ${ARGO_DOMAIN}}, \"max_early_data\":2560, \"early_data_header_name\":\"Sec-WebSocket-Protocol\" } }" \
    "trojan://${UUID}@${SERVER}:${SERVER_PORT_NOW}?peer=${ARGO_DOMAIN}&plugin=obfs-local;obfs=websocket;obfs-host=${ARGO_DOMAIN};obfs-uri=/${WS_PATH}-tr?ed=2560#${NODE_NAME// /%20}%20${NODE_TAG[5]}" \
    "trojan://${UUID}@${SERVER}:${SERVER_PORT_NOW}?security=tls&sni=${ARGO_DOMAIN}&fp=${FINGER_PRINT:-chrome}&insecure=0&allowInsecure=0&type=ws&host=${ARGO_DOMAIN}&path=/${WS_PATH}-tr?ed%3D2560#${NODE_NAME// /%20}%20${NODE_TAG[5]}" \
    "{ \"type\":\"trojan\", \"tag\":\"${NODE_NAME} ${NODE_TAG[5]}\", \"server\": \"${SERVER}\", \"server_port\": ${SERVER_PORT_NOW}, \"password\": \"${UUID}\", \"tls\": { \"enabled\":true, \"server_name\":\"${ARGO_DOMAIN}\", \"utls\": { \"enabled\":true, \"fingerprint\":\"${FINGER_PRINT:-chrome}\" } }, \"transport\": { \"type\":\"ws\", \"path\":\"/${WS_PATH}-tr\", \"headers\": { \"Host\": \"${ARGO_DOMAIN}\" }, \"max_early_data\":2560, \"early_data_header_name\":\"Sec-WebSocket-Protocol\" } }" \
    "trojan://${UUID}@${SERVER}:${SERVER_PORT_NOW}?security=tls&sni=${ARGO_DOMAIN}&alpn&fp=${FINGER_PRINT:-chrome}&type=ws&host=${ARGO_DOMAIN}&path=/${WS_PATH}-tr#${NODE_NAME// /%20}%20${NODE_TAG[5]}" \
    "${NODE_NAME} ${NODE_TAG[5]}"

  # ss-ws
  grep -qw 'ss-ws' <<< "$PROTOS_NOW" && _add \
    "{name: \"${NODE_NAME} ${NODE_TAG[6]}\", type: ss, server: ${SERVER}, port: ${SERVER_PORT_NOW}, cipher: ${SS_WS_METHOD}, password: ${UUID}, udp: true, plugin: v2ray-plugin, plugin-opts: { mode: websocket, host: ${ARGO_DOMAIN}, path: \"/${WS_PATH}-sh\", tls: true, servername: ${ARGO_DOMAIN}, skip-cert-verify: false, mux: false } }" \
    "ss://$(echo -n "${SS_WS_METHOD}:${UUID}@${SERVER}:${SERVER_PORT_NOW}" | base64 -w0)?uot=2&v2ray-plugin=$(echo -n "{\"peer\":\"${ARGO_DOMAIN}\",\"mux\":false,\"path\":\"\\/${WS_PATH}-sh\",\"host\":\"${ARGO_DOMAIN}\",\"mode\":\"websocket\",\"tls\":true}" | base64 -w0)#${NODE_NAME// /%20}%20${NODE_TAG[6]}" \
    "v2rayn://shadowsocks/$(echo -n "{\"ConfigType\":3,\"ConfigVersion\":4,\"Remarks\":\"${NODE_NAME} ${NODE_TAG[6]}\",\"Address\":\"${SERVER}\",\"Port\":${SERVER_PORT_NOW},\"Password\":\"${UUID}\",\"Network\":\"ws\",\"StreamSecurity\":\"tls\",\"AllowInsecure\":\"false\",\"Sni\":\"${ARGO_DOMAIN}\",\"Fingerprint\":\"${FINGER_PRINT:-chrome}\",\"AlterId\":0,\"ProtoExtraObj\":{\"SsMethod\":\"${SS_WS_METHOD}\"},\"TransportExtraObj\":{\"Host\":\"${ARGO_DOMAIN}\",\"Path\":\"/${WS_PATH}-sh\"}}" | base64 -w0 | tr '+/' '-_' | tr -d '=')" \
    "{ \"type\": \"shadowsocks\", \"tag\": \"${NODE_NAME} ${NODE_TAG[6]}\", \"server\": \"${SERVER}\", \"server_port\": ${SERVER_PORT_NOW}, \"method\": \"${SS_WS_METHOD}\", \"password\": \"${UUID}\", \"udp_over_tcp\": {\"enabled\": true,\"version\": 2}, \"plugin\": \"v2ray-plugin\", \"plugin_opts\": \"mode=websocket;host=${ARGO_DOMAIN};path=/${WS_PATH}-sh;tls=true;servername=${ARGO_DOMAIN};skip-cert-verify=false;mux=0\"}" \
    "ss://$(echo -n "${SS_WS_METHOD}:${UUID}" | base64 -w0)@${SERVER}:${SERVER_PORT_NOW}?plugin=v2ray-plugin%3Bmode%3Dwebsocket%3Bhost%3D${ARGO_DOMAIN}%3Bpath%3D%2F${WS_PATH}-sh%3Btls%3Dtrue%3Bservername%3D${ARGO_DOMAIN}%3Bskip-cert-verify%3Dfalse%3Bmux%3D0&uot=1#${NODE_NAME// /%20}%20${NODE_TAG[6]}" \
    "${NODE_NAME} ${NODE_TAG[6]}"

  # xhttp-h1.1-cdn（固定隧道下输出，使用 HTTP/1.1）
  grep -q 'xhttp-h1.1-cdn' <<< "$PROTOS_NOW" && ! grep -q 'trycloudflare\.com$' <<< "${ARGO_DOMAIN}" && _add \
    "{name: \"${NODE_NAME} ${NODE_TAG[7]}\", type: vless, server: ${SERVER}, port: ${SERVER_PORT_NOW}, uuid: ${UUID}, udp: true, tls: true, network: xhttp, alpn: [h2,http/1.1], servername: ${ARGO_DOMAIN}, client-fingerprint: ${FINGER_PRINT:-chrome}, encryption: \"\", xhttp-opts: {path: \"/${WS_PATH}-xh\", host: ${ARGO_DOMAIN}, mode: auto} }" \
    "vless://$(echo -n ":${UUID}@${SERVER}:${SERVER_PORT_NOW}" | base64 -w0)?path=/${WS_PATH}-xh&remarks=${NODE_NAME// /%20}%20${NODE_TAG[7]}&obfsParam=%7B%22Host%22:%22${ARGO_DOMAIN}%22%7D&obfs=xhttp&tls=1&peer=${ARGO_DOMAIN}&alpn=h2,http/1.1&h2=1&mode=auto" \
    "vless://${UUID}@${SERVER}:${SERVER_PORT_NOW}?encryption=none&security=tls&sni=${ARGO_DOMAIN}&fp=${FINGER_PRINT:-chrome}&alpn=h2%2Chttp%2F1.1&type=xhttp&host=${ARGO_DOMAIN}&path=%2F${WS_PATH}-xh&mode=auto#${NODE_NAME// /%20}%20${NODE_TAG[7]}" \
    "" \
    "vless://${UUID}@${SERVER}:${SERVER_PORT_NOW}?encryption=none&security=tls&sni=${ARGO_DOMAIN}&fp=${FINGER_PRINT:-chrome}&alpn=h2%2Chttp%2F1.1&type=xhttp&host=${ARGO_DOMAIN}&path=%2F${WS_PATH}-xh&mode=auto#${NODE_NAME// /%20}%20${NODE_TAG[7]}" \
    ""

  # xhttp-h2-reality（直连，Reality 安全层，HTTP/2）
  grep -q 'xhttp-h2-reality' <<< "$PROTOS_NOW" && _add \
    "{name: \"${NODE_NAME} ${NODE_TAG[8]}\", type: vless, server: ${SERVER_IP}, port: ${XHTTP_H2_PORT}, uuid: ${UUID}, udp: true, tls: true, network: xhttp, alpn: [h2], servername: ${TLS_SERVER}, client-fingerprint: ${FINGER_PRINT:-chrome}, reality-opts: {public-key: ${REALITY_PUBLIC}, short-id: \"\"}, xhttp-opts: {path: \"/${WS_PATH}-xh2\", mode: auto} }" \
    "vless://$(echo -n \"auto:${UUID}@${SERVER_IP_2}:${XHTTP_H2_PORT}\" | base64 -w0)?path=/${WS_PATH}-xh2&remarks=${NODE_NAME// /%20}%20${NODE_TAG[8]}&obfs=xhttp&tls=1&peer=${TLS_SERVER}&alpn=h2&mode=auto&pbk=${REALITY_PUBLIC}" \
    "vless://${UUID}@${SERVER_IP_1}:${XHTTP_H2_PORT}?encryption=none&security=reality&sni=${TLS_SERVER}&fp=${FINGER_PRINT:-chrome}&pbk=${REALITY_PUBLIC}&type=xhttp&path=%2F${WS_PATH}-xh2&mode=auto#${NODE_NAME// /%20}%20${NODE_TAG[8]}" \
    "" \
    "vless://${UUID}@${SERVER_IP_1}:${XHTTP_H2_PORT}?encryption=none&security=reality&sni=${TLS_SERVER}&fp=${FINGER_PRINT:-chrome}&pbk=${REALITY_PUBLIC}&type=xhttp&path=%2F${WS_PATH}-xh2&mode=auto#${NODE_NAME// /%20}%20${NODE_TAG[8]}" \
    "${NODE_NAME} ${NODE_TAG[8]}"

  # xhttp-h3-direct
  grep -q 'xhttp-h3-direct' <<< "$PROTOS_NOW" && _add \
    "{name: \"${NODE_NAME} ${NODE_TAG[9]}\", type: vless, server: ${SERVER_IP}, port: ${XHTTP_PORT}, uuid: ${UUID}, udp: true, tls: true, network: xhttp, alpn: [h3], servername: ${CERT_SNI}, client-fingerprint: ${FINGER_PRINT:-chrome}, skip-cert-verify: false, fingerprint: ${FP_SHA256}, xhttp-opts: {path: \"/${WS_PATH}-xh3\", mode: stream-up} }" \
    "vless://$(echo -n \"auto:${UUID}@${SERVER_IP_1}:${XHTTP_PORT}\" | base64 -w0)?path=/${WS_PATH}-xh3&remarks=${NODE_NAME// /%20}%20${NODE_TAG[9]}&obfs=xhttp&tls=1&peer=${CERT_SNI}&alpn=h3&mode=stream-up&hpkp=${FP_SHA256}" \
    "v2rayn://vless/$(echo -n "{\"ConfigType\":5,\"ConfigVersion\":4,\"Remarks\":\"${NODE_NAME} ${NODE_TAG[9]}\",\"Address\":\"${SERVER_IP}\",\"Port\":${XHTTP_PORT},\"Password\":\"${UUID}\",\"Network\":\"xhttp\",\"StreamSecurity\":\"tls\",\"AllowInsecure\":\"false\",\"Sni\":\"${CERT_SNI}\",\"Alpn\":\"h3\",\"Fingerprint\":\"${FINGER_PRINT:-chrome}\",\"Cert\":\"${CERT_URL_2}\",\"TransportExtraObj\":{\"Path\":\"/${WS_PATH}-xh3\",\"XhttpMode\":\"stream-up\"}}" | base64 -w0 | tr '+/' '-_' | tr -d '=')" \
    "" \
    "vless://${UUID}@${SERVER_IP_1}:${XHTTP_PORT}?encryption=none&security=tls&sni=${CERT_SNI}&fp=${FINGER_PRINT:-chrome}&alpn=h3&pcs=${FP_SHA256//:/}&type=xhttp&path=%2F${WS_PATH}-xh3&mode=stream-up#${NODE_NAME// /%20}%20${NODE_TAG[9]}" \
    ""

  # trojan-direct
  grep -q 'trojan-direct' <<< "$PROTOS_NOW" && _add \
    "{name: \"${NODE_NAME} ${NODE_TAG[10]}\", type: trojan, server: ${SERVER_IP}, port: ${TROJAN_PORT}, password: ${UUID}, udp: true, tls: true, sni: ${CERT_SNI}, servername: ${CERT_SNI}, skip-cert-verify: false, fingerprint: ${FP_SHA256} }" \
    "trojan://${UUID}@${SERVER_IP_1}:${TROJAN_PORT}?peer=${CERT_SNI}&tls=1&allowInsecure=0&sni=${CERT_SNI}&hpkp=${FP_SHA256}#${NODE_NAME// /%20}%20${NODE_TAG[10]}" \
    "v2rayn://trojan/$(echo -n "{\"ConfigType\":6,\"ConfigVersion\":4,\"Remarks\":\"${NODE_NAME} ${NODE_TAG[10]}\",\"Address\":\"${SERVER_IP}\",\"Port\":${TROJAN_PORT},\"Password\":\"${UUID}\",\"Network\":\"raw\",\"StreamSecurity\":\"tls\",\"AllowInsecure\":\"false\",\"Sni\":\"${CERT_SNI}\",\"Fingerprint\":\"${FINGER_PRINT:-chrome}\",\"Cert\":\"${CERT_URL_2}\"}" | base64 -w0 | tr '+/' '-_' | tr -d '=')" \
    "{ \"type\":\"trojan\", \"tag\":\"${NODE_NAME} ${NODE_TAG[10]}\", \"server\": \"${SERVER_IP}\", \"server_port\": ${TROJAN_PORT}, \"password\": \"${UUID}\", \"tls\": { \"enabled\": true, \"server_name\": \"${CERT_SNI}\", \"certificate_public_key_sha256\": [\"${FP_BASE64}\"] } }" \
    "trojan://${UUID}@${SERVER_IP_1}:${TROJAN_PORT}?security=tls&sni=${TLS_SERVER}&tls_certificate=${CERT_URL_1}&fp=${FINGER_PRINT:-chrome}#${NODE_NAME// /%20}%20${NODE_TAG[10]}" \
    "${NODE_NAME} ${NODE_TAG[10]}"

  # ss2022-direct
  grep -q 'ss2022-direct' <<< "$PROTOS_NOW" && _add \
    "{name: \"${NODE_NAME} ${NODE_TAG[11]}\", type: ss, server: ${SERVER_IP}, port: ${SS2022_PORT}, cipher: ${SS_DIRECT_METHOD}, password: ${SS2022_PASSWORD}, udp: true }" \
    "ss://$(echo -n "${SS_DIRECT_METHOD}:${SS2022_PASSWORD}@${SERVER_IP_1}:${SS2022_PORT}" | base64 -w0)#$(echo -n "${NODE_NAME# }" | sed 's/ /%20/g')%20${NODE_TAG[11]}" \
    "ss://$(echo -n "${SS_DIRECT_METHOD}:${SS2022_PASSWORD}" | base64 -w0)@${SERVER_IP_1}:${SS2022_PORT}#${NODE_NAME// /%20}%20${NODE_TAG[11]}" \
    "{ \"type\": \"shadowsocks\", \"tag\": \"${NODE_NAME} ${NODE_TAG[11]}\", \"server\": \"${SERVER_IP}\", \"server_port\": ${SS2022_PORT}, \"method\": \"${SS_DIRECT_METHOD}\", \"password\": \"${SS2022_PASSWORD}\" }" \
    "ss://${SS_DIRECT_METHOD}:${SS2022_PASSWORD}@${SERVER_IP_1}:${SS2022_PORT}#${NODE_NAME// /%20}%20${NODE_TAG[11]}" \
    "${NODE_NAME} ${NODE_TAG[11]}"

  # 写入订阅文件（仅 IS_SUB=is_sub 且有协议时生成；0 协议跳过，避免生成空订阅覆盖现有文件）
  if [ "$IS_SUB" = 'is_sub' ] && [ -n "$PROTOS_NOW" ]; then
    echo -e "$CLASH" > $WORK_DIR/subscribe/proxies
    wget --no-check-certificate -qO- --tries=3 --timeout=2 ${SUBSCRIBE_TEMPLATE}/clash | sed "s#NODE_NAME#${NODE_NAME}#g; s#PROXY_PROVIDERS_URL#${_SUB_SCHEME}://${_SUB_DOMAIN}/${UUID}/proxies#" > $WORK_DIR/subscribe/clash
    echo -n "$SHADOWROCKET_SUBSCRIBE" | sed -E '/^[ ]*#|^--/d' | sed '/^$/d' | base64 -w0 > $WORK_DIR/subscribe/shadowrocket
    echo -n "$V2RAYN_SUBSCRIBE" | sed -E '/^[ ]*#|^--/d' | sed '/^$/d' | base64 -w0 > $WORK_DIR/subscribe/v2rayn
    echo -n "$THRONE_SUBSCRIBE" | sed -E '/^[ ]*#|^--/d' | sed '/^$/d' | base64 -w0 > $WORK_DIR/subscribe/throne
  fi

  # sing-box 订阅：纯 xhttp 场景直接跳过；其余场景仅在确实生成了 sing-box outbound 时才处理
  local SINGBOX_DISPLAY='' SINGBOX_BLOCK='' SINGBOX_LINK_BLOCK=''
  if ! grep -Eq '^[[:space:]]*(xhttp-h1\.1-cdn|xhttp-h2-reality|xhttp-h3-direct)[[:space:]]*$' <<< "$PROTOS_NOW" || grep -Eq '(^|[[:space:]])(reality-vision|hysteria2|reality-grpc|vless-ws|vmess-ws|trojan-ws|ss-ws|trojan-direct|ss2022-direct)([[:space:]]|$)' <<< "$PROTOS_NOW"; then
    if [ -n "$SINGBOX_OUTBOUNDS" ]; then
    local SING_BOX_JSON=$(wget --no-check-certificate -qO- --tries=3 --timeout=2 ${SUBSCRIBE_TEMPLATE}/sing-box)
    echo "$SING_BOX_JSON" | sed "s#\"<OUTBOUND_REPLACE>\"#${SINGBOX_OUTBOUNDS}#; s#\"<NODE_REPLACE>\"#${SINGBOX_TAGS}#g" | $WORK_DIR/jq > $WORK_DIR/subscribe/sing-box
    SINGBOX_DISPLAY=$(echo "{ \"outbounds\":[ ${SINGBOX_OUTBOUNDS} ] }" | $WORK_DIR/jq 2>/dev/null)
    SINGBOX_BLOCK="*******************************************
┌────────────────┐
│                │
│    $(warning "Sing-box")    │
│                │
└────────────────┘
----------------------------

$(info "${SINGBOX_DISPLAY}")"
    SINGBOX_LINK_BLOCK="

sing-box $(text 64):
${_SUB_SCHEME}://${_SUB_DOMAIN}/${UUID}/sing-box"
    else
      rm -f $WORK_DIR/subscribe/sing-box >/dev/null 2>&1 || true
    fi
  else
    rm -f $WORK_DIR/subscribe/sing-box >/dev/null 2>&1 || true
  fi

  # 显示用变量
  local CLASH_DISPLAY=$(echo -e "$CLASH" | sed '1d')

  check_system_info
  local ARGO_V=$([ -s "$WORK_DIR/cloudflared" ] && $WORK_DIR/cloudflared -v 2>/dev/null | awk '{print $3}')
  local XRAY_V=$($WORK_DIR/xray version | awk 'NR==1 {print $2}')
  local NGINX_V=$(nginx -v 2>&1 | sed "s#.*/##")
  local SYS_INFO=" $(text 19):\n\t $(text 20): $SYS\n\t $(text 21): $(uname -r)\n\t $(text 22): $ARGO_ARCH\n\t $(text 23): $VIRT\n\t IPv4: $WAN4 $COUNTRY4 $ASNORG4\n\t IPv6: $WAN6 $COUNTRY6 $ASNORG6\n\t Argo: ${STATUS[0]}\t Version: ${ARGO_V}\t $(text 52): ${ARGO_MEM}\n\t Xray: ${STATUS[1]}\t Version: ${XRAY_V}\t $(text 52): ${XRAY_MEM}"
  [ -s $WORK_DIR/nginx.conf ] && SYS_INFO+="\n\t Nginx: ${STATUS[2]}\t Version: ${NGINX_V}\t $(text 52): ${NGINX_MEM}"

  # 0 协议时节点区块为空：提示“已安装的协议 (0)”，不再输出空客户端区块
  if [ -z "$PROTOS_NOW" ]; then
    EXPORT_LIST_FILE="*******************************************
┌────────────────┐
│                │
│     $(warning "ArgoX")     │
│                │
└────────────────┘
----------------------------

$(info "$(text 88) (0)")"
  else
    EXPORT_LIST_FILE="*******************************************
┌────────────────┐
│                │
│     $(warning "V2rayN")     │
│                │
└────────────────┘
----------------------------
$(info "$(echo -e "${V2RAYN_DISPLAY}")")

*******************************************
┌────────────────┐
│                │
│  $(warning "Shadowrocket")  │
│                │
└────────────────┘
----------------------------

$(hint "$(echo -e "${SHADOWROCKET_DISPLAY}")")

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
│     $(warning "Throne")     │
│                │
└────────────────┘
----------------------------
$(hint "$(echo -e "${THRONE_DISPLAY}")")

${SINGBOX_BLOCK}
"
  fi

  # 订阅聚合 URL：仅 IS_SUB=is_sub 时显示
  local SUB_URL_BLOCK=''
  if [ "$IS_SUB" = 'is_sub' ]; then
    SUB_URL_BLOCK="*******************************************

$(hint "Index:
${_SUB_SCHEME}://${_SUB_DOMAIN}/${UUID}/

QR code:
${_SUB_SCHEME}://${_SUB_DOMAIN}/${UUID}/qr

V2rayN $(text 64):
${_SUB_SCHEME}://${_SUB_DOMAIN}/${UUID}/v2rayn

Throne $(text 64):
${_SUB_SCHEME}://${_SUB_DOMAIN}/${UUID}/throne

Clash $(text 64):
${_SUB_SCHEME}://${_SUB_DOMAIN}/${UUID}/clash${SINGBOX_LINK_BLOCK}

Shadowrocket $(text 64):
${_SUB_SCHEME}://${_SUB_DOMAIN}/${UUID}/shadowrocket")

*******************************************

$(info " $(text 66):
${_SUB_SCHEME}://${_SUB_DOMAIN}/${UUID}/auto

$(text 64) QRcode:
https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${_SUB_SCHEME}://${_SUB_DOMAIN}/${UUID}/auto")

$([ -s "$WORK_DIR/qrencode" ] && $WORK_DIR/qrencode ${_SUB_SCHEME}://${_SUB_DOMAIN}/${UUID}/auto)
"
  fi

  EXPORT_LIST_FILE="${EXPORT_LIST_FILE}${SUB_URL_BLOCK}"

  # === 流量统计块（仅 API 可用时显示；流量为 0 时显示 0 B） ===
  if ensure_stats_data; then
    local _in_sum=0 _out_sum=0 _line _name _val
    while IFS= read -r _line; do
      _name=$(echo "$_line" | $WORK_DIR/jq -r '.name // empty' 2>/dev/null)
      _val=$(echo "$_line" | $WORK_DIR/jq -r '.value // 0' 2>/dev/null)
      [ -z "$_name" ] && continue
      case "$_name" in
        inbound*traffic*downlink ) _in_sum=$((_in_sum + _val)) ;;
        outbound*traffic*uplink )  _out_sum=$((_out_sum + _val)) ;;
      esac
    done < <(echo "$STATS_JSON" | $WORK_DIR/jq -c '.stat[]' 2>/dev/null)
    EXPORT_LIST_FILE="${EXPORT_LIST_FILE}

*******************************************
┌────────────────┐
│                │
│  $(warning "Traffic Stats") │
│                │
└────────────────┘
---------------------------

$(info "⬇ Inbound  (total):  $(format_traffic $_in_sum)")
$(hint "⬆ Outbound (total):  $(format_traffic $_out_sum)")
"
  fi
  # === 结束 ===

  echo "$EXPORT_LIST_FILE" > $WORK_DIR/list
  cat $WORK_DIR/list

  statistics_of_run-times get
}


# 增加或删除协议
change_protocols() {
  check_install
  [ "${STATUS[1]}" = "$(text 26)" ] && error "\n $(text 39) \n"

  check_system_ip

  # 加载流量统计（静默；API 不可用时 STATS_JSON 为空，各协议行不显示流量）
  ensure_stats_data 2>/dev/null

  # 根据协议名返回该协议流量字符串；stats 不可用时返回空串（不显示），
  # 可用时始终显示（流量为 0 时显示 0 B）
  _proto_traffic_str() {
    [ -z "$STATS_JSON" ] && { echo ''; return; }
    local _p="$1" _ts='' _dl=0 _ul=0 _line _n _v _idx
    for _idx in "${!NODE_TAG[@]}"; do
      local _pn="${PROTOCOL_LIST[$_idx]}"
      [ "$_idx" = '7' ] && _pn=$(text 101)
      [ "$_p" = "$_pn" ] && { _ts="${NODE_TAG[$_idx]}"; break; }
    done
    if [ -n "$_ts" ]; then
      while IFS= read -r _line; do
        _n=$(echo "$_line" | $WORK_DIR/jq -r '.name // empty' 2>/dev/null)
        _v=$(echo "$_line" | $WORK_DIR/jq -r '.value // 0' 2>/dev/null)
        [ -z "$_n" ] && continue
        # stats 名称格式：inbound>>>{节点名 后缀}>>>traffic>>>{downlink|uplink}，
        # 后缀前是空格（完整 tag 是 "节点名 后缀"），因此模式为 " ${_ts}>>>"
        case "$_n" in
          *" ${_ts}>>>traffic>>>downlink" ) _dl=$((_dl + _v)) ;;
          *" ${_ts}>>>traffic>>>uplink" )   _ul=$((_ul + _v)) ;;
        esac
      done < <(echo "$STATS_JSON" | $WORK_DIR/jq -c '.stat[]' 2>/dev/null)
    fi
    echo "  ⬇$(format_traffic $_dl) ⬆$(format_traffic $_ul)"
  }

  local EXISTED_PROTOCOLS=() NOT_EXISTED_PROTOCOLS=()
  for tag in "${CURRENT_PROTOCOLS[@]}"; do
    for idx in "${!NODE_TAG[@]}"; do
      if [ "${NODE_TAG[$idx]}" = "$tag" ]; then
        local p_name="${PROTOCOL_LIST[$idx]}"
        [ "$idx" = '7' ] && p_name=$(text 101)
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
      [ "$idx" = '7' ] && p_name=$(text 101)
      NOT_EXISTED_PROTOCOLS+=("${p_name}")
    fi
  done

  local REMOVE_PROTOCOLS=() KEEP_PROTOCOLS=()
  # 已安装协议为空时不交互删除，直接进入添加
  if [ "${#EXISTED_PROTOCOLS[@]}" -gt 0 ]; then
    hint "\n $(text 88) (${#EXISTED_PROTOCOLS[@]})"
    for h in "${!EXISTED_PROTOCOLS[@]}"; do
      # 协议名按 29 列左对齐（最长名 "VLESS + XHTTP HTTP/3 Direct" 为 27 字符 + 2 空格间隔），使 ⬇ 对齐
      hint " $(printf "\\$(printf '%03o' $((h+97)))"). $(printf '%-29s' "${EXISTED_PROTOCOLS[h]}")$(_proto_traffic_str "${EXISTED_PROTOCOLS[h]}")"
    done
    reading "\n $(text 89) " REMOVE_SELECT

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
  fi

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

  hint "\n $(text 92) (${#REINSTALL_PROTOCOLS[@]})"
  [ "${#KEEP_PROTOCOLS[@]}" -gt 0 ] && hint "\n $(text 96) (${#KEEP_PROTOCOLS[@]})"
  for r in "${!KEEP_PROTOCOLS[@]}"; do hint " $(printf '%3d.' $((r+1))) ${KEEP_PROTOCOLS[r]}"; done
  [ "${#ADD_PROTOCOLS[@]}" -gt 0 ] && hint "\n $(text 97) (${#ADD_PROTOCOLS[@]})"
  for r in "${!ADD_PROTOCOLS[@]}"; do hint " $(printf '%3d.' $((r+1))) ${ADD_PROTOCOLS[r]}"; done
  reading "\n $(text 93) " CONFIRM
  [ "${CONFIRM,,}" = 'n' ] && exit 0

  local REINSTALL_TAGS=() REMOVE_TAGS=() ADD_TAGS=()
  for idx in "${!NODE_TAG[@]}"; do
    local tag="${NODE_TAG[$idx]}"
    local pname="${PROTOCOL_LIST[$idx]}"
    for p in "${REINSTALL_PROTOCOLS[@]}"; do
      if [ "$p" = "$pname" ] || [ "$tag" = "${NODE_TAG[7]}" -a "$p" = "$(text 101)" ]; then
        REINSTALL_TAGS+=("$tag")
        break
      fi
    done
  done

  for pname in "${REMOVE_PROTOCOLS[@]}"; do
    for idx in "${!PROTOCOL_LIST[@]}"; do
      [[ "${PROTOCOL_LIST[$idx]}" = "$pname" || ( "$idx" = '7' && "$pname" = "$(text 101)" ) ]] && REMOVE_TAGS+=("${NODE_TAG[$idx]}") && break
    done
  done
  for pname in "${ADD_PROTOCOLS[@]}"; do
    for idx in "${!PROTOCOL_LIST[@]}"; do
      [[ "${PROTOCOL_LIST[$idx]}" = "$pname" || ( "$idx" = '7' && "$pname" = "$(text 101)" ) ]] && ADD_TAGS+=("${NODE_TAG[$idx]}") && break
    done
  done

  local _HAS_HY2_ADD=false _HAS_HY2_KEEP=false
  for t in "${ADD_TAGS[@]}"; do [ "$t" = 'hysteria2' ] && _HAS_HY2_ADD=true && break; done
  for t in "${REINSTALL_TAGS[@]}"; do [ "$t" = 'hysteria2' ] && _HAS_HY2_KEEP=true && break; done
  if $_HAS_HY2_ADD; then
    ssl_certificate "${TLS_SERVER}"
    # Hysteria2 Realm 交互（在端口跳跃之前询问，需要先 Realm 再端口跳跃）
    input_hy2_realm
    input_hy2_warp
    # Realm ID 默认使用 UUID
    [ "$IS_HY2_REALM" = 'is_hy2_realm' ] && HY2_REALM_ID="$UUID"
    # 先收集端口跳跃范围，再写 NAT 规则（原逻辑顺序颠倒，NAT 参数为空）
    unset IS_HOPPING PORT_HOPPING_RANGE PORT_HOPPING_START PORT_HOPPING_END
    [ "$IS_HY2_REALM" != 'is_hy2_realm' ] && input_hopping_port
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
  for _t in "${ADD_TAGS[@]}"; do [[ "$_t" =~ ^(reality-vision|reality-grpc|xhttp-h2-reality)$ ]] && _HAS_REALITY_ADD=true && break; done
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
  # 全部协议移除、无需重装时不需要 UUID，避免卸载场景被额外询问
  [ -z "$UUID" ] && [ "${#REINSTALL_TAGS[@]}" -gt 0 ] && input_uuid

  # 无既有协议时（inbound.json 无入站，fetch_nodes_value 会把 NODE_NAME 置为默认 ArgoX），
  # 像全新安装一样询问节点名称；已有节点名称则沿用
  if [ "${#REINSTALL_TAGS[@]}" -gt 0 ] && [ -z "$(grep -v '^//' "$WORK_DIR/inbound.json" | $WORK_DIR/jq -r '.inbounds[0].tag // empty' 2>/dev/null)" ]; then
    NODE_NAME=''
    input_node_name
  fi

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
        vless-ws) VLESS_WS_PORT=$_EXIST_PORT ;;
        vmess-ws) VMESS_WS_PORT=$_EXIST_PORT ;;
        trojan-ws) TROJAN_WS_PORT=$_EXIST_PORT ;;
        ss-ws) SS_WS_PORT=$_EXIST_PORT ;;
        xhttp-h1.1-cdn) VLESS_XHTTP_PORT=$_EXIST_PORT ;;
        xhttp-h2-reality) XHTTP_H2_PORT=$_EXIST_PORT ;;
        xhttp-h3-direct) XHTTP_PORT=$_EXIST_PORT ;;
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
        vless-ws) VLESS_WS_PORT=$_NEW_PORT ;;
        vmess-ws) VMESS_WS_PORT=$_NEW_PORT ;;
        trojan-ws) TROJAN_WS_PORT=$_NEW_PORT ;;
        ss-ws) SS_WS_PORT=$_NEW_PORT ;;
        xhttp-h1.1-cdn) VLESS_XHTTP_PORT=$_NEW_PORT ;;
        xhttp-h2-reality) XHTTP_H2_PORT=$_NEW_PORT ;;
        xhttp-h3-direct) XHTTP_PORT=$_NEW_PORT ;;
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
    [[ "$_t" =~ ^(vless-ws|vmess-ws|trojan-ws|ss-ws|xhttp-h1.1-cdn)$ ]] && _HAS_WS_XHTTP_ADD=true && break
  done

  # 在用户交互（CDN 选择 / Argo 域名）之前尽早后台安装 nginx，让安装与交互并行
  local _PRELIM_NEED_NGINX=false
  [ "$IS_SUB" = 'is_sub' ] && _PRELIM_NEED_NGINX=true
  $_HAS_WS_XHTTP_ADD && _PRELIM_NEED_NGINX=true
  # 检查已有协议中是否有 WS/XHTTP（这些也要保留 nginx）
  for _t in "${KEEP_TAGS[@]}"; do
    [[ "$_t" =~ ^(vless-ws|vmess-ws|trojan-ws|ss-ws|xhttp-h1.1-cdn)$ ]] && _PRELIM_NEED_NGINX=true && break
  done
  if $_PRELIM_NEED_NGINX && ! command -v nginx >/dev/null 2>&1; then
    hint "\n $(text 148) "
    ( ${PACKAGE_UPDATE[int]} >/dev/null 2>&1; ${PACKAGE_INSTALL[int]} nginx >/dev/null 2>&1; [ "$SYSTEM" != 'Alpine' ] && systemctl disable --now nginx >/dev/null 2>&1; ) &
  fi

  if $_HAS_WS_XHTTP_ADD && [[ -z "$SERVER" || "$SERVER" == '__CDN_UNSET__' ]]; then
    echo ""
    for _c in "${!CDN_DOMAIN[@]}"; do
      hint " $((_c+1)). ${CDN_DOMAIN[_c]} "
    done
    reading "\n $(text 42) " CUSTOM_CDN
    case "$CUSTOM_CDN" in
      [1-9]|[1-9][0-9] )
        [ "$CUSTOM_CDN" -le "${#CDN_DOMAIN[@]}" ] && SERVER="${CDN_DOMAIN[$((CUSTOM_CDN-1))]}" || SERVER="${CDN_DOMAIN[0]}"
        SERVER_PORT=443
        ;;
      ?????* )
        parse_preferred_addr "$CUSTOM_CDN" || error " $(text 118) "
        SERVER="$PREFERRED_ADDR"
        SERVER_PORT="$PREFERRED_PORT"
        ;;
      * )
        SERVER="${CDN_DOMAIN[0]}"
        SERVER_PORT=443
    esac
  fi

  # 若最终协议列表中不含任何 Reality 协议，清除公私钥
  local _HAS_REALITY_FINAL=false
  for _t in "${REINSTALL_TAGS[@]}"; do
    [[ "$_t" =~ ^(reality-vision|reality-grpc|xhttp-h2-reality)$ ]] && _HAS_REALITY_FINAL=true && break
  done
  $_HAS_REALITY_FINAL || { REALITY_PRIVATE='__KEY_UNSET__'; REALITY_PUBLIC='__KEY_UNSET__'; }

  # 若最终协议列表中不含任何 WS/XHTTP 协议，清除 CDN
  local _HAS_WS_XHTTP_FINAL=false
  for _t in "${REINSTALL_TAGS[@]}"; do
    [[ "$_t" =~ ^(vless-ws|vmess-ws|trojan-ws|ss-ws|xhttp-h1.1-cdn)$ ]] && _HAS_WS_XHTTP_FINAL=true && break
  done
  $_HAS_WS_XHTTP_FINAL || SERVER='__CDN_UNSET__'

  # 推导 IS_ARGO：最终协议中有 WS/XHTTP 时需要 Argo
  # 如果用户通过 --ARGO 或 config.conf 显式设置了 IS_ARGO，则不覆盖
  [ "${IS_ARGO_EXPLICIT:-false}" != 'true' ] && IS_ARGO=no_argo
  [ "${IS_ARGO_EXPLICIT:-false}" != 'true' ] && $_HAS_WS_XHTTP_FINAL && IS_ARGO=is_argo

  # 推导是否需要 Nginx（订阅 或 WS/XHTTP 协议都需要 nginx 做反向代理）
  local _NEED_NGINX=false
  [ "$IS_SUB" = 'is_sub' ] || [ "$IS_ARGO" = 'is_argo' ] && _NEED_NGINX=true

  # Nginx 端口：之前没有 nginx.conf（首次需要 nginx）时询问端口
  if $_NEED_NGINX && [ ! -s "$WORK_DIR/nginx.conf" ] && ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL"; then
    [ -z "$NGINX_PORT" ] && input_nginx_port
    NGINX_PORT=${NGINX_PORT:-"$NGINX_PORT_DEFAULT"}
  fi

  # Argo 联动：新增 WS/XHTTP 且无现有 cloudflared → 交互询问 Argo 域名
  if $_HAS_WS_XHTTP_ADD && [ ! -s "${ARGO_DAEMON_FILE}" ]; then
    if [ -z "$ARGO_DOMAIN" ]; then
      reading "\n $(text 10) " ARGO_DOMAIN
    fi
    if [[ -n "$ARGO_DOMAIN" && ! "$ARGO_DOMAIN" =~ trycloudflare\.com$ && -z "$ARGO_AUTH" ]]; then
      hint "\n $(text 11)"
      reading "\n $(text 86) " ARGO_AUTH
    fi
  fi

  # 移除所有 WS/XHTTP 且有现有 cloudflared → 主动清理：
  # 有订阅且固定隧道（--token/--config）→ 保留（订阅继续经固定域名分发），IS_ARGO 保持 is_argo；
  # 无订阅或临时隧道（--url）→ 停止服务、移除开机启动、删除守护文件、删除二进制和 tunnel 配置
  if ! $_HAS_WS_XHTTP_FINAL && [ -s "${ARGO_DAEMON_FILE}" ]; then
    if [ "$IS_SUB" = 'is_sub' ] && ! grep -qs -- '--url' "${ARGO_DAEMON_FILE}" && { [ "${IS_ARGO_EXPLICIT:-false}" != 'true' ] || [ "$IS_ARGO" = 'is_argo' ]; }; then
      IS_ARGO=is_argo
    else
      hint "\n $(text 147) "
      cmd_systemctl disable argo
      if [ "$SYSTEM" = 'Alpine' ]; then
        rm -f /etc/init.d/argo
      else
        rm -f ${ARGO_DAEMON_FILE}
      fi
      rm -f $WORK_DIR/cloudflared $WORK_DIR/tunnel.json $WORK_DIR/tunnel.yml
    fi
  fi

  local _XHTTP_TLS_SERVER_NAME="$ARGO_DOMAIN"
  if printf '%s
' "${REINSTALL_TAGS[@]}" | grep -qx 'xhttp-h1.1-cdn'; then
    if [ -z "$_XHTTP_TLS_SERVER_NAME" ]; then
      case $(grep "${DAEMON_RUN_PATTERN}" ${ARGO_DAEMON_FILE} 2>/dev/null) in
        *--config* ) fetch_tunnel_domain config >/dev/null 2>&1 || true ;;
        *--token* ) fetch_tunnel_domain config >/dev/null 2>&1 || true ;;
        * ) fetch_tunnel_domain quick >/dev/null 2>&1 || true ;;
      esac
      _XHTTP_TLS_SERVER_NAME="$ARGO_DOMAIN"
    fi
    [ -z "$_XHTTP_TLS_SERVER_NAME" ] && _XHTTP_TLS_SERVER_NAME="$TLS_SERVER"
  fi

  write_custom 'serverIp' "${SERVER_IP}"
  write_custom 'privateKey' "${REALITY_PRIVATE:-__KEY_UNSET__}"
  write_custom 'publicKey' "${REALITY_PUBLIC:-__KEY_UNSET__}"
  write_custom 'cdn' "${SERVER:-__CDN_UNSET__}"
  write_custom 'cdnPort' "${SERVER_PORT:-443}"

  # 获取或分配 API 端口（完全以 inbound.json 现有 api 监听端口为准，custom 不再保存该字段）
  local _api_port
  _api_port=$(grep -v '^//' "$WORK_DIR/inbound.json" | $WORK_DIR/jq -r '.api.listen // empty' 2>/dev/null | awk -F: '{print $2}')
  [ -z "$_api_port" ] && _api_port=$(find_free_port 10000 65535)

  cat > $WORK_DIR/inbound.json << EOF
{
  "api": {
    "tag": "api",
    "listen": "127.0.0.1:${_api_port}",
    "services": [
      "HandlerService",
      "LoggerService",
      "StatsService",
      "RoutingService"
    ]
  },
  "stats": {},
  "policy": {
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink": true,
      "statsOutboundDownlink": true
    }
  },
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
      hysteria2) NEW_BLOCK="{\"tag\":\"${NODE_NAME} ${NODE_TAG[1]}\",\"protocol\":\"hysteria\",\"port\":${HY2_PORT},\"settings\":{\"version\":2,\"clients\":[{\"auth\":\"${UUID}\"}]},\"streamSettings\":{\"network\":\"hysteria\",\"security\":\"tls\",\"tlsSettings\":{\"serverNames\":[\"${TLS_SERVER}\"],\"alpn\":[\"h3\"],\"certificates\":[{\"certificateFile\":\"${WORK_DIR}/cert/cert.pem\",\"keyFile\":\"${WORK_DIR}/cert/private.key\"}]}}}" ;;
      vless-ws) NEW_BLOCK="{\"port\":${VLESS_WS_PORT},\"listen\":\"127.0.0.1\",\"protocol\":\"vless\",\"tag\":\"${NODE_NAME} ${NODE_TAG[3]}\",\"settings\":{\"clients\":[{\"id\":\"${UUID}\",\"level\":0}],\"decryption\":\"none\"},\"streamSettings\":{\"network\":\"ws\",\"security\":\"none\",\"wsSettings\":{\"path\":\"/${WS_PATH}-vl\"}},\"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\",\"quic\"],\"metadataOnly\":false}}" ;;
      vmess-ws) NEW_BLOCK="{\"port\":${VMESS_WS_PORT},\"listen\":\"127.0.0.1\",\"protocol\":\"vmess\",\"tag\":\"${NODE_NAME} ${NODE_TAG[4]}\",\"settings\":{\"clients\":[{\"id\":\"${UUID}\",\"alterId\":0}]},\"streamSettings\":{\"network\":\"ws\",\"wsSettings\":{\"path\":\"/${WS_PATH}-vm\"}},\"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\",\"quic\"],\"metadataOnly\":false}}" ;;
      trojan-ws) NEW_BLOCK="{\"port\":${TROJAN_WS_PORT},\"listen\":\"127.0.0.1\",\"protocol\":\"trojan\",\"tag\":\"${NODE_NAME} ${NODE_TAG[5]}\",\"settings\":{\"clients\":[{\"password\":\"${UUID}\"}]},\"streamSettings\":{\"network\":\"ws\",\"security\":\"none\",\"wsSettings\":{\"path\":\"/${WS_PATH}-tr\"}},\"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\",\"quic\"],\"metadataOnly\":false}}" ;;
      ss-ws) NEW_BLOCK="{\"port\":${SS_WS_PORT},\"listen\":\"127.0.0.1\",\"protocol\":\"shadowsocks\",\"tag\":\"${NODE_NAME} ${NODE_TAG[6]}\",\"settings\":{\"clients\":[{\"method\":\"${SS_WS_METHOD:-chacha20-ietf-poly1305}\",\"password\":\"${UUID}\"}],\"network\":\"tcp,udp\"},\"streamSettings\":{\"network\":\"ws\",\"wsSettings\":{\"path\":\"/${WS_PATH}-sh\"}},\"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\",\"quic\"],\"metadataOnly\":false}}" ;;
      xhttp-h1.1-cdn) NEW_BLOCK="{\"port\":${VLESS_XHTTP_PORT},\"listen\":\"127.0.0.1\",\"protocol\":\"vless\",\"tag\":\"${NODE_NAME} ${NODE_TAG[7]}\",\"settings\":{\"clients\":[{\"id\":\"${UUID}\",\"level\":0}],\"decryption\":\"none\"},\"streamSettings\":{\"network\":\"xhttp\",\"security\":\"none\",\"xhttpSettings\":{\"path\":\"/${WS_PATH}-xh\",\"mode\":\"auto\"}},\"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\",\"quic\"],\"metadataOnly\":false}}" ;;
      xhttp-h2-reality) NEW_BLOCK="{\"tag\":\"${NODE_NAME} ${NODE_TAG[8]}\",\"port\":${XHTTP_H2_PORT},\"protocol\":\"vless\",\"settings\":{\"clients\":[{\"id\":\"${UUID}\",\"flow\":\"\"}],\"decryption\":\"none\"},\"streamSettings\":{\"network\":\"xhttp\",\"xhttpSettings\":{\"mode\":\"auto\",\"path\":\"/${WS_PATH}-xh2\"},\"security\":\"reality\",\"realitySettings\":{\"show\":false,\"minClientVer\":\"1.0.0\",\"dest\":\"${TLS_SERVER}:443\",\"xver\":0,\"serverNames\":[\"${TLS_SERVER}\"],\"privateKey\":\"${REALITY_PRIVATE}\",\"publicKey\":\"${REALITY_PUBLIC}\",\"shortIds\":[\"\"],\"alpn\":[\"h2\"]}},\"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\",\"quic\"]}}" ;;
      xhttp-h3-direct) NEW_BLOCK="{\"tag\":\"${NODE_NAME} ${NODE_TAG[9]}\",\"port\":${XHTTP_PORT},\"protocol\":\"vless\",\"settings\":{\"clients\":[{\"id\":\"${UUID}\"}],\"decryption\":\"none\"},\"streamSettings\":{\"network\":\"xhttp\",\"security\":\"tls\",\"xhttpSettings\":{\"mode\":\"stream-up\",\"extra\":{\"alpn\":[\"h3\"]},\"path\":\"/${WS_PATH}-xh3\"},\"tlsSettings\":{\"serverName\":\"${TLS_SERVER}\",\"alpn\":[\"h3\"],\"certificates\":[{\"certificateFile\":\"${WORK_DIR}/cert/cert.pem\",\"keyFile\":\"${WORK_DIR}/cert/private.key\"}]}},\"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\",\"quic\"]}}" ;;
      trojan-direct) NEW_BLOCK="{\"port\":${TROJAN_PORT},\"protocol\":\"trojan\",\"tag\":\"${NODE_NAME} ${NODE_TAG[10]}\",\"settings\":{\"clients\":[{\"password\":\"${UUID}\"}]},\"streamSettings\":{\"network\":\"tcp\",\"security\":\"tls\",\"tlsSettings\":{\"serverName\":\"${TLS_SERVER}\",\"certificates\":[{\"certificateFile\":\"${WORK_DIR}/cert/cert.pem\",\"keyFile\":\"${WORK_DIR}/cert/private.key\"}]}},\"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\",\"quic\"],\"metadataOnly\":false}}" ;;
      ss2022-direct) NEW_BLOCK="{\"port\":${SS2022_PORT},\"protocol\":\"shadowsocks\",\"tag\":\"${NODE_NAME} ${NODE_TAG[11]}\",\"settings\":{\"method\":\"${SS_DIRECT_METHOD:-2022-blake3-aes-128-gcm}\",\"password\":\"${SS2022_PASSWORD:-$(openssl rand -base64 16)}\",\"network\":\"tcp,udp\"},\"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\",\"quic\"],\"metadataOnly\":false}}" ;;
      reality-vision) NEW_BLOCK="{\"tag\":\"${NODE_NAME} ${NODE_TAG[0]}\",\"protocol\":\"vless\",\"port\":${REALITY_PORT},\"settings\":{\"clients\":[{\"id\":\"${UUID}\",\"flow\":\"xtls-rprx-vision\"}],\"decryption\":\"none\"},\"streamSettings\":{\"network\":\"tcp\",\"security\":\"reality\",\"realitySettings\":{\"show\":false,\"minClientVer\":\"1.0.0\",\"dest\":\"${TLS_SERVER}:443\",\"xver\":0,\"serverNames\":[\"${TLS_SERVER}\"],\"privateKey\":\"${REALITY_PRIVATE}\",\"publicKey\":\"${REALITY_PUBLIC}\",\"shortIds\":[\"\"]}},\"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\"]}}" ;;
      reality-grpc) NEW_BLOCK="{\"port\":${GRPC_PORT},\"protocol\":\"vless\",\"tag\":\"${NODE_NAME} ${NODE_TAG[2]}\",\"settings\":{\"clients\":[{\"id\":\"${UUID}\",\"flow\":\"\"}],\"decryption\":\"none\"},\"streamSettings\":{\"network\":\"grpc\",\"security\":\"reality\",\"realitySettings\":{\"show\":false,\"minClientVer\":\"1.0.0\",\"dest\":\"${TLS_SERVER}:443\",\"xver\":0,\"serverNames\":[\"${TLS_SERVER}\"],\"privateKey\":\"${REALITY_PRIVATE}\",\"publicKey\":\"${REALITY_PUBLIC}\",\"shortIds\":[\"\"]},\"grpcSettings\":{\"serviceName\":\"grpc\",\"multiMode\":true}},\"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\"]}}" ;;
    esac
    if [ -n "$NEW_BLOCK" ] && [ -x "$WORK_DIR/jq" ]; then
      $WORK_DIR/jq --argjson block "$NEW_BLOCK" '.inbounds += [$block]' \
        $WORK_DIR/inbound.json > $TEMP_DIR/inbound_tmp.json \
        && mv $TEMP_DIR/inbound_tmp.json $WORK_DIR/inbound.json
    fi

  done

  # Hysteria2 Realm: 注入 finalmask（如果启用）
  if [ "$IS_HY2_REALM" = 'is_hy2_realm' ] && printf '%s\n' "${REINSTALL_TAGS[@]}" | grep -qx 'hysteria2'; then
    local _realm_id="${HY2_REALM_ID:-$UUID}"
    local _finalmask_json
    _finalmask_json=$(build_finalmask_json_str "$_realm_id")
    grep -v '^//' "$WORK_DIR/inbound.json" | $WORK_DIR/jq --argjson fm "$_finalmask_json" \
      '(.inbounds[] | select(.tag | endswith("hysteria2")) | .streamSettings.finalmask) |= $fm' \
      > "$TEMP_DIR/inbound_tmp.json" && mv "$TEMP_DIR/inbound_tmp.json" "$WORK_DIR/inbound.json"
  fi

  mapfile -t CURRENT_PROTOCOLS < <(get_installed_protocols)

  # 等待后台 nginx 安装完成后再生成配置和启动
  wait
  json_nginx
  [ -s "$WORK_DIR/tunnel.json" ] && json_argo
  # nginx 已安装（已 wait 确保完毕）才启动/重载；
  # 不再需要 nginx 时停止脚本管理的 nginx 进程
  if $_NEED_NGINX; then
    if command -v nginx >/dev/null 2>&1; then
      nginx_sync
    fi
  else
    # 不再需要 nginx：停止并删除 nginx.conf，保证「nginx.conf 存在 ≈ 需要 nginx」
    nginx_stop
    rm -f $WORK_DIR/nginx.conf
  fi

  # 当 IS_ARGO=is_argo 但守护进程文件不存在时（如之前被清理），需要完整重建 Argo
  if [ "$IS_ARGO" = 'is_argo' ] && [ ! -s "${ARGO_DAEMON_FILE}" ]; then
    argo_variable

    # 确保 cloudflared 二进制存在（优先用后台已下载到 TEMP_DIR 的缓存）
    wait
    if [ ! -s $WORK_DIR/cloudflared ]; then
      if [ -x $TEMP_DIR/cloudflared ] && [ -s $TEMP_DIR/cloudflared ]; then
        mv $TEMP_DIR/cloudflared $WORK_DIR
      fi
      # 如果复制后还是没有有效二进制，直接下载到工作目录
      if [ ! -s $WORK_DIR/cloudflared ]; then
        rm -f $WORK_DIR/cloudflared $TEMP_DIR/cloudflared
        wget --no-check-certificate -qO $WORK_DIR/cloudflared ${GH_PROXY}https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$ARGO_ARCH 2>/dev/null && chmod +x $WORK_DIR/cloudflared 2>/dev/null
        # 如果还是 0 字节，标记失败以便后续处理
        [ ! -s $WORK_DIR/cloudflared ] && rm -f $WORK_DIR/cloudflared
      fi
    fi

    # 构造 ARGO_RUNS 命令
    if [[ -n "${ARGO_JSON}" && -n "${ARGO_DOMAIN}" ]]; then
      ARGO_RUNS="$WORK_DIR/cloudflared tunnel --edge-ip-version auto --config $WORK_DIR/tunnel.yml run"
      json_argo
    elif [[ -n "${ARGO_TOKEN}" && -n "${ARGO_DOMAIN}" ]]; then
      ARGO_RUNS="$WORK_DIR/cloudflared tunnel --edge-ip-version auto run --token ${ARGO_TOKEN}"
    else
      ARGO_RUNS="$WORK_DIR/cloudflared tunnel --edge-ip-version auto --no-autoupdate --url http://localhost:${NGINX_PORT}"
    fi

    # 创建守护进程文件：统一走 write_argo_daemon，避免 Alpine/systemd 双份手写模板
    write_argo_daemon

    cmd_systemctl enable argo

  elif [ -s "$WORK_DIR/tunnel.json" ]; then
    cmd_systemctl restart argo
  fi

  # 重写 xray 守护进程文件（重装/改协议场景）。
  # 原逻辑：Alpine 不动 init.d（start_pre 已动态检查 nginx），仅 systemd 按 _NEED_NGINX 重写 ExecStartPre。
  # 现统一走 write_xray_daemon，通过临时映射 INSTALL_NGINX=(_NEED_NGINX?y:n) 保持与原 systemd 分支等价，
  # 同时 Alpine 分支也顺带刷新 init.d（函数内 start_pre 等价实现旧逻辑），不会比不刷新更差。
  local INSTALL_NGINX="y"
  [ "$_NEED_NGINX" = 'false' ] && INSTALL_NGINX="n"
  write_xray_daemon
  # 恢复调用方作用域（local 仅在本函数块有效，无需手工 unset）

  # 在 check_install/export_list 之前持久化 IS_SUB/IS_ARGO，确保状态正确
  write_custom 'isSub' "${IS_SUB}"
  write_custom 'isArgo' "${IS_ARGO}"

  # 确保 xray 开机自启（不启动，由后续 API 热更处理）
  if [ "$SYSTEM" = 'Alpine' ]; then
    rc-update add xray default >/dev/null 2>&1
  else
    systemctl daemon-reload 2>/dev/null
    systemctl enable xray >/dev/null 2>&1
  fi
  if api_hot_reload inbounds; then
    info "\n $(text 128) \n"
  else
    warning "\n $(text 94) \n"
  fi
  check_install
  cmd_systemctl status xray &>/dev/null \
    && info "\n Xray $(text 28) $(text 37) \n" \
    || warning "\n Xray $(text 28) $(text 38) \n"
  export_list
  sync_firewall_rules
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

  # 若 Try 隧道且已安装 xhttp-h1.1-cdn，在类型后附加提示
  local ARGO_TYPE="$ARGO_TYPE"
  if [ "$ARGO_TYPE" = 'Try' ] && get_installed_protocols | grep -q 'xhttp-h1.1-cdn'; then
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

  # 隧道类型变化后 nginx 反代目标可能变化，同步脚本 nginx
  [ -s $WORK_DIR/nginx.conf ] && json_nginx
  nginx_sync
  [ -s "$WORK_DIR/tunnel.json" ] && json_argo
  cmd_systemctl enable argo
  export_list
}

# 端口列表压缩为连续段显示（方案 C）：排序去重后按连续段显示，单段 "a - b"，多段逗号分隔；
# 段数 >4 时只显示前 4 段，末尾追加 "等 N 个"（N = 未显示的端口总数）
format_ports_display() {
  local -a PORTS=("$@") SEGS=()
  local -i TOTAL=0 i a b
  local PREV='' SEG_START='' OUT=''
  [ "${#PORTS[@]}" -eq 0 ] && { echo; return; }
  PORTS=($(printf '%s\n' "${PORTS[@]}" | sort -n | uniq))
  TOTAL=${#PORTS[@]}
  SEG_START=${PORTS[0]}
  PREV=${PORTS[0]}
  for ((i=1; i<TOTAL; i++)); do
    if [ $((PREV + 1)) -eq ${PORTS[i]} ]; then
      PREV=${PORTS[i]}
    else
      SEGS+=("$SEG_START $PREV")
      SEG_START=${PORTS[i]}
      PREV=${PORTS[i]}
    fi
  done
  SEGS+=("$SEG_START $PREV")
  if [ "${#SEGS[@]}" -eq 1 ]; then
    read -r a b <<< "${SEGS[0]}"
    [ "$a" -eq "$b" ] && OUT="$a" || OUT="${a} - ${b}"
    if [ "$TOTAL" -gt 6 ]; then
      [ "$L" = 'C' ] && OUT="${OUT}，共 ${TOTAL} 个" || OUT="${OUT}, ${TOTAL} in total"
    fi
  elif [ "${#SEGS[@]}" -le 4 ]; then
    local -a PARTS=()
    for s in "${SEGS[@]}"; do
      read -r a b <<< "$s"
      [ "$a" -eq "$b" ] && PARTS+=("$a") || PARTS+=("${a} - ${b}")
    done
    OUT="${PARTS[0]}"
    for s in "${PARTS[@]:1}"; do OUT="${OUT}, ${s}"; done
  else
    local -a PARTS=()
    local -i SHOWN=0
    for ((i=0; i<4; i++)); do
      read -r a b <<< "${SEGS[i]}"
      SHOWN=$(( SHOWN + b - a + 1 ))
      [ "$a" -eq "$b" ] && PARTS+=("$a") || PARTS+=("${a} - ${b}")
    done
    OUT="${PARTS[0]}"
    for s in "${PARTS[@]:1}"; do OUT="${OUT}, ${s}"; done
    if [ "$L" = 'C' ]; then
      OUT="${OUT} ... 等 $(( TOTAL - SHOWN )) 个"
    else
      OUT="${OUT} ... $(( TOTAL - SHOWN )) more"
    fi
  fi
  echo "$OUT"
}

# -d 菜单：监听端口 → 方式选择（1. 修改开始端口，默认 / 2. 各协议独立端口）
change_port_mode() {
  local PORTS_MODE='' MODE_ERROR=6
  while true; do
    hint "\n $(text 157) "
    reading "\n $(text 24) " PORTS_MODE
    case "${PORTS_MODE:-1}" in
      1 ) change_start_port; return ;;
      2 ) change_independent_port; return ;;
      * ) (( MODE_ERROR-- )) || true
          [ "$MODE_ERROR" = 0 ] && error "\n $(text 3) \n"
          warning " $(text 123) " ;;
    esac
  done
}

# 读取 hysteria2 当前监听端口（未安装时输出为空）
get_hy2_port() {
  [ -s "$WORK_DIR/inbound.json" ] || return
  grep -v '^//' "$WORK_DIR/inbound.json" | $WORK_DIR/jq -r '[.inbounds[] | select(.tag | split(" ")[-1] == "hysteria2") | .port] | .[0] // empty' 2>/dev/null
}

# 端口应用后的通用后处理（方式 1 / 2 共用）：nginx / argo / 热加载 / hy2 端口跳跃目标重建 / 防火墙 / 订阅
apply_ports_post() {
  local HY2_OLD="$1" HY2_NEW="$2"
  fetch_nodes_value
  # proxy_pass 端口已更新，同步脚本 nginx（已在运行则 reload，未运行则启动）
  [ -s "$WORK_DIR/nginx.conf" ] && json_nginx
  nginx_sync
  [ -s "$WORK_DIR/tunnel.json" ] && json_argo

  # 提取所有 inbound tag 强制热更新（端口变更但 tag 不变，增量 diff 无法检测）
  local _force_all_tags=()
  while IFS= read -r _t; do
    [ -n "$_t" ] && _force_all_tags+=("$_t")
  done < <(grep -v '^//' "$WORK_DIR/inbound.json" | $WORK_DIR/jq -r '.inbounds[].tag // empty' 2>/dev/null)
  api_hot_reload inbounds "${_force_all_tags[@]}"
  info "\n $(text 128) \n"

  # Hysteria2 端口跳跃目标同步（hy2 端口变化且跳跃已启用时，显式重建 dnat 目标）
  if [ -n "$HY2_OLD" ] && [ -n "$HY2_NEW" ] && [ "$HY2_OLD" != "$HY2_NEW" ]; then
    check_port_hopping_nat
    if [ -n "$PORT_HOPPING_START" ] && [ -n "$PORT_HOPPING_END" ]; then
      del_port_hopping_nat
      FIREWALL_SILENT=1 add_port_hopping_nat "$PORT_HOPPING_START" "$PORT_HOPPING_END" "$HY2_NEW" >/dev/null 2>&1
    fi
  fi

  FIREWALL_SILENT=1 sync_firewall_rules >/dev/null 2>&1 || true
  [ -s "$WORK_DIR/tunnel.json" ] && cmd_systemctl restart argo
  export_list
  cmd_systemctl status xray &>/dev/null && info "
 Xray $(text 28) $(text 37)
" || warning "
 Xray $(text 27) $(text 38)
"
  # 显示新端口列表
  local PORTS=$(format_ports_display $(grep -v '^//' "$WORK_DIR/inbound.json" | $WORK_DIR/jq -r '.inbounds[] | .port // empty' 2>/dev/null))
  [ -n "$PORTS" ] && hint " $(text 160) "
  info " $(text 166) "
}

# 方式 2：各协议独立端口（多选协议 → 逐项询问端口 → 校验 → 预览确认 → 应用）
change_independent_port() {
  local -a LETTERS=() PROTOS=() PORTS=() PROTO_IDX=()
  local -A OWNER=()
  local -i i j
  local letter proto port json
  json=$(grep -v '^//' "$WORK_DIR/inbound.json" 2>/dev/null)
  [ -z "$json" ] && { info " $(text 130) "; return; }
  for ((i=0; i<${#PROTOCOL_LIST[@]}; i++)); do
    port=$(echo "$json" | $WORK_DIR/jq -r --arg tag "${NODE_TAG[i]}" '[.inbounds[] | select(.tag | split(" ")[-1] == $tag) | .port] | .[0] // empty' 2>/dev/null)
    [ -z "$port" ] && continue
    letter=$(asc $((i+98)))
    LETTERS+=("$letter"); PROTOS+=("${PROTOCOL_LIST[i]}"); PORTS+=("$port"); PROTO_IDX+=("$i")
    OWNER[$port]="${PROTOCOL_LIST[i]}"
  done
  [ "${#LETTERS[@]}" -eq 0 ] && { info " $(text 130) "; return; }

  # 多选需要修改端口的协议（a = 全部，b.. = 逐协议，留空 = 不修改，顺序 = 输入顺序）
  local MAX_LETTER=$(asc $(( ${#PROTOCOL_LIST[@]} + 97 )))
  local CHOOSE='' SELECTED=()
  hint "\n $(text 158) "
  for ((i=0; i<${#LETTERS[@]}; i++)); do
    local LETTER="${LETTERS[i]}" PROTO="${PROTOS[i]}" PORT="${PORTS[i]}"
    hint " $(text 168) "
  done
  reading "\n $(text 24) " CHOOSE
  if [ -z "$CHOOSE" ]; then
    info " $(text 130) "
    return
  fi
  if [[ "${CHOOSE,,}" =~ ^[aA]$ ]]; then
    SELECTED=("${LETTERS[@]}")
  else
    local FILTERED=$(grep -o . <<< "${CHOOSE,,}" | sed "/[^b-$MAX_LETTER]/d" | awk '!seen[$0]++' | tr -d '\n')
    local TMP=() ch
    while IFS= read -r -n1 ch; do
      [ -n "$ch" ] && [[ " ${LETTERS[*]} " =~ " $ch " ]] && TMP+=("$ch")
    done <<< "$FILTERED"
    SELECTED=("${TMP[@]}")
  fi
  [ "${#SELECTED[@]}" -eq 0 ] && { info " $(text 130) "; return; }

  # 逐协议询问新端口（留空 = 不变；校验：数字范围 / 与他协议重复 / 系统占用，错误即时提示，上限 6 次）
  local -a CHG_LETTERS=() CHG_OLDS=() CHG_NEWS=()
  local chg_letter proto oldport newport conflict new_port err_time
  for ((j=0; j<${#SELECTED[@]}; j++)); do
    chg_letter="${SELECTED[j]}"
    for ((i=0; i<${#LETTERS[@]}; i++)); do
      [ "${LETTERS[i]}" = "$chg_letter" ] && break
    done
    proto="${PROTOS[i]}"; oldport="${PORTS[i]}"
    new_port=''
    err_time=6
    while true; do
      local PROTO="$proto" PORT="$oldport"
      reading " $(text 159) " new_port
      if [ -z "$new_port" ]; then
        newport="$oldport"; break
      fi
      if [[ "$new_port" =~ ^[1-9][0-9]{2,4}$ && "$new_port" -ge "$MIN_PORT" && "$new_port" -le "$MAX_PORT" ]]; then
        conflict="${OWNER[$new_port]-}"
        if [ -n "$conflict" ] && [ "$conflict" != "$proto" ]; then
          local PORT="$new_port" PROTO="$conflict"
          warning " $(text 167) "
          (( err_time-- )) || true
          [ "$err_time" = 0 ] && error "\n $(text 3) \n"
          continue
        fi
        if [ "$new_port" != "$oldport" ]; then
          refresh_port_snapshot
          if is_port_in_use "$new_port"; then
            local PORT="$new_port"
            warning " $(text 162) "
            (( err_time-- )) || true
            [ "$err_time" = 0 ] && error "\n $(text 3) \n"
            continue
          fi
        fi
        newport="$new_port"; break
      else
        local PORT="$new_port"
        warning " $(text 162) "
        (( err_time-- )) || true
        [ "$err_time" = 0 ] && error "\n $(text 3) \n"
      fi
    done
    [ "$newport" != "$oldport" ] && { unset "OWNER[$oldport]"; OWNER[$newport]="$proto"; }
    [ "$newport" != "$oldport" ] && { CHG_LETTERS+=("$chg_letter"); CHG_OLDS+=("$oldport"); CHG_NEWS+=("$newport"); }
  done

  [ "${#CHG_LETTERS[@]}" -eq 0 ] && { info " $(text 161) "; return; }

  # 变更预览（只列变更项）与确认
  hint "\n $(text 163) "
  for ((j=0; j<${#CHG_LETTERS[@]}; j++)); do
    for ((i=0; i<${#LETTERS[@]}; i++)); do
      [ "${LETTERS[i]}" = "${CHG_LETTERS[j]}" ] && break
    done
    local PROTO="${PROTOS[i]}" OLD="${CHG_OLDS[j]}" NEW="${CHG_NEWS[j]}"
    hint " $(text 165) "
  done
  reading " $(text 164) " PORTS_CONFIRM
  [ "${PORTS_CONFIRM,,}" != 'y' ] && { info " $(text 130) "; return; }

  # 应用（按 tag 映射逐一改写 inbound.json，避免端口号在其他字段重复出现时误伤）
  local HY2_OLD=$(get_hy2_port)
  for ((j=0; j<${#CHG_LETTERS[@]}; j++)); do
    for ((i=0; i<${#LETTERS[@]}; i++)); do
      [ "${LETTERS[i]}" = "${CHG_LETTERS[j]}" ] && break
    done
    grep -v '^//' "$WORK_DIR/inbound.json" | $WORK_DIR/jq --arg tag "${NODE_TAG[PROTO_IDX[i]]}" --argjson port "${CHG_NEWS[j]}"       '.inbounds |= map(if (.tag | split(" ")[-1] == $tag) then .port = $port else . end)'       > "$TEMP_DIR/inbound_tmp.json" && mv "$TEMP_DIR/inbound_tmp.json" "$WORK_DIR/inbound.json" || error " $(text 38) "
  done
  apply_ports_post "$HY2_OLD" "$(get_hy2_port)"
}

# 方式 1：修改开始端口（各协议按顺序占用，现有逻辑 + 预览确认 + hy2 跳跃联动）
change_start_port() {
  local OLD_PORTS OLD_START_PORT OLD_CONSECUTIVE_PORTS
  local _STEP_NUM_BAK="${STEP_NUM-}" _TOTAL_STEPS_BAK="${TOTAL_STEPS-}"
  [ ! -s "$WORK_DIR/inbound.json" ] && error " $(text 70) "
  OLD_PORTS=$(grep -v '^//' "$WORK_DIR/inbound.json" | $WORK_DIR/jq -r '.inbounds[].port' 2>/dev/null)
  [ -z "$OLD_PORTS" ] && error " $(text 70) "
  OLD_START_PORT=$(awk 'NR == 1 { min = $0 } { if ($0 < min) min = $0 } END {print min}' <<< "$OLD_PORTS")
  OLD_CONSECUTIVE_PORTS=$(awk 'END { print NR }' <<< "$OLD_PORTS")
  local HY2_OLD=$(get_hy2_port)
  unset STEP_NUM TOTAL_STEPS
  START_PORT=''
  input_start_port "$OLD_CONSECUTIVE_PORTS"
  STEP_NUM="$_STEP_NUM_BAK"
  TOTAL_STEPS="$_TOTAL_STEPS_BAK"
  [ -z "$START_PORT" ] && info " $(text 103) " && return
  [ "$START_PORT" = "$OLD_START_PORT" ] && info " $(text 103) " && return
  # 预览确认（方式 1 / 方式 2 同一套确认交互）
  local NUM="$OLD_CONSECUTIVE_PORTS" OLD_START="$OLD_START_PORT" NEW_START="$START_PORT" NEW_END=$((START_PORT + OLD_CONSECUTIVE_PORTS - 1))
  hint "\n $(text 169) "
  reading " $(text 164) " PORTS_CONFIRM
  [ "${PORTS_CONFIRM,,}" != 'y' ] && { info " $(text 130) "; return; }

  grep -v '^//' "$WORK_DIR/inbound.json"     | $WORK_DIR/jq --argjson start "$START_PORT" '.inbounds |= (to_entries | map(.value.port = ($start + .key) | .value))'     > "$TEMP_DIR/inbound_tmp.json"     && mv "$TEMP_DIR/inbound_tmp.json" "$WORK_DIR/inbound.json" || error " $(text 38) "

  apply_ports_post "$HY2_OLD" "$(get_hy2_port)"
}

# ===================== 自定义路由规则（Xray 版本）=====================
CUSTOM_ROUTE_FILE="${WORK_DIR}/custom_route.json"

# 统计自定义路由规则数量
custom_route_count() {
  [ -s "$CUSTOM_ROUTE_FILE" ] && $WORK_DIR/jq -r 'length // 0' "$CUSTOM_ROUTE_FILE" 2>/dev/null || echo 0
}

# 同步自定义路由规则到 outbound.json
# 使用 _remark 字段标记自定义规则，Xray 会忽略未知字段，同时方便我们识别和清除旧规则
custom_route_sync() {
  local _ob="$WORK_DIR/outbound.json" _ob_tmp="$TEMP_DIR/outbound_tmp.json"
  [ -s "$_ob" ] || return 1
  grep -v '^//' "$_ob" > "$_ob_tmp.clean" 2>/dev/null || return 1

  if [ -s "$CUSTOM_ROUTE_FILE" ] && [ "$($WORK_DIR/jq -r 'length // 0' "$CUSTOM_ROUTE_FILE")" -gt 0 ]; then
    # 兼容旧版：domain 为字符串的条目归一化为数组并落盘（只迁移一次）
    if $WORK_DIR/jq -e '[.[] | select((.domain | type) != "array")] | length > 0' "$CUSTOM_ROUTE_FILE" >/dev/null 2>&1; then
      $WORK_DIR/jq '[.[] | .domain = (if (.domain | type) == "array" then .domain else [.domain] end)]' "$CUSTOM_ROUTE_FILE" > "$_ob_tmp.migrate" 2>/dev/null \
        && mv "$_ob_tmp.migrate" "$CUSTOM_ROUTE_FILE"
    fi
    # 将 custom_route.json 条目转为 Xray 路由规则，合并到 outbound.json
    $WORK_DIR/jq -s '
      .[0] as $ob |
      .[1] as $custom |
      ($custom | to_entries | map({type:"field", domain: (.value.domain | if type == "array" then . else [.] end), outboundTag: .value.outboundTag, _remark:"custom-route"})) as $new_rules |
      $ob | .routing.rules = ($new_rules + [.routing.rules[]? | select(._remark != "custom-route")])
    ' "$_ob_tmp.clean" "$CUSTOM_ROUTE_FILE" > "$_ob_tmp" 2>/dev/null && mv "$_ob_tmp" "$_ob"
  else
    # 无自定义规则，清除残留的旧规则
    $WORK_DIR/jq '
      .routing.rules = [.routing.rules[]? | select(._remark != "custom-route")]
    ' "$_ob_tmp.clean" > "$_ob_tmp" 2>/dev/null && mv "$_ob_tmp" "$_ob"
  fi
  rm -f "$_ob_tmp.clean"
}

# 添加自定义路由规则
custom_route_add() {
  # 选择规则类型
  hint "\n $(text 133) "
  reading " $(text 24) " RULE_TYPE_CHOICE
  case "$RULE_TYPE_CHOICE" in
    1 ) local RULE_TYPE="domain" ;;
    2 ) local RULE_TYPE="geosite" ;;
    * ) info " $(text 130) " && return ;;
  esac

  # 选择出站
  hint "\n $(text 136) "
  reading " $(text 24) " OUTBOUND_CHOICE
  case "$OUTBOUND_CHOICE" in
    1|"" ) local OUTBOUND_TAG="warp-IPv4" ;;
    2 ) local OUTBOUND_TAG="warp-IPv6" ;;
    * ) info " $(text 130) " && return ;;
  esac

  local VALIDATED_VALUES=()

  if [ "$RULE_TYPE" = "domain" ]; then
    # 输入域名后缀
    reading " $(text 134) " DOMAIN_INPUT
    [ -z "$DOMAIN_INPUT" ] && info " $(text 130) " && return

    # 处理输入：支持逗号、顿号、分号、竖线等分隔（全角/半角）
    local DOMAINS=()
    while IFS= read -r _seg; do
      _seg=$(sed 's/^[[:space:]]*//; s/[[:space:]]*$//' <<< "$_seg")
      [ -n "$_seg" ] && DOMAINS+=("$_seg")
    done < <(printf '%s\n' "$DOMAIN_INPUT" | sed -e 's/，/,/g' -e 's/、/,/g' -e 's/；/,/g' -e 's/｜/,/g' -e 's/[;|]/,/g' | tr ',' '\n')
    [ "${#DOMAINS[@]}" -eq 0 ] && info " $(text 130) " && return

    # 验证域名格式
    local DOMAIN
    for DOMAIN in "${DOMAINS[@]}"; do
      DOMAIN=$(sed -e 's/。/./g' -e 's/．/./g' <<< "$DOMAIN" | tr '[:upper:]' '[:lower:]')
      if [[ "$DOMAIN" =~ ^[a-z0-9]([a-z0-9.-]*[a-z0-9])?\.[a-z]{2,}$ ]]; then
        VALIDATED_VALUES+=("$DOMAIN")
      else
        warning " $(text 141) "
      fi
    done
    [ "${#VALIDATED_VALUES[@]}" -eq 0 ] && warning " $(text 130) " && return

  elif [ "$RULE_TYPE" = "geosite" ]; then
    # 输入 geosite 分类名称
    reading "\n $(text 135) " GEOSITE_INPUT
    [ -z "$GEOSITE_INPUT" ] && info " $(text 130) " && return

    # 解析逗号分隔输入
    local GEOSITES=()
    while IFS= read -r _seg; do
      _seg=$(sed 's/^[[:space:]]*//; s/[[:space:]]*$//' <<< "$_seg")
      [ -n "$_seg" ] && GEOSITES+=("$_seg")
    done < <(printf '%s\n' "$GEOSITE_INPUT" | sed -e 's/，/,/g' -e 's/、/,/g' -e 's/；/,/g' -e 's/｜/,/g' -e 's/[;|]/,/g' | tr ',' '\n')
    [ "${#GEOSITES[@]}" -eq 0 ] && info " $(text 130) " && return

    local GS
    for GS in "${GEOSITES[@]}"; do
      GS=$(sed 's/^[[:space:]]*//; s/[[:space:]]*$//' <<< "$GS" | tr '[:upper:]' '[:lower:]')
      # 统一格式：去掉 geosite- 或 geosite: 前缀再重新添加
      GS=$(sed -E 's/^geosite[-:]//I' <<< "$GS")
      # 校验 geosite 名称：仅字母数字、下划线、连字符
      [[ "$GS" =~ ^[a-z0-9][a-z0-9_-]*$ ]] && VALIDATED_VALUES+=("geosite:${GS}") || warning " $(text 141) "
    done
    [ "${#VALIDATED_VALUES[@]}" -eq 0 ] && info " $(text 130) " && return
  fi

  # 构建新规则 JSON（Xray 路由格式：domain 为数组，多值归并为一条规则）
  local NEW_JSON='[]' DOMAIN_JSON='[]' VAL
  for VAL in "${VALIDATED_VALUES[@]}"; do
    DOMAIN_JSON=$(echo "$DOMAIN_JSON" | $WORK_DIR/jq --arg d "$VAL" '. + [$d]')
  done
  NEW_JSON=$(echo "$NEW_JSON" | $WORK_DIR/jq --argjson d "$DOMAIN_JSON" --arg t "$OUTBOUND_TAG" \
    '. + [{"domain": $d, "outboundTag": $t}]')

  # 读现有规则，去重合并（domain 数组内容 + outboundTag 联合去重）
  if [ -s "$CUSTOM_ROUTE_FILE" ]; then
    $WORK_DIR/jq -s '
      .[0] + .[1] |
      unique_by((.domain | if type == "array" then . else [.] end | join(",")), .outboundTag)
    ' "$CUSTOM_ROUTE_FILE" <(echo "$NEW_JSON") > "$CUSTOM_ROUTE_FILE.tmp" 2>/dev/null \
      && mv "$CUSTOM_ROUTE_FILE.tmp" "$CUSTOM_ROUTE_FILE"
  else
    echo "$NEW_JSON" | $WORK_DIR/jq '.' > "$CUSTOM_ROUTE_FILE" 2>/dev/null
  fi

  custom_route_sync
  api_hot_reload custom_routes
  info " $(text 137) "
}

# 查看自定义路由规则
custom_route_view() {
  if [ ! -s "$CUSTOM_ROUTE_FILE" ] || [ "$($WORK_DIR/jq -r 'length // 0' "$CUSTOM_ROUTE_FILE")" -eq 0 ]; then
    hint " $(text 138) "
    return 1
  fi

  hint "\n $(text 142) \n"
  printf "  %-4s %-20s %s\n" "#" "OutboundTag" "Domain"
  printf "  %-4s %-20s %s\n" "---" "-------------------" "---------------------------------------"

  local IDX=0
  while IFS= read -r _item; do
    ((IDX++))
    local _d=$(echo "$_item" | $WORK_DIR/jq -r '.domain | if type == "array" then join(", ") else . end')
    local _t=$(echo "$_item" | $WORK_DIR/jq -r '.outboundTag // "warp-IPv4"')
    printf "  %-4s %-20s %s\n" "$IDX" "$_t" "$_d"
  done < <($WORK_DIR/jq -c '.[]?' "$CUSTOM_ROUTE_FILE" 2>/dev/null)
  echo ""
  return 0
}

# 删除自定义路由规则
custom_route_delete() {
  custom_route_view || return

  reading " $(text 139) " DELETE_INPUT
  [ -z "$DELETE_INPUT" ] && info " $(text 130) " && return

  # 解析编号：全角/半角分隔符（，、；;|｜）统一为半角逗号后按 `,` 切分；
  # 逐段去除首尾空格，段内含非数字/非连字符则整段丢弃，防止粘连误删；
  # 支持范围段：2-4 / 2－4 表示 2、3、4 连续，反向如 4-2 无效
  local DELETE_NUMS=()
  while IFS= read -r _seg; do
    _seg=$(sed 's/^[[:space:]]*//; s/[[:space:]]*$//' <<< "$_seg")
    [ -z "$_seg" ] && continue
    if [[ "$_seg" =~ ^[0-9]+$ ]]; then
      DELETE_NUMS+=("$_seg")
    elif [[ "$_seg" =~ ^([0-9]+)-([0-9]+)$ ]]; then
      local _range_s="${BASH_REMATCH[1]}" _range_e="${BASH_REMATCH[2]}"
      [ "$_range_s" -le "$_range_e" ] || continue
      local _i
      for _i in $(seq "$_range_s" "$_range_e"); do DELETE_NUMS+=("$_i"); done
    fi
  done < <(printf '%s\n' "$DELETE_INPUT" | sed -e 's/，/,/g' -e 's/、/,/g' -e 's/；/,/g' -e 's/｜/,/g' -e 's/[;|]/,/g' -e 's/－/-/g' | tr ',' '\n')
  [ "${#DELETE_NUMS[@]}" -eq 0 ] && info " $(text 130) " && return

  local TOTAL
  TOTAL=$($WORK_DIR/jq -r 'length // 0' "$CUSTOM_ROUTE_FILE" 2>/dev/null)
  local TO_DELETE=()
  local NUM
  for NUM in "${DELETE_NUMS[@]}"; do
    [[ "$NUM" =~ ^[0-9]+$ ]] && [ "$NUM" -ge 1 ] && [ "$NUM" -le "$TOTAL" ] && TO_DELETE+=("$NUM")
  done
  [ "${#TO_DELETE[@]}" -eq 0 ] && info " $(text 130) " && return

  # 排序去重（数字降序；同步读取避免进程替换在 bash 3.2 下的竞态）
  local SORTED_NUMS
  SORTED_NUMS=$(printf '%s\n' "${TO_DELETE[@]}" | sort -rn -u)
  TO_DELETE=()
  while IFS= read -r NUM; do [ -n "$NUM" ] && TO_DELETE+=("$NUM"); done <<< "$SORTED_NUMS"

  # 删除指定索引的条目（jq 索引从 0 开始）
  local DEL_FILTER='del('
  local FIRST=true
  for NUM in "${TO_DELETE[@]}"; do
    $FIRST || DEL_FILTER+=', '
    DEL_FILTER+=".[$((NUM-1))]"
    FIRST=false
  done
  DEL_FILTER+=')'

  $WORK_DIR/jq "$DEL_FILTER" "$CUSTOM_ROUTE_FILE" > "$CUSTOM_ROUTE_FILE.tmp" 2>/dev/null \
    && mv "$CUSTOM_ROUTE_FILE.tmp" "$CUSTOM_ROUTE_FILE"

  # 如果全部删完了，删除文件
  [ "$($WORK_DIR/jq -r 'length // 0' "$CUSTOM_ROUTE_FILE" 2>/dev/null)" -eq 0 ] && rm -f "$CUSTOM_ROUTE_FILE"

  custom_route_sync
  api_hot_reload custom_routes
  [ "${#TO_DELETE[@]}" -gt 1 ] && info " $(text 140) (${#TO_DELETE[@]})" || info " $(text 140) "
}

# 自定义路由规则子菜单
custom_route_menu() {
  while true; do
    CUSTOM_ROUTE_COUNT=$(custom_route_count)
    hint "\n $(text 131) \n"
    [ "$CUSTOM_ROUTE_COUNT" -eq 0 ] && warning " $(text 138) \n"
    hint " $(text 132) "
    hint ""
    reading " $(text 24) " CUSTOM_ROUTE_CHOICE

    case "$CUSTOM_ROUTE_CHOICE" in
      1 ) custom_route_add ;;
      2 ) custom_route_view ;;
      3 ) custom_route_delete ;;
      0 ) return ;;
      * ) info " $(text 130) " && return ;;
    esac
  done
}
# ===================== 自定义路由规则 END =====================

# ===================== 更换 WARP 账户 START =====================

# 更换 WARP 账户：二级菜单（重新注册 / 手动输入）
change_warp_account() {
  local WARP_ACCOUNT_CHOICE
  while true; do
    hint "\n $(text 171) \n"
    reading " $(text 24) " WARP_ACCOUNT_CHOICE

    case "$WARP_ACCOUNT_CHOICE" in
      1 ) change_warp_account_register ;;
      2 ) change_warp_account_manual ;;
      0 ) return ;;
      * ) info " $(text 103) " ;;
    esac
  done
}

# 方式1：重新注册免费账户
change_warp_account_register() {
  local WARP_ACCOUNT PRIVATE_KEY ADDRESS6 R1 R2 R3
  WARP_ACCOUNT=$(wget -qO- --tries=10 --waitretry=1 --timeout=2 "https://warp.cloudflare.nyc.mn/?run=register")

  if ! grep -q '"id"' <<< "$WARP_ACCOUNT"; then
    warning "\n $(text 172) \n"
    return
  fi

  PRIVATE_KEY=$(awk -F'"' '/"private_key"/{print $4}' <<< "$WARP_ACCOUNT")
  ADDRESS6=$(awk -F'"' '/"v6":/ && $4 !~ /^\[/ {print $4}' <<< "$WARP_ACCOUNT")
  R1=$(awk '/"reserved":/ {getline; gsub(/[^0-9]/, ""); print}' <<< "$WARP_ACCOUNT")
  R2=$(awk '/"reserved":/ {getline; getline; gsub(/[^0-9]/, ""); print}' <<< "$WARP_ACCOUNT")
  R3=$(awk '/"reserved":/ {getline; getline; getline; gsub(/[^0-9]/, ""); print}' <<< "$WARP_ACCOUNT")

  # 兜底：接口返回格式异常导致提取为空时，按注册失败处理，保留原账户
  if [ -z "$PRIVATE_KEY" ] || [ -z "$ADDRESS6" ] || [ -z "$R1" ] || [ -z "$R2" ] || [ -z "$R3" ]; then
    warning "\n $(text 172) \n"
    return
  fi

  change_warp_account_apply "$ADDRESS6" "$PRIVATE_KEY" "$R1" "$R2" "$R3"
}

# 方式2：手动输入账户信息（IPv6 / Private Key / Reserved）
change_warp_account_manual() {
  local ADDRESS6 PRIVATE_KEY RESERVED_INPUT R1 R2 R3 RESERVED_ERROR_TIME=5

  # 第 1 步：IPv6 地址（校验含冒号）
  while true; do
    reading "\n $(text 173) " ADDRESS6
    [[ "$ADDRESS6" =~ : ]] && break
    warning " $(text 180) "
  done

  # 第 2 步：Private Key（43 位 base64 字符 + 结尾 =）
  while true; do
    reading " $(text 174) " PRIVATE_KEY
    [[ "$PRIVATE_KEY" =~ ^[A-Za-z0-9+/_-]{43}=$ ]] && break
    warning " $(text 179) "
  done

  # 第 3 步：Reserved（先读取一次，再进入校验循环；捕获组提取 3 组连续数字，错误计数复用 uuid 的 a=5 风格）
  reading " $(text 175) " RESERVED_INPUT
  until [[ "$RESERVED_INPUT" =~ ([0-9]+)[^0-9]*([0-9]+)[^0-9]*([0-9]+) ]] || [ "$RESERVED_ERROR_TIME" = 0 ]; do
    (( RESERVED_ERROR_TIME-- )) || true
    [ "$RESERVED_ERROR_TIME" = 0 ] && { warning "\n $(text 176) \n"; return; }
    warning " $(text 176) "
    reading " $(text 175) " RESERVED_INPUT
  done
  R1="${BASH_REMATCH[1]}"; R2="${BASH_REMATCH[2]}"; R3="${BASH_REMATCH[3]}"

  change_warp_account_apply "$ADDRESS6" "$PRIVATE_KEY" "$R1" "$R2" "$R3"
}

# 替换 outbound.json + xray -test + API 热更 + 结果提示
change_warp_account_apply() {
  local ADDRESS6="$1" PRIVATE_KEY="$2" R1="$3" R2="$4" R3="$5"
  local OB_FILE="$WORK_DIR/outbound.json"
  local OB_TMP="$TEMP_DIR/outbound_warp_tmp.json"

  [ -s "$OB_FILE" ] && grep -q '"wireguard"' "$OB_FILE" || return 1

  cp "$OB_FILE" "$OB_FILE.bak"

  sed -i "s|\"secretKey\":[ ]*\".*\"|\"secretKey\": \"${PRIVATE_KEY}\"|" "$OB_FILE"
  sed -i -E "s|\"([0-9a-fA-F:]+)/128\"|\"${ADDRESS6}/128\"|" "$OB_FILE"
  # reserved 为多行数组，sed 单行正则无法覆盖，用 jq 原子更新（失败不落盘）
  $WORK_DIR/jq --argjson res "[${R1},${R2},${R3}]" \
    '(.outbounds[] | select(.tag == "wireguard") | .settings.reserved) = $res' \
    "$OB_FILE" > "$OB_TMP" 2>/dev/null && mv "$OB_TMP" "$OB_FILE"

  # 直接热更单个出站（内部已含 API 不可用时降级 restart 的兜底）；force 强制替换 wireguard 账户字段
  if api_hot_reload outbound "wireguard" force; then
    sleep 1
    if cmd_systemctl status xray &>/dev/null; then
      rm -f "$OB_FILE.bak"
      info "\n $(text 178) $(text 37) \n"
      info " $(text 181) "
      exit 0
    else
      mv -f "$OB_FILE.bak" "$OB_FILE"
      cmd_systemctl restart xray >/dev/null 2>&1 || true
      warning "\n $(text 178) $(text 38) \n"
    fi
  else
    mv -f "$OB_FILE.bak" "$OB_FILE"
    cmd_systemctl restart xray >/dev/null 2>&1 || true
    warning "\n $(text 178) $(text 38) \n"
  fi
}

# ===================== 更换 WARP 账户 END =====================

change_config() {
  [ ! -d "${WORK_DIR}" ] && error " $(text 70) "

  fetch_nodes_value || error " $(text 70) "

  local MENU_IDX=() MENU_KEY=() MENU_VAL=()

  [[ -n "$SERVER" && "$SERVER" != '__CDN_UNSET__' ]] && MENU_IDX+=(107) && MENU_KEY+=(cdn) && MENU_VAL+=("${SERVER_DISPLAY:-$SERVER}")
  [ -n "$TLS_SERVER" ] && MENU_IDX+=(108) && MENU_KEY+=(sni) && MENU_VAL+=("$TLS_SERVER")
  local PORTS_NOW=$(grep -v '^//' "$WORK_DIR/inbound.json" 2>/dev/null | $WORK_DIR/jq -r '.inbounds[] | .port // empty' 2>/dev/null)
  if [ -n "$PORTS_NOW" ]; then
    MENU_IDX+=(119) && MENU_KEY+=(ports) && MENU_VAL+=("$(format_ports_display ${PORTS_NOW})")
  fi
  [ -n "$NODE_NAME" ] && MENU_IDX+=(109) && MENU_KEY+=(name) && MENU_VAL+=("$NODE_NAME")
  [ -n "$UUID" ] && MENU_IDX+=(110) && MENU_KEY+=(uuid) && MENU_VAL+=("$UUID")
  [ -n "$SERVER_IP" ] && MENU_IDX+=(111) && MENU_KEY+=(serverip) && MENU_VAL+=("$SERVER_IP")

  # Hysteria2 带宽和端口跳跃（仅在 Hysteria2 已安装时显示）
  if [ -n "$HY2_PORT" ]; then
    # Hysteria2 带宽参数（一定有，默认 200/1000）
    HY2_UP_NOW=${HY2_UP_NOW:-200}
    HY2_DOWN_NOW=${HY2_DOWN_NOW:-1000}
    MENU_IDX+=(120) && MENU_KEY+=(hy2bw) && MENU_VAL+=("${HY2_UP_NOW}/${HY2_DOWN_NOW}")

    # 端口跳跃选项；是否已启用由 PORT_HOPPING_START/END 决定
    MENU_IDX+=(6) && MENU_KEY+=(hopping)
    if [ -n "$PORT_HOPPING_START" ]; then
      MENU_VAL+=("${PORT_HOPPING_START}:${PORT_HOPPING_END}")
    else
      MENU_VAL+=("$(text 67)")
    fi

    # Hysteria2 Realm 开关（当前状态由 IS_HY2_REALM 决定）
    if [ "$IS_HY2_REALM" = 'is_hy2_realm' ]; then
      MENU_IDX+=(127) && MENU_KEY+=(hy2realm) && MENU_VAL+=("$(text 127)")
    else
      MENU_IDX+=(129) && MENU_KEY+=(hy2realm) && MENU_VAL+=("$(text 129)")
    fi
  fi

  # 客户端指纹（始终显示，默认 chrome）
  MENU_IDX+=(143) && MENU_KEY+=(fingerprint) && MENU_VAL+=("${FINGER_PRINT:-chrome}")

  # 指定网络出口（始终显示，默认空 = 不指定）
  MENU_IDX+=(75) && MENU_KEY+=(bindinterface) && MENU_VAL+=("${BIND_IFACE:-default}")

  # 自定义 warp 出站路由规则（使用 custom_route_count 统计）
  CUSTOM_ROUTE_COUNT=$(custom_route_count 2>/dev/null || echo 0)
  MENU_IDX+=(131) && MENU_KEY+=(customroute) && MENU_VAL+=("${CUSTOM_ROUTE_COUNT}")

  # 更换 WARP 账户（仅当 outbound.json 中存在 wireguard 出站时显示）
  grep -q '"wireguard"' ${WORK_DIR}/outbound.json 2>/dev/null && {
    MENU_IDX+=(170) && MENU_KEY+=(warpaccount) && MENU_VAL+=("")
  }

  # 订阅开关（始终显示，判断当前状态；显示的是可执行的操作：已开启 → 关闭，已关闭 → 开启）
  if [ "$IS_SUB" = 'is_sub' ]; then
    MENU_IDX+=(150) && MENU_KEY+=(subscribe) && MENU_VAL+=("$(text 150)")
  else
    MENU_IDX+=(149) && MENU_KEY+=(subscribe) && MENU_VAL+=("$(text 149)")
  fi

  [ "${#MENU_IDX[@]}" -eq 0 ] && error " $(text 70) "

  hint "\n $(text 106)\n"
  for _i in "${!MENU_IDX[@]}"; do
    local _val="${MENU_VAL[_i]}"
    local _raw
    eval "_raw=\"\${${L}[${MENU_IDX[_i]}]}\""
    eval "hint \" $(printf '%3d.' $(( _i+1 ))) ${_raw}\""
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

  # 特殊操作路由（不走通用 reading/sed 替换）
  if [ "$KEY" = "ports" ]; then
    change_port_mode
    return
  elif [ "$KEY" = "hy2bw" ]; then
    # 修改 Hysteria2 带宽 - 内联实现
    local HY2_UP HY2_DOWN
    while true; do
      reading " $(text 121) " HY2_UP
      [[ "$HY2_UP" =~ ^[1-9][0-9]*$ ]] && break
      warning " $(text 123) "
    done
    while true; do
      reading " $(text 122) " HY2_DOWN
      [[ "$HY2_DOWN" =~ ^[1-9][0-9]*$ ]] && break
      warning " $(text 123) "
    done
    HY2_UP_NOW="$HY2_UP"; HY2_DOWN_NOW="$HY2_DOWN"
    [ -s ${WORK_DIR}/subscribe/proxies ] && sed -i -E "s/(up: \")([0-9]+)( Mbps\")/\1${HY2_UP}\3/g; s/(down: \")([0-9]+)( Mbps\")/\1${HY2_DOWN}\3/g" ${WORK_DIR}/subscribe/proxies
    export_list
    return
  elif [ "$KEY" = "hopping" ]; then
    # 保存旧状态，留空禁用时需要正确判断“是禁用成功”还是“本来就没开”
    local _OLD_HOP_START="$PORT_HOPPING_START" _OLD_HOP_END="$PORT_HOPPING_END" _OLD_HOP_RANGE="$OLD"
    # 提前保存 TARGET，del_port_hopping_nat / sync_firewall_rules 内部检查可能会重置相关变量
    local _HOP_TARGET="${PORT_HOPPING_TARGET:-$HY2_PORT}"
    unset IS_HOPPING PORT_HOPPING_RANGE PORT_HOPPING_START PORT_HOPPING_END
    # Realm 与端口跳跃互斥：Realm 已开启时先确认，确认后才进入输入流程
    if detect_hy2_realm_status; then
      local HY2_CONFIRM
      reading "\n $(text 184) " HY2_CONFIRM
      [[ "${HY2_CONFIRM,,}" =~ ^(y|yes)$ ]] || return
      set_hy2_realm_config disable
      sync_hy2_warp_route disable
      local _HY2_TAG=$(grep -v '^//' "$WORK_DIR/inbound.json" | $WORK_DIR/jq -r '.inbounds[] | select(.tag | endswith("hysteria2")) | .tag // empty' 2>/dev/null)
      api_hot_reload inbounds ${_HY2_TAG:+"$_HY2_TAG"}
      api_hot_reload routing_rules
    fi
    input_hopping_port
    # 保存用户输入的起止端口，后续删除旧规则时内部检测可能会清空
    local _NEW_HOP_START="$PORT_HOPPING_START" _NEW_HOP_END="$PORT_HOPPING_END"
    # 先删除旧规则（无论原来是否有）
    del_port_hopping_nat
    if [ "$IS_HOPPING" = 'is_hopping' ]; then
      PORT_HOPPING_START="$_NEW_HOP_START"
      PORT_HOPPING_END="$_NEW_HOP_END"
      PORT_HOPPING_RANGE="${_NEW_HOP_START}:${_NEW_HOP_END}"
      PORT_HOPPING_TARGET="$_HOP_TARGET"
      FIREWALL_SILENT=1 add_port_hopping_nat "$PORT_HOPPING_START" "$PORT_HOPPING_END" "$PORT_HOPPING_TARGET" >/dev/null 2>&1
    else
      unset PORT_HOPPING_START PORT_HOPPING_END PORT_HOPPING_RANGE
      PORT_HOPPING_TARGET="$_HOP_TARGET"
      # 只有在未做任何修改时才提示
      if [ -z "$_NEW_HOP_START" ] && [ -z "$_OLD_HOP_START" ]; then
        info "
 $(text 103)
"
        return
      fi
    fi
    FIREWALL_SILENT=1 sync_firewall_rules >/dev/null 2>&1 || true
    export_list
    return
  elif [ "$KEY" = "hy2realm" ]; then
    # 添加 / 删除 Hysteria2 Realm
    # 判断依据：检查 inbound.json 中是否有 finalmask
    if detect_hy2_realm_status; then
      # 已开启 → 直接关闭
      handle_hy2_realm disable
    else
      # 未开启 → 先设置 Realm，再询问 WARP 辅助打洞
      # Realm 与端口跳跃互斥：端口跳跃已开启时需确认，确认后先关闭端口跳跃
      check_port_hopping_nat
      if [ -n "$PORT_HOPPING_START" ]; then
        local HY2_CONFIRM
        reading "\n $(text 183) " HY2_CONFIRM
        [[ "${HY2_CONFIRM,,}" =~ ^(y|yes)$ ]] || return
        del_port_hopping_nat
        unset PORT_HOPPING_START PORT_HOPPING_END PORT_HOPPING_RANGE
      fi
      IS_HY2_REALM=is_hy2_realm
      HY2_REALM_ID="${HY2_REALM_ID:-$UUID}"
      input_hy2_warp
      handle_hy2_realm enable
    fi
    return
  elif [ "$KEY" = "fingerprint" ]; then
    # 修改客户端指纹
    hint "\n $(text 144) \n" && reading " $(text 24) " FP_CHOICE
    case "$FP_CHOICE" in
      ""|1) NEW_VAL="chrome" ;;
      2 ) NEW_VAL="firefox" ;;
      * ) NEW_VAL="$FP_CHOICE" ;;
    esac
    [[ ! "${NEW_VAL,,}" =~ ^[0-9a-z]+$ ]] && error " $(text 145) " || FINGER_PRINT="$NEW_VAL"
    write_custom 'fingerprint' "${FINGER_PRINT}"
    export_list
    return
  elif [ "$KEY" = "bindinterface" ]; then
    # 指定网络出口 — 获取系统接口列表 + 选择 + 更新 outbound.json
    local IFACE_LIST=() CHOOSE_BIND IDX=2
    local _ob="$WORK_DIR/outbound.json" _ob_tmp="$TEMP_DIR/outbound_tmp.json"

    if command -v ip >/dev/null 2>&1; then
      while read -r _ iface; do
        iface="${iface%%:*}"
        iface="${iface%%@*}"
        [ "$iface" != "lo" ] && IFACE_LIST+=("$iface")
      done < <(ip -o link show up 2>/dev/null)
    elif command -v ifconfig >/dev/null 2>&1; then
      while read -r iface _; do
        iface="${iface%%:}"
        [ "$iface" != "lo" ] && IFACE_LIST+=("$iface")
      done < <(ifconfig -a 2>/dev/null | awk '/^[a-zA-Z]/')
    else
      for _if in /sys/class/net/*; do
        _if="${_if##*/}"
        [ "$_if" != "lo" ] && IFACE_LIST+=("$_if")
      done
    fi
    mapfile -t IFACE_LIST < <(printf '%s\n' "${IFACE_LIST[@]}" | sort -u)
    [ "${#IFACE_LIST[@]}" -eq 0 ] && warning " $(text 2) " && return

    hint "\n $(text 73) \n"
    hint " $(printf '%3d.' 1) $(text 69 | sed 's/^1\. //') "
    for _if in "${IFACE_LIST[@]}"; do
      hint " $(printf '%3d.' $IDX) $_if"
      ((IDX++))
    done
    hint " $(printf '%3d.' 0) $(text 35)"
    hint ""
    reading " $(text 24) " CHOOSE_BIND

    if [[ "$CHOOSE_BIND" == "0" ]]; then
      return
    elif [[ "$CHOOSE_BIND" == "1" || "${CHOOSE_BIND,,}" == "default" ]]; then
      # 删除 bind_interface（恢复默认），同时清理 streamSettings 避免残留 {}
      [ -s "$_ob" ] && grep -v '^//' "$_ob" | $WORK_DIR/jq \
        'del(.outbounds[] | select(.tag == "direct") | .streamSettings)' \
        > "$_ob_tmp" 2>/dev/null && mv "$_ob_tmp" "$_ob"
      write_custom 'bind_interface' ''
      BIND_IFACE=''
      info " $(text 45) $(text 69 | sed 's/^1\. //')"
    elif [[ "$CHOOSE_BIND" =~ ^[0-9]+$ ]] && [ "$CHOOSE_BIND" -ge 2 ] && [ "$CHOOSE_BIND" -le "$((IDX - 1))" ]; then
      local SELECTED_IF="${IFACE_LIST[$((CHOOSE_BIND - 2))]}"
      # 使用 streamSettings.sockopt.interface 绑定网络接口（Xray 官方方案）
      [ -s "$_ob" ] && grep -v '^//' "$_ob" | $WORK_DIR/jq --arg iface "$SELECTED_IF" \
        '.outbounds |= map(if .tag == "direct" then .streamSettings.sockopt.interface = $iface else . end)' \
        > "$_ob_tmp" 2>/dev/null && mv "$_ob_tmp" "$_ob"
      write_custom 'bind_interface' "${SELECTED_IF}"
      BIND_IFACE="$SELECTED_IF"
      info " $(text 45) ${SELECTED_IF}"
    else
      info " $(text 103) "
      return
    fi
    api_hot_reload outbound "direct"
    info "\n $(text 128) \n"
    export_list
    return
  elif [ "$KEY" = "customroute" ]; then
    custom_route_menu
    return
  elif [ "$KEY" = "warpaccount" ]; then
    change_warp_account
    return
  elif [ "$KEY" = "subscribe" ]; then
    if [ "$IS_SUB" = 'is_sub' ]; then
      # 关闭订阅
      IS_SUB=no_sub
      json_nginx

      # 检查是否还需要 nginx（是否还有 WS/XHTTP 协议）
      local _HAS_WS=false
      for _t in $(get_installed_protocols); do
        [[ "$_t" =~ ^(vless-ws|vmess-ws|trojan-ws|ss-ws|xhttp-h1.1-cdn)$ ]] && _HAS_WS=true && break
      done

      if ! $_HAS_WS; then
        # 没有任何 WS/XHTTP → nginx 不再需要，停止并清理
        nginx_stop
        rm -f $WORK_DIR/nginx.conf
        # 无订阅后 Argo 也不再生效（固定隧道一并清理），保持与协议状态一致
        if [ -s "${ARGO_DAEMON_FILE}" ]; then
          cmd_systemctl disable argo
          if [ "$SYSTEM" = 'Alpine' ]; then
            rm -f /etc/init.d/argo
          else
            rm -f ${ARGO_DAEMON_FILE}
          fi
          rm -f $WORK_DIR/cloudflared $WORK_DIR/tunnel.json $WORK_DIR/tunnel.yml
          write_custom 'isArgo' 'no_argo'
        fi
        # 回收 nginx 端口放行规则
        FIREWALL_SILENT=1 sync_firewall_rules >/dev/null 2>&1 || true
        # 重写 xray.service 去掉 ExecStartPre（仅 systemd）
        if [ "$SYSTEM" != 'Alpine' ]; then
          sed -i '/ExecStartPre.*nginx/d' ${XRAY_DAEMON_FILE} 2>/dev/null
          cmd_systemctl daemon-reload 2>/dev/null || true
        fi
      else
        # 还有 WS/XHTTP，同步 nginx（新配置不包含订阅路由；未运行则复活）
        nginx_sync
      fi

      # 清理旧的订阅文件及 qrencode
      rm -f $WORK_DIR/subscribe/{proxies,clash,shadowrocket,v2rayn,throne,sing-box,qr}
      rm -f "$WORK_DIR/qrencode"

      write_custom 'isSub' "${IS_SUB}"
      export_list
      info "\n $(text 150) $(text 37) \n"
    else
      # 开启订阅
      IS_SUB=is_sub

      # 如果 nginx 未安装，后台安装
      if ! command -v nginx >/dev/null 2>&1; then
        hint "\n $(text 148) "
        ( ${PACKAGE_UPDATE[int]} >/dev/null 2>&1; ${PACKAGE_INSTALL[int]} nginx >/dev/null 2>&1; [ "$SYSTEM" != 'Alpine' ] && systemctl disable --now nginx >/dev/null 2>&1; ) &
      fi

      # 首次需要 nginx（nginx.conf 不存在）时交互询问端口（与新安装相同）
      if [ ! -s "$WORK_DIR/nginx.conf" ]; then
        [ -z "$NGINX_PORT" ] && input_nginx_port
        NGINX_PORT=${NGINX_PORT:-"$NGINX_PORT_DEFAULT"}
      fi
      wait

      # 确保 qrencode 可用：先从 TEMP_DIR 复制，没有再直接下载（export_list 用 qrencode 显示二维码）
      # 先检查架构，确保 QRENCODE_ARCH 已设置（check_arch 不在本路径调用）
      check_arch >/dev/null 2>&1 || true
      if [ ! -s "$WORK_DIR/qrencode" ]; then
        if [ -x "$TEMP_DIR/qrencode" ]; then
          mv "$TEMP_DIR/qrencode" "$WORK_DIR"
        else
          wget --no-check-certificate --continue -qO "$WORK_DIR/qrencode" ${GH_PROXY}https://github.com/fscarmen/client_template/raw/main/qrencode-go/qrencode-go-linux-$QRENCODE_ARCH >/dev/null 2>&1 && chmod +x "$WORK_DIR/qrencode" >/dev/null 2>&1
        fi
      fi

      json_nginx

      # 确保 xray.service 包含 ExecStartPre（仅 systemd，含 CentOS7）
      if [ "$SYSTEM" != 'Alpine' ]; then
        if ! grep -q 'ExecStartPre.*nginx' ${XRAY_DAEMON_FILE} 2>/dev/null; then
          sed -i '/^ExecStart=/i ExecStartPre=/bin/bash -c '\''nginx -c '"$WORK_DIR"'/nginx.conf -s reload 2>/dev/null || nginx -c '"$WORK_DIR"'/nginx.conf'\' "${XRAY_DAEMON_FILE}"
          cmd_systemctl daemon-reload 2>/dev/null || true
        fi
      fi

      # 启动/重载 nginx
      nginx_sync
      # 放行 nginx 端口（首次从纯直连开启订阅时防火墙未放行）
      FIREWALL_SILENT=1 sync_firewall_rules >/dev/null 2>&1 || true

      write_custom 'isSub' "${IS_SUB}"
      export_list
      info "\n $(text 149) $(text 37) \n"
    fi
    return
  fi

  hint ""
  if [ "$KEY" = "cdn" ]; then
    local CUSTOM_CDN NEW_PORT NEW_DISPLAY
    for _c in "${!CDN_DOMAIN[@]}"; do
      hint " $((_c+1)). ${CDN_DOMAIN[_c]} "
    done
    reading "
 $(text 72) " CUSTOM_CDN
    [ -z "$CUSTOM_CDN" ] && info " $(text 103) " && return
    case "$CUSTOM_CDN" in
      [1-9]|[1-9][0-9] )
        [ "$CUSTOM_CDN" -le "${#CDN_DOMAIN[@]}" ] && NEW_VAL="${CDN_DOMAIN[$((CUSTOM_CDN-1))]}" || NEW_VAL="${CDN_DOMAIN[0]}"
        NEW_PORT=443
        NEW_DISPLAY="$NEW_VAL"
        ;;
      * )
        parse_preferred_addr "$CUSTOM_CDN" || error " $(text 118) "
        NEW_VAL="$PREFERRED_ADDR"
        NEW_PORT="$PREFERRED_PORT"
        NEW_DISPLAY="$PREFERRED_DISPLAY"
        ;;
    esac
  else
    if [ "$KEY" = "uuid" ]; then
      local a=5
      while true; do
        reading " $(text 4) " NEW_VAL
        [ -z "$NEW_VAL" ] && info " $(text 103) " && return
        [[ "${NEW_VAL,,}" =~ ^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$ ]] && break
        ((a--)) || true
        [ "$a" -eq 0 ] && error "\n $(text 3) \n"
      done
    else
      reading " $(text 60) " NEW_VAL
      [ -z "$NEW_VAL" ] && info " $(text 103) " && return
    fi
  fi

  if [ "$KEY" = "sni" ]; then
    ssl_certificate "$NEW_VAL"
  elif [ "$KEY" = "serverip" ]; then
    is_valid_server_addr "$NEW_VAL" || error " $(text 112) "
  fi

  # 按字段定点更新，不再全目录暴力 sed 替换
  local _IB="$WORK_DIR/inbound.json"
  local _IB_TMP="$TEMP_DIR/inbound_tmp.json"
  case "$KEY" in
    cdn)
      write_custom 'cdn' "${NEW_VAL}"
      write_custom 'cdnPort' "${NEW_PORT:-443}"
      SERVER_PORT="${NEW_PORT:-443}"
      SERVER_DISPLAY="${NEW_DISPLAY:-$NEW_VAL}"
      export_list
      return
      ;;
    serverip)
      write_custom 'serverIp' "${NEW_VAL}"
      export_list
      return
      ;;
    name)
      # 更新 inbound.json 所有 inbound 的 tag（"OLD_NAME proto" → "NEW_NAME proto"）
      if [ -s "$_IB" ] && [ -x "$WORK_DIR/jq" ]; then
        grep -v '^//' "$_IB" \
          | $WORK_DIR/jq --arg old "$OLD" --arg new "$NEW_VAL" \
              '(.inbounds[].tag) |= if startswith($old + " ") then ($new + " " + (ltrimstr($old + " "))) else . end' \
          > "$_IB_TMP" && mv "$_IB_TMP" "$_IB"
      fi
      api_hot_reload inbounds
      ;;
    uuid)
      # 精确更新 inbound.json 中各协议的认证字段
      local _force_update_tags=()
      if [ -s "$_IB" ] && [ -x "$WORK_DIR/jq" ]; then
        # 提取出因修改 UUID 受影响的 tag，以用来强制重载
        # 不仅检查 clients 中的 id/password/auth，还检查 realm URL 中的 UUID 子串
        while IFS= read -r _t; do
          [ -n "$_t" ] && _force_update_tags+=("$_t")
        done < <(grep -v '^//' "$_IB" | $WORK_DIR/jq -r --arg old "$OLD" '.inbounds[] | select(
          (.settings.clients[]? | (.id == $old or .password == $old or .auth == $old))
          or
          (.streamSettings.finalmask.udp[]?.settings.url | strings | contains($old))
        ) | .tag' 2>/dev/null)

        grep -v '^//' "$_IB" \
          | $WORK_DIR/jq --arg old "$OLD" --arg new "$NEW_VAL" \
              '(.inbounds[].settings.clients[]? | (.id, .password, .auth) | select(. == $old)) = $new
              | walk(if type == "string" and contains($old) then sub($old; $new) else . end)' \
          > "$_IB_TMP" && mv "$_IB_TMP" "$_IB"
      fi
      # UUID 用于 nginx.conf 的 location 路径，仅需要 nginx 时重新生成并同步
      UUID="$NEW_VAL"
      [ -s "$WORK_DIR/nginx.conf" ] && { json_nginx; nginx_sync; }
      api_hot_reload inbounds "${_force_update_tags[@]}"
      ;;
    sni)
      # TLS_SERVER 存储在 inbound.json，精确更新所有 serverNames/serverName 字段
      local _force_update_tags=()
      if [ -s "$_IB" ] && [ -x "$WORK_DIR/jq" ]; then
        # 提取出因修改 sni 受影响的 tag，以用来强制重载
        while IFS= read -r _t; do
          [ -n "$_t" ] && _force_update_tags+=("$_t")
        done < <(grep -v '^//' "$_IB" | $WORK_DIR/jq -r --arg old "$OLD" '.inbounds[] | select(
            (.streamSettings.tlsSettings.serverName == $old) or
            (.streamSettings.realitySettings.serverNames[]? == $old)
          ) | .tag' 2>/dev/null)

        grep -v '^//' "$_IB" \
          | $WORK_DIR/jq --arg old "$OLD" --arg new "$NEW_VAL" \
              'walk(if type == "object" then
                (if has("serverNames") then .serverNames |= map(if . == $old then $new else . end) else . end) |
                (if has("serverName")  then .serverName  |= if . == $old then $new else . end else . end)
              else . end)' \
          > "$_IB_TMP" && mv "$_IB_TMP" "$_IB"
      fi
      api_hot_reload inbounds "${_force_update_tags[@]}"
      ;;
    ports)
      local _force_update_tags=()
      if [ -x "$WORK_DIR/jq" ] && [ -s "$_IB" ] && [ -s "$WORK_DIR/outbound.json" ]; then
        # 提取出因修改 port 受影响的 tag
        while IFS= read -r _t; do
          [ -n "$_t" ] && _force_update_tags+=("$_t")
        done < <(grep -v '^//' "$_IB" | $WORK_DIR/jq -r --arg old "$OLD" '.inbounds[] | select(
            (.port == ($old | tonumber)) or
            (.port == $old)
          ) | .tag' 2>/dev/null)

        grep -v '^//' "$_IB" \
          | $WORK_DIR/jq --arg old "$OLD" --arg new "$NEW_VAL" \
              'walk(if type == "object"
                    then (if has("port") and .port == ($old | tonumber) then .port = ($new | tonumber) else . end) |
                         (if has("port") and .port == $old then .port = $new else . end)
                    else . end)' \
          > "$_IB_TMP" && mv "$_IB_TMP" "$_IB"

        # argo tunnel 出站和订阅地址也要同步更新端口
        # customroute 需要重新绑定路由
      fi

      # nginx.conf 的 proxy_pass 指向 ws 端口，需重新生成并同步 nginx
      [ -s "$WORK_DIR/nginx.conf" ] && json_nginx
      nginx_sync
      api_hot_reload inbounds "${_force_update_tags[@]}"
      ;;
  esac

  # name/uuid/sni/ports 已经通过 api_hot_reload inbounds 热更新，无需再重启
  info "\n $(text 128) \n"
  cmd_systemctl status xray &>/dev/null && \
    info "\n Xray $(text 28) $(text 37) \n" || \
    warning "\n Xray $(text 27) $(text 38) \n"

  FIREWALL_SILENT=1 sync_firewall_rules >/dev/null 2>&1 || true
  export_list
}

# 卸载 ArgoX
uninstall() {
  if [ -d $WORK_DIR ]; then
    cmd_systemctl disable argo >/dev/null 2>&1
    cmd_systemctl disable xray >/dev/null 2>&1
    purge_managed_firewall_rules >/dev/null 2>&1 || true
    nginx_stop
    # 仅当 WORK_DIR/nginx.conf 存在时（即本脚本管理的 nginx 实例）才询问是否卸载
    [ -s $WORK_DIR/nginx.conf ] && command -v nginx >/dev/null 2>&1 && {
      reading "\n $(text 65) " REMOVE_NGINX
      [ "${REMOVE_NGINX,,}" = 'y' ] && ${PACKAGE_UNINSTALL[int]} nginx >/dev/null 2>&1
    }
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

  ONLINE=$(wget --no-check-certificate -qO- "${GH_PROXY}https://api.github.com/repos/XTLS/Xray-core/releases" | awk -F '["v]' '/tag_name/{print $5}' | sort -rV | sed -n 1p)
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
    wget --no-check-certificate -O $TEMP_DIR/Xray-linux-$XRAY_ARCH.zip ${GH_PROXY}https://github.com/XTLS/Xray-core/releases/download/v${ONLINE}/Xray-linux-$XRAY_ARCH.zip
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
  # 重置菜单显示变量，避免同进程内状态变化后残留旧值
  ARGO_VERSION='' XRAY_VERSION='' NGINX_VERSION='' ARGO_CHECKHEALTH='' ARGO_MEMORY='' XRAY_MEMORY='' NGINX_MEMORY=''
  if [[ "${STATUS[*]}" =~ $(text 27)|$(text 28) ]]; then
    if [ -s $WORK_DIR/cloudflared ]; then
      ARGO_VERSION=$($WORK_DIR/cloudflared -v | awk '{print $3}' | sed "s@^@Version: &@g")
      local ARGO_PID=$(awk '/cloudflared/{print $1}' <<< "$PS_LIST")
      local REALTIME_METRICS_PORT=$(ss -nltp | awk -v pid=${ARGO_PID} '$0 ~ "pid="pid"," {split($4, a, ":"); print a[length(a)]}')
      ss -nltp | grep -q "cloudflared.*pid=${ARGO_PID}," && ARGO_CHECKHEALTH="$(text 46): $(wget -qO- http://localhost:${REALTIME_METRICS_PORT}/healthcheck | sed "s/OK/$(text 37)/")"
    fi
    [ -s $WORK_DIR/xray ] && XRAY_VERSION=$($WORK_DIR/xray version | awk 'NR==1 {print $2}' | sed "s@^@Version: &@g")
    [ -s $WORK_DIR/nginx.conf ] && NGINX_VERSION=$(nginx -v 2>&1 | sed "s#.*/##; s/ (.*)//" | sed "s@^@Version: &@g")

    local _opt=1
    OPTION[_opt]="$(printf '%3d.' $_opt) $(text 29)"
    eval "ACTION[$_opt]() { export_list; exit 0; }"
    ((_opt++))

    # Argo 选项：仅当 Argo 守护进程文件存在时才显示
    if [ -s "${ARGO_DAEMON_FILE}" ]; then
      if [ "${STATUS[0]}" = "$(text 28)" ]; then
        local ARGO_PID=$(pgrep -f "$WORK_DIR/cloudflared")
        [ -n "$ARGO_PID" ] && ARGO_MEMORY="$(text 52): $(awk '/VmRSS/{printf "%.1f", $2/1024}' /proc/${ARGO_PID%% *}/status 2>/dev/null) MB"
        OPTION[_opt]="$(printf '%3d.' $_opt) $(text 27) Argo (argox -a)"
      else
        OPTION[_opt]="$(printf '%3d.' $_opt) $(text 28) Argo (argox -a)"
      fi
      [[ ${STATUS[0]} = "$(text 28)" ]] &&
      eval "ACTION[$_opt]() {
        cmd_systemctl disable argo
        cmd_systemctl status argo &>/dev/null && error \" Argo \$(text 27) \$(text 38) \" || info \"\n Argo \$(text 27) \$(text 37)\"
      }" ||
      eval "ACTION[$_opt]() {
        cmd_systemctl enable argo
        sleep 2
        cmd_systemctl status argo &>/dev/null && info \"\n Argo \$(text 28) \$(text 37)\" || error \" Argo \$(text 28) \$(text 38) \"
        grep -qs \"^${DAEMON_RUN_PATTERN}.*--url\" ${ARGO_DAEMON_FILE} && fetch_tunnel_domain quick && export_list
      }"
      ((_opt++))
    fi

    if [ -s $WORK_DIR/nginx.conf ]; then
      local NGINX_PID=$(nginx_pid)
      [ -n "$NGINX_PID" ] && NGINX_MEMORY="$(text 52): $(awk '/VmRSS/{printf "%.1f", $2/1024}' /proc/${NGINX_PID%% *}/status 2>/dev/null) MB"
    fi
    if [ "${STATUS[1]}" = "$(text 28)" ]; then
      local XRAY_PID=$(pgrep -f "$WORK_DIR/xray")
      [ -n "$XRAY_PID" ] && XRAY_MEMORY="$(text 52): $(awk '/VmRSS/{printf "%.1f", $2/1024}' /proc/${XRAY_PID%% *}/status 2>/dev/null) MB"
      OPTION[_opt]="$(printf '%3d.' $_opt) $(text 27) Xray (argox -x)"
    else
      OPTION[_opt]="$(printf '%3d.' $_opt) $(text 28) Xray (argox -x)"
    fi
    [[ ${STATUS[1]} = "$(text 28)" ]] &&
    eval "ACTION[$_opt]() {
      cmd_systemctl disable xray
      cmd_systemctl status xray &>/dev/null && error \" Xray \$(text 27) \$(text 38) \" || info \"\n Xray \$(text 27) \$(text 37)\"
    }" ||
    eval "ACTION[$_opt]() {
      cmd_systemctl enable xray
      sleep 2
      cmd_systemctl status xray &>/dev/null && info \"\n Xray \$(text 28) \$(text 37)\" || error \" Xray \$(text 28) \$(text 38) \"
    }"
    ((_opt++))

    # 更换 Argo 隧道：仅当 Argo 守护进程文件存在时才显示
    if [ -s "${ARGO_DAEMON_FILE}" ]; then
      OPTION[_opt]="$(printf '%3d.' $_opt) $(text 30)"
      eval "ACTION[$_opt]() { change_argo; exit; }"
      ((_opt++))
    fi

    OPTION[_opt]="$(printf '%3d.' $_opt) $(text 76)"
    eval "ACTION[$_opt]() { change_config; exit; }"
    ((_opt++))

    OPTION[_opt]="$(printf '%3d.' $_opt) $(text 95)"
    eval "ACTION[$_opt]() { change_protocols; exit; }"
    ((_opt++))

    OPTION[_opt]="$(printf '%3d.' $_opt) $(text 31)"
    eval "ACTION[$_opt]() { version; exit; }"
    ((_opt++))

    OPTION[_opt]="$(printf '%3d.' $_opt) $(text 32)"
    eval "ACTION[$_opt]() { bash <(wget --no-check-certificate -qO- ${GH_PROXY}https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh); exit; }"
    ((_opt++))

    OPTION[_opt]="$(printf '%3d.' $_opt) $(text 33)"
    eval "ACTION[$_opt]() { uninstall; exit; }"
    ((_opt++))

    OPTION[_opt]="$(printf '%3d.' $_opt) $(text 51)"
    eval "ACTION[$_opt]() { bash <(wget --no-check-certificate -qO- ${GH_PROXY}https://raw.githubusercontent.com/fscarmen/sing-box/main/sing-box.sh) -\$L; exit; }"
    ((_opt++))

    OPTION[_opt]="$(printf '%3d.' $_opt) $(text 57)"
    eval "ACTION[$_opt]() { bash <(wget --no-check-certificate -qO- ${GH_PROXY}https://raw.githubusercontent.com/fscarmen/sba/main/sba.sh) -\$L; exit; }"
    ((_opt++))

  else
    OPTION[1]="$(printf '%3d.' 1) $(text 77)"
    OPTION[2]="$(printf '%3d.' 2) $(text 146)"
    OPTION[3]="$(printf '%3d.' 3) $(text 34)"
    OPTION[4]="$(printf '%3d.' 4) $(text 32)"
    OPTION[5]="$(printf '%3d.' 5) $(text 51)"
    OPTION[6]="$(printf '%3d.' 6) $(text 57)"

    ACTION[1]() { NONINTERACTIVE_INSTALL='noninteractive_install'; IS_SUB=is_sub; fast_install_variables; install_argox; export_list; create_shortcut; exit;}
    ACTION[2]() { IS_SUB=is_sub; install_argox; export_list; create_shortcut; exit; }
    ACTION[3]() { IS_SUB=no_sub; install_argox; export_list; create_shortcut; exit; }
    ACTION[4]() { bash <(wget --no-check-certificate -qO- ${GH_PROXY}https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh); exit; }
    ACTION[5]() { bash <(wget --no-check-certificate -qO- ${GH_PROXY}https://raw.githubusercontent.com/fscarmen/sing-box/main/sing-box.sh) -$L; exit; }
    ACTION[6]() { bash <(wget --no-check-certificate -qO- ${GH_PROXY}https://raw.githubusercontent.com/fscarmen/sba/main/sba.sh) -$L; exit; }
  fi

  # 统一编号右对齐：退出选项 0 （数字占3字符位宽+点，与上面所有菜单项完全对齐）
  OPTION[0]="$(printf '%3d.' 0) $(text 35)"
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
  info "\t Argo:  $(_sv "${STATUS[0]}")  ${_AV}${ARGO_MEMORY}\t ${ARGO_CHECKHEALTH}"
  local _xray_traffic=""
  if ensure_stats_data 2>/dev/null; then
    local _in_sum=0 _out_sum=0 _line _name _val
    while IFS= read -r _line; do
      _name=$(echo "$_line" | $WORK_DIR/jq -r '.name // empty' 2>/dev/null)
      _val=$(echo "$_line" | $WORK_DIR/jq -r '.value // 0' 2>/dev/null)
      [ -z "$_name" ] && continue
      case "$_name" in
        inbound*traffic*downlink ) _in_sum=$((_in_sum + _val)) ;;
        outbound*traffic*uplink )  _out_sum=$((_out_sum + _val)) ;;
      esac
    done < <(echo "$STATS_JSON" | $WORK_DIR/jq -c '.stat[]' 2>/dev/null)
    _xray_traffic="  ⬇$(format_traffic $_in_sum) ⬆$(format_traffic $_out_sum)"
  fi
  info "\t Xray:  $(_sv "${STATUS[1]}")  ${_XV}${XRAY_MEMORY}${_xray_traffic}"
  [ -s $WORK_DIR/nginx.conf ] && info "\t Nginx: $(_sv "${STATUS[2]}")  ${_NV}${NGINX_MEMORY}"
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

###### API 端口统一收口：custom 不再保存 apiPort，一律以 inbound.json 的 api.listen 为准（仅清理一次）,将于 2026年10月31日移除
grep -q '^apiPort=' "$CUSTOM_FILE" 2>/dev/null && sed -i '/^apiPort=/d' "$CUSTOM_FILE"

###### 为了把 tag 后缀从 vless-xhttp 改为 xhttp-h1.1-cdn 做的处理，将于 2026年9月30日移除
if ls $WORK_DIR/inbound.json >/dev/null 2>&1 && grep -q 'vless-xhttp",' $WORK_DIR/inbound.json && [[ "$(date +%Y%m%d)" < "20260930" ]]; then
  sed -i "s/vless-xhttp\",$/${NODE_TAG[7]}\",/g" $WORK_DIR/inbound.json
  base64 -d $WORK_DIR/subscribe/base64 | sed "s/vless-xhttp$/${NODE_TAG[7]}/g" | base64 -w0 > $WORK_DIR/subscribe/base64
  sed -i "s/vless-xhttp\",/${NODE_TAG[7]}\",/g" $WORK_DIR/subscribe/proxies
  base64 -d $WORK_DIR/subscribe/shadowrocket | sed "s/vless-xhttp&obfsParam=/${NODE_TAG[7]}\&obfsParam=/g" | base64 -w0 > $WORK_DIR/subscribe/shadowrocket
fi

###### 为了把原来的 nekobox/v2rayN 合并在一起的内容拆分做的处理，将于 2026年9月30日移除
if [ -s $WORK_DIR/nginx.conf ] && grep -q 'v2rayN|Neko|Throne' $WORK_DIR/nginx.conf; then
  sed -i '/~\*v2rayN|Neko|Throne/s#~\*v2rayN|Neko|Throne[[:space:]]*/base64;#~*v2rayN              /v2rayn;\n    ~*Throne|Neko         /throne;#' /etc/argox/nginx.conf
  [ -s $WORK_DIR/subscribe/base64 ] && rm -f $WORK_DIR/subscribe/base64
  export_list >/dev/null 2>&1
fi

###### 为了给旧版本 inbound.json 补全 Xray API 配置块与流量统计配置，将于 2026年10月31日移除
if [ -x "$WORK_DIR/jq" ] && [ -s "$WORK_DIR/inbound.json" ] && [[ "$(date +%Y%m%d)" < "20261031" ]]; then
  # 三个配置块（api / stats / policy）任一缺失即统一补全并重排：
  #   - api 仅在缺失时生成（已有 api 对象原样保留）
  #   - stats 缺失时补 {}，已有时保留
  #   - policy 缺失或缺少 system 时合并补全，保留已有字段，只添四个统计开关
  #   - 最后 {api, stats, policy} + . 将三者按 api→stats→policy 顺序置于 JSON 最顶（与新装模板一致）
  grep -v '^//' "$WORK_DIR/inbound.json" | $WORK_DIR/jq -e '
    (has("api")) and
    (has("stats") and (.stats | type) == "object") and
    (has("policy") and ((.policy.system?) | type) == "object")
  ' >/dev/null 2>&1 || {
    # 旧版本升级默认开启 isSub/isArgo，并补全 bind_interface（仅当 custom 中不存在时）
    grep -q '^isSub=' "$CUSTOM_FILE" 2>/dev/null || write_custom 'isSub' 'is_sub'
    grep -q '^isArgo=' "$CUSTOM_FILE" 2>/dev/null || write_custom 'isArgo' 'is_argo'
    grep -q '^bind_interface=' "$CUSTOM_FILE" 2>/dev/null || write_custom 'bind_interface' ''
    _api_port=$(grep -v '^//' "$WORK_DIR/inbound.json" | $WORK_DIR/jq -r '.api.listen // empty' 2>/dev/null | awk -F: '{print $2}')
    refresh_port_snapshot
    if [ -z "$_api_port" ] || is_port_in_use "$_api_port"; then
      _api_port=$(find_free_port 10000 65535)
    fi
    _api_listen="127.0.0.1:${_api_port}"
    grep -v '^//' "$WORK_DIR/inbound.json" | $WORK_DIR/jq --arg listen "$_api_listen" '
      .api = (if has("api") then .api
              else { "tag": "api", "listen": $listen,
                     "services": ["HandlerService", "LoggerService", "StatsService", "RoutingService"] }
              end) |
      .stats = (.stats // {}) |
      .policy = ((.policy // {}) + {
        "system": (((.policy // {}).system // {}) + {
          "statsInboundUplink": true,
          "statsInboundDownlink": true,
          "statsOutboundUplink": true,
          "statsOutboundDownlink": true
        })
      }) |
      {api, stats, policy} + .
    ' > "$TEMP_DIR/inbound_stats_tmp.json" 2>/dev/null && mv "$TEMP_DIR/inbound_stats_tmp.json" "$WORK_DIR/inbound.json" && {
      # 补全了 api/stats/policy，xray 需重启才能加载 API 监听。
      # 必须后台执行：若经 xray 代理连接 SSH，重启瞬间连接断开，
      # 前台等待会因 SSH 中断导致命令未跑完。
      # 此处在 check_system_info() 之前，SYSTEM 未设置，用 openrc/rc-service 检测区分 Alpine 与 systemd。
      if [ -d /run/openrc ] || command -v rc-service >/dev/null 2>&1; then
        ( nohup rc-service xray restart >/dev/null 2>&1 & )
      else
        ( nohup systemctl restart xray >/dev/null 2>&1 & )
      fi
    }
  }
fi

# ── 传参处理1: 语言识别 + SKIP_MENU 检测（在 select_language 之前） ──
# 支持 --LANGUAGE C|E 长参数，在 select_language() 之前识别，避免非交互安装仍弹出语言选择。
# 同时检测是否有任何 --XXX 长参数，有则跳过主菜单直接进入菜单 2（install_argox）。
for ((_param_i=1; _param_i<=$#; _param_i++)); do
  eval "_param_v=\${${_param_i}}"
  case "${_param_v^^}" in
    --LANGUAGE )
      _param_n=$((_param_i+1))
      eval "_param_lang=\${${_param_n}}"
      [[ "${_param_lang^^}" =~ ^C ]] && L=C || L=E
      SKIP_MENU=skip_menu
      ;;
    --LANGUAGE=* )
      _param_lang="${_param_v#*=}"
      [[ "${_param_lang^^}" =~ ^C ]] && L=C || L=E
      SKIP_MENU=skip_menu
      ;;
    --* )
      # 任何其他 --XXX 长参数也触发跳过菜单
      SKIP_MENU=skip_menu
      ;;
  esac
done
unset _param_i _param_v _param_n _param_lang

# ── 传参处理2: 长参数解析（在 getopts 之前） ──
# 可以是 Key Value 或者 Key=Value 的形式。
# 传参处理: 把所有的 = 变为空格，但保留 =" ，因为 Json TunnelSecret 是 =" 结尾的
ALL_PARAMETER=($(sed -E 's/=([^"])/ \1/g' <<< $*))
# 已传参的变量跳过交互，未传参的变量仍交互询问。

for z in ${!ALL_PARAMETER[@]}; do
  case "${ALL_PARAMETER[z]^^}" in
    --CHOOSE_PROTOCOLS ) ((z++)); CHOOSE_PROTOCOLS=${ALL_PARAMETER[z]} ;;
    --START_PORT ) ((z++)); START_PORT=${ALL_PARAMETER[z]} ;;
    --NGINX_PORT ) ((z++)); NGINX_PORT=${ALL_PARAMETER[z]} ;;
    --SERVER_IP ) ((z++)); SERVER_IP=${ALL_PARAMETER[z]} ;;
    --CDN ) ((z++)); CDN=${ALL_PARAMETER[z]} ;;
    --UUID ) ((z++)); UUID=${ALL_PARAMETER[z]} ;;
    --WS_PATH ) ((z++)); WS_PATH=${ALL_PARAMETER[z]} ;;
    --NODE_NAME ) ((z++))
      for ((z=$z; z<${#ALL_PARAMETER[@]}; z++)); do
        [[ ! "${ALL_PARAMETER[z]}" =~ ^- ]] && NODE_NAME_ARRAY+=(${ALL_PARAMETER[z]}) || break
      done
      NODE_NAME=${NODE_NAME_ARRAY[@]}
      unset NODE_NAME_ARRAY
      ((z--))
      ;;
    --ARGO_DOMAIN ) ((z++)); ARGO_DOMAIN=${ALL_PARAMETER[z]} ;;
    --ARGO_AUTH ) ((z++)); ARGO_AUTH=${ALL_PARAMETER[z]} ;;
    --TLS_SERVER ) ((z++)); TLS_SERVER=${ALL_PARAMETER[z]} ;;
    --REALITY_PRIVATE ) ((z++)); REALITY_PRIVATE=${ALL_PARAMETER[z]} ;;
    --PORT_HOPPING_RANGE ) ((z++)); PORT_HOPPING_RANGE=${ALL_PARAMETER[z]} ;;
    --HY2_REALM|--REALM ) ((z++)); HY2_REALM_SET=1; [[ "${ALL_PARAMETER[z],,}" =~ ^(true|1|y|yes)$ ]] && IS_HY2_REALM=is_hy2_realm ;;
    --HY2_WARP|--REALM_WARP|--WARP_REALM ) ((z++)); HY2_WARP_SET=1; [[ "${ALL_PARAMETER[z],,}" =~ ^(true|1|y|yes)$ ]] && IS_HY2_WARP=is_hy2_warp && IS_HY2_REALM=is_hy2_realm ;;
    --SUBSCRIBE|--SUB ) ((z++)); [[ "${ALL_PARAMETER[z],,}" =~ ^(true|1|y|yes)$ ]] && IS_SUB=is_sub || IS_SUB=no_sub ;;
    --ARGO ) ((z++)); [[ "${ALL_PARAMETER[z],,}" =~ ^(true|1|y|yes)$ ]] && IS_ARGO=is_argo || IS_ARGO=no_argo; IS_ARGO_EXPLICIT=true ;;
  esac
done

# 从 $@ 中移除所有长参数（--XXX 及其值），避免：
# 1. getopts 错误解析（bash 3.2 会把 --LANGUAGE 中的 -L 当作短选项 -l）
# 2. 短参数检测 regex 误匹配（如 --CHOOSE_PROTOCOLS 中的 -c 导致 L=C 被误设）
# 长参数解析引擎已在上方处理了所有需要的参数，未被识别的 --XXX 应被忽略。
# 不移除 -f、-l 等短参数。
_REMAINING_ARGS=()
_skip_next=false
for _arg in "$@"; do
  if $_skip_next; then
    _skip_next=false
    continue
  fi
  case "${_arg}" in
    --* )
      _skip_next=true ;;
    * ) _REMAINING_ARGS+=("$_arg") ;;
  esac
done
set -- "${_REMAINING_ARGS[@]}"
unset _REMAINING_ARGS _arg _skip_next

# 传参（短参数）
# 注意：此时 $@ 中已无 --XXX 长参数，避免长参数名中的字符导致误匹配
[[ "${*,,}" =~ '-e'|'-k' ]] && L=E
[[ "${*,,}" =~ '-c'|'-b'|'-l' ]] && L=C

while getopts ":AaXxTtDdUuNnVvBbRrF:f:KkLl" OPTNAME; do
  case "${OPTNAME,,}" in
    a ) select_language; check_system_info; check_arch; check_install
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

    x ) select_language; check_system_info; check_arch; check_install
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
    r ) select_language; check_system_info; check_arch; check_install; change_protocols; exit 0 ;;
    u ) select_language; check_system_info; uninstall; exit 0;;
    n ) select_language; check_system_info; export_list; exit 0 ;;
    v ) select_language; check_system_info; check_arch; version; exit 0;;
    b ) select_language; bash <(wget --no-check-certificate -qO- "${GH_PROXY}https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh"); exit ;;
    f ) NONINTERACTIVE_INSTALL='noninteractive_install'; VARIABLE_FILE=$OPTARG; . $VARIABLE_FILE ;;
    k|l ) NONINTERACTIVE_INSTALL='noninteractive_install'; fast_install_variables ;;
  esac
done

# 配置变量后处理：SUBSCRIBE → IS_SUB / ARGO → IS_ARGO 转换（仅当在 config 中被显式设置时）
[[ -n "${SUBSCRIBE:-}" ]] && { [[ "${SUBSCRIBE,,}" =~ ^(y|yes|true|1)$ ]] && IS_SUB=is_sub || IS_SUB=no_sub; }
unset SUBSCRIBE
[[ -n "${ARGO:-}" ]] && { [[ "${ARGO,,}" =~ ^(y|yes|true|1)$ ]] && IS_ARGO=is_argo || IS_ARGO=no_argo; IS_ARGO_EXPLICIT=true; }
unset ARGO

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

check_root
select_language
check_arch
check_system_info
check_dependencies
[ "$NONINTERACTIVE_INSTALL" != 'noninteractive_install' ] && check_system_ip
check_install
menu_setting
[ "$SKIP_MENU" = 'skip_menu' ] || [ "$NONINTERACTIVE_INSTALL" = 'noninteractive_install' ] && ACTION[2] || menu
