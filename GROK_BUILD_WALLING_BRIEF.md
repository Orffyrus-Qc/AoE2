# Grok Build Brief: AoE2 TC Walling, Gates, Repair, and Rebuild

This is the working model Grok should use when changing `AdaptiveAI`.

## Objective

Create a closed, useful defensive compound around each Town Center, and later around castles, using only:

- palisade walls, stone walls, and fortified walls
- palisade gates and stone gates
- watch towers, guard towers, keeps, bombard towers
- castles
- real natural blockers such as forest, cliffs, water, map edge, and other unwalkable terrain

Do not use houses, farms, barracks, ranges, stables, markets, blacksmiths, monasteries, docks, camps, mills, or random economy buildings as intentional wall pieces. They may be inside the protected area, but they are not the wall.

## Current Project Shape

The relevant files are:

- `AdaptiveAI/resources/_common/ai/AdaptiveAI/stronghold.per`
- `AdaptiveAI/resources/_common/ai/AdaptiveAI/defense.per`
- `AdaptiveAI/resources/_common/ai/AdaptiveAI/fortify.per`
- `AdaptiveAI/resources/_common/ai/AdaptiveAI/gatealign.per`
- `AdaptiveAI/resources/_common/ai/AdaptiveAI/builders.per`
- `AdaptiveAI/resources/_common/ai/AdaptiveAI/constants.per`

The current `stronghold.per` design is a full rectangular wall ring with one controlled gate on the longest side. That is a good default for AI: one gate is easier to build, align, defend, repair, and rebuild than four gates. If you want four gates later, treat that as a separate optional mode, not the default repair-safe design.

## Mental Model

Teach the AI to think in segments, not in a single magic wall:

1. Pick an anchor building: Town Center first, castle second.
2. Compute four ring corners around it using padding.
3. For each side, try to build a wall line.
4. If the line cannot be built, do not automatically call that side finished. First decide why:
   - Existing wall/gate/tower/castle at the point: acceptable barrier.
   - Forest, cliff, water, or map edge: acceptable natural barrier.
   - Unknown obstruction: retry shifted outward/inward, or split into smaller segments.
5. Put one gate on the best side for army and villager access.
6. Put towers/castles near exposed access points, especially the gate and resource-facing sides.
7. Maintain forever: repair damaged pieces, rebuild missing pieces, and re-check after attacks.

## Gate Rules

Gates should be built into an existing wall tile or wall foundation. The correct sequence is:

1. Build the wall line or at least a short wall stub at the gate point.
2. Use `gatealign.per` to probe valid gate orientation.
3. Build exactly one palisade or stone gate at the local gate point.
4. Assign extra builders to the gate foundation because incomplete gates are common weak points.
5. When checking whether a gate already exists, search near `saved-point-x`; do not use a global gate count.

Reason: a global check like "any gate exists anywhere" lets one old gate satisfy a new TC or castle compound. That makes later bases skip their own gate and breaks rebuild logic.

## Natural Obstruction Rules

Natural obstructions are useful only when they actually block enemy movement. Treat them as anchors, not as vague decoration.

Accept as barrier:

- dense forest or tree line
- water edge
- cliff or impassable terrain
- map edge
- existing wall, gate, tower, or castle

Do not accept as barrier:

- farms
- resource drop sites
- houses or production buildings
- temporary enemy units
- a failed `up-can-build-line` result with no evidence of a blocker

If the script cannot prove the obstruction is safe, it should either shift the wall outward or split the side into shorter wall lines.

## Repair and Rebuild Rules

Repair and rebuild are separate jobs:

- Repair: find damaged local `wall-class` and `gate-class` objects near the compound, then assign builders with `action-default`/repair behavior.
- Rebuild: recompute the intended side lines and gate point, then build missing wall/gate pieces if `up-can-build-line` allows it.
- Maintenance must run on a timer and immediately when `underattack` is true.
- Maintenance must iterate every TC/castle, not only the first one.
- Builders must keep a reserve pool so repair does not steal the whole economy.

## Acceptance Checklist

Grok should not call the feature done until these are true in a test game:

- First TC has a full wall ring or a ring closed by valid natural obstruction.
- At least one local gate exists on the compound, not just somewhere on the map.
- Gate orientation matches the wall side.
- Towers/castles are used as defenders near access points, not as random wall replacement.
- A damaged wall or gate gets repaired.
- A destroyed wall line gets rebuilt.
- A destroyed gate gets rebuilt at the local access point.
- New TCs/castles get their own local compound instead of relying on the first base gate.
- The AI does not intentionally wall with houses or production buildings.

## Prompt To Give Grok

Read `GROK_BUILD_WALLING_BRIEF.md`, then inspect `stronghold.per`, `gatealign.per`, `builders.per`, and `constants.per`. Keep the current one-gate-per-compound design unless explicitly asked to add a four-gate mode. Fix walling by using local compound checks: a gate only counts if `gate-class` is near the current `saved-point-x`; a blocked wall side only counts as closed if the blocker is wall/gate/tower/castle or a real natural obstruction. Preserve the build corps and repair loop, and prove the change with an in-game checklist covering first TC, second TC, castle, damaged wall, destroyed wall, and destroyed gate.

## Research Notes

- Official Age of Empires defense guidance emphasizes proactive walls, castles, towers, and safe response to raids: https://www.ageofempires.com/learn-to-play/defending-your-empires-aoe2/
- AoE2 AI scripting references document the rule-based command approach used here, including build-line/search/builder style commands: https://airef.github.io/commands/commands-index.html
- The classic AoE2 AI Expert Documentation is still useful background for AI rule behavior and strategic-number driven control: https://www.scribd.com/document/133400412/Age-of-Empires-II-AI-Expert-Documentation-PC
