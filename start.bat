@echo off
title FlowDJ Hardware Controller
echo ============================================
echo   FlowDJ Hardware Controller
echo ============================================
echo.

REM 檢查 Node.js 是否安裝
where node >nul 2>nul
if errorlevel 1 (
    echo [錯誤] 找不到 Node.js
    echo.
    echo 請先安裝 Node.js：https://nodejs.org/
    echo 安裝完後再雙擊本檔案
    echo.
    pause
    exit /b 1
)

REM 切到 app 目錄
cd /d "%~dp0app"

echo 正在 http://localhost:3000 啟動本地伺服器...
echo （第一次執行需下載 serve 工具，約 30 秒）
echo.
echo 啟動成功後會自動開瀏覽器
echo 結束使用：把這個黑視窗關掉即可
echo.

REM 用預設瀏覽器開（Chrome / Edge 都支援 Web MIDI）
start "" "http://localhost:3000"

REM npx --yes 自動同意安裝 serve；-p 3000 指定 port
npx --yes serve -p 3000 .
