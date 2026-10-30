# Poly Warfront — Native 1.0 Master Roadmap

**Status:** Proposed replacement scope, not yet committed to GitHub.  
**Repository:** AlmightyTank/WebRTS-Native  
**Working title:** Poly Warfront  
**Engine:** Godot 4 / GDScript, native low-poly 3D RTS.  
**Targets:** Windows and Android; offline campaign and skirmish first. Multiplayer after 1.0.

## Vision
An original, accessible but strategically deep RTS inspired by the *pace and base-building readability* of Red Alert 2 and the *asymmetric general specializations* of Generals: Zero Hour. Create original fiction, factions, units, art, maps, music and superweapons; do not reproduce existing games' assets or story.

## Locked design decisions
- Three core factions, each with three selectable generals (nine total).
- Three chronological, overlapping campaigns, approximately ten missions each. Campaign assigns specific named generals for story purposes; skirmish allows free choice.
- Factions collectively dominate the world at the start of the conflict. A technologically dominant republic slowly drifts into authoritarian expansion; the other powers try to contain it, survive it, or exploit it. Political transformation should feel human, incremental and credible. Ending resolves the immediate war while leaving room for a sequel.
- Mission variety: base construction, defense, garrison, capture, escort/evacuation, raids, survival, infiltration, multi-objective and changing-objective scenarios. Maps allow tactical freedom.
- Capturing a rival command/construction center unlocks its entire buildable tech tree, including general-specific units and superweapons, provided infrastructure, prerequisites and costs are met. The player's chosen general retains exclusive command-level abilities.
- One universal resource: iron ore, refined into credits. Each faction uses distinctive harvesters. Standard deposits deplete; skirmish can enable unlimited ore while retaining harvester/refinery vulnerability. No fuel, ammunition or supply-chain micromanagement.
- Red Alert 2-style sidebar construction, ghost placement, completed buildings immovable, MCV expansion, optional forward outposts. One active build per production category, with explicit queue behavior and multiple factories subject to balance rules.
- Power generation and brownouts matter. Native desktop mouse/keyboard and Android touch share identical game rules.

## Proposed factions and generals (names are placeholders)
### 1. Meridian Republic — precision, energy, global reach
A democratic technological superpower whose leadership progressively invokes emergency powers and military rule. Expensive high-tech forces, precise strikes, sophisticated air support and energy infrastructure. Three general archetypes:
- **Photon Command:** beam vehicles, energy shields, precision orbital/particle strike.
- **Air Dominance:** aircraft, drones, airfields, interception and a specialized strategic air strike.
- **Security Directorate:** surveillance, electronic warfare, defensive systems and a network-disruption superweapon.

### 2. Free Territories — improvisation, mobility, resilience
A decentralized coalition of communities and regional governments. Low-cost equipment, salvage, tunnels, concealment, ambushes and distributed production; low dependence on the power grid, but not a magical or powerless faction. Three archetypes:
- **Insurgent Logistics:** mobile workshops, cheap replacements, tunnels and supply disruption.
- **Saboteur Network:** stealth infantry, infiltration, mines and coordinated infrastructure attacks.
- **People's Defense:** garrisons, improvised fortifications, resistance mobilization and area-denial weaponry.

### 3. Iron Directorate — armored doctrine, industrial might, attrition
A centralized militaristic power with heavy armor, artillery, layered air defenses and durable factories. Three archetypes:
- **Armored Spearhead:** advanced tanks, assault transports and breakthrough abilities.
- **Siege Command:** long-range guns, fortresses, counter-battery systems and strategic bombardment.
- **Mechanized Vanguard:** rapid mechanized formations, battlefield repair and heavy combined-arms strike.

**Design note:** All nine generals require counters, clear silhouettes and meaningful tradeoffs. Their superweapons should differ in delivery, warning, defenses and strategic role rather than simply dealing more damage.

## Campaign outline — 30 missions
### Act I: The Republic (missions 1–10)
Introduce a respected military commander, popular elected leadership and legitimate security concerns. Escalating emergency measures lead to controversial interventions. Missions move from humanitarian escort and border defense to coercive occupation and the first unmistakably unlawful order. The player sees why loyal officers initially trust the government.

### Act II: The Territories (missions 11–20)
Show civilian consequences, splintered local leadership, resistance and moral disagreements. Mix evacuation, limited-force infiltration, sabotage, base capture, convoy rescue, urban defense and counteroffensives. Revisit Act I battlefields from different viewpoints, with new information rather than identical missions.

### Act III: The Directorate (missions 21–30)
The militaristic power initially seeks deterrence and territorial stability, then faces an unavoidable confrontation. Missions emphasize heavy armor, contested industry, combined-arms sieges, amphibious operations and efforts to prevent strategic superweapon escalation. Final missions converge the three viewpoints; stop the immediate threat and deliver a satisfying resolution, while leaving political and personal consequences for a sequel.

### Mission authoring rules
Every mission specifies: playable general; starting forces/buildings; available tech; primary, optional and fail objectives; enemy AI behavior; scripted triggers; briefing/debriefing; checkpoint/save policy; estimated duration; and desktop/Android acceptance tests. Avoid forced linear corridors; use tactical freedom even when story beats are fixed.

## Roadmap — implement sequentially, each letter a separately testable slice

### v0.1 — Native foundation (A–H)
A Bootstrap Godot project; B modular services/scenes; C native main menu; D offline settings persistence; E shared command contract; F CI and headless tests; G Windows export; H Android baseline/export. **Current repository evidence indicates A–D code exists; verify acceptance before marking done.**

