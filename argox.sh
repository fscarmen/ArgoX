#!/usr/bin/env bash

# 当前脚本版本号
VERSION=beta

# 各变量默认值
UUID_DEFAULT='ffffffff-ffff-ffff-ffff-ffffffffffff'
WS_PATH_DEFAULT='argox'
WORKDIR='/etc/argox'
TEMPDIR='/tmp'
#IP_API=https://api.ip.sb/geoip; ISP=isp
IP_API=https://ifconfig.co/json; ISP=asn_org

trap "rm -f $TEMPDIR/{cloudflared*,Xray*.zip,xray,geo*.dat}; exit 1" INT

E[0]="\n Language:\n 1. English (default) \n 2. 简体中文\n"
C[0]="${E[0]}"
E[1]="Argo+Xray=ArgoX"
C[1]="Argo+Xray=ArgoX"
E[2]="Project to create Argo tunnels and Xray specifically for VPS, detailed:[https://github.com/fscarmen/argox]\n Features:\n\t • Allows the creation of Argo tunnels via Token, Json and ad hoc methods.\n\t • Extremely fast installation method, saving users time.\n\t • Support system: Ubuntu 16.04、18.04、20.04、22.04,Debian 9、10、11,CentOS 7、8、9, Alpine, Arch Linux 3.\n\t • Support architecture: AMD,ARM and s390x\n"
C[2]="本项目专为 VPS 添加 Argo 隧道及 Xray，详细说明: [https://github.com/fscarmen/argox]\n 脚本特点:\n\t • 允许通过 Token, Json 及 临时方式来创建 Argo 隧道\n\t • 极速安装方式，大大节省用户时间\n\t • 智能判断操作系统: Ubuntu 、Debian 、CentOS、 Alpine 和 Arch Linux，请务必选择 LTS 系统\n\t • 支持硬件结构类型: AMD 和 ARM\n"
E[3]="Input errors up to 5 times.The script is aborted."
C[3]="输入错误达5次，脚本退出"
E[4]="UUID should be 36 characters, please re-enter \(\${a} times remaining\):"
C[4]="UUID 应为36位字符，请重新输入 \(剩余\${a}次\):"
E[5]="The script supports Debian, Ubuntu, CentOS, Arch or Alpine systems only. Feedback: [https://github.com/fscarmen/argox/issues]"
C[5]="本脚本只支持 Debian、Ubuntu、CentOS、Arch 或 Alpine 系统,问题反馈:[https://github.com/fscarmen/argox/issues]"
E[6]="Curren operating system is \$SYS.\\\n The system lower than \$SYSTEM \${MAJOR[int]} is not supported. Feedback: [https://github.com/fscarmen/argox/issues]"
C[6]="当前操作是 \$SYS\\\n 不支持 \$SYSTEM \${MAJOR[int]} 以下系统,问题反馈:[https://github.com/fscarmen/argox/issues]"
E[7]="Install dependence-list:"
C[7]="安装依赖列表:"
E[8]="All dependencies already exist and do not need to be installed additionally."
C[8]="所有依赖已存在，不需要额外安装"
E[9]="Installing \$APP ..."
C[9]="正在安装 \$APP"
E[10]="Please input Argo Domain (Default is temporary domain if left blank):"
C[10]="请输入 Argo 域名 (如果没有，可以跳过以使用 Argo 临时域名):"
E[11]="Please input Argo Token or Json:"
C[11]="请输入 Argo Token 或者 Json:"
E[12]="Please input Xray UUID \(Default is \$UUID_DEFAULT\):"
C[12]="请输入 Xray UUID \(默认为 \$UUID_DEFAULT\):"
E[13]="Please input Xray WS Path \(Default is \$WS_PATH_DEFAULT\):"
C[13]="请输入 Xray WS 路径 \(默认为 \$WS_PATH_DEFAULT\):"
E[14]="Xray WS Path only allow uppercase and lowercase letters and numeric characters, please re-enter \(\${a} times remaining\):"
C[14]="Xray WS 路径只允许英文大小写及数字字符，请重新输入 \(剩余\${a}次\):"
E[15]="ArgoX script is installed."
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
E[27]="Close"
C[27]="关闭"
E[28]="Open"
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
E[37]="Succeed"
C[37]="成功"
E[38]="fail"
C[38]="失败"
E[39]=""
C[39]=""


