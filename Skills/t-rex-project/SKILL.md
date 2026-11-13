---
name: t-rex-project
description: Author, organize, localize, build, and verify scripts in T-RexProject. Use when scaffolding a new game under T-RexProject/Games, moving shared Luau modules into UniversalCode, wiring Assets (T-RexLogo.png), setting up runtime JSON Config and 4-language Lang packs (Thai default, en-us, vi, zh), merging builds into Games/Game__/Build, or updating T-RexProject architecture.
---

# T-Rex Project Engineering Guide

Standard architecture, file layout, runtime path conventions, localization rules, and build workflow for **T-RexProject**.

> **Sibling skills (load alongside this when relevant):**
> - UI design, themes, fonts, and Thai copy: read `Skills/thai-clean-ui/SKILL.md`
> - End-to-end verification before handoff: read `Skills/scrutinize/SKILL.md`

---

## 1. Workspace Directory Layout

Workspace root: `C:\Users\ClostO_O\AppData\Local\Real\workspace\T-RexProject`  
(Inside Real MCP tools with `folder: "Workspace"`, omit the prefix and pass `T-RexProject/...`.)

```text
T-RexProject/
├── Assets/                     # Shared project media & branding (e.g., T-RexLogo.png)
├── UniversalCode/              # Reusable Luau code shared across all games (merged at build)
├── Games/                      # Per-game workspaces (Game__ template: Game01, Game02, ...)
│   └── Game__/
│       ├── Modules/            # Game-specific feature modules (e.g., 01_core_security.lua ...)
│       ├── Build/              # Final built single-file script(s) for distribution/execution
│       ├── Config/             # Runtime JSON settings (.\T-RexProject\Games\Game__\Config)
│       └── Lang/               # Runtime JSON language packs (.\T-RexProject\Games\Game__\Lang)
├── Skills/                     # Project-local agent skills (t-rex-project, thai-clean-ui, scrutinize)
├── T-RexDumper/                # Project utility scripts & builds
└── Temp/                       # Scratch/reference files (never shipped in builds)
```

- `Game__` is a placeholder template (`Game01`, `Game02`, etc.). Always match or substitute `<GameId>` cleanly when creating or referencing a specific game.
- Never place game-specific Remotes, place IDs, NPC/map coordinates, or game hooks inside `UniversalCode/`.
- Never leave temporary experiments (`Temp/`) referenced by `UniversalCode/` or `Games/<GameId>/Build/`.

---

## 2. Responsibility Boundaries

| Folder | Owns | Must NOT Contain |
| :--- | :--- | :--- |
| `Assets/` | Brand icons/images used across T-Rex scripts (`T-RexLogo.png`). | Game-specific dump outputs or temporary screenshots. |
| `UniversalCode/` | Shared executor shims (`resolveGlobalFunc`), path/folder helpers, singleton cleanup, UI framework (`thai-clean-ui`), Config JSON loader/saver, Lang i18n engine, generic movement/render/optimizer helpers. | Hardcoded PlaceIds, game-specific Remote paths, or game-specific UI tabs. |
| `Games/Game__/Modules/` | Game-specific hooks, farming/combat/shop/admin logic, game UI tab builders consuming `UniversalCode`. | Duplicated UI engine, duplicated Config/Lang parser, or copy-pasted executor wrappers. |
| `Games/Game__/Build/` | Self-contained bundled `.lua` output merging `UniversalCode` + `Games/Game__/Modules` + embedded default Config/Lang fallbacks. | Unmerged scratch snippets. |
| `Games/Game__/Config/` | Per-game saved settings in JSON format (`Default.json` or profile JSONs). | Unstructured plain text or hardcoded credentials. |
| `Games/Game__/Lang/` | Multi-language JSON dictionaries (`th.json`, `en-us.json`, `vi.json`, `zh.json`). | Partial/orphan translation keys only in one file. |

---

## 3. Runtime Path Convention (`.\T-RexProject\...`)

Roblox executors resolve `isfile`, `readfile`, `writefile`, `isfolder`, `makefolder`, and `getcustomasset` relative to the executor's `workspace/` directory. Because `T-RexProject` lives directly inside `workspace/`, the runtime paths after building are:

- **Assets**: `T-RexProject/Assets/T-RexLogo.png` (or `.\T-RexProject\Assets\T-RexLogo.png`)
- **Config directory**: `.\T-RexProject\Games\<GameId>\Config`
- **Lang directory**: `.\T-RexProject\Games\<GameId>\Lang`

