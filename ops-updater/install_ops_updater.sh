#!/bin/bash
set -e

# ==================== 配置区 ====================
DOWNLOAD_BASE="http://192.168.170.249/download/readonly"
BINARY_NAME="ops_updater"
INSTALL_DIR="/opt/ops_agent"
SERVICE_NAME="ops_updater"
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
    x86_64)  ARCH_NAME="x86_64";  REMOTE_FILE="ops_updater_linux_amd64" ;;
    aarch64) ARCH_NAME="aarch64"; REMOTE_FILE="ops_updater_linux_arm64" ;;
    *)       echo "不支持的架构: ${ARCH}"; exit 1 ;;
esac
echo "  架构: ${ARCH} -> ${REMOTE_FILE}"

echo "  下载二进制文件..."
curl -fSL "${DOWNLOAD_BASE}/${REMOTE_FILE}" -o "${INSTALL_DIR}/${BINARY_NAME}"

echo "  写入配置文件 cfg.json..."
cat > "${INSTALL_DIR}/cfg.json" << 'EOF'
{
    "debug": true,
    "hostname": "",
    "desiredAgent": "",
    "server": "127.0.0.1:2000",
    "interval": 60,
    "http": {
        "enabled": false,
        "listen": "0.0.0.0:2001"
    }
}
EOF

echo "  创建空密码文件 password..."
touch "${INSTALL_DIR}/password"

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
