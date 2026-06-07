# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"Raise and Hatch" — a Roblox pet-tycoon game written in **Luau**, built with **Rojo** (7.5.1). Live: https://www.roblox.com/games/80420751886453/Raise-and-hatch

## General
- All `require` calls must be at the top of the file.
Group `require` blocks in this order:
1. Common ancestor definition
2. Imported packages
3. Definitions derived from packages (can be broken down by subfolder)
4. Same-project modules (can be broken down by subfolder)

## Metatables
Used only for:
- **Prototype‑based classes** (with `__index` trick and explicit typing)
- **Guarding against typos** (e.g., enums that throw on missing keys)

## Classes
- Dot syntax with explicit self: function MyClass.Method(self: MyClass). Required for strict typing.
- Private fields and methods use a leading underscore.
- Use :: any casts sparingly, only at boundaries (constructors, binder registration). Fix upstream types when you can.

## Functions
- Keep arguments small (1–2)

## Comments
- Block comments for file/function documentation
- Moonwave docstrings: --[=[ @class ClassName ]=] at the top of the method/file.

## Naming
- Spell out words fully
- `PascalCase` for classes/enums and Roblox APIs
- `camelCase` for locals, members, functions
- `LOUD_SNAKE_CASE` for local constants
- File name matches the object it exports

## Yielding
- Do not call yielding functions on the main task – use `coroutine.wrap`/`delay` or Promises

## Error Handling
- Throw only to validate correct usage, with `assert` when it MUST and close guard early return when it should

## General Roblox Best Practices
- All services via `game:GetService` at top of file
- Imported module variable name = module name

## Tooling & Commands

**Reality of this environment (verify before relying on a command):** the only
Luau/Roblox tool installed on PATH is **`rojo`**. There is **no** `stylua`,
`selene`, `luau-lsp`, or `luau-analyze` available, and the root `package.json`
has **no `scripts` block** and there is **no `tools/` directory**. So the
`npm run lint:* / build:sourcemap / format` commands and the `tools/nevermore-cli`
build referenced in older notes **do not run here** — don't promise a clean lint
you can't actually produce. Type-checking and formatting happen inside Roblox
Studio (or after you install the toolchain yourself).

What actually works from the repo root:

```shell
npm install                                            # pull the Quenty deps into node_modules/
rojo serve                                             # live-sync into Studio (primary dev loop)
rojo build                                             # produce an rbxlx/rbxm
rojo sourcemap default.project.json -o sourcemap.json  # regenerate the sourcemap
```

