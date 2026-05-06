# 韌體說明

`05_full_integration.ino` 是 Teensy 4.0 上跑的完整韌體，負責：

- 讀取 3 顆 MPR121 capacitive touch 晶片（總共 36 個電極通道）
- 用軟體 baseline + 滯後（hysteresis）判定觸碰
- 演算法：1D centroid（slider/fader 連續位置）、2D vector sum（jog wheel 角度）
- 透過 USB MIDI 送出按鈕、CC、jog delta 給瀏覽器

## 燒錄前提（Ubuntu）

- **Teensy 4.0** 板子（不是 Teensy LC、不是 Teensy 3.x）
- **Arduino IDE 2.x** + **Teensyduino** 擴充
- **Adafruit_MPR121** library（Library Manager 安裝）
- **Teensy udev 規則**：`/etc/udev/rules.d/00-teensy.rules`（見根目錄 README Step 4）

## Arduino IDE 設定

| 設定 | 值 |
|---|---|
| Tools → Board | **Teensy 4.0** |
| Tools → USB Type | **Serial + MIDI**（**重要：必選這個，不然瀏覽器抓不到 MIDI**） |
| Tools → CPU Speed | 600 MHz（預設） |
| Tools → Optimize | Faster（預設） |
| Tools → Port | `/dev/ttyACM0` 或 `/dev/ttyACM1`（顯示 `Teensy` 的那個） |

## 關鍵參數（看程式碼開頭）

```cpp
#define TOUCH_DELTA   3      // 觸碰判定門檻
#define RELEASE_DELTA 1      // 放開判定門檻（hysteresis）
#define BASELINE_EMA  0.99f  // baseline 追蹤速度（越高越慢）
#define NOISE_THR     1      // weight 雜訊去除門檻
#define WSUM_MIN      3      // 小於這個權重和視為沒按
#define SCAN_INTERVAL_MS 10  // 掃描週期 → 100 Hz
```

如果觸碰反應太遲鈍，可以把 `TOUCH_DELTA` 降到 2；太敏感（誤觸）就拉到 4。

## I²C 位址對應

| 晶片 | 位址 | 連接 |
|---|---|---|
| MPR121 #1 | 0x5A | CUE / Play / SYNC + 8 顆 Jog 電極 |
| MPR121 #2 | 0x5B | 速度 slider（10 顆） |
| MPR121 #3 | 0x5C | PAD 1–4 + 音量 fader（5 顆） |

如果硬體 ADDR 接腳改了，這些位址會跑。請對照硬體實際接線。

## MIDI 對應

詳見 `../hardware/midi-protocol.md`。

## 常見的燒錄問題

### Permission denied: /dev/ttyACM0
udev 規則沒裝好。執行：
```bash
ls -l /etc/udev/rules.d/00-teensy.rules
```
如果檔案不存在，回 README Step 4 重做。

### Port 列表沒有 /dev/ttyACM*
- 確認 Teensy 已通電（板上 LED 常亮）
- 拔插 USB
- `dmesg | tail` 看插入時的 kernel log，看有沒有抓到裝置

### 上傳卡在 "Waiting for Teensy device..."
按一下 Teensy 板上的小白按鈕，它會強制進入 bootloader，上傳會繼續。
