# MIDI 協議對照表

韌體 → 瀏覽器之間的 MIDI 訊息格式。**正常使用不需要看**，當你打開 MIDI Monitor 看到奇怪的事件想對照時再回來查。

## 通用設定

- **MIDI Channel**：1（所有訊息）
- **按鈕慣例**：按下 → `Note On velocity 127`；放開 → `Note Off velocity 0`

## Note 對應（按鈕類）

| Note | 元件 | 觸發時機 |
|---|---|---|
| **36** (C2) | CUE | 按下 / 放開 |
| **37** (C#2) | Play / Pause | 按下 / 放開 |
| **38** (D2) | SYNC | 按下 / 放開 |
| **40** (E2) | PAD 1 | 按下 / 放開 |
| **41** (F2) | PAD 2 | 按下 / 放開 |
| **42** (F#2) | PAD 3 | 按下 / 放開 |
| **43** (G2) | PAD 4 | 按下 / 放開 |
| **48** (C3) | Jog 觸摸 | 任一 jog 電極被摸 → On；全部放開 → Off |

## CC 對應（連續控制類）

| CC # | 元件 | 解析度 | 範圍 | 說明 |
|---|---|---|---|---|
| **7** | 音量 fader | 7-bit | 0–127 | 標準 MIDI Channel Volume |
| **14** | 速度 slider MSB | 7-bit | 0–127 | 跟 CC 46 配對 |
| **46** | 速度 slider LSB | 7-bit | 0–127 | `MSB × 128 + LSB` = 14-bit 0–16383 |
| **16** | Jog 旋轉 | 7-bit signed | 1–127 | 64=不動；>64=順時針（前進）；<64=逆時針（後退） |

## 範例 MIDI Monitor 輸出

按下 Play：
```
button:play DOWN
button:play UP
```

調速度 slider 到中間：
```
tempo: 8192 (50.0%)
```

順時針撥 jog：
```
button:jogTouch DOWN
jog: +2
jog: +3
jog: +1
button:jogTouch UP
```

## 備註

- **CC 14**：在 MIDI 1.0 spec 是 "Undefined"，本專案拿來自訂高位元組。
- **14-bit 慣例**：LSB 編號 = MSB 編號 + 32（14+32=46）。
- **Jog CC 16**：值經過韌體小數累加器處理，慢速旋轉也不會被截斷吃光。
