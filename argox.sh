#!/usr/bin/env bash

# 当前脚本版本号
VERSION=1.0

# 各变量默认值
CDN='https://ghproxy.com'
SERVER_DEFAULT='icook.hk'
UUID_DEFAULT='ffffffff-ffff-ffff-ffff-ffffffffffff'
WS_PATH_DEFAULT='argox'
WORK_DIR='/etc/argox'
CLOUDFLARED_PORT='54321'
TEMP_DIR='/tmp/argox'

trap "rm -rf $TEMP_DIR; echo -e '\n' ;exit 1" INT QUIT TERM EXIT

mkdir -p $TEMP_DIR

E[0]="Language:\n 1. English (default) \n 2. 简体中文"
C[0]="${E[0]}"
E[1]="Users can easily obtain the JSON of a fixed domain name tunnel through the accompanying function website at https://fscarmen.cloudflare.now.cc"
C[1]="用户可以通过配套的功能网轻松获取固定域名隧道的 json, https://fscarmen.cloudflare.now.cc"
E[2]="Project to create Argo tunnels and Xray specifically for VPS, detailed:[https://github.com/fscarmen/argox]\n Features:\n\t • Allows the creation of Argo tunnels via Token, Json and ad hoc methods. User can easily obtain the json at https://fscarmen.cloudflare.now.cc .\n\t • Extremely fast installation method, saving users time.\n\t • Support system: Ubuntu, Debian, CentOS, Alpine and Arch Linux 3.\n\t • Support architecture: AMD,ARM and s390x\n"
C[2]="本项目专为 VPS 添加 Argo 隧道及 Xray,详细说明: [https://github.com/fscarmen/argox]\n 脚本特点:\n\t • 允许通过 Token, Json 及 临时方式来创建 Argo 隧道,用户通过以下网站轻松获取 json: https://fscarmen.cloudflare.now.cc\n\t • 极速安装方式,大大节省用户时间\n\t • 智能判断操作系统: Ubuntu 、Debian 、CentOS 、Alpine 和 Arch Linux,请务必选择 LTS 系统\n\t • 支持硬件结构类型: AMD 和 ARM\n"
E[3]="Input errors up to 5 times.The script is aborted."
C[3]="输入错误达5次,脚本退出"
E[4]="UUID should be 36 characters, please re-enter \(\${a} times remaining\):"
C[4]="UUID 应为36位字符,请重新输入 \(剩余\${a}次\):"
E[5]="The script supports Debian, Ubuntu, CentOS, Alpine or Arch systems only. Feedback: [https://github.com/fscarmen/argox/issues]"
C[5]="本脚本只支持 Debian、Ubuntu、CentOS、Alpine 或 Arch 系统,问题反馈:[https://github.com/fscarmen/argox/issues]"
E[6]="Curren operating system is \$SYS.\\\n The system lower than \$SYSTEM \${MAJOR[int]} is not supported. Feedback: [https://github.com/fscarmen/argox/issues]"
C[6]="当前操作是 \$SYS\\\n 不支持 \$SYSTEM \${MAJOR[int]} 以下系统,问题反馈:[https://github.com/fscarmen/argox/issues]"
E[7]="Install dependence-list:"
C[7]="安装依赖列表:"
E[8]="All dependencies already exist and do not need to be installed additionally."
C[8]="所有依赖已存在，不需要额外安装"
E[9]="To upgrade, press [y]. No upgrade by default:"
C[9]="升级请按 [y]，默认不升级:"
E[10]="Please input Argo Domain (Default is temporary domain if left blank):"
C[10]="请输入 Argo 域名 (如果没有，可以跳过以使用 Argo 临时域名):"
E[11]="Please input Argo Token or Json ( User can easily obtain the json at https://fscarmen.cloudflare.now.cc ):"
C[11]="请输入 Argo Token 或者 Json ( 用户通过以下网站轻松获取 json: https://fscarmen.cloudflare.now.cc ):"
E[12]="Please input Xray UUID \(Default is \$UUID_DEFAULT\):"
C[12]="请输入 Xray UUID \(默认为 \$UUID_DEFAULT\):"
E[13]="Please input Xray WS Path \(Default is \$WS_PATH_DEFAULT\):"
C[13]="请输入 Xray WS 路径 \(默认为 \$WS_PATH_DEFAULT\):"
E[14]="Xray WS Path only allow uppercase and lowercase letters and numeric characters, please re-enter \(\${a} times remaining\):"
C[14]="Xray WS 路径只允许英文大小写及数字字符，请重新输入 \(剩余\${a}次\):"
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
E[29]="View links"
C[29]="查看节点信息"
E[30]="Change the Argo tunnel"
C[30]="更换 Argo 隧道"
E[31]="Sync Argo and Xray to the latest version"
C[31]="同步 Argo 和 Xray 至最新版本"
E[32]="Upgrade kernel, turn on BBR, change Linux system"
C[32]="升级内核、安装BBR、DD脚本"
E[33]="Uninstall"
C[33]="卸载"
E[34]="Install script"
C[34]="安装脚本"
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
E[40]="Argo tunnel is: \$ARGO_TYPE\\\n The domain is: \$ARGO_DOMAIN"
C[40]="Argo 隧道类型为: \$ARGO_TYPE\\\n 域名是: \$ARGO_DOMAIN"
E[41]="Argo tunnel type:\n 1. Try\n 2. Token or Json"
C[41]="Argo 隧道类型:\n 1. Try\n 2. Token 或者 Json"
E[42]="Please input Xray Server \(Default is \$SERVER_DEFAULT\):"
C[42]="请输入 Xray server \(默认为 \$SERVER_DEFAULT\):"
E[43]="\$APP local verion: \$LOCAL.\\\t The newest verion: \$ONLINE"
C[43]="\$APP 本地版本: \$LOCAL.\\\t 最新版本: \$ONLINE"
E[44]="No upgrade required."
C[44]="不需要升级"
E[45]="Argo authentication message does not match the rules, neither Token nor Json, script exits. Feedback:[https://github.com/fscarmen/argox/issues]"
C[45]="Argo 认证信息不符合规则，既不是 Token，也是不是 Json，脚本退出，问题反馈:[https://github.com/fscarmen/argox/issues]"
E[46]="Connect"
C[46]="连接"
E[47]="The script must be run as root, you can enter sudo -i and then download and run again. Feedback:[https://github.com/fscarmen/argox/issues]"
C[47]="必须以root方式运行脚本，可以输入 sudo -i 后重新下载运行，问题反馈:[https://github.com/fscarmen/argox/issues]"
E[48]="Downloading the latest version \$APP failed, script exits. Feedback:[https://github.com/fscarmen/argox/issues]"
C[48]="下载最新版本 \$APP 失败，脚本退出，问题反馈:[https://github.com/fscarmen/argox/issues]"

