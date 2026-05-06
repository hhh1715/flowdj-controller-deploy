# 詳細疑難排解（Ubuntu）

按症狀分類。如果在 README 的「故障排除」區找不到答案，這裡會更詳細。

## 安裝階段

### Node.js 安裝失敗 / `node --version` 出現舊版本（如 v12.x）
Ubuntu apt 內建的 Node 通常版本太舊。改用 NodeSource：
```bash
sudo apt remove -y nodejs npm  # 先把舊的清掉
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
node --version  # 應該 v20.x
```

### Arduino IDE AppImage 雙擊沒反應
```bash
chmod +x ~/arduino-ide_*.AppImage
```
然後從終端機執行看錯誤訊息：
```bash
~/arduino-ide_*.AppImage
```
缺套件的話通常會印出來。常見：
```bash
sudo apt install -y libfuse2
```

### Arduino IDE 找不到 Teensy 4.0
1. **File → Preferences → Additional boards manager URLs** 是否有：
   ```
   https://www.pjrc.com/teensy/package_teensy_index.json
   ```
2. **Tools → Board → Boards Manager...** 搜尋 Teensy，是否顯示 INSTALLED
3. 沒裝好就點 Install，跑完重啟 Arduino IDE

### 找不到 Adafruit_MPR121 library
- **Sketch → Include Library → Manage Libraries...**
- 搜尋 `Adafruit MPR121`
- 點 **Install**，如跳出依賴提示選 **Install all**

### Tools → Port 沒看到 /dev/ttyACM0
- udev 規則沒裝好或沒重載：見下一條
- USB 線可能不支援資料傳輸（換一條試試）
- 換另一個 USB 埠
- 用 `lsusb` 看：
  ```bash
  lsusb | grep -i teensy
  ```
  沒輸出代表系統沒抓到裝置 → 硬體層問題

### Permission denied: /dev/ttyACM0
udev 規則檔可能不存在或沒生效：
```bash
ls -l /etc/udev/rules.d/00-teensy.rules
```
如果不存在：
```bash
sudo wget -O /etc/udev/rules.d/00-teensy.rules https://www.pjrc.com/teensy/00-teensy.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```
還是不行 → 重啟電腦。

## 燒韌體階段

### 上傳卡在 `Waiting for Teensy device...`
按一下 Teensy 板上的小白按鈕（強制 bootloader），上傳會繼續。

### 編譯錯誤 `Wire.h: No such file`
Arduino IDE 沒裝好標準函式庫。重新安裝 Arduino IDE 即可。

### 編譯錯誤 `Adafruit_MPR121.h: No such file`
回到 [找不到 Adafruit_MPR121 library](#找不到-adafruit_mpr121-library) 重做。

### 上傳成功但 Serial Monitor 印 `MPR121 #X not found!`
韌體跑了但偵測不到 MPR121 晶片：
- USB 拔掉重插
- 檢查硬體 I²C 線（正常使用不會發生這狀況，除非運送中震斷）

## 使用階段

### `./start.sh` 報 `Permission denied`
還沒給執行權限：
```bash
chmod +x start.sh
```

### `./start.sh` 報 `node: command not found`
Node.js 沒裝好或不在 PATH。回到 README Step 1 重做：
```bash
node --version
```
應該印出 v20.x。

### `./start.sh` 卡在「下載 serve 工具」很久
- 第一次執行需從網路下載 `serve`（約 5–10 MB），網路慢就會慢
- 等 1–2 分鐘還沒好 → 檢查網路、防火牆 / 公司 proxy 是否擋 npm registry

### 開的瀏覽器是 Firefox
Firefox 預設不支援 Web MIDI（雖然有 flag 可以開但不穩定）。建議用 Chrome 或 Chromium。
- 把 Chrome 設為預設瀏覽器：系統設定 → 預設應用程式 → 瀏覽器
- 或手動開 Chrome 貼網址：`http://localhost:3000`

### MIDI Monitor 顯示紅色 `unsupported`
你開的瀏覽器是 **Firefox**，換 Chrome 或 Chromium。

### MIDI Monitor 顯示黃色 `connecting` 永遠不變綠
1. F5 重整
2. 拒絕過 MIDI 權限的話，需到 chrome://settings/content/midiDevices 重新允許
3. 看右下「inputs」有沒有列出 Teensy；沒有就重接 USB

### MIDI Monitor 綠色 `ready`，但摸硬體完全沒事件
- 韌體沒燒對：USB Type 不是 Serial + MIDI
- 重做 [README Step 6](../README.md#step-6--燒韌體到-teensy)，留意 USB Type 的選擇

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
- 系統音量沒開 / 靜音：點右上角喇叭圖示
- 瀏覽器分頁靜音（網址列右邊有沒有 🔇 圖示）
- 沒拖曲目到 deck 上
- 用 `pavucontrol` 確認音訊輸出裝置正確：
  ```bash
  sudo apt install -y pavucontrol
  pavucontrol
  ```

### Chrome 沒辦法用 / 開不起來（Snap chromium 卡頓）
Snap chromium 在某些 Ubuntu 版本上會卡。改裝 Google Chrome `.deb`：
```bash
wget -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y /tmp/chrome.deb
sudo snap remove chromium  # 可選，移掉舊的
```

## 還是不行？

帶這些訊息找原作者：
1. 卡在哪一步驟（README 的 Step 幾？）
2. 完整的錯誤訊息文字（截圖或複製）
3. Ubuntu 版本（`lsb_release -a`）
4. Node.js 版本（`node --version`）
5. `lsusb` 輸出（看 USB 裝置）
