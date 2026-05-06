# FlowDJ Hardware Controller — 設置手冊

把硬體 DJ 控制器接上電腦、燒韌體、開瀏覽器混音。

> 🎨 Web App 原作者：[@guiguiiii](https://github.com/guiguiiii)（[原始碼](https://github.com/guiguiiii/flowdj---pro-mixing-interface)）
> 🔌 硬體整合（Teensy + MPR121 韌體 + Web MIDI 串接）：[@hhh1715](https://github.com/hhh1715)
> 📦 此 repo 為部署用整合版（含預先 build 的靜態頁面、韌體、設置手冊）。

---

## 你需要什麼

| 項目 | 說明 |
|---|---|
| 💻 電腦 | Windows 11（Win 10 應該也可以但沒測過） |
| 🌐 瀏覽器 | **Chrome** 或 **Edge**（兩者都支援 Web MIDI）。**Firefox 不支援，請勿使用** |
| 🎛 硬體 | FlowDJ DJ Controller（已組裝好的整組設備，含 USB Type-C 線） |
| 🔌 USB 埠 | 一個空的 USB-A 或 USB-C 埠 |
| 📦 一些下載 | 約 200 MB（Node.js + Arduino IDE + Teensyduino） |

---

## 一次性安裝（約 20 分鐘）

> 💡 **以下三個步驟只要做一次。下次使用直接看「日常使用」即可。**

### Step 1 — 安裝 Node.js（給網頁用）

1. 到 https://nodejs.org/ 下載 **LTS 版**（左邊綠色按鈕）
2. 雙擊 `.msi` → 一路 Next（保持預設選項就好）
3. 安裝完打開 PowerShell 或 cmd，輸入下列指令確認：
   ```
   node --version
   ```
   有看到版本號（像 `v20.11.0`）就成功

### Step 2 — 安裝 Arduino IDE + Teensyduino（燒韌體用）

#### 2-1. Arduino IDE
1. 到 https://www.arduino.cc/en/software 下載 **Arduino IDE 2.x for Windows**
2. 雙擊 `.exe` 安裝（一路 Next）
3. 第一次開啟時 Windows 會跳許可權提示，按**允許**

#### 2-2. Teensyduino（Teensy 4.0 的擴充支援）
1. 到 https://www.pjrc.com/teensy/td_download.html
2. 在「Boards Manager Install」區塊複製這個網址：
   ```
   https://www.pjrc.com/teensy/package_teensy_index.json
   ```
3. 回到 Arduino IDE：
   - **File → Preferences**
   - 找到「**Additional boards manager URLs**」這欄
   - 把上面那個網址貼進去，按 **OK**
4. 接著：
   - **Tools → Board → Boards Manager...**
   - 搜尋 **Teensy**，點 **Install**（會下載一陣子）

#### 2-3. 安裝必要的 library
- **Tools → Manage Libraries...**（或左側 📚 圖示）
- 搜尋 **Adafruit MPR121** → 點 **Install**
- 跳出「Install dependencies?」時選 **Install all**

---

### Step 3 — 燒韌體到 Teensy

1. **接 USB**：把硬體控制器接到電腦，等 Windows 顯示「裝置就緒」。
2. **開啟韌體檔**：Arduino IDE → **File → Open** → 找到這個資料夾裡的：
   ```
   firmware\05_full_integration.ino
   ```
3. **設定 Board**：
   - **Tools → Board → Teensyduino → Teensy 4.0**
   - **Tools → USB Type → Serial + MIDI**
   - **Tools → Port** → 選那個顯示 **Teensy** 的（通常是 `COM3` 或 `COM4`）
4. **按上方箭頭 → Upload**（或快捷鍵 `Ctrl+U`）
5. 下方訊息列出現 `Done uploading.` + Teensy 上的 LED 閃一下 → 成功

> ⚠️ 如果上傳卡住、或找不到 Port，按一下 Teensy 板子上的小按鈕（強制進入 bootloader），再重新 Upload。

---

## 日常使用

### 雙擊 `start.bat`

第一次跑會自動下載 `serve` 工具（約 30 秒），之後每次都是秒開。

腳本會：
1. 在 `http://localhost:3000` 啟動本地網頁伺服器
2. 自動用預設瀏覽器打開頁面

### 第一次開啟時

1. 瀏覽器跳「**允許 MIDI 裝置存取**」→ 按 **允許**
2. 右下角應該會看到 MIDI Monitor 顯示綠色 ● `ready`
3. 摸一下 jog wheel 或按按鈕，看右下會不會出現對應事件

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
| 右下「**HW → A**」膠囊 | 點一下切換硬體控制 Deck A 還是 Deck B |
| 右下「**MIDI**」膠囊 | 展開 MIDI 事件監看 |

---

## 故障排除

### 🔴 雙擊 `start.bat` 後黑視窗一閃就關
代表 Node.js 沒裝好。重新做 [Step 1](#step-1--安裝-nodejs給網頁用)，輸入 `node --version` 確認。

### 🔴 瀏覽器打開但 MIDI Monitor 顯示紅色 `unsupported`
你正在用 Firefox。改用 Chrome 或 Edge 開 `http://localhost:3000`。

### 🔴 MIDI Monitor 是綠色 `ready` 但摸硬體沒反應
1. 把硬體 USB 拔掉重接
2. F5 重整網頁
3. 仍無效 → Teensy 韌體可能沒燒成功，重做 [Step 3](#step-3--燒韌體到-teensy)

### 🔴 Arduino IDE 找不到 Teensy 板
- Tools → Board 列表沒有 Teensy → Teensyduino 沒裝好，重做 [Step 2-2](#2-2-teensyduinoteensy-40-的擴充支援)
- Tools → Port 沒看到 Teensy → 確認 USB 線、換另一個 USB 埠試試

### 🔴 Jog wheel 反應靈敏度怪怪
- 太敏感 / 太鈍：這個是設計上選定的甜蜜點（0.018），如果真的不適應，編輯 `app/assets/index-*.js` 不可行（已 minify）。回去找原始碼版本調整。

### 🔴 沒聲音
- 檢查 Windows 音量、瀏覽器音量
- 確認有把曲目從左下角的曲庫拖到 deck 上

---

## 目錄結構

```
flowdj-controller-deploy/
├── README.md                ← 你正在看的這份
├── start.bat                ← 雙擊啟動
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
