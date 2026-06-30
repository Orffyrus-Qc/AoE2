# AoE2

Age of Empires II: Definitive Edition mods and AI projects.

## AdaptiveAI (v3.1)

**AdaptiveAI** is a local mod that runs **Promisory Extreme** for core economy, production, and military — then layers adaptive modules on top for opening detection, walling, raids, and age-up priority. User-tested and working as of June 2026.

### What it does

| Module | Role |
|--------|------|
| **Age** | **Highest priority.** Loads last. Feudal → Castle → Imperial via escrow; **68% food** while an age is pending; extra TCs before castle/imperial clicks. |
| **Detection** | Identifies enemy openings (drush, scout rush, archer rush, MAA flush, fast castle, boom, siege, smush, water) and mid-game pivots. Works in 1v1 and team games via `any-enemy`. |
| **Intel** | Tracks enemy TC/castle counts, siege/monk/military peaks for superiority decisions. |
| **Superiority** | Presses when ahead, turtles when behind, releases defensive mode after calm period. |
| **Counters** | Civ-aware unit counter steering on top of opening detection. |
| **Response** | Bridges detections into goals: counter unit training, enemy-goal tags, rally posture. |
| **Economy** | Feudal/castle boom guards; defers fortify wood bias while castle/imperial age is pending. |
| **Defense** | **Full square TC wall ring** (no holes), **one gate on the longest side**, then forward choke walls with gates. |
| **Isolate** | Choke walls at map openings only — resource boxes are not walled separately. |
| **Towers** | Defensive towers on TC flanks + resource sites; forward waves after isolation. |
| **Fortify** | Progressive stone walls, extended chokes, castle-age guard towers. Surplus wood/stone → extra walls/gates up to caps. |
| **Stronghold** | Every TC and castle gets a **closed square compound** with **one gate on the long wall** (gate placed over existing wall). Repairs and rebuilds on timer + under attack. |
| **Explore** | **1–2 scouts only.** Defend vs wolves/boar/jaguars; **retreat to TC** when ≥2 enemy military nearby; no archer/knight explore blobs. |
| **Raid** | Food raids after explore intel (8‑min fallback). Raiders **flank**, **skip/retreat** from enemy groups ≥3. Forward base order: **TC → attack tower → wall → gate** (castle optional). |
| **Builders** | Dedicated build corps (group 19): scales over time for walls, gates, towers, TCs, castles; continuous repair/rebuild. |
| **Military** | Unified melee + ranged blobs (anti-TSA), safe TC staging, population-scaled waves, siege escorts. Explore/raid groups stay out of the main attack blob. |
| **Pre-attack** | Fortify first → prep/stage → max-pop commit → sustain until half losses → 90s recover → repeat. |
| **Coordination** | Pauses raids during main push, re-fortifies when raided, explore before raid dispatch, preserves counter modes. |

Adaptation is **silent** — no in-game chat spam from the adaptive layer.

### Attack lifecycle

1. **Fortify** — At feudal, build walls, gates, and towers around TC before any offensive.
2. **Defend & grow** — Hold attack, rally army at TC, train to military cap.
3. **Sustain push** — Commit when fortify is done and army is at cap; keep attacking until losses reach **50%** of commit peak.
4. **Rebuild** — Pull back, re-rally, refill army, repeat.

### Requirements

- **Age of Empires II: Definitive Edition** (Steam or Microsoft Store)
- **Windows**
- Promisory Extreme AI files (included with the game install; `deploy.ps1` patches debug chat)

### Install

**Option A — Automatic (recommended)**

1. Clone or download this repo.
2. Open the [`AdaptiveAI`](./AdaptiveAI) folder.
3. Right-click `install-on-friend-pc.ps1` → **Run with PowerShell**.
4. If blocked: `Set-ExecutionPolicy -Scope Process Bypass` in PowerShell, then run again.
5. Launch AoE2 DE → **Mod Manager** → **Local** → enable **AdaptiveAI**.

**Option B — Manual**

Copy the `AdaptiveAI` folder to:

```
%USERPROFILE%\Games\Age of Empires 2 DE\mods\local\AdaptiveAI
```

Then enable the mod in-game.

**Option C — Developer deploy**

From the dev tree at `aoe2-adaptive-ai/`, run `deploy.ps1` to copy into the Steam install, local mod mirror, and regenerate the test scenario.

### Test in-game

1. Enable the **AdaptiveAI** local mod.
2. **Single Player** → **Load Scenario** → **AdaptiveAI 1v1 Test**.
3. Pick **AdaptiveAI** as the opponent AI.

Watch for:

- Fast feudal/castle/imperial (food-heavy eco while aging)
- Closed square wall ring around TC with **one gate** on the longest side
- 1–2 scouts exploring; retreating from enemy armies, fighting animals only
- Raiders flanking to food; retreating from large enemy groups
- Forward raid compounds: TC + tower + wall + gate near enemy eco
- Counter units (spears vs scouts, skirms vs archers, etc.)
- One large mixed push at military cap; sustain until ~half the army is gone

Scout the enemy so detection can see your units and buildings.

For walling design notes, see [`GROK_BUILD_WALLING_BRIEF.md`](./GROK_BUILD_WALLING_BRIEF.md).

### Project layout

```
AoE2/
├── README.md
├── GROK_BUILD_WALLING_BRIEF.md
└── AdaptiveAI/
    ├── info.json
    ├── resources/_common/ai/   # AdaptiveAI.per + AdaptiveAI/*.per
    ├── deploy.ps1
    ├── package-for-sharing.ps1
    ├── create_test_scenario.py
    └── install-on-friend-pc.ps1
```

Dev source (this machine): `C:\Users\Orffyrus\.grok\bin\aoe2-adaptive-ai\`

### Architecture

`AdaptiveAI.per` loads Promisory Extreme first, then the adaptive layer. **`age.per` loads last** so age-up food priority wins over economy/fortify rules.

```
Promisory (economy, units, buildings, researches, …)
  → constants → memory → intel → detection → superiority → counters → response
  → economy → builders → gatealign → defense → isolate → towers → fortify
  → stronghold → military → preattack → explore → raid → coordination → age
```

Goal slots **1900–1982** in `constants.per` avoid collisions with Promisory goals.

### Version history (high level)

- **v3.1** — Age-up module (loads last, highest priority). Scout-only explore with animal defense and enemy retreat. Raid enemy avoidance (skip/retreat at ≥3 units). Forward raid build order: TC → tower → wall → gate. Military isolates explore/raid from main blob. Script fixes: valid age IDs (`feudal-age`), `up-modify-goal g:=`, `up-point-distance` in conditions, `action-default` for combat. **User-verified working.**
- **v3.0** — Square wall ring with no holes; one gate on longest side only; gates over existing wall; resource isolation removed; strongerhold/TC padding bumped.
- **v2.6** — Standalone loader experiment (superseded; current build uses Promisory + adaptive layer).
- **v2.5** — Scaling dedicated build/repair corps.
- **v2.4** — Raid forward TC/tower/castle/wall/gate builders.
- **v2.3** — Army explore + enemy position monitor for raid intel.
- **v2.2** — Stronghold compounds per TC/castle with controlled gate.
- **v2.0–v1.6** — Surplus fortify waves, food raids, pre-attack governor, unified attack blobs.
- **v1.4–v0.3** — TC isolation, opening detection, Promisory Extreme base.

### License / credits

- **Author:** Orffyrus
- **Base AI:** Promisory Extreme (game install)
- **Adaptive layer:** AdaptiveAI modules
- Use and modify freely; no warranty.