### v0.2 — Battlefield and controls (A–H)
A angled 3D camera and terrain picking; B desktop pan/zoom; C touch pan/pinch; D unit selection/box select; E contextual move/attack; F control groups; G feedback/order indicators; H PC and Android input acceptance.

### v0.3 — Maps and movement (A–H)
A versioned map format; B low-poly terrain/obstacles; C pathfinding; D dynamic building blockers; E group formations and anti-stuck; F fog of war; G minimap; H large-army profiling.

### v0.4 — Economy and construction (A–J)
A MCV/command center; B placement ghost and build radius; C iron ore/refinery loop; D three harvester prototypes; E depletion and unlimited-ore setting; F power/brownouts; G RA2-style per-category construction queues; H tech prerequisites and production; I repair/sell/forward outposts; J save/load and economy regression tests.

### v0.5 — Ground combat (A–I)
A data-driven unit registry; B infantry; C engineers/capture; D light vehicles and transports; E tanks/artillery/AA; F armor/projectiles/splash; G orders/stances/patrol; H garrisons/veterancy; I complete battle acceptance.

### v0.6 — Complete offline skirmish (A–I)
A match setup; B victory/defeat/restart; C economic AI; D tactical AI; E difficulty tuning; F local saves/autosaves; G configurable ore/starting credits/teams; H results/statistics; I full-match soak tests. **First genuinely complete playable game milestone.**

### v0.7 — Three faction foundations (A–J)
A world/lore bible; B Republic base roster; C Territories base roster; D Directorate base roster; E three distinct harvester behaviors; F faction tech/building visuals; G economy/defense asymmetry; H faction-specific superweapon foundations; I cross-faction capture tech-tree system; J balance and readability acceptance.

### v0.8 — Nine generals (A–L)
A general-selection framework; B–D Republic generals; E–G Territories generals; H–J Directorate generals; K capture of general-specific buildable tech while retaining player command powers; L general matchups, AI and balance tests.

### v0.9 — Air, sea and advanced warfare (A–J)
A air movement/airfields; B fighters/bombers/transports; C anti-air; D shore/naval placement; E ships/submarines; F amphibious transport; G stealth/detection; H infiltration/electronic warfare; I strategic weapons, alerts and counters; J mixed-domain stress tests.

### v0.10 — Presentation and interface (A–J)
A original art bible; B desktop sidebar and build queues; C mobile HUD; D final low-poly buildings; E final unit models/animations; F terrain/environment polish; G effects and destruction; H music/audio/voice responses; I accessibility/settings; J performance budgets and visual QA.

### v0.11 — Campaign framework (A–I)
A mission schema; B multi-objective graph; C trigger engine; D cinematic/briefing/dialogue support; E scripted AI and reinforcements; F campaign progression/checkpoints; G mission authoring/debug tools; H general locking and tech restrictions; I three complete test missions.

### v0.12 — Republic campaign (A–J)
Author, implement and playtest missions 1–10, escalating from legitimate security operations to authoritarian overreach. Each slice delivers one fully playable mission including briefings, objectives, optional content and test coverage.

### v0.13 — Territories campaign (A–J)
Author, implement and playtest missions 11–20. Each slice delivers one mission showing the war's consequences, divergent resistance approaches and overlapping revelations.

### v0.14 — Directorate campaign and finale (A–J)
Author, implement and playtest missions 21–30. Each slice delivers one mission, ending in a full strategic confrontation and a complete, satisfying first-game resolution.

### v0.15 — Maps, balance and onboarding (A–J)
A–D twelve distinct skirmish maps in batches of three; E guided RTS tutorial; F campaign difficulty and assists; G all nine generals matchup balance; H capture/superweapon balance; I accessibility/localization-ready UI; J full campaign and skirmish regression.

### v0.16 — Release engineering (A–H)
A Windows profiling; B Android profiling; C Android touch/hardware acceptance; D save corruption/migration tests; E input and resolution matrix; F packaging/signing; G offline release-candidate testing; H blocker fixes and freeze.

### v1.0 — Launch (A–H)
A content freeze; B Windows package; C Android package; D full 30-mission QA; E AI and 12-map QA; F documentation and licenses; G publish release builds; H hotfix/rollback plan.

**Total proposed:** 17 milestones, 159 slices. Slices are deliverables, not time estimates.

## Definition of done for every slice
- Actual working game behavior, not only a mock UI or placeholder.
- Automated test(s) and headless import pass; platform build remains valid.
- A manual desktop acceptance scenario; Android checks whenever input, visuals or performance are affected.
- Documentation and compatibility notes updated; reviewed PR merged only after CI passes.
- No claims that a campaign, export or mechanic is finished without direct verification.

## Risk and scope recommendations
1. Build one excellent end-to-end skirmish before producing dozens of units or missions.
2. Prototype one general from each faction early to test asymmetry before building all nine.
3. Validate capture-and-cross-tech rules before balancing late-game superweapons.
4. Build mission tools before writing 30 bespoke scripts.
5. Keep native offline launch independent of any server or account; investigate LAN/online multiplayer only after 1.0.
6. Track Android memory, thermal behavior and touch ergonomics from the beginning, not just at release.
7. Treat faction names, leaders, story mission titles and superweapon names as creative proposals pending a dedicated narrative/design pass.
