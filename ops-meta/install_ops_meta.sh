#!/bin/bash
set -e

# ==================== 配置区 ====================
DOWNLOAD_BASE="http://192.168.170.249/download/readonly"
BINARY_NAME="ops_meta"
INSTALL_DIR="/opt/ops_meta"
SERVICE_NAME="ops_meta"
# ================================================

echo "[1/6] 清理旧环境..."
if systemctl is-active --quiet ${SERVICE_NAME} 2>/dev/null; then
    echo "  停止运行中的服务..."
    systemctl stop ${SERVICE_NAME}
fi
if [ -d "${INSTALL_DIR}" ]; then
    echo "  清空安装目录: ${INSTALL_DIR}"
    rm -rf "${INSTALL_DIR}"
fi

echo "[2/6] 创建安装目录: ${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"

echo "[3/6] 检测系统架构..."
ARCH=$(uname -m)
case ${ARCH} in
    x86_64)  ARCH_NAME="x86_64";  REMOTE_FILE="ops_meta_linux_amd64" ;;
    aarch64) ARCH_NAME="aarch64"; REMOTE_FILE="ops_meta_linux_arm64" ;;
    *)       echo "不支持的架构: ${ARCH}"; exit 1 ;;
esac
echo "  架构: ${ARCH} -> ${REMOTE_FILE}"

echo "  下载二进制文件..."
curl -fSL "${DOWNLOAD_BASE}/${REMOTE_FILE}" -o "${INSTALL_DIR}/${BINARY_NAME}"

echo "  写入配置文件 cfg.json..."
cat > "${INSTALL_DIR}/cfg.json" << 'EOF'
{
    "debug": true,
    "tarballDir": "./tarball",
    "http": {
        "enabled": true,
        "listen": "0.0.0.0:2000"
    },
    "agents": [
        {
            "default": {
                "name": "dev_report",
                "version": "1.0.0",
                "tarball": "http://192.168.170.249/download/readonly",
                "md5": "http://192.168.170.249/download/readonly",
                "cmd": "stop"
            },
            "others": [
                {
                    "groups": ["localhost"],
                    "version": "1.0.1",
                    "tarball": "",
                    "md5": "",
                    "cmd": ""
                }
            ]
        }
    ]
}
EOF


echo "  写入证书文件 cert.pem..."
cat > "${INSTALL_DIR}/cert.pem" << 'EOF'
-----BEGIN CERTIFICATE-----
MIIDfDCCAmSgAwIBAgIUZ4vOC0817LDIDqlDOw5pINpo8lIwDQYJKoZIhvcNAQEL
BQAwRTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoM
GEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDAeFw0yNjA2MzAwNjU1MDJaFw0zNjA2
MjcwNjU1MDJaMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEw
HwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQCtB0zZiWWRLLIfHcZ6kRo9vLFAZL0a9LsOY3ceMyvr
m6SuYKI77+WA88H4coACcpi5xsPcrxGiJW2hrdb8KXnPHFInoJ4loSDRpptS4lA7
ZR5VLVbJXj0+pJsO46bXZo9rx3WrSJBRtkzhMEvJ9D150Kh+Hulj8l0lqK+0AHE3
YaWyb3FV9NMZ8z5iAwxO4601IZIuu6t1mcz2IbUzGzRrk8z9OhCzOKp29Kp2PjwI
83XPPuQwgZvz5Q2PAY/RGqpHziO03nLzLBc4x5vp11ddoqtaZF+ytDSReubFLbnl
zjvzAw/W02wL4hICat71mCiQMoe2sRx8Z8JonwUNasUvAgMBAAGjZDBiMB0GA1Ud
DgQWBBRlozjfKAQtF7YLYbEHA6TcLRYFNzAfBgNVHSMEGDAWgBRlozjfKAQtF7YL
YbEHA6TcLRYFNzAPBgNVHRMBAf8EBTADAQH/MA8GA1UdEQQIMAaHBMCoqvwwDQYJ
KoZIhvcNAQELBQADggEBAIDMmT7AEe1IrqOQ3l0FzZWD4Pn8gl2YBSiZZTEkkf2j
7S0FWplPi/gB8V79S83jEe5it/dG5MNtVJjpYilhREIeaXq0tRSzm2LzPVA4V0Zk
GWbHE0L6dFDq9yV1tkBQCmVZdpSdPnwlr4C9S7TT+4PmHTwigBS9+Io6KpWNk4NC
VXA6k2xbBOlqaDLQvuBrdvXP8df23RqK+lD6CnDEOzOv4ck/VwzWKQjctrJo0Mg+
NepMUkv42aX4jkrt0fxNROXDmHicr/KNr2uT7ond6U6jbWxSXp7hUBSuRjiSWaX3
w5VVvsuGuHYswk6EAeb7iXfsA6yWPRTGRwOq4i30BqU=
-----END CERTIFICATE-----
EOF