- `rojo sourcemap` validates the **project tree and require paths** (a new file
  showing up in the map confirms it's wired in) but it does **not** parse or
  type-check Luau — it won't catch a syntax or type error.
- Runtime verification is a **Studio playtest**; debug with `print()` and inspect
  attributes/events in the Studio explorer. There are no automated tests.
- If you genuinely need type/format gating, install `stylua` and
  `luau-lsp`/`luau-analyze` yourself (cargo/rokit) — they are not provisioned here.

## Project layout (see `default.project.json` for the authoritative mapping)

| Source path | Roblox location |
|---|---|
| `src/shared` | `ReplicatedStorage` |
| `src/server` | `ServerScriptService` |
| `src/client` | `StarterPlayer.StarterPlayerScripts` |
| `node_modules/@quenty` | `ReplicatedStorage.Nevermore.Quenty` |
| `node_modules/@quentystudios` | `ReplicatedStorage.Nevermore.QuentyStudio` |
| `src/myNeverMoreS` | `ReplicatedStorage.Nevermore.Custom` |

So a `require(ReplicatedStorage.Nevermore.Custom.bestiary.src.Server.BestiaryList)` resolves to `src/myNeverMoreS/bestiary/src/Server/BestiaryList.luau`. Custom Nevermore packages follow Quenty's `package/src/{Shared,Server,Client}/...` convention.

## Architecture

This game is built on **Quenty's Nevermore framework**. Understanding three of its primitives is essential before touching most code:

- **ServiceBag** — dependency-injection container. Both entry points construct one, register services, then call `:Init()` and `:Start()`.
- **Binder / BinderProvider** — attach a class instance to every `Instance` carrying a given `CollectionService` tag. Tag strings come from `src/shared/utils/Constants.luau` (e.g. `NPC`, `fighter`, `AnimationHandler`, `PetFollower`).
- **Maid / ValueObject / Brio** — lifecycle/cleanup, observable values, and value-with-lifetime. Used pervasively for teardown and reactive state.

### Entry points / bootstrap order

- **Server:** `src/server/ServiceRoot.server.luau` — bootstraps the ServiceBag, then runs one-time world setup (collision groups on pets, cloning `ServerStorage.Pets` into `ReplicatedFirst` as `PetModels` / `PetsTemplates` / `PetsTransparentTemplates`), wires DataStore save/load via `Players.PlayerAdded/Removing`, and connects the pet RemoteEvents. Delegates per-player setup to `src/server/Mediator.luau`.
- **Client:** `src/client/ServiceRoot.client.luau` — bootstraps the ServiceBag, registers the four Binders, hooks `ClassAddedSignal` to init animations/state machines per spawned model, and mounts the Roact UI (`require(script.Parent.RoactApp)`). `src/client/Main.client.luau` is a small secondary script for the money/stat HUD.

The bootstrap idiom (repeated in both roots):
```lua
local Nevermore = require(NeverMorePackages:FindFirstChild("LoaderUtils", true).Parent).bootstrapGame(NeverMorePackages)
local serviceBag = Nevermore("ServiceBag").new()
-- ... register services / binders ...
serviceBag:Init(); serviceBag:Start()
```
Globals are deliberately exported during/after boot: `_G.ServiceBag`, `_G.BinderProvider`, and the client pet registry `_G.pets_registry` / `_G.pets_registry_value` (a ValueObject synced from the `PetNew` remote). `_G.FistBag` (sic) holds the bag mid-init and is nilled after `:Start()`.

### Per-player state ("player binders")

`Mediator.PlayerAdded` is the heart of server-side player setup. It loads DataStore data (key `data_<UserId>`, store name from `src/server/Env.luau` `DB_URI`), then instantiates a set of per-player handler objects and wires them together via a hand-rolled DI table literally named `fakeServiceBag`:

- **`Registry` / `BestiaryList`** (`src/myNeverMoreS/bestiary`) — the player's pets: XP/leveling, stat points, click state. Look up with `Registry:GetHandler(player)`.
- **`PlayerInventory`** (`src/server/Player/Inventory`) — cash + items.
- **`Incomes`** (`src/myNeverMoreS/values`) — passive/active income bonuses and multipliers.

`Mediator.PlayerRemoving` collects state from these handlers, destroys them, and returns the table that gets `SetAsync`'d. Saved shape: `{ cash, items, pets, lastConnection }`. Offline earnings are computed from `lastConnection` on next join.

### Pet NPC AI — state machine

Pet behaviour is a **state machine** (vendored runner at `src/shared/StateMachine`, plus the `StateMachine` Nevermore module):

- States: `src/shared/NPC/States` (`Idle`, `Patrol`, `Eat`)
- Transitions: `src/shared/NPC/Transitions` (`StartPatrol`, `FinnishPatrol`, `StartEating`, `FinnishEating`)
- Controllers (the behaviours states drive): `src/shared/NPC/Controllers` (`Movement`, `Eat`, `Target`, `Sound`, `PetAnimator`)
- The binder that builds a machine per tagged model: `src/myNeverMoreS/npc/src/Shared/Binder/StateMachine.luau`. `:Init(player)` constructs `StateMachine.new("Idle", LoadDirectory(StatesFolder), setCtx(...))`. Context (char, serviceBag, player, maid) is assembled in `helpers/setCtx.luau`.

Plot/world services live in `src/shared/NPC/Servicies` (note spelling): `PlotService` (fence bounds, spawn plots, online/offline marking) and `BillboardService`.

#### Non-Combat pets

A tagged pet model is brought to life by `StateMachineBinder:Init(player)`, which builds the `StateMachine.new("Idle", ...)` with a context assembled by `helpers/setCtx.luau`. `setCtx` reads the pet's `petName` attribute, gathers stats/animations into a `petData` ctx table, and instantiates the per-pet controllers (`Sound`, `Eat`, `Movement`, `Targeting`, `PetAnimator`). All controllers are collected into one table and each handed to the binder's `maid` (`maid:GiveTask`) so their `:Destroy()` runs on cleanup — `MovementController` holds Heartbeat connections and leaks if not cleaned; the others get `:Destroy()` for free via Quenty `BaseObject`. `SoundController`/billboard/proximity-prompt only spawn for the local owner (`isOwnerLocal`).

### Client UI

Two coexisting UI layers:

- **Roact** (`src/client/RoactApp`) — the current approach. Roact itself is vendored at `src/shared/Roact`. Uses a Context/Provider pattern (`Context/{Inventory,PetRegistry,Billboard,Healthbar,Prompt}`) with components under `Components/` (pet panel, boosters, billboards, custom proximity prompts). Custom `useContext` helper in `Context/Utils`.
- **`src/client/facade`** — older imperative UI modules (`TopButtons`, `IndexButton`, shops, alerts) still in use, mounted directly from `ServiceRoot.client.luau`.

### Client ↔ server communication

All via `ReplicatedStorage.RemoteEvents`, declared as `*.model.json` files in `src/shared/RemoteEvents` (e.g. `PetClicked`, `PetLevel`, `PetStat`, `PetNew`, `HatchEgg`, `BuyEggRemote`, `TeleportRemote`, `Amount`, `Notifier`, `TextFade`). Server-side handlers for the pet remotes are in `ServiceRoot.server.luau`; inventory/equipment/teleport handlers are spread across `Mediator.luau` and the various `*Mediator.luau` modules (`src/server/Pets/petMediator`, `src/server/ShopKeepers/npcMediator`, `src/client/UI/petMediatorClient`).

## Conventions & gotchas

- **Naming is inconsistent and full of intentional-looking typos / Spanglish** — `myNeverMoreS`, `Servicies`, `boludeces`, `FistBag`, `Destoy()`, `FinnishPatrol`, `PleyerId`, `telepor_point_`. When referencing existing identifiers, **copy the existing (mis)spelling exactly** — fixing them silently will break tag/require lookups.
- Tag and attribute strings are centralised in `src/shared/utils/Constants.luau`. Prefer it over string literals.
- DI is informal on the server: handlers receive a plain `fakeServiceBag` table, not a real ServiceBag. Match that pattern when adding a per-player handler.
- `src/server/Env.luau` `DB_URI` selects the DataStore — it currently points at a `_test` store, so changing it migrates all player data to a fresh namespace.
- Many root-level `.rbxm` / `.rbxl` / image files are art/model assets, not code; `default.project.json` does **not** import them — they're loaded into Studio manually.

## Security note

`get_token.sh` at the repo root contains a hardcoded GitHub personal-access token. It is gitignored (so not committed), but it sits in plaintext on disk — treat it as compromised and rotate it if it was ever real.
