# FlowDJ Hardware Controller — Ubuntu 設置手冊

把硬體 DJ 控制器接上電腦、燒韌體、開瀏覽器混音。

> 🎨 Web App 原作者：[@guiguiiii](https://github.com/guiguiiii)（[原始碼](https://github.com/guiguiiii/flowdj---pro-mixing-interface)）
> 🔌 硬體整合（Teensy + MPR121 韌體 + Web MIDI 串接）：[@hhh1715](https://github.com/hhh1715)
> 📦 此 repo 為部署用整合版（含預先 build 的靜態頁面、韌體、設置手冊）。

---

## 你需要什麼

| 項目 | 說明 |
|---|---|
| 💻 電腦 | **Ubuntu 22.04 LTS 或更新版**（24.04 已測試 OK） |
| 🌐 瀏覽器 | **Google Chrome** 或 **Chromium**（Firefox 預設不支援 Web MIDI） |
| 🎛 硬體 | FlowDJ DJ Controller（已組裝好，含 USB 線） |
| 🔌 USB 埠 | 一個空的 USB 埠 |
| 📦 一些下載 | 約 200 MB（Node.js + Arduino IDE + Teensyduino） |

---

## 一次性安裝（約 15 分鐘）

> 💡 **以下這節只要做一次。下次使用直接看「日常使用」即可。**
>
> 終端機指令前的 `$` 是提示符，不用打進去。打開終端機的快捷鍵：`Ctrl + Alt + T`。

### Step 1 — 安裝 Node.js（給網頁用）

複製貼上整段執行：

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
node --version
```

最後一行印出 `v20.x.x` 就成功。

### Step 2 — 安裝 Chrome（給 Web MIDI 用）

選一個就好（推薦 Chrome）：

#### 選項 A：Google Chrome
```bash
wget -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y /tmp/chrome.deb
```

#### 選項 B：Chromium（Snap 套件）
```bash
sudo snap install chromium
```

### Step 3 — 安裝 Arduino IDE

到 https://www.arduino.cc/en/software 下載 **Linux AppImage 64 bit**，放到家目錄（`~/`）。

```bash
cd ~
chmod +x arduino-ide_*.AppImage
./arduino-ide_*.AppImage
```

第一次開啟可能彈警告，按允許。確認可以開後先關掉，繼續下一步。

> 想要每次都從應用程式選單開啟？把 AppImage 拖到 `~/Applications/` 並安裝 [AppImageLauncher](https://github.com/TheAssassin/AppImageLauncher)（可選）。

### Step 4 — 安裝 Teensy udev 規則（**Linux 必做**）

Linux 預設不允許一般使用者直接寫入 USB 裝置。下載 PJRC 提供的規則檔解決這個：

```bash
sudo wget -O /etc/udev/rules.d/00-teensy.rules https://www.pjrc.com/teensy/00-teensy.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

### Step 5 — 在 Arduino IDE 安裝 Teensyduino + MPR121 library

打開 Arduino IDE：

#### 5-1. 加入 Teensy boards manager URL
- **File → Preferences**
- 找到「**Additional boards manager URLs**」這欄
- 貼上：
  ```
  https://www.pjrc.com/teensy/package_teensy_index.json
  ```
- 按 **OK**

#### 5-2. 安裝 Teensyduino
- **Tools → Board → Boards Manager...**
- 搜尋 **Teensy** → 點 **Install**（會下載一段時間）

#### 5-3. 安裝 Adafruit MPR121 library
- **Tools → Manage Libraries...**（或左側 📚 圖示）
- 搜尋 **Adafruit MPR121** → 點 **Install**
- 跳出 dependencies 提示時選 **Install all**

### Step 6 — 燒韌體到 Teensy

1. **接 USB**：把硬體控制器接到電腦
2. **開啟韌體**：Arduino IDE → **File → Open** → 找到本資料夾的：
   ```
   firmware/05_full_integration.ino
   ```
3. **設定 Board**：
   - **Tools → Board → Teensyduino → Teensy 4.0**
   - **Tools → USB Type → Serial + MIDI**（**重要：必選這個，瀏覽器才抓得到 MIDI**）
   - **Tools → Port** → 顯示 `Teensy` 的那個（通常是 `/dev/ttyACM0`）
4. **按上方箭頭 → Upload**（或 `Ctrl+U`）
5. 訊息列出現 `Done uploading.` + Teensy 上 LED 閃 → 成功

> ⚠️ 上傳卡住或 Port 抓不到 → 按 Teensy 板上的小白按鈕強制 bootloader，再 Upload。

---

## 日常使用

### 第一次：給啟動腳本執行權限（只做一次）

```bash
cd <flowdj-controller-deploy 資料夾>
chmod +x start.sh
```

### 之後：每次用就執行

```bash
./start.sh
```

腳本會：
1. 檢查 Node.js 是否安裝
2. 在 `http://localhost:3000` 啟動本地伺服器
3. 自動用 Chrome / Chromium 打開頁面

> 不喜歡終端機？也可以在檔案管理員按右鍵 → 屬性 → 權限勾「Execute」，然後雙擊 `start.sh` → 「在終端機中執行」。

### 第一次開啟瀏覽器時

1. 跳「**允許 MIDI 裝置存取**」→ 按 **允許**
2. 右下角 MIDI Monitor 顯示 ● `ready`（綠）
3. 摸 jog 或按按鈕，看右下事件流是否會更新

### 玩起來

| 硬體 | 對應 |
|---|---|
| **CUE** 鈕 | 設 cue 點 / recall cue |
| **Play** 鈕 | 播放 / 暫停 |
| **SYNC** 鈕 | 同步另一台 deck 的 BPM |
| **PAD 1–4** | hot cue / sample / pad FX（看你切到哪個 mode） |
| **Jog Wheel** | 觸摸 + 旋轉 = scratch（順時針=前進、逆時針=倒退） |
| **速度 slider** | tempo 微調 |
| **音量 fader** | 該 deck 的音量 |
| 右下「**HW A / B**」鈕 | 點一下切換硬體控制 Deck A 還是 Deck B |
| 右下「**MIDI**」鈕 | 展開 MIDI 事件監看 |

---

## 故障排除

### 🔴 `./start.sh: command not found: node`
Node.js 沒裝好。重做 [Step 1](#step-1--安裝-nodejs給網頁用)，輸入 `node --version` 確認。

### 🔴 `./start.sh: Permission denied`
還沒加上執行權限：
```bash
chmod +x start.sh
```

### 🔴 瀏覽器打開但 MIDI Monitor 顯示紅色 `unsupported`
你開的是 Firefox（預設不支援 Web MIDI）。改用 Chrome 或 Chromium 打開 `http://localhost:3000`。

### 🔴 Arduino IDE 找不到 Port / 上傳印 `Permission denied: /dev/ttyACM0`
udev 規則沒裝好或沒重載。確認檔案存在：
```bash
ls -l /etc/udev/rules.d/00-teensy.rules
```
如果不存在，重做 [Step 4](#step-4--安裝-teensy-udev-規則linux-必做)。如果存在但還是不行，重啟電腦。

### 🔴 Arduino IDE 找不到 Teensy 板
- Tools → Board 列表沒有 Teensy → Teensyduino 沒裝好，重做 [Step 5-2](#5-2-安裝-teensyduino)
- 用 `lsusb` 看有沒有 `Teensy` 字眼

### 🔴 MIDI Monitor 是綠色 `ready` 但摸硬體沒反應
1. USB 拔掉重接
2. F5 重整網頁
3. 仍無效 → Teensy 韌體可能沒燒成功，重做 [Step 6](#step-6--燒韌體到-teensy)，留意 USB Type 的選擇

### 🔴 沒聲音
- 檢查系統音量、瀏覽器分頁是否靜音（網址列右邊 🔇 圖示）
- 用 `pavucontrol` 確認輸出裝置正確（沒裝 → `sudo apt install pavucontrol`）
- 確認有把曲目從左下角的曲庫拖到 deck 上

更詳細的問題見 [`docs/troubleshooting.md`](docs/troubleshooting.md)。

---

## 目錄結構

```
flowdj-controller-deploy/
├── README.md                ← 你正在看的這份
├── start.sh                 ← 執行啟動
├── app/                     ← 預先 build 好的 Web App（不需要改）
├── firmware/
│   ├── 05_full_integration.ino   ← 用 Arduino IDE 開這個燒
│   └── README.md            ← 韌體相關 notes
├── hardware/
│   ├── wiring.md            ← 硬體規格、接線圖（除錯參考）
│   └── midi-protocol.md     ← MIDI 訊息對照表（除錯參考）
└── docs/
    └── troubleshooting.md   ← 詳細疑難排解
```

---

## 技術規格速覽

- **韌體**：Teensy 4.0 + 3 顆 MPR121（I²C 0x5A / 0x5B / 0x5C），USB MIDI Class
- **Web App**：React 19 + Vite 6（已預先 build，無需 dev server）
- **MIDI 協議**：見 `hardware/midi-protocol.md`