# 自定义字体彩色，read 函数，友道翻译函数
warning() { echo -e "\033[31m\033[01m$*\033[0m"; }  # 红色
error() { echo -e "\033[31m\033[01m$*\033[0m" && exit 1; } # 红色
info() { echo -e "\033[32m\033[01m$*\033[0m"; }   # 绿色
hint() { echo -e "\033[33m\033[01m$*\033[0m"; }   # 黄色
reading() { read -rp "$(info "$1")" "$2"; } 
text() { eval echo "\${${L}[$*]}"; }
text_eval() { eval echo "\$(eval echo "\${${L}[$*]}")"; }
translate() { [ -n "$1" ] && wget -qO- -t1T1 "http://fanyi.youdao.com/translate?&doctype=json&type=EN2ZH_CN&i=${1//[[:space:]]/}" | cut -d \" -f18 2>/dev/null; }

# 选择中英语言
select_language() {
  if [ -z "$L" ]; then
    case $(cat $WORK_DIR/language 2>&1) in
      E ) L=E ;;
      C ) L=C ;;
      * ) [ -z "$L" ] && L=E && hint "\n $(text 0) \n" && reading " $(text 24) " LANGUAGE
      [ "$LANGUAGE" = 2 ] && L=C ;;
    esac
  fi
}

check_root() {
  [ "$(id -u)" != 0 ] && error "\n $(text 47) \n"
}

check_arch() {
  # 判断处理器架构
  case $(uname -m) in
    aarch64|arm64 ) ARGO_ARCH=arm64 ; XRAY_ARCH=arm64-v8a ;;
    x86_64|amd64 ) ARGO_ARCH=amd64 ; XRAY_ARCH=64 ;;
    armv7l ) ARGO_ARCH=arm ; XRAY_ARCH=arm32-v7a ;;
 #   s390x ) ARCHITECTURE=s390x ;;
    * ) error " $(text_eval 25) " ;;
  esac
}

# 查安装及运行状态，下标0: argo，下标1: xray，下标2：docker；状态码: 26 未安装， 27 已安装未运行， 28 运行中
check_install() {
  STATUS[0]=$(text 26) && [ -e /etc/systemd/system/argo.service ] && STATUS[0]=$(text 27) && [ "$(systemctl is-active argo)" = 'active' ] && STATUS[0]=$(text 28)
  STATUS[1]=$(text 26) && [ -e /etc/systemd/system/xray.service ] && STATUS[1]=$(text 27) && [ "$(systemctl is-active xray)" = 'active' ] && STATUS[1]=$(text 28)
  [[ ${STATUS[0]} = "$(text 26)" ]] && [ ! -e $WORK_DIR/cloudflared ] && { wget -qO $TEMP_DIR/cloudflared $CDN/https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$ARGO_ARCH >/dev/null 2>&1 && chmod +x $TEMP_DIR/cloudflared >/dev/null 2>&1; }&
  [[ ${STATUS[1]} = "$(text 26)" ]] && [ ! -e $WORK_DIR/xray ] && { wget -qO $TEMP_DIR/Xray.zip $CDN/https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-$XRAY_ARCH.zip >/dev/null 2>&1; unzip -qo $TEMP_DIR/Xray.zip xray *.dat -d $TEMP_DIR >/dev/null 2>&1; }&
}

