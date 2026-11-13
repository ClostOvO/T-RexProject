# แผนผังโครงสร้าง 7 หมวดหมู่หลัก (7 Clean Modules)
**แหล่งที่มา**: ข้อมูลดิบและโค้ดทั้งหมดจาก `static_content_170926/f89d249a195wn04n10b81rk7a6i1q00.json`  
**สถานะการตรวจสอบ**: ครอบคลุม Remote ทั้งหมด **75/75 รายการ (100.0%)** และ Special Methods ครบถ้วนทุกตัว  
**โฟลเดอร์ไฟล์**: `C:\Users\ClostO_O\AppData\Local\Real\workspace\static_content_170926\clean_modules`

---

## 1. สรุปภาพรวมและสถิติ 7 หมวดหมู่หลัก

| หมวดที่ | ชื่อไฟล์ | บทบาทหลัก | รายละเอียดฟังก์ชันที่รวบรวมไว้ |
| :---: | :--- | :---: | :--- |
| **1** | [01_core_security.lua](file:///C:/Users/ClostO_O/AppData/Local/Real/workspace/static_content_170926/clean_modules/01_core_security.lua) | **ระบบหลักและความปลอดภัย** | Service, Upvalues, Remote Watchdog 15 วินาที, Safe Zone (`X < 552.2`), ลาน Rift Machine, ระบบ RigSync, Ghost Desync และ Clean Respawn |
| **2** | [02_auto_farm_pets.lua](file:///C:/Users/ClostO_O/AppData/Local/Real/workspace/static_content_170926/clean_modules/02_auto_farm_pets.lua) | **ระบบฟาร์มและจัดการสัตว์เลี้ยง** | ขโมยไข่อัตโนมัติ (Auto Steal), ลู่วิ่งสปีด (Treadmill), ฟัก/วางไข่ในคอก, ตู้ผสมสัตว์เลี้ยง (Auto Fusery), ใช้น้ำยากลายพันธุ์ (Auto Mutate), ขายสัตว์เลี้ยงอัตโนมัติพร้อม Whitelist ล็อกสัตว์แรร์, สวมใส่อุปกรณ์/สัตว์เลี้ยงที่ดีที่สุด (Wear Best) |
| **3** | [03_events_minigames.lua](file:///C:/Users/ClostO_O/AppData/Local/Real/workspace/static_content_170926/clean_modules/03_events_minigames.lua) | **ระบบกิจกรรมและมินิเกม** | ผีเสื้อ Butterfly Bloom (รับตาข่าย, คำนวณทิศทางบิน 3D, คราฟต์ Essence), ลู่วิ่งแอดมิน, Cursed Island Wars, Pete Space Raid, ตกปลา (เหวี่ยง/ดึง/มาสเตอร์รี่), เก็บดาวตก, Alien Lagoon และ Banjo Cricket |
| **4** | [04_player_combat.lua](file:///C:/Users/ClostO_O/AppData/Local/Real/workspace/static_content_170926/clean_modules/04_player_combat.lua) | **ระบบตัวละครและการต่อสู้** | การเคลื่อนที่ขั้นสูง (Fast Tween ตาม Heartbeat, Ragdoll TP, Velocity Glide) และการตีด้วยอาวุธอัตโนมัติ (Bat Swing Payload ลำดับตัวเลข พร้อมระบบชดเชย Ping) |
| **5** | [05_server_config.lua](file:///C:/Users/ClostO_O/AppData/Local/Real/workspace/static_content_170926/clean_modules/05_server_config.lua) | **ระบบเซิร์ฟเวอร์และการตั้งค่า** | ย้ายเซิร์ฟเวอร์อัตโนมัติ (Server Hop ตามจำนวนคน พร้อมแคช 30 นาที), บันทึก/โหลดโปรไฟล์ JSON และการแจ้งเตือน Discord Webhook เมื่อเจอไข่แรร์ |
| **6** | [06_render_esp.lua](file:///C:/Users/ClostO_O/AppData/Local/Real/workspace/static_content_170926/clean_modules/06_render_esp.lua) | **ระบบการแสดงผลและมองทะลุ (Render & ESP)** | ESP ผู้เล่นพร้อมรูปโปรไฟล์ Avatar HeadShot, กล่องครอบตัว, ชื่อ, อาวุธในมือ, ESP การ์ดผู้พิทักษ์, ESP ไข่และระดับแรร์, เส้นบอกขอบเขต Safe Zone และการชดเชย ViewportSize |
| **7** | [07_optimizer.lua](file:///C:/Users/ClostO_O/AppData/Local/Real/workspace/static_content_170926/clean_modules/07_optimizer.lua) | **ระบบเพิ่มประสิทธิภาพและลดแล็ก (Optimizer)** | ปิดการเรนเดอร์ 3D (Disable 3D Render / `no3d`) ประหยัด GPU มหาศาลตอนเปิดฟาร์มทิ้งไว้, ระบบล็อก FPS, ปรับ QualityLevel เป็น Level 1, ซ่อน UI/CoreGui (`hideUI`), ซ่อนสายพานลู่วิ่ง (`hideTread`) และล้างหน่วยความจำ |

---

## 2. ดัชนีการครอบคลุม Remotes ครบถ้วน 75/75 (100.0%)
- **ความปลอดภัย**: `RE/RigSync/*`, `RE/GearSatchel/*`
- **ฟาร์มและสัตว์เลี้ยง**: `DropFieldEgg`, `RF/EggWorld/*`, `RF/Treadmill/*`, `RF/Fusery/*`, `RF/BossMastery/*`, `RF/Haul/*`, `RE/PetSatchel/*`
- **กิจกรรมและมินิเกม**: `RF/Butterflies/*`, `RF/Fishing/*`, `RF/ShootingStar/*`, `RF/AlienLagoon/*`, `RF/AlienGate/*`, `RF/IslandWars/*`, `RF/LiveEvents/*`, `RE/BanjoCricket/*`
- **การต่อสู้**: `RE/BatSwing/Trigger`, `RE/ToolTrigger/Trigger`