echo "  写入证书文件 key.pem..."
cat > "${INSTALL_DIR}/key.pem" << 'EOF'
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCtB0zZiWWRLLIf
HcZ6kRo9vLFAZL0a9LsOY3ceMyvrm6SuYKI77+WA88H4coACcpi5xsPcrxGiJW2h
rdb8KXnPHFInoJ4loSDRpptS4lA7ZR5VLVbJXj0+pJsO46bXZo9rx3WrSJBRtkzh
MEvJ9D150Kh+Hulj8l0lqK+0AHE3YaWyb3FV9NMZ8z5iAwxO4601IZIuu6t1mcz2
IbUzGzRrk8z9OhCzOKp29Kp2PjwI83XPPuQwgZvz5Q2PAY/RGqpHziO03nLzLBc4
x5vp11ddoqtaZF+ytDSReubFLbnlzjvzAw/W02wL4hICat71mCiQMoe2sRx8Z8Jo
nwUNasUvAgMBAAECggEACk6lBVBp/HvtIG1lpWd/aK4U4QEfQrvRaMoEDoh91Usw
RDL9dxSTV1st8t7fQUYSUv7ELCFBq6cPINJ6PAs8dln5iuLGiPdQPSzvk8BnhyI+
7FQHF3fFrjWgBwMIrUwuvvzixZFNB5EUg1WdLiqefuMvJlQxEwMdCWFDFjXwiJvv
b0+8Mtl8SB3s70c99HtD7C6WbVDGgGOAdVkoZ4UfJyNFyUsfqMPX+qNhg3GfjvAr
n2il1grJeHNuVNYN4k0MGz2iUuyknwJBW6d3gSfLA5n87Bz1aSU2ZNaROydJqDTu
zsgDu6YchwdCzYJlMYEaALc8Ehic2DFwuK27DU/mAQKBgQDVA+9NYY1TKP2hL1iy
CgsthZ7rJMu2/TLsq31680XS5A9jnE1/HSeYJlv97ZSB5H5mlqHsnArvsK3hdxgq
J0pZHYn8C63bmhTwDFlCQSwS43jmNj/rzBRTB4sD8GexnOFst7mFnp0X+LYOQPV2
ov8iZJ0yNNKODelHcDyQnyq8TQKBgQDP8bPYPoX7o7MvN6MwlQcpKhmQOboyS64q
M/poXmwGfvb5V2v7TGT1CY5vO939QM2MGegqBsiKefngAqP5DMThaJQNZQ+SYyGe
6s2eVuEG4KejKta2pe2M8gFS+wjdTTbXYajZt5ESKgFnHXIVLoNJMtixOSs3S/vM
JI06AGrVawKBgQCUy7nWUMVaiLCabitDunZSZxs6YCqY+UcgQS5WuyZUCRCi4STV
HTVyN6FcwB9TmJue56vWTq3o/n6HlxxfHbD2jQa89B+O3ZOwlr+m40V5MEJcdRqz
iIvN79/wcXbNf6uLuM60Arbzbr0lOcT9CSC1Epkn3/QQXLFOQJ1d3IEKpQKBgHtO
akTannyfj8t6BIz0cjCYxFvfv2e/tOFVvTFSfGBFvZIRovh7Top3RjzzlSlt2fUw
D5mMODLVLbUGG9G9HqpDZzeiK9+0ZOVletRf1ERNx1pcNsJMFlcz0lEwhwsjlFeX
k5a24ZGR0w8gSNwCntszCYfdzKCXsBJXwl8YjEFNAoGBAMLErDnTs1/41rIG3NTM
sKZ0uyKm575xlZXwcJesJ3T340+V6l5HNwXCavFdUvfduTs2XUbajbbJpbCqebuj
lFICk7xMN8Rp0u85283MYZXjUEcyIHfBdRenWU26Y0gXw1J5cPZ3Q7y4aVfP6INp
xGBilUpupIHXDG7Mz8w6egIj
-----END PRIVATE KEY-----
EOF

echo "[4/6] 设置权限..."
chmod +x "${INSTALL_DIR}/${BINARY_NAME}"

echo "[5/6] 创建 systemd 服务..."
cat > /etc/systemd/system/${SERVICE_NAME}.service << EOF
[Unit]
Description=Ops Updater Service
After=network.target

[Service]
Type=simple
WorkingDirectory=${INSTALL_DIR}
ExecStart=${INSTALL_DIR}/${BINARY_NAME}
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "[6/6] 启用并启动服务..."
systemctl daemon-reload
systemctl enable ${SERVICE_NAME}
systemctl start ${SERVICE_NAME}

echo "========================================="
echo "部署完成！"
echo "  安装目录: ${INSTALL_DIR}"
echo "  服务状态: systemctl status ${SERVICE_NAME}"
echo "  查看日志: journalctl -u ${SERVICE_NAME} -f"
echo "========================================="