# 自定义字体彩色，read 函数，友道翻译函数
warning() { echo -e "\033[31m\033[01m$*\033[0m"; }  # 红色
error() { echo -e "\033[31m\033[01m$*\033[0m" && exit 1; } # 红色
info() { echo -e "\033[32m\033[01m$*\033[0m"; }   # 绿色
hint() { echo -e "\033[33m\033[01m$*\033[0m"; }   # 黄色
reading() { read -rp "$(info "$1")" "$2"; } 
text() { eval echo "\${${L}[$*]}"; }
text_eval() { eval echo "\$(eval echo "\${${L}[$*]}")"; }
translate() { [ -n "$1" ] && curl -ksm8 "http://fanyi.youdao.com/translate?&doctype=json&type=AUTO&i=$1" | cut -d \" -f18 2>/dev/null; }

# 脚本当天及累计运行次数统计
statistics_of_run-times() {
  :
}

# 选择中英语言
select_language() {
  case $(cat $WORKDIR/language 2>&1) in
    E ) L=E ;;
    C ) L=C ;;
    * ) [ -z "$L" ] && L=E && hint " $(text 0) " && reading " $(text 24) " LANGUAGE
    [ "$LANGUAGE" = 2 ] && L=C ;;
  esac
}

# 查安装及运行状态，下标0: argo，下标1: xray，下标2：docker；状态码: 26 未安装， 27 已安装未运行， 28 运行中
check_install() {
  # 判断处理器架构
  case $(uname -m) in
    aarch64 ) ARCHITECTURE=arm64 ;;
    x86_64 ) ARCHITECTURE=amd64 ;;
 #   s390x ) ARCHITECTURE=s390x ;;
    * ) error " $(text_eval 25) " ;;
  esac

  STATUS[0]=$(text 26) && [ -e /etc/systemd/system/argo.service ] && STATUS[0]=$(text 27) && [ $(systemctl is-active argo) = 'active' ] && STATUS[0]=$(text 28)
  STATUS[1]=$(text 26) && [ -e /etc/systemd/system/xray.service ] && STATUS[1]=$(text 27) && [ $(systemctl is-active xray) = 'active' ] && STATUS[1]=$(text 28)
  [[ ${STATUS[0]} = "$(text 26)" ]] && [ ! -e $WORKDIR/cloudflared ] && { wget -qO $TEMPDIR/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$ARCHITECTURE && chmod +x $TEMPDIR/cloudflared && rm -f $TEMPDIR/cloudflared*.zip; }&
  [[ ${STATUS[1]} = "$(text 26)" ]] && [ ! -e $WORKDIR/xray ] && { wget -qNP $TEMPDIR https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-${ARCHITECTURE//amd/}.zip; unzip -qo $TEMPDIR/Xray-linux-${ARCHITECTURE//amd/}.zip xray *.dat -d /tmp; rm -f $TEMPDIR/Xray*.zip; }&
}

check_system_info() {
  # 检测 IPv4 IPv6 信息，WARP Ineterface 开启，普通还是 Plus账户 和 IP 信息
  IP4=$(curl -ks4m5 -A Mozilla $IP_API)
  WAN4=$(expr "$IP4" : '.*ip\":[ ]*\"\([^"]*\).*')
  COUNTRY4=$(expr "$IP4" : '.*country\":[ ]*\"\([^"]*\).*')
  ASNORG4=$(expr "$IP4" : '.*'$ISP'\":[ ]*\"\([^"]*\).*')

  IP6=$(curl -ks6m5 -A Mozilla $IP_API)
  WAN6=$(expr "$IP6" : '.*ip\":[ ]*\"\([^"]*\).*')
  COUNTRY6=$(expr "$IP6" : '.*country\":[ ]*\"\([^"]*\).*')
  ASNORG6=$(expr "$IP6" : '.*'$ISP'\":[ ]*\"\([^"]*\).*')

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

  # 自定义 Alpine 系统若干函数
  alpine_argox_restart() { \1; }
  alpine_argox_enable() { echo -e "/usr/bin/tun.sh\nwg-quick up wgcf" > /etc/local.d/wgcf.start; chmod +x /etc/local.d/wgcf.start; rc-update add local; }

  REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "amazon linux" "alpine" "arch linux")
  RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Alpine" "Arch")
  EXCLUDE=("bookworm")
  MAJOR=("9" "16" "7" "7" "3" "")
  PACKAGE_UPDATE=("apt -y update" "apt -y update" "yum -y update" "yum -y update" "apk update -f" "pacman -Sy")
  PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "yum -y install" "apk add -f" "pacman -S --noconfirm")
  PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove" "yum -y autoremove" "apk del -f" "pacman -Rcnsu --noconfirm")
  SYSTEMCTL_ARGO_START=("systemctl start argo" "systemctl start argo" "systemctl start argo" "systemctl start argo" "wg-quick up wgcf" "systemctl start argo")
  SYSTEMCTL_ARGO_DISABLE=("systemctl disable --now argo" "systemctl disable --now argo" "systemctl disable --now argo" "systemctl disable --now argo" "alpine_argox_disable --now" "systemctl disable --now argo")
  SYSTEMCTL_ARGO_ENABLE=("systemctl enable --now argo" "systemctl enable --now argo" "systemctl enable --now argo" "systemctl enable --now argo" "alpine_argox_enable" "systemctl enable --now argo")
  SYSTEMCTL_XRAY_START=("systemctl start xray" "systemctl start xray" "systemctl start xray" "systemctl start xray" "wg-quick up wgcf" "systemctl start xray")
  SYSTEMCTL_XRAY_DISABLE=("systemctl disable --now xray" "systemctl disable --now xray" "systemctl disable --now xray" "systemctl disable --now xray" "alpine_xrayx_disable --now" "systemctl disable --now xray")
  SYSTEMCTL_XRAY_ENABLE=("systemctl enable --now xray" "systemctl enable --now xray" "systemctl enable --now xray" "systemctl enable --now xray" "alpine_xrayx_enable" "systemctl enable --now xray")

  for ((int=0; int<${#REGEX[@]}; int++)); do
    [[ $(tr 'A-Z' 'a-z' <<< "$SYS") =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && [ -n "$SYSTEM" ] && break
  done
  [ -z "$SYSTEM" ] && error " $(text 5) "

  # 先排除 EXCLUDE 里包括的特定系统，其他系统需要作大发行版本的比较
  for ex in "${EXCLUDE[@]}"; do [[ ! $(tr 'A-Z' 'a-z' <<< "$SYS")  =~ $ex ]]; done &&
  [[ "$(echo "$SYS" | sed "s/[^0-9.]//g" | cut -d. -f1)" -lt "${MAJOR[int]}" ]] && error " $(text_eval 6) "
}

# 定义各变量
custom_variable() {
  [ -z "$ARGO_DOMAIN" ] && reading "\n $(text 10) " ARGO_DOMAIN

  if [[ -n "$ARGO_DOMAIN" && -z "$ARGO_AUTH" ]]; then
    reading "\n $(text 11) " ARGO_AUTH
    [[ $ARGO_AUTH =~ TunnelSecret ]] && ARGO_JSON=$ARGO_AUTH
    [[ $ARGO_AUTH =~ ^[A-Z0-9a-z]{120,250}$ ]] && ARGO_TOKEN=$ARGO_AUTH
  fi

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
  # 对于 alpine 系统，升级库并重新安装依赖
  if [ "$SYSTEM" = Alpine ]; then
    ${PACKAGE_UPDATE[int]}; ${PACKAGE_INSTALL[int]} curl wget grep
  else
    DEPS_CHECK=("ping" "wget" "systemctl" "ip")
    DEPS_INSTALL=(" iputils-ping" " wget" " systemctl" " iproute2")
    for ((g=0; g<${#DEPS_CHECK[@]}; g++)); do [ ! $(type -p ${DEPS_CHECK[g]}) ] && DEPS+=${DEPS_INSTALL[g]}; done
    if [ -n "$DEPS" ]; then
      info "\n $(text 7) $DEPS \n"
      ${PACKAGE_UPDATE[int]} >/dev/null 2>&1
      ${PACKAGE_INSTALL[int]} $DEPS >/dev/null 2>&1
    else
      info "\n $(text 8) \n"
    fi
  fi
}

install_argox() {
  custom_variable
  wait
  mkdir -p $WORKDIR && echo "$L" > $WORKDIR/language
  # Argo    生成守护进程文件
  local APP='Argo' && info "\n $(text_eval 9) "
  [ ! -e $WORKDIR/cloudflared ] && { mv $TEMPDIR/cloudflared $WORKDIR; }
  if [[ -n "${ARGO_JSON}" && -n "${ARGO_DOMAIN}" ]]; then
    ARGO_RUNS="$WORKDIR/cloudflared tunnel --no-autoupdate --config $WORKDIR/tunnel.yml --url http://localhost:8080 run"
    [ ! -e $WORKDIR/tunnel.json ] && echo $ARGO_JSON > $WORKDIR/tunnel.json
    [ ! -e $WORKDIR/tunnel.yml ] && echo -e "tunnel: $(cut -d\" -f12 <<< $ARGO_JSON)\ncredentials-file: $WORKDIR/tunnel.json" > $WORKDIR/tunnel.yml
  elif [[ -n "${ARGO_TOKEN}" && -n "${ARGO_DOMAIN}" ]]; then
    ARGO_RUNS="$WORKDIR/cloudflared tunnel --no-autoupdate run --token ${ARGO_TOKEN}"
  else
    ARGO_RUNS="$WORKDIR/cloudflared tunnel --no-autoupdate --url http://localhost:8080"
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
  local APP='Xray' && info "\n $(text_eval 9) "
  [ ! -e $WORKDIR/xray ] && { mv $TEMPDIR/{xray,geo*.dat} $WORKDIR; }
  cat > $WORKDIR/config.json << EOF
{
    "log":{
        "access":"/dev/null",
        "error":"/dev/null",
        "loglevel":"none"
    },
    "inbounds":[
        {
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
                        "path":"/${WS_PATH}-vless",
                        "dest":3002
                    },
                    {
                        "path":"/${WS_PATH}-vmess",
                        "dest":3003
                    },
                    {
                        "path":"/${WS_PATH}-trojan",
                        "dest":3004
                    },
                    {
                        "path":"/${WS_PATH}-shadowsocks",
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
                    "path":"/${WS_PATH}-vless"
                }
            },
            "sniffing":{
                "enabled":true,
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
                    "path":"/${WS_PATH}-vmess"
                }
            },
            "sniffing":{
                "enabled":true,
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
                    "path":"/${WS_PATH}-trojan"
                }
            },
            "sniffing":{
                "enabled":true,
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
                    "path":"/${WS_PATH}-shadowsocks"
                }
            },
            "sniffing":{
                "enabled":true,
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
ExecStart=$WORKDIR/xray run -c $WORKDIR/config.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOF

}

run() {
  check_install
  [[ ${STATUS[0]} = "$(text 27)" ]] && ${SYSTEMCTL_ARGO_ENABLE[int]}
  [[ ${STATUS[1]} = "$(text 27)" ]] && ${SYSTEMCTL_XRAY_ENABLE[int]}

  if grep -q "^ExecStart.*8080$" /etc/systemd/system/argo.service; then
    sleep 5 && ARGO_DOMAIN=$(journalctl -u argo | grep -o "https://.*trycloudflare.com" | tail -n 1)
  else
    ARGO_DOMAIN=${ARGO_DOMAIN:-"$(grep '^vless' $WORKDIR/list | head -n 1 | sed "s@.*host=\(.*\)&.*@\1@g")"}
  fi
  UUID=${UUID:-"$(grep 'password' $WORKDIR/config.json | awk -F \" 'NR==1{print $4}')"}
  WS_PATH=${WS_PATH:-"$(grep 'path.*vmess' $WORKDIR/config.json | head -n 1 | sed "s@.*/\(.*\)-vmess.*@\1@g")"} 

  # 生成配置文件
  VMESS="{ \"v\": \"2\", \"ps\": \"Argo-Vmess\", \"add\": \"icook.hk\", \"port\": \"443\", \"id\": \"${UUID}\", \"aid\": \"0\", \"scy\": \"none\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"${ARGO_DOMAIN}\", \"path\": \"/${WS_PATH}-vmess\", \"tls\": \"tls\", \"sni\": \"${ARGO_DOMAIN}\", \"alpn\": \"\" }"
  cat > $WORKDIR/list << EOF
*******************************************
V2-rayN:
----------------------------
vless://${UUID}@icook.hk:443?encryption=none&security=tls&sni=${ARGO_DOMAIN}&type=ws&host=${ARGO_DOMAIN}&path=%2F${WS_PATH}-vless#Argo-Vless
----------------------------
vmess://$(base64 -w0 <<< $VMESS)
----------------------------
trojan://${UUID}@icook.hk:443?security=tls&sni=${ARGO_DOMAIN}&type=ws&host=${ARGO_DOMAIN}&path=%2F${WS_PATH}-trojan#Argo-Trojan
----------------------------
ss://$(echo "chacha20-ietf-poly1305:${UUID}@icook.hk:443" | base64 -w0)@icook.hk:443#Argo-Shadowsocks
由于该软件导出的链接不全，请自行处理如下: 传输协议: WS ， 伪装域名: ${ARGO_DOMAIN} ，路径: /${WS_PATH}-shadowsocks ， 传输层安全: tls ， sni: ${ARGO_DOMAIN}
*******************************************
小火箭 Shadowrocket:
----------------------------
vless://${UUID}@icook.hk:443?encryption=none&security=tls&type=ws&host=${ARGO_DOMAIN}&path=/${WS_PATH}-vless&sni=${ARGO_DOMAIN}#Argo-Vless
----------------------------
vmess://$(echo "none:${UUID}@icook.hk:443" | base64 -w0)?remarks=Argo-Vmess&obfsParam=${ARGO_DOMAIN}&path=/${WS_PATH}-vmess&obfs=websocket&tls=1&peer=${ARGO_DOMAIN}&alterId=0
----------------------------
trojan://${UUID}@icook.hk:443?peer=${ARGO_DOMAIN}&plugin=obfs-local;obfs=websocket;obfs-host=${ARGO_DOMAIN};obfs-uri=/${WS_PATH}-trojan#Argo-Trojan
----------------------------
ss://$(echo "chacha20-ietf-poly1305:${UUID}@icook.hk:443" | base64 -w0)?obfs=wss&obfsParam=${ARGO_DOMAIN}&path=/${WS_PATH}-shadowsocks#Argo-Shadowsocks
*******************************************
Clash:
----------------------------
- {name: Argo-Vless, type: vless, server: icook.hk, port: 443, uuid: ${UUID}, tls: true, servername: ${ARGO_DOMAIN}, skip-cert-verify: false, network: ws, ws-opts: {path: /${WS_PATH}-vless, headers: { Host: ${ARGO_DOMAIN}}}, udp: true}
----------------------------
- {name: Argo-Vmess, type: vmess, server: icook.hk, port: 443, uuid: ${UUID}, alterId: 0, cipher: none, tls: true, skip-cert-verify: true, network: ws, ws-opts: {path: /${WS_PATH}-vmess, headers: {Host: ${ARGO_DOMAIN}}}, udp: true}
----------------------------
- {name: Argo-Trojan, type: trojan, server: icook.hk, port: 443, password: ${UUID}, udp: true, tls: true, sni: ${ARGO_DOMAIN}, skip-cert-verify: false, network: ws, ws-opts: { path: /${WS_PATH}-trojan, headers: { Host: ${ARGO_DOMAIN} } } }
----------------------------
- {name: Argo-Shadowsocks, type: ss, server: icook.hk, port: 443, cipher: chacha20-ietf-poly1305, password: ${UUID}, plugin: v2ray-plugin, plugin-opts: { mode: websocket, host: ${ARGO_DOMAIN}, path: /${WS_PATH}-shadowsocks, tls: true, skip-cert-verify: false, mux: false } }
*******************************************
EOF
  cat $WORKDIR/list
}

uninstall() {
  if [ -d $WORKDIR ]; then
    systemctl disable --now {argo,xray} 2>/dev/null
    rm -f /etc/systemd/system/{xray,argo}.service
    rm -rf $WORKDIR
    rm -f $TEMPDIR/{cloudflared*,Xray*.zip,xray,geo*.dat}
    info "\n $(text 16) \n"
  else
    error "\n $(text 15) \n"
  fi
  exit 0
}

# 判断当前 Argo-X 的运行状态，并对应的给菜单和动作赋值
menu_setting() {
  if [[ ${STATUS[*]} =~ $(text 27)|$(text 28) ]]; then
    [ -e $WORKDIR/cloudflared ] && ARGO_VERSION=$($WORKDIR/cloudflared -v | sed "s@cloudflared version @@")
    [ -e $WORKDIR/xray ] && XRAY_VERSION=$($WORKDIR/xray version | head -n 1 | sed "s@Xray @@g")
    MAX_CHOOSE=7
    OPTION1="1.  $(text 29)"
    [ ${STATUS[0]} = "$(text 28)" ] && OPTION2="2.  $(text 27) Argo" || OPTION2="2.  $(text 28) Argo"
    [ ${STATUS[1]} = "$(text 28)" ] && OPTION3="3.  $(text 27) Xray" || OPTION3="3.  $(text 28) Xray"
    OPTION4="4.  $(text 30)"
    OPTION5="5.  $(text 31)"
    OPTION6="6.  $(text 32)"
    OPTION7="7.  $(text 33)"

    ACTION1() { run; }
    [[ ${STATUS[0]} = "$(text 28)" ]] && ACTION2() { ${SYSTEMCTL_ARGO_DISABLE[int]}; [ $(systemctl is-active argo) = 'inactive' ] && info " $(text 27) argo $(text 37)" || error " $(text27) argo $(text 38) "; } || ACTION2() { ${SYSTEMCTL_ARGO_ENABLE[int]} && [ $(systemctl is-active argo) = 'active' ] && info " $(text 28) argo $(text 37)" || error " $(text28) argo $(text 38) "; }
    [[ ${STATUS[1]} = "$(text 28)" ]] && ACTION3() { ${SYSTEMCTL_XRAY_DISABLE[int]}; [ $(systemctl is-active xray) = 'inactive' ] && info " $(text 27) xray $(text 37)" || error " $(text27) xray $(text 38) "; } || ACTION3() { ${SYSTEMCTL_XRAY_ENABLE[int]} && [ $(systemctl is-active xray) = 'active' ] && info " $(text 28) xray $(text 37)" || error " $(text28) xray $(text 38) "; }
    ACTION4() { exit 0; }
    ACTION5() { exit 0; }
    ACTION6() { bash <(wget -qO- --no-check-certificate "https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh"); }
    ACTION7() { uninstall; }

  else
    MAX_CHOOSE=2
    OPTION1="1.  $(text 34)"
    OPTION2="2.  $(text 32)"

    ACTION1() { install_argox; run; }
    ACTION2() { bash <(wget -qO- --no-check-certificate "https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh"); }
  fi

  OPTION0="0. $(text 35)"
  ACTION0() { exit; }
}

menu() {
  clear
  hint " $(text 2) "
  echo -e "======================================================================================================================\n"
  info " $(text 17):$VERSION\n $(text 18):$(text 1)\n $(text 19):\n\t $(text 20):$SYS\n\t $(text 21):$(uname -r)\n\t $(text 22):$ARCHITECTURE\n\t $(text 23):$VIRT "
  info "\t IPv4: $WAN4 $WARPSTATUS4 $COUNTRY4  $ASNORG4 "
  info "\t IPv6: $WAN6 $WARPSTATUS6 $COUNTRY6  $ASNORG6 "
  info "\t Argo: ${STATUS[0]}\t Version: $ARGO_VERSION\n\t Xray: ${STATUS[1]}\t Version: $XRAY_VERSION"
  echo -e "\n======================================================================================================================\n"
  for ((b=1;b<=$MAX_CHOOSE;b++)); do hint " $(eval echo \$OPTION$b) "; done
  hint " $OPTION0 "
  reading "\n $(text 24) " CHOOSE

  # 输入必须是数字且少于等于最大可选项
  if grep -qE "^[0-9]$" <<< "$CHOOSE" && [ "$CHOOSE" -le "$MAX_CHOOSE" ]; then
    ACTION$CHOOSE
  else
    warning " $(text 36) [0-$MAX_CHOOSE] " && sleep 1 && menu
  fi
}

# 传参
[[ "$*" =~ -[Ee] ]] && L=E
[[ "$*" =~ -[Cc] ]] && L=C

while getopts ":UuLlD:d:A:a:I:i:W:w:" OPTNAME; do
  case "$OPTNAME" in
    'U'|'u' ) select_language; uninstall ;;
    'L'|'l' ) select_language; run; exit 0;;
    'D'|'d' ) ARGO_DOMAIN=$OPTARG ;;
    'A'|'a' ) ARGO_AUTH=$OPTARG ;;
    'I'|'i' ) UUID=$OPTARG ;;
    'W'|'w' ) WS_PATH=$OPTARG ;;
  esac
done

statistics_of_run-times
select_language
check_install
check_system_info
check_dependencies
menu_setting
menu