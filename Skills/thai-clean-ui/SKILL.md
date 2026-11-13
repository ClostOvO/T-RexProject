---
name: thai-clean-ui
description: Design and build clean, modern Thai-first UX/UI menus, dashboards, and modular GUI systems (in Luau/Roblox ScreenGui or HTML/CSS/JS). Use when the user asks to create a Thai UI, clean GUI menu, floating circular toggle overlay, profile management UI, status banner, or customizable theme, font, and hotkey settings panel without English text in parentheses.
---
# Thai Clean UI

Build clean, responsive Thai-first graphical user interfaces with a 740×460 two-column dashboard layout, top status banner, floating circular overlay button, profile persistence, live status badges, and dynamic theme/typography registries.

## When to Use

- The user asks to build, style, or refactor a clean Thai UX/UI menu, dashboard, or control panel.
- The user wants natural Thai labels without English translations inside parentheses.
- The interface needs a close/hide button that minimizes into a draggable circular overlay button (`เปิดเมนู` / `ซ่อนเมนู`) to toggle the window.
- The interface requires a real-time Status Banner (`StatusBanner`), Profile Management (`โปรไฟล์`), and a Settings tab (`ตั้งค่า`) with the 6 standard Thai themes, 5 Thai font presets, numeric font/scale inputs, background blur, hotkeys, and global reset/unload actions.

## Steps

### 1. Enforce Clean Thai Copywriting

Write all visible labels, section headers, status badges, notifications, and validation messages in natural Thai without appending English words in parentheses.

- Use concise, direct Thai labels: `โปรไฟล์`, `ตั้งค่า`, `หน้าตาเมนู`, `ปุ่มลัด`, `ความจางพื้นหลัง`, `ขนาดเมนู %`, `ขนาดตัวอักษร`, `เริ่มส่งออก`, `หยุดงาน`, `ปิดหน้าต่าง`.
- Translate keycode names via a lookup table (`KEYCODE_THAI_NAMES`), such as `RightControl = "คอนโทรลขวา"`, `LeftControl = "คอนโทรลซ้าย"`, `RightShift = "ชิฟต์ขวา"`, `LeftShift = "ชิฟต์ซ้าย"`, `Insert = "อินเสิร์ต"`, `Home = "โฮม"`, `End = "เอนด์"`, `F1 = "เอฟ 1"`.
- Separate information with `•` (bullet dot) for clean inline status strings (for example, `"สถานะระบบ: พร้อมทำงาน • ไม่มีความขัดแย้งของฟังก์ชัน"` or `"กดปุ่มใหม่ • Esc เพื่อยกเลิก"`).

### 2. Standardize Window Layout & Visual Hierarchy

Use the canonical `740×460` dashboard geometry so all tabs, banners, and cards align cleanly:

- **MainWindow**: `Size = UDim2.fromOffset(740, 460)`, centered (`AnchorPoint = Vector2.new(0.5, 0.5)`, `Position = UDim2.fromScale(0.5, 0.5)`), `UICorner` radius `14`, `UIStroke` thickness `1.5` (`Border` role), and a child `UIScale` (`MainScale`).
- **TopBar**: `Size = UDim2.new(1, 0, 0, 50)`, `Sidebar` color role, with a bottom cover frame (`14px` tall) to square off the bottom corners. Contains:
  - `AccentDot`: `10×10` circular indicator (`Accent` role) at `X = 17..18`.
  - `HeaderTitle`: `17px` bold title at `X = 38`.
  - `ActiveProfileBadge`: rounded `Card` pill on the right showing `"โปรไฟล์: " .. CurrentProfileName`.
  - `CloseButton`: right-aligned button (`ปิดหน้าต่าง` in red `220, 38, 38` or compact `×` button) that hides the window.