### Path & Folder Helper Rules (Required in `UniversalCode`)

1. **Normalize separators carefully**: Some executors fail on leading `.\` or backslashes inside `makefolder`/`writefile`. Provide a shared `normalizePath(relPath)` helper in `UniversalCode` that strips leading `.\` / `./` and converts `\` to `/` before passing paths to executor I/O, while keeping `.\T-RexProject\Games\<GameId>\...` cleanly documented as the logical runtime path.
2. **Create directories step-by-step**: Never assume nested `makefolder("a/b/c")` works in all executors. Walk each segment (`T-RexProject`, `T-RexProject/Games`, `T-RexProject/Games/<GameId>`, `.../Config` or `.../Lang`) and call `if not isfolder(part) then makefolder(part) end`.
3. **Wrap every executor I/O API**: Resolve `isfile`, `readfile`, `writefile`, `isfolder`, `makefolder`, `getcustomasset` via `resolveGlobalFunc(name)` and guard calls in `pcall`. A build in `Games/<GameId>/Build/` **must still boot cleanly** even if the player's executor lacks file I/O or `Assets/T-RexLogo.png` is missing.

---

## 4. Assets Standard (`T-RexProject/Assets`)

- Primary logo file: `T-RexProject/Assets/T-RexLogo.png`.
- Loading pattern:
  - Check `isfile("T-RexProject/Assets/T-RexLogo.png")` and `getcustomasset`.
  - Wrap `getcustomasset(...)` in `pcall`; if unavailable or failed, fall back gracefully to a clean built-in badge/text icon or empty image so the UI never errors.
- Avoid hardcoding unverified external `rbxassetid://` URLs as the sole brand icon when `T-RexLogo.png` is present locally.

---

## 5. Config Standard (`.\T-RexProject\Games\<GameId>\Config`)

- Format: **JSON** encoded/decoded via `HttpService:JSONEncode` / `HttpService:JSONDecode` inside `pcall`.
- Default file: `.\T-RexProject\Games\<GameId>\Config\Default.json` (plus optional named profiles `<ProfileName>.json` + `Meta.json` storing `{ "ActiveProfile": "Default" }` if multi-profile is enabled).
- **Schema & Sanitization Rules**:
  1. Keep an immutable `DEFAULT_CONFIG` table in code (including `SchemaVersion`, `Language = "th"`, `Theme`, `Font`, UI position/toggle defaults, and game feature flags).
  2. When loading JSON from disk, deep-merge / sanitize every key against `DEFAULT_CONFIG` type-by-type so missing keys from older configs get defaults and corrupted types are discarded safely.
  3. On first launch when `Default.json` does not exist on disk (and file I/O is supported), auto-create the folder hierarchy and write `DEFAULT_CONFIG` as JSON so the `Config` directory stays populated and inspectable.
  4. Persist changes explicitly on save or debounced toggle changes; never crash if `writefile` fails.

---

## 6. Multi-Language (`Lang`) Standard (`.\T-RexProject\Games\<GameId>\Lang`)

