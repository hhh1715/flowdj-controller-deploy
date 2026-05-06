#!/usr/bin/env bash
# FlowDJ Hardware Controller — Ubuntu launcher
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/app"

# 檢查 Node.js
if ! command -v node &> /dev/null; then
    echo "✗ 找不到 Node.js"
    echo ""
    echo "請先安裝（複製貼上整段執行）："
    echo "  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -"
    echo "  sudo apt install -y nodejs"
    echo ""
    read -rp "按 Enter 關閉..."
    exit 1
fi

cat <<'EOF'
============================================
  FlowDJ Hardware Controller
============================================

正在 http://localhost:3000 啟動本地伺服器...
（第一次執行需下載 serve 工具，約 30 秒）

啟動成功後會自動開瀏覽器
結束使用：在這個終端機按 Ctrl+C

EOF

# 開瀏覽器（優先用支援 Web MIDI 的瀏覽器）
if command -v google-chrome &> /dev/null; then
    google-chrome http://localhost:3000 &
elif command -v chromium &> /dev/null; then
    chromium http://localhost:3000 &
elif command -v chromium-browser &> /dev/null; then
    chromium-browser http://localhost:3000 &
elif command -v xdg-open &> /dev/null; then
    # 系統預設瀏覽器（要確認不是 Firefox）
    xdg-open http://localhost:3000 &
else
    echo "⚠️ 沒抓到 Chrome / Chromium，請手動打開：http://localhost:3000"
fi

# npx --yes 自動同意安裝 serve；-p 3000 指定 port
exec npx --yes serve -p 3000 .