check_system_info() {
  # 判断虚拟化，选择 Wireguard内核模块 还是 Wireguard-Go
  VIRT=$(systemd-detect-virt 2>/dev/null | tr 'A-Z' 'a-z')
  [ -n "$VIRT" ] || VIRT=$(hostnamectl 2>/dev/null | tr 'A-Z' 'a-z' | grep virtualization | sed "s/.*://g")

  CMD=( "$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)"
        "$(hostnamectl 2>/dev/null | grep -i system | cut -d : -f2)"
        "$(lsb_release -sd 2>/dev/null)"
        "$(grep -i description /etc/lsb-release 2>/dev/null | cut -d \" -f2)"
        "$(grep . /etc/redhat-release 2>/dev/null)"
        "$(grep . /etc/issue 2>/dev/null | cut -d \\ -f1 | sed '/^[ ]*$/d')"
      )

  for i in "${CMD[@]}"; do
    SYS="$i" && [ -n "$SYS" ] && break
  done

  REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "amazon linux" "arch linux" "alpine")
  RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Arch" "Alpine")
  EXCLUDE=("bookworm")
  MAJOR=("9" "16" "7" "7" "" "")
  PACKAGE_UPDATE=("apt -y update" "apt -y update" "yum -y update" "yum -y update" "pacman -Sy" "apk update -f")
  PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "yum -y install" "pacman -S --noconfirm" "apk add --no-cache")
  PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove" "yum -y autoremove" "pacman -Rcnsu --noconfirm" "apk del -f")

  for ((int=0; int<${#REGEX[@]}; int++)); do
    [[ $(tr 'A-Z' 'a-z' <<< "$SYS") =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && break
  done
  [ -z "$SYSTEM" ] && error " $(text 5) "

  # 先排除 EXCLUDE 里包括的特定系统，其他系统需要作大发行版本的比较
  for ex in "${EXCLUDE[@]}"; do [[ ! $(tr 'A-Z' 'a-z' <<< "$SYS")  =~ $ex ]]; done &&
  [[ "$(echo "$SYS" | sed "s/[^0-9.]//g" | cut -d. -f1)" -lt "${MAJOR[int]}" ]] && error " $(text_eval 6) "
}

check_system_ip() {
  if [ -z "$VARIABLE_FILE" ]; then
    # 检测 IPv4 IPv6 信息，WARP Ineterface 开启，普通还是 Plus账户 和 IP 信息
    IP4=$(wget -4 -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=3 http://ip-api.com/json/) &&
    WAN4=$(expr "$IP4" : '.*query\":[ ]*\"\([^"]*\).*') &&
    COUNTRY4=$(expr "$IP4" : '.*country\":[ ]*\"\([^"]*\).*') &&
    ASNORG4=$(expr "$IP4" : '.*isp\":[ ]*\"\([^"]*\).*') &&
    [[ "$L" = C && -n "$COUNTRY4" ]] && COUNTRY4=$(translate "$COUNTRY4")

    IP6=$(wget -6 -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=3 https://api.ip.sb/geoip) &&
    WAN6=$(expr "$IP6" : '.*ip\":[ ]*\"\([^"]*\).*') &&
    COUNTRY6=$(expr "$IP6" : '.*country\":[ ]*\"\([^"]*\).*') &&
    ASNORG6=$(expr "$IP6" : '.*isp\":[ ]*\"\([^"]*\).*') &&
    [[ "$L" = C && -n "$COUNTRY6" ]] && COUNTRY6=$(translate "$COUNTRY6")
  fi
}

# 定义 Argo 变量
argo_variable() {
  [ -z "$ARGO_DOMAIN" ] && reading "\n $(text 10) " ARGO_DOMAIN

  if [ -n "$ARGO_DOMAIN" ]; then
    [ -z "$ARGO_AUTH" ] && reading "\n $(text 11) " ARGO_AUTH
    if [[ "$ARGO_AUTH" =~ TunnelSecret ]]; then
      ARGO_JSON=$ARGO_AUTH
    elif [[ "$ARGO_AUTH" =~ ^[A-Z0-9a-z=]{120,250}$ ]]; then
      ARGO_TOKEN=$ARGO_AUTH
    elif grep -qoP ".*cloudflared.*service install [A-Z0-9a-z=]{120,250}$" <<< "$ARGO_AUTH"; then
      ARGO_TOKEN=$(awk -F ' ' '{print $NF}' <<< "$ARGO_AUTH")
    else
      error "\n $(text 45) \n"
    fi
  fi
}

# 定义 Xray 变量
xray_variable() {
  [ -z "$SERVER" ] && reading "\n $(text_eval 42) " SERVER
  SERVER=${SERVER:-"$SERVER_DEFAULT"}

  [ -z "$UUID" ] && reading "\n $(text_eval 12) " UUID
  local a=5
  until [[ -z "$UUID" || "$UUID" =~ ^[A-F0-9a-f]{8}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{12}$ ]]; do
    (( a-- )) || true
    [ "$a" = 0 ] && error " $(text 3) " || reading " $(text_eval 4) " UUID
  done
  UUID=${UUID:-"$UUID_DEFAULT"}

  [ -z "$WS_PATH" ] && reading "\n $(text_eval 13) " WS_PATH
  local a=5
  until [[ -z "$WS_PATH" || "$WS_PATH" =~ ^[A-Z0-9a-z]+$ ]]; do
    (( a-- )) || true
    [ "$a" = 0 ] && error " $(text 3) " || reading " $(text_eval 14) " WS_PATH
  done
  WS_PATH=${WS_PATH:-"$WS_PATH_DEFAULT"}
}

check_dependencies() {
  # 如果是 Alpine，先升级 wget ，安装 systemctl-py 版
  if [ "$SYSTEM" = 'Alpine' ]; then
    CHECK_WGET=$(wget 2>&1 | head -n 1)
    grep -qi 'busybox' <<< "$CHECK_WGET" && ${PACKAGE_INSTALL[int]} wget >/dev/null 2>&1

    DEPS_CHECK=("bash" "python3" "rc-update")
    DEPS_INSTALL=("bash" "python3" "openrc")
    for ((g=0; g<${#DEPS_CHECK[@]}; g++)); do [ ! $(type -p ${DEPS_CHECK[g]}) ] && [[ ! "${DEPS[@]}" =~ "${DEPS_INSTALL[g]}" ]] && DEPS+=(${DEPS_INSTALL[g]}); done
    if [ "${#DEPS[@]}" -ge 1 ]; then
      info "\n $(text 7) ${DEPS[@]} \n"
      ${PACKAGE_UPDATE[int]} >/dev/null 2>&1
      ${PACKAGE_INSTALL[int]} ${DEPS[@]} >/dev/null 2>&1
    fi

    [ ! $(type -p systemctl) ] && wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py -O /bin/systemctl && chmod a+x /bin/systemctl
  fi

  # 检测 Linux 系统的依赖，升级库并重新安装依赖
  unset DEPS_CHECK DEPS_INSTALL DEPS
  DEPS_CHECK=("ping" "wget" "systemctl" "ip" "unzip" "bash")
  DEPS_INSTALL=("iputils-ping" "wget" "systemctl" "iproute2" "unzip" "bash")
  for ((g=0; g<${#DEPS_CHECK[@]}; g++)); do [ ! $(type -p ${DEPS_CHECK[g]}) ] && [[ ! "${DEPS[@]}" =~ "${DEPS_INSTALL[g]}" ]] && DEPS+=(${DEPS_INSTALL[g]}); done
  if [ "${#DEPS[@]}" -ge 1 ]; then
    info "\n $(text 7) ${DEPS[@]} \n"
    ${PACKAGE_UPDATE[int]} >/dev/null 2>&1
    ${PACKAGE_INSTALL[int]} ${DEPS[@]} >/dev/null 2>&1
  else
    info "\n $(text 8) \n"
  fi
}

# Json 生成两个配置文件
json_argo() {
  [ ! -e $WORK_DIR/tunnel.json ] && echo $ARGO_JSON > $WORK_DIR/tunnel.json
  [ ! -e $WORK_DIR/tunnel.yml ] && cat > $WORK_DIR/tunnel.yml << EOF
tunnel: $(cut -d\" -f12 <<< $ARGO_JSON)
credentials-file: $WORK_DIR/tunnel.json
protocol: http2

ingress:
  - hostname: ${ARGO_DOMAIN}
    service: http://localhost:8080
  - service: http_status:404
EOF
}

install_argox() {
  argo_variable
  xray_variable
  wait
  [ ! -d /etc/systemd/system ] && mkdir -p /etc/systemd/system
  mkdir -p $WORK_DIR && echo "$L" > $WORK_DIR/language
  [ -e "$VARIABLE_FILE" ] && cp $VARIABLE_FILE $WORK_DIR/
  # Argo 生成守护进程文件
  [ ! -e $WORK_DIR/cloudflared ] && wait && { mv $TEMP_DIR/cloudflared $WORK_DIR; }
  if [[ -n "${ARGO_JSON}" && -n "${ARGO_DOMAIN}" ]]; then
    ARGO_RUNS="$WORK_DIR/cloudflared tunnel --edge-ip-version auto --config $WORK_DIR/tunnel.yml run"
    json_argo
  elif [[ -n "${ARGO_TOKEN}" && -n "${ARGO_DOMAIN}" ]]; then
    ARGO_RUNS="$WORK_DIR/cloudflared tunnel --edge-ip-version auto --protocol http2 run --token ${ARGO_TOKEN}"
  else
    ARGO_RUNS="$WORK_DIR/cloudflared tunnel --edge-ip-version auto --no-autoupdate --protocol http2 --metrics localhost:$CLOUDFLARED_PORT --url http://localhost:8080"
  fi

  cat > /etc/systemd/system/argo.service << EOF
[Unit]
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
WantedBy=multi-user.target
EOF

  # 生成配置文件及守护进程文件
  [ ! -e $WORK_DIR/xray ] && wait && { mv $TEMP_DIR/{xray,geo*.dat} $WORK_DIR; }
  cat > $WORK_DIR/config.json << EOF
{
    "log":{
        "access":"/dev/null",
        "error":"/dev/null",
        "loglevel":"none"
    },
    "inbounds":[
        {
            "listen":"127.0.0.1",
            "port":8080,
            "protocol":"vless",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "flow":"xtls-rprx-direct"
                    }
                ],
                "decryption":"none",
                "fallbacks":[
                    {
                        "dest":3001
                    },
                    {
                        "path":"/${WS_PATH}-vl",
                        "dest":3002
                    },
                    {
                        "path":"/${WS_PATH}-vm",
                        "dest":3003
                    },
                    {
                        "path":"/${WS_PATH}-tr",
                        "dest":3004
                    },
                    {
                        "path":"/${WS_PATH}-sh",
                        "dest":3005
                    }
                ]
            },
            "streamSettings":{
                "network":"tcp"
            }
        },
        {
            "port":3001,
            "listen":"127.0.0.1",
            "protocol":"vless",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}"
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "security":"none"
            }
        },
        {
            "port":3002,
            "listen":"127.0.0.1",
            "protocol":"vless",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "level":0
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "security":"none",
                "wsSettings":{
                    "path":"/${WS_PATH}-vl"
                }
            },
            "sniffing":{
                "enabled":false,
                "destOverride":[
                    "http",
                    "tls"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3003,
            "listen":"127.0.0.1",
            "protocol":"vmess",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "alterId":0
                    }
                ]
            },
            "streamSettings":{
                "network":"ws",
                "wsSettings":{
                    "path":"/${WS_PATH}-vm"
                }
            },
            "sniffing":{
                "enabled":false,
                "destOverride":[
                    "http",
                    "tls"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3004,
            "listen":"127.0.0.1",
            "protocol":"trojan",
            "settings":{
                "clients":[
                    {
                        "password":"${UUID}"
                    }
                ]
            },
            "streamSettings":{
                "network":"ws",
                "security":"none",
                "wsSettings":{
                    "path":"/${WS_PATH}-tr"
                }
            },
            "sniffing":{
                "enabled":false,
                "destOverride":[
                    "http",
                    "tls"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3005,
            "listen":"127.0.0.1",
            "protocol":"shadowsocks",
            "settings":{
                "clients":[
                    {
                        "method":"chacha20-ietf-poly1305",
                        "password":"${UUID}"
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "wsSettings":{
                    "path":"/${WS_PATH}-sh"
                }
            },
            "sniffing":{
                "enabled":false,
                "destOverride":[
                    "http",
                    "tls"
                ],
                "metadataOnly":false
            }
        }
    ],
    "dns":{
        "servers":[
            "https+local://8.8.8.8/dns-query"
        ]
    },
    "outbounds":[
        {
            "protocol":"freedom"
        }
    ]
}
EOF

  cat > /etc/systemd/system/xray.service << EOF
[Unit]
Description=Xray Service
Documentation=https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target
Wants=network-online.target

[Service]
Type=simple
NoNewPrivileges=yes
ExecStart=$WORK_DIR/xray run -c $WORK_DIR/config.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOF

  # 再次检测状态，运行 Argo 和 Xray
  check_install
  [[ ${STATUS[0]} = "$(text 27)" ]] && systemctl enable --now argo && info "\n Argo $(text 28) $(text 37) \n" || warning "\n Argo $(text 28) $(text 38) \n"
  [[ ${STATUS[1]} = "$(text 27)" ]] && systemctl enable --now xray && info "\n Xray $(text 28) $(text 37) \n" || warning "\n Xray $(text 28) $(text 38) \n"
  
  # 如果 Alpine 系统，放到开机自启动
  if [ "$SYSTEM" = 'Alpine' ]; then
    cat > /etc/local.d/argox.start << EOF
#!/usr/bin/env bash

systemctl start argo
systemctl start xray
EOF
    chmod +x /etc/local.d/argox.start
    rc-update add local
  fi
}

export_list() {
  check_install

  if grep -q "^ExecStart.*8080$" /etc/systemd/system/argo.service; then
    sleep 5 && ARGO_DOMAIN=$(wget -qO- http://localhost:$CLOUDFLARED_PORT/quicktunnel | cut -d\" -f4)
  else
    ARGO_DOMAIN=${ARGO_DOMAIN:-"$(grep '^vless' $WORK_DIR/list | head -n 1 | sed "s@.*host=\(.*\)&.*@\1@g")"}
  fi
  SERVER=${SERVER:-"$(grep '^vless' $WORK_DIR/list | head -n 1 | sed "s/.*@\(.*\):443.*/\1/g")"}
  UUID=${UUID:-"$(grep 'password' $WORK_DIR/config.json | awk -F \" 'NR==1{print $4}')"}
  WS_PATH=${WS_PATH:-"$(grep 'path.*vm' $WORK_DIR/config.json | head -n 1 | sed "s@.*/\(.*\)-vm.*@\1@g")"} 

  # 生成配置文件
  VMESS="{ \"v\": \"2\", \"ps\": \"ArgoX-Vm\", \"add\": \"icook.hk\", \"port\": \"443\", \"id\": \"${UUID}\", \"aid\": \"0\", \"scy\": \"none\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"${ARGO_DOMAIN}\", \"path\": \"/${WS_PATH}-vm\", \"tls\": \"tls\", \"sni\": \"${ARGO_DOMAIN}\", \"alpn\": \"\" }"
  cat > $WORK_DIR/list << EOF
*******************************************
V2-rayN:
----------------------------
vless://${UUID}@${SERVER}:443?encryption=none&security=tls&sni=${ARGO_DOMAIN}&type=ws&host=${ARGO_DOMAIN}&path=%2F${WS_PATH}-vl#ArgoX-Vl
----------------------------
vmess://$(base64 -w0 <<< $VMESS)
----------------------------
trojan://${UUID}@${SERVER}:443?security=tls&sni=${ARGO_DOMAIN}&type=ws&host=${ARGO_DOMAIN}&path=%2F${WS_PATH}-tr#ArgoX-Tr
----------------------------
ss://$(echo "chacha20-ietf-poly1305:${UUID}@${SERVER}:443" | base64 -w0)@${SERVER}:443#ArgoX-Sh
由于该软件导出的链接不全，请自行处理如下: 传输协议: WS , 伪装域名: ${ARGO_DOMAIN} , 路径: /${WS_PATH}-sh , 传输层安全: tls , sni: ${ARGO_DOMAIN}
*******************************************
小火箭 Shadowrocket:
----------------------------
vless://${UUID}@${SERVER}:443?encryption=none&security=tls&type=ws&host=${ARGO_DOMAIN}&path=/${WS_PATH}-vl&sni=${ARGO_DOMAIN}#ArgoX-Vl
----------------------------
vmess://$(echo "none:${UUID}@${SERVER}:443" | base64 -w0)?remarks=ArgoX-Vm&obfsParam=${ARGO_DOMAIN}&path=/${WS_PATH}-vm&obfs=websocket&tls=1&peer=${ARGO_DOMAIN}&alterId=0
----------------------------
trojan://${UUID}@${SERVER}:443?peer=${ARGO_DOMAIN}&plugin=obfs-local;obfs=websocket;obfs-host=${ARGO_DOMAIN};obfs-uri=/${WS_PATH}-tr#ArgoX-Tr
----------------------------
ss://$(echo "chacha20-ietf-poly1305:${UUID}@${SERVER}:443" | base64 -w0)?obfs=wss&obfsParam=${ARGO_DOMAIN}&path=/${WS_PATH}-sh#ArgoX-Sh
*******************************************
Clash:
----------------------------
- {name: ArgoX-Vl, type: vless, server: ${SERVER}, port: 443, uuid: ${UUID}, tls: true, servername: ${ARGO_DOMAIN}, skip-cert-verify: false, network: ws, ws-opts: {path: /${WS_PATH}-vl, headers: { Host: ${ARGO_DOMAIN}}}, udp: true}
----------------------------
- {name: ArgoX-Vm, type: vmess, server: ${SERVER}, port: 443, uuid: ${UUID}, alterId: 0, cipher: none, tls: true, skip-cert-verify: true, network: ws, ws-opts: {path: /${WS_PATH}-vm, headers: {Host: ${ARGO_DOMAIN}}}, udp: true}
----------------------------
- {name: ArgoX-Tr, type: trojan, server: ${SERVER}, port: 443, password: ${UUID}, udp: true, tls: true, sni: ${ARGO_DOMAIN}, skip-cert-verify: false, network: ws, ws-opts: { path: /${WS_PATH}-tr, headers: { Host: ${ARGO_DOMAIN} } } }
----------------------------
- {name: ArgoX-Sh, type: ss, server: ${SERVER}, port: 443, cipher: chacha20-ietf-poly1305, password: ${UUID}, plugin: v2ray-plugin, plugin-opts: { mode: websocket, host: ${ARGO_DOMAIN}, path: /${WS_PATH}-sh, tls: true, skip-cert-verify: false, mux: false } }
*******************************************
EOF
  cat $WORK_DIR/list
}

change_argo() {
  check_install
  [[ ${STATUS[0]} = "$(text 26)" ]] && error " $(text 39) "

  case $(grep "ExecStart" /etc/systemd/system/argo.service) in 
    *--config* ) ARGO_TYPE='Json'; ARGO_DOMAIN="$(grep '^vless' $WORK_DIR/list | head -n 1 | sed "s@.*host=\(.*\)&.*@\1@g")" ;;
    *--token* ) ARGO_TYPE='Token'; ARGO_DOMAIN="$(grep '^vless' $WORK_DIR/list | head -n 1 | sed "s@.*host=\(.*\)&.*@\1@g")" ;;
    * ) ARGO_TYPE='Try'; ARGO_DOMAIN=$(wget -qO- http://localhost:$CLOUDFLARED_PORT/quicktunnel | cut -d\" -f4) ;;
  esac

  hint "\n $(text_eval 40) \n"
  unset ARGO_DOMAIN
  hint " $(text 41) \n" && reading " $(text 24) " CHANGE_TO
    case "$CHANGE_TO" in
      1 ) systemctl disable --now argo
          [ -e $WORK_DIR/tunnel.json ] && rm -f $WORK_DIR/tunnel.{json,yml}
          sed -i "s@ExecStart.*@ExecStart=$WORK_DIR/cloudflared tunnel --edge-ip-version auto --protocol http2 --no-autoupdate --metrics localhost:$CLOUDFLARED_PORT --url http://localhost:8080@g" /etc/systemd/system/argo.service
          systemctl enable --now argo
          ;;
      2 ) argo_variable
          systemctl disable --now argo
          if [ -n "$ARGO_TOKEN" ]; then
            [ -e $WORK_DIR/tunnel.json ] && rm -f $WORK_DIR/tunnel.{json,yml}
            sed -i "s@ExecStart.*@ExecStart=$WORK_DIR/cloudflared tunnel --edge-ip-version auto --protocol http2 run --token ${ARGO_TOKEN}@g" /etc/systemd/system/argo.service
          elif [ -n "$ARGO_JSON" ]; then
            [ -e $WORK_DIR/tunnel.json ] && rm -f $WORK_DIR/tunnel.{json,yml}
            json_argo            
            sed -i "s@ExecStart.*@ExecStart=$WORK_DIR/cloudflared tunnel --edge-ip-version auto --config $WORK_DIR/tunnel.yml run@g" /etc/systemd/system/argo.service
          fi
          systemctl enable --now argo
          ;;
      * ) exit 0
          ;;
    esac

    export_list
}

uninstall() {
  if [ -d $WORK_DIR ]; then
    systemctl disable --now {argo,xray} 2>/dev/null
    rm -rf $WORK_DIR $TEMP_DIR /etc/systemd/system/{xray,argo}.service
    info "\n $(text 16) \n"
  else
    error "\n $(text 15) \n"
  fi

  # 如果 Alpine 系统，删除开机自启动
  [ "$SYSTEM" = 'Alpine' ] && ( rm -f /etc/local.d/argox.start; rc-update add local )
}

# Argo 与 Xray 的最新版本 
version() {
  # Argo 版本
  local ONLINE=$(wget -qO- "https://api.github.com/repos/cloudflare/cloudflared/releases/latest" | grep "tag_name" | cut -d \" -f4)
  local LOCAL=$($WORK_DIR/cloudflared -v | awk '{for (i=0; i<NF; i++) if ($i=="version") {print $(i+1)}}')
  local APP=ARGO && info "\n $(text_eval 43) "
  [[ -n "$ONLINE" && "$ONLINE" != "$LOCAL" ]] && reading "\n $(text 9) " UPDATE[0] || info " $(text 44) "
  local ONLINE=$(wget -qO- "https://api.github.com/repos/XTLS/Xray-core/releases/latest" | grep "tag_name" | sed "s@.*\"v\(.*\)\",@\1@g")
  local LOCAL=$($WORK_DIR/xray version | awk '{for (i=0; i<NF; i++) if ($i=="Xray") {print $(i+1)}}')
  local APP=Xray && info "\n $(text_eval 43) "
  [[ -n "$ONLINE" && "$ONLINE" != "$LOCAL" ]] && reading "\n $(text 9) " UPDATE[1] || info " $(text 44) "

  [[ ${UPDATE[*]} =~ [Yy] ]] && check_system_info
  if [[ ${UPDATE[0]} = [Yy] ]]; then
    wget -O $TEMP_DIR/cloudflared $CDN/https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$ARGO_ARCH
    if [ -s $TEMP_DIR/cloudflared ]; then
      systemctl disable --now argo
      chmod +x $TEMP_DIR/cloudflared && mv $TEMP_DIR/cloudflared $WORK_DIR/cloudflared
      systemctl enable --now argo && [ "$(systemctl is-active argo)" = 'active' ] && info " Argo $(text 28) $(text 37)" || error " Argo $(text 28) $(text 38) "
    else
      local APP=ARGO && error "\n $(text_eval 48) "
    fi
  fi
  if [[ ${UPDATE[1]} = [Yy] ]]; then
    wget -O $TEMP_DIR/Xray-linux-$XRAY_ARCH.zip $CDN/https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-$XRAY_ARCH.zip
    if [ -s $TEMP_DIR/Xray-linux-$XRAY_ARCH.zip ]; then
      systemctl disable --now xray
      unzip -qo $TEMP_DIR/Xray-linux-$XRAY_ARCH.zip xray *.dat -d $WORK_DIR; rm -f $TEMP_DIR/Xray*.zip
      systemctl enable --now xray && [ "$(systemctl is-active xray)" = 'active' ] && info " Xray $(text 28) $(text 37)" || error " Xray $(text 28) $(text 38) "
    else
      local APP=Xray && error "\n $(text_eval 48) "
    fi
  fi
}

# 判断当前 Argo-X 的运行状态，并对应的给菜单和动作赋值
menu_setting() {
  OPTION[0]="0.  $(text 35)"
  ACTION[0]() { exit; }

  if [[ ${STATUS[*]} =~ $(text 27)|$(text 28) ]]; then
    if [ -e $WORK_DIR/cloudflared ]; then
      ARGO_VERSION=$($WORK_DIR/cloudflared -v | awk '{print $3}' | sed "s@^@Version: &@g")
      ss -nltp | grep -q "127\.0\.0\.1:$CLOUDFLARED_PORT.*cloudflared" && ARGO_CHECKHEALTH="$(text 46): $(wget -qO- http://localhost:$CLOUDFLARED_PORT/healthcheck | sed "s/OK/$(text 37)/")"
    fi
    [ -e $WORK_DIR/xray ] && XRAY_VERSION=$($WORK_DIR/xray version | awk 'NR==1 {print $2}' | sed "s@^@Version: &@g")
    OPTION[1]="1.  $(text 29)"
    [ ${STATUS[0]} = "$(text 28)" ] && OPTION[2]="2.  $(text 27) Argo" || OPTION[2]="2.  $(text 28) Argo"
    [ ${STATUS[1]} = "$(text 28)" ] && OPTION[3]="3.  $(text 27) Xray" || OPTION[3]="3.  $(text 28) Xray"
    OPTION[4]="4.  $(text 30)"
    OPTION[5]="5.  $(text 31)"
    OPTION[6]="6.  $(text 32)"
    OPTION[7]="7.  $(text 33)"

    ACTION[1]() { export_list; }
    [[ ${STATUS[0]} = "$(text 28)" ]] && ACTION[2]() { systemctl disable --now argo; [ "$(systemctl is-active argo)" = 'inactive' ] && info " Argo $(text 27) $(text 37)" || error " Argo $(text 27) $(text 38) "; } || ACTION[2]() { systemctl enable --now argo && [ "$(systemctl is-active argo)" = 'active' ] && info " Argo $(text 28) $(text 37)" || error " Argo $(text 28) $(text 38) "; }
    [[ ${STATUS[1]} = "$(text 28)" ]] && ACTION[3]() { systemctl disable --now xray; [ "$(systemctl is-active xray)" = 'inactive' ] && info " Xray $(text 27) $(text 37)" || error " Xray $(text 27) $(text 38) "; } || ACTION[3]() { systemctl enable --now xray && [ "$(systemctl is-active xray)" = 'active' ] && info " Xray $(text 28) $(text 37)" || error " Xray $(text 28) $(text 38) "; }
    ACTION[4]() { change_argo; }
    ACTION[5]() { version; }
    ACTION[6]() { bash <(wget -qO- --no-check-certificate "https://raw.githubusercontents.com/ylx2016/Linux-NetSpeed/master/tcp.sh"); exit; }
    ACTION[7]() { uninstall; }

  else
    OPTION[1]="1.  $(text 34)"
    OPTION[2]="2.  $(text 32)"

    ACTION[1]() { install_argox; export_list; }
    ACTION[2]() { bash <(wget -qO- --no-check-certificate "https://raw.githubusercontents.com/ylx2016/Linux-NetSpeed/master/tcp.sh"); exit; }
  fi
}

menu() {
  clear
  hint " $(text 2) "
  echo -e "======================================================================================================================\n"
  info " $(text 17):$VERSION\n $(text 18):$(text 1)\n $(text 19):\n\t $(text 20):$SYS\n\t $(text 21):$(uname -r)\n\t $(text 22):$ARCHITECTURE\n\t $(text 23):$VIRT "
  info "\t IPv4: $WAN4 $WARPSTATUS4 $COUNTRY4  $ASNORG4 "
  info "\t IPv6: $WAN6 $WARPSTATUS6 $COUNTRY6  $ASNORG6 "
  info "\t Argo: ${STATUS[0]}\t $ARGO_VERSION\t $ARGO_CHECKHEALTH\n\t Xray: ${STATUS[1]}\t $XRAY_VERSION"
  echo -e "\n======================================================================================================================\n"
  for ((b=1;b<${#OPTION[*]};b++)); do hint " ${OPTION[b]} "; done
  hint " ${OPTION[0]} "
  reading "\n $(text 24) " CHOOSE

  # 输入必须是数字且少于等于最大可选项
  if grep -qE "^[0-9]$" <<< "$CHOOSE" && [ "$CHOOSE" -lt "${#OPTION[*]}" ]; then
    ACTION[$CHOOSE]
  else
    warning " $(text 36) [0-$((${#OPTION[*]}-1))] " && sleep 1 && menu
  fi
}

# 传参
[[ "$*" =~ -[Ee] ]] && L=E
[[ "$*" =~ -[Cc] ]] && L=C

while getopts ":SsUuVvLlF:f:" OPTNAME; do
  case "$OPTNAME" in
    'S'|'s' ) select_language; change_argo; exit 0 ;;
    'U'|'u' ) select_language; uninstall; exit 0;;
    'L'|'l' ) select_language; export_list; exit 0 ;;
    'V'|'v' ) select_language; check_arch; version; exit 0;;
    'F'|'f' ) VARIABLE_FILE=$OPTARG; . $VARIABLE_FILE ;;
  esac
done

select_language
check_root
check_arch
check_system_info
check_dependencies
check_system_ip
check_install
menu_setting
[ -z "$VARIABLE_FILE" ] && menu || ACTION[1]