- Format: **JSON** key-value dictionary files inside `.\T-RexProject\Games\<GameId>\Lang\`.
- **Required Language Set & Codes**:
  1. `th.json` — **Thai (ภาษาไทย) — MANDATORY DEFAULT LANGUAGE**
  2. `en-us.json` — **English (US)**
  3. `vi.json` — **Vietnamese (Tiếng Việt)**
  4. `zh.json` — **Chinese (中文)**
- **Structure & Parity Rules**:
  - Use flat or dot-namespaced semantic keys consistently across all 4 files (e.g., `"ui.title"`, `"nav.combat"`, `"opt.fps_boost"`, `"msg.saved"`).
  - Preserve format placeholders identically across languages (e.g., `{name}`, `{count}`, `%d`, `%s`).
  - Keep **exact key parity** across `th.json`, `en-us.json`, `vi.json`, and `zh.json`. Whenever adding a new UI string or status message, add keys to all 4 files in the same change.
- **Runtime Loading & Fallback Chain**:
  1. Read selected language code from Config (default `"th"` if unset or invalid).
  2. Load `.\T-RexProject\Games\<GameId>\Lang\<lang>.json` with `pcall` + `JSONDecode`.
  3. On first boot (or missing `.json` files), seed/sync the 4 default JSON files (`th.json`, `en-us.json`, `vi.json`, `zh.json`) from embedded fallback tables when file I/O is available, so standalone built scripts immediately materialize the `Lang` folder.
  4. Lookup resolution order for key `k`:  
     `ActiveLang[k]` -> `ThaiDefault[k]` (`th`) -> `EmbeddedThai[k]` -> `k`
  5. **Thai Default Copy Rule**: Because `"th"` is the default experience, `th.json` text must follow `thai-clean-ui` conventions — natural Thai labels without cluttered English translations in parentheses unless truly necessary technical terms.
  6. Expose live language switching in UI settings (`ไทย`, `English (US)`, `Tiếng Việt`, `中文`) that updates visible labels or prompts cleanly and persists `"Language"` in Config.

---

## 7. Build & Bundling Workflow (`Games/<GameId>/Build`)

When building a game (e.g. `Game01`, `Game02`):

1. **Confirm Scope**: Identify `<GameId>` under `T-RexProject/Games/<GameId>/`. Ensure `Modules/`, `Build/`, `Config/`, and `Lang/` exist.
2. **Place Shared Logic First**: Put any reusable framework piece (executor globals, path helpers, Config/Lang loaders, UI primitives, generic optimization/render/movement helpers) in `T-RexProject/UniversalCode/`.
3. **Keep Game Modules Modular**: Organize `Games/<GameId>/Modules/` cleanly by responsibility (e.g., numbered or named modules such as core/security, movement, combat, farming, utility/admin, render, optimizer) rather than one unmaintainable monolith.
4. **Build Assembly**:
   - Merge `UniversalCode/` modules in dependency order, followed by `Games/<GameId>/Modules/` and embedded default `DEFAULT_CONFIG` + `DEFAULT_LANG` (`th`, `en-us`, `vi`, `zh`) tables.
   - Emit the runnable single-file bundle into `T-RexProject/Games/<GameId>/Build/<GameId>_TRex.lua` (or versioned filename per user request).
   - Ensure the built header includes singleton cleanup (e.g., `_G.__TRexCleanup_<GameId>` cleanly tearing down previous GUIs, connections, loops, and restores before re-initializing) and safe GUI mounting (`LocalPlayer.PlayerGui` with `gethui` fallback and anti-cheat awareness).
5. **Sync JSON Artifacts**: Ensure `Games/<GameId>/Config/Default.json` (template or generated) and `Games/<GameId>/Lang/{th,en-us,vi,zh}.json` stay aligned with the keys used in the built script.
6. **Mandatory Validation**:
   - Run `real:check-script` on modified `.lua` source modules AND the final built file in `Games/<GameId>/Build/`. Target **0 syntax/type errors**.
   - Inspect JSON files (`Config` and all 4 `Lang` files) to confirm valid JSON, UTF-8 text (Thai, Vietnamese, Chinese intact), and 100% key parity across `th`, `en-us`, `vi`, `zh`.
   - Perform a `scrutinize` pass checking dependency order, singleton teardown, error guards (`pcall`), runtime path resolution (`.\T-RexProject\...`), and UI cleanliness (`thai-clean-ui`).

---

## 8. Critical Gotchas

- **Don't lose UTF-8 characters**: Ensure `th.json`, `vi.json`, `zh.json`, and built `.lua` files preserve UTF-8 encoding cleanly without mojibake.
- **No duplicate source of truth during edits**: Edit `UniversalCode/` or `Games/<GameId>/Modules/` first and regenerate `Games/<GameId>/Build/...` — never patch only `Build/` and leave source modules stale.
- **Standalone resilience**: A user might drop ONLY the compiled `.lua` from `Games/<GameId>/Build/` into an executor without copying `Config/` or `Lang/` first. Built scripts must therefore embed minimal defaults (`DEFAULT_CONFIG` + `th`/`en-us`/`vi`/`zh` fallback strings) and bootstrap `.\T-RexProject\Games\<GameId>\Config` and `.\T-RexProject\Games\<GameId>\Lang` on first execution if missing.
- **Singleton & Memory Safety**: Track every `RBXScriptConnection`, spawned task/thread flag, ESP/Billboard/Highlight instance, and modified lighting/terrain property so toggling features off or re-executing the build leaves zero orphan connections or leaked visuals.
- **MCP Tool Discipline**: Prefer `real` MCP tools (`list-files`, `read-file`, `write-file`, `check-script`) when reading, writing, and validating scripts inside `workspace/T-RexProject`. Note in summaries if an external tool like `vscode-mcp-server` was unavailable.
