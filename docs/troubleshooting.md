# 詳細疑難排解

按症狀分類。如果在 README 的「故障排除」區找不到答案，這裡會更詳細。

## 安裝階段

### Arduino IDE 找不到 Teensy 4.0
**確認順序**：
1. **File → Preferences → Additional boards manager URLs** 是否有 `https://www.pjrc.com/teensy/package_teensy_index.json`
2. **Tools → Board → Boards Manager...** 搜尋 Teensy，是否顯示 INSTALLED
3. 沒裝好就點 Install，跑完重啟 Arduino IDE

### 找不到 Adafruit_MPR121 library
- **Sketch → Include Library → Manage Libraries...**
- 搜尋 `Adafruit MPR121`
- 點 **Install**，如跳出依賴提示選 **Install all**

### Tools → Port 沒有顯示 Teensy
1. 換另一條 USB 線（充電線可能不支援資料傳輸）
2. 換另一個 USB 埠
3. **按一下 Teensy 板上的小白按鈕**強制進入燒錄模式
4. 還是不行 → 可能 Teensy 板壞了，找原作者

## 燒韌體階段

### 上傳卡在 "Waiting for Teensy device..."
- 按 Teensy 板上的小白按鈕（強制 bootloader）
- 上傳會繼續

### 編譯錯誤 `Wire.h: No such file`
Arduino IDE 沒裝好標準函式庫。重新安裝 Arduino IDE 即可。

### 編譯錯誤 `Adafruit_MPR121.h: No such file`
回到 [找不到 Adafruit_MPR121 library](#找不到-adafruit_mpr121-library) 重做。

### 上傳成功但 Serial Monitor 印 `MPR121 #X not found!`
韌體跑了但偵測不到 MPR121 晶片：
- USB 拔掉重插
- 檢查硬體 I²C 線（正常使用不會發生這狀況，除非運送中震斷）

## 使用階段

### 雙擊 start.bat 後黑視窗閃一下就消失
**原因**：Node.js 沒裝好或不在 PATH
**修復**：
1. 開 PowerShell，執行 `node --version`
2. 如果說「不是內部或外部命令」→ Node.js 沒裝好，重做 README Step 1
3. 重灌 Node.js 時記得勾選「**Add to PATH**」（預設就有勾）

### 雙擊 start.bat 卡在 "下載 serve 工具" 很久
- 第一次執行需從網路下載 `serve`（約 5–10 MB），網路慢就會慢
- 等 1–2 分鐘還沒好 → 檢查網路、防火牆是否擋 npm

### 瀏覽器自動打開的是 Edge 而我想用 Chrome
- 用 Chrome 手動開 `http://localhost:3000` 即可（兩個都支援 Web MIDI）
- 想預設改 Chrome：Windows 設定 → 應用程式 → 預設應用程式 → 把瀏覽器設為 Chrome

### MIDI Monitor 顯示紅色 `unsupported`
你用的瀏覽器是 **Firefox**（預設不支援 Web MIDI）。換 Chrome 或 Edge。

### MIDI Monitor 顯示黃色 `connecting` 永遠不變綠
1. F5 重整
2. 拒絕過 MIDI 權限的話，需到 chrome://settings/content/midiDevices 重新允許
3. 看右下「inputs」有沒有列出 Teensy；沒有就重接 USB

### MIDI Monitor 綠色 ready，但摸硬體完全沒事件
- 韌體沒燒對：USB Type 不是 Serial + MIDI
- 重做 [README Step 3](../README.md#step-3--燒韌體到-teensy)，留意 USB Type 的選擇

### Jog 摸了會動，但方向跟期待相反
DJ 慣例是順時針 = 前進。如果你的硬體裝配 jog 電極順序跟韌體不一致，會反過來。
- 修法：在 `firmware/05_full_integration.ino` 找到這行：
  ```cpp
  delta = -delta;  // 翻方向
  ```
- 註解掉這行（前面加 `//`），重新燒錄

### 某顆 PAD 一直沒反應 / 一直觸發
- 可能是該電極跟 MPR121 之間鬆脫或短路
- 暫時性可調 firmware 裡的 `TOUCH_DELTA`、`NOISE_THR` 補救
- 根本性需要檢查硬體接線

### 沒聲音
- Windows 系統音量沒開 / 靜音
- 瀏覽器分頁靜音（網址列右邊有沒有 🔇 圖示）
- 沒拖曲目到 deck 上
- Audio output 不在預期裝置（系統設定 → 音效 → 輸出裝置）

## 還是不行？

帶這些訊息找原作者：
1. 卡在哪一步驟（README 的 Step 幾？）
2. 完整的錯誤訊息文字（截圖或複製）
3. 你的 Windows 版本（按 `Win + R` → 輸入 `winver`）
4. Node.js 版本（`node --version`）