- **Sidebar**: `Position = UDim2.fromOffset(0, 50)`, `Size = UDim2.new(0, 175, 1, -50)`, `Sidebar` color role, `UIPadding` (`Top = 12, Left = 10, Right = 10`), and `UIListLayout` (`Padding = UDim.new(0, 6)`). Tab buttons are `38px` tall (`UICorner` radius `8..9`) with an optional `4×20` left active indicator bar.
- **StatusBanner**: `Position = UDim2.fromOffset(185, 54)`, `Size = UDim2.new(1, -195, 0, 48)`, `Card` color role, `UICorner` radius `8`, `UIStroke` thickness `1`. Contains:
  - `StatusDot`: `8×8` circle colored by state (`16, 185, 129` green for ready/confirmed, `245, 158, 11` amber for waiting/warning, `239, 68, 68` red for error).
  - `StatusBannerLabel`: `12px` wrapped text summarizing current state or active task.
  - Optional `ProgressTrack` (`5px` tall at `Y = 35`) and `ProgressFill` (`Accent` role) for determinate progress (`completed / total`), plus a `38px` bottom footer (`Actions`) when primary start/stop action buttons are needed.
- **ContentContainer**: `Position = UDim2.fromOffset(185, 108..112)`, `Size = UDim2.new(1, -195, 1, -118..-174)`. Holds one `ScrollingFrame` per tab (`AutomaticCanvasSize = Enum.AutomaticSize.Y`, `ScrollBarThickness = 4`, `ScrollBarImageColor3` bound to `Accent`).
- **Section Cards**: Inside each page, group controls into auto-sizing cards (`AutomaticSize = Enum.AutomaticSize.Y`, `BackgroundTransparency = 0.12`, `UICorner` radius `11`, `UIStroke` thickness `1`, `UIPadding` `12px` vertical / `14px` horizontal, `UIListLayout` padding `8px`) led by a `15px` bold `SectionTitle` in `Accent` color.

### 3. Build Draggable Window, Circular Overlay & Toast Notifications

- **Floating Circular Overlay (`CircleOverlay`)**:
  - Create a `62×62` or `64×64` circular button (`UICorner` radius `1, 0` or `32px`) with a `2.5px` `UIStroke` bound to `Accent`, displaying `"เปิดเมนู"` / `"ซ่อนเมนู"`.
  - Either toggle visibility exclusively with `MainWindow` (`CircleOverlay.Visible = not IsWindowOpen`) or keep it anchored at bottom-right (`UDim2.new(1, -24, 1, -24)`) with dynamic caption `"ซ่อนเมนู"` when open and `"เปิดเมนู"` when closed.
- **Drag vs. Click Guard**:
  - Track `dragStart` on `InputBegan` (`MouseButton1` or `Touch`). Only mark as dragged and update `Position` when `(input.Position - dragStart).Magnitude > 5..8`.
  - Suppress the click/reopen callback if a drag occurred, resetting the flag via `task.defer` on `InputEnded`.
- **Toast Notification Stack (`ToastContainer`)**:
  - Anchor at bottom-right (`UDim2.new(1, -20, 1, -20)`, `Size = UDim2.fromOffset(290, 220)`, `ZIndex = 50`).
  - Spawn `42px` tall `Card` toast frames with a `1.2px` `Accent` stroke, a `4px` vertical `Accent` bar on the left, and a `2.3s` delay before tweening transparency out and destroying.

### 4. Use Theme & Typography Binding Registries

Never hardcode static colors or font sizes on individual controls. Register every themed property and text instance so switching themes, fonts, or font sizes updates the entire UI in place:

- **Standard 6 Thai Themes (`THEMES`)**: Always include these 6 named palettes with keys `Bg`, `Sidebar`, `Card`, `CardHover`, `Accent`, `AccentSoft`, `Text`, `SubText`, `Border` (defaulting to `"ชมพูซากุระ"`):
  - `"ชมพูซากุระ"`: Bg `(31, 16, 26)`, Sidebar `(23, 11, 19)`, Card `(52, 27, 43)`, CardHover `(68, 36, 56)`, Accent `(244, 114, 182)`, AccentSoft `(219, 39, 119)`, Text `(253, 242, 248)`, SubText `(249, 168, 212)`, Border `(99, 48, 79)`
  - `"มืดคราม"`: Bg `(15, 23, 42)`, Sidebar `(11, 17, 32)`, Card `(30, 41, 59)`, CardHover `(40, 53, 74)`, Accent `(56, 189, 248)`, AccentSoft `(14, 116, 144)`, Text `(248, 250, 252)`, SubText `(148, 163, 184)`, Border `(51, 65, 85)`
  - `"เขียวมรกต"`: Bg `(12, 26, 22)`, Sidebar `(8, 19, 16)`, Card `(20, 44, 37)`, CardHover `(28, 59, 49)`, Accent `(16, 185, 129)`, AccentSoft `(5, 150, 105)`, Text `(240, 253, 244)`, SubText `(134, 239, 172)`, Border `(34, 78, 64)`
  - `"ม่วงอเมทิสต์"`: Bg `(22, 16, 36)`, Sidebar `(16, 11, 28)`, Card `(38, 28, 60)`, CardHover `(50, 37, 78)`, Accent `(168, 85, 247)`, AccentSoft `(126, 34, 206)`, Text `(250, 245, 255)`, SubText `(216, 180, 254)`, Border `(76, 53, 117)`
  - `"ทองคำมืด"`: Bg `(20, 19, 16)`, Sidebar `(14, 13, 11)`, Card `(36, 33, 27)`, CardHover `(48, 44, 36)`, Accent `(250, 204, 21)`, AccentSoft `(202, 138, 4)`, Text `(254, 252, 232)`, SubText `(253, 224, 71)`, Border `(71, 63, 47)`
  - `"สว่างสะอาด"`: Bg `(241, 245, 249)`, Sidebar `(226, 232, 240)`, Card `(255, 255, 255)`, CardHover `(248, 250, 252)`, Accent `(14, 165, 233)`, AccentSoft `(2, 132, 199)`, Text `(15, 23, 42)`, SubText `(100, 116, 139)`, Border `(203, 213, 225)`
- **Standard 5 Thai Font Presets (`THAI_FONTS`)**:
  - `"โกธิคทันสมัย"` (`GothamMedium` fallback `SourceSans`)
  - `"โกธิคหนา"` (`GothamBold` fallback `SourceSansBold`)
  - `"ซอร์สแซนส์"` (`SourceSans`)
  - `"ซอร์สแซนส์หนา"` (`SourceSansBold`)
  - `"อารีย์"` (`Arial` fallback `SourceSans`)
- **Dynamic Scaling (`applyAppearance` / `applyThemeAndTypography`)**:
  - Maintain `ThemeRegistry` (`{ Instance, Property, Role }`) and `TextRegistry` (`{ Instance, BaseSize, IsBold }`).
  - Scale every registered text element proportionally from base size `14`: `TextSize = math.clamp(entry.BaseSize * Config.FontSize / 14, 1, 100)`.
  - Scale `MainScale.Scale` using `Config.GuiScalePercent / 100` (optionally clamped against `Workspace.CurrentCamera.ViewportSize` so the `740×460` window never overflows small screens).

### 5. Implement Core Reusable Controls & Refresh Callbacks

Maintain a central `UIRefreshCallbacks` (`ui.Refresh`) list so loading a profile, resetting defaults, or changing state updates all controls at once:

- **Toggle Switch (Compact or Status-Rich)**:
  - *Compact Row*: `46px` tall row with a right-aligned `66×27` button showing `"เปิด"` (`AccentSoft`) or `"ปิด"` (`Sidebar`), or a `44×22` pill switch with a sliding `16×16` white knob.
  - *Status-Rich Row*: Auto-sizing row (`AutomaticSize = Enum.AutomaticSize.Y`) containing the title label, a pill `ConflictBadge` (`72×20`, showing states like `"ยืนยันแล้ว"`, `"รอ / พัก"`, `"ฝั่งเรา"`, `"ใช้ไม่ได้"`, `"เปิดใช้งาน"`), the `44×22` switch knob, and a wrapped `11px` `FeatureStatus` description label in `SubText` color.
- **Numeric Input (`createNumericInput` / `ui.input`)**:
  - Use a validated `TextBox` (`ClearTextOnFocus = false`) for numeric settings (`FontSize` 1–100, `GuiScalePercent` 1–200, `BackgroundTransparency`, intervals, thresholds).
  - On `FocusLost`, strip commas/spaces, check finiteness (`type(v) == "number" and v == v and math.abs(v) < math.huge`), clamp to `[Min, Max]`, revert and show a Thai validation message or toast (`"ตัวเลขที่กรอกใช้ไม่ได้ จึงใช้ค่าเดิม"` / `"กรอกตัวเลขที่ถูกต้อง"`) if invalid, and trigger `applyAppearance()`.
- **Dropdown (Single-Select & Multi-Select Filter)**:
  - Display current selection on the header button with `▾` / `▼` (`▲` when open).
  - For multi-select filters (`createFilterDropdown`), show `"ทุกตัวเลือก"` when the selection table is empty or `"เลือก N รายการ"` when active, prefixing active options with `"✓ "`. Selecting `"All"` clears the table.
- **Keybind Picker**:
  - Enter listening mode on click (`"กดปุ่มที่ต้องการ..."` or `"กดปุ่มใหม่ • Esc เพื่อยกเลิก"`).
  - Cancel on `Escape`, clear on `Backspace`/`Delete`, reject duplicate keybinds with a Thai notice, and ignore keybinds when `UserInputService:GetFocusedTextBox()` is active or `gameProcessed` is true.

### 6. Include Profile Persistence, Safe Mounting & Clean Unload

- **Profile Management (`โปรไฟล์` / `ค่าเริ่มต้น`)**:
  - Sanitize loaded profile tables against `defaults` (`applySettings` / `applyProfileTableToConfig`) so missing keys, out-of-range numbers, unknown themes/fonts, or invalid `Enum.KeyCode` names automatically fall back to safe defaults.
  - Guard file I/O (`isfile`, `readfile`, `writefile`, `makefolder`) with `pcall` and `type(...) == "function"` checks, displaying a clear Thai status message if the environment does not support disk persistence.
- **Safe Lifecycle & Singleton Cleanup**:
  - Store a cleanup function in the global environment (`getgenv().__...Cleanup` or `_G.__...Cleanup`) and invoke any previous cleanup before mounting a new instance so re-running never stacks duplicate GUIs or `BlurEffect` instances.
  - Wrap all signal connections in a helper (`connect` / `connectSignal`) that checks `if closed / not IsScriptRunning then return end` and wraps the callback in `pcall`, routing any runtime error to the status banner.
  - Provide global action buttons in Settings: `"ปิดทุกค่าที่เปิดทั้งหมด"` (disable all active toggles), `"คืนค่ามาตรฐาน"` / `"รีเซ็ตตั้งค่าทั้งหมด"` (restore defaults), and `"หยุดและนำเมนูออก"` / `"หยุดงานและปิดเมนูทั้งหมด"` (disconnect all signals, destroy `BlurEffect` and `ScreenGui`).

## Gotchas

- **BillboardGui / Highlight Parenting in Roblox**: Never parent a `BillboardGui` or `Highlight` inside a 2D `Frame`. Parent `BillboardGui` instances to a dedicated `Folder` (`ESPFolder`) under `ScreenGui`, and use a separate transparent full-screen `Frame` (`RenderLayer`) for 2D screen-space lines.
- **Row Height vs. Large Font Sizes**: When `FontSize` increases above `14`, fixed-height rows can clip text. Use `AutomaticSize = Enum.AutomaticSize.Y` on cards/rows or recalculate row height in `ui.Refresh` (`math.max(46, settings.FontSize * 2 + 16)`).
- **Focused TextBox Overwrite on Refresh**: In `ui.Refresh` callbacks for `TextBox` inputs, check `if UserInputService:GetFocusedTextBox() ~= box then` before overwriting `box.Text` so background refreshes never clobber what the user is actively typing.
