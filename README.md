# StartingBuildMod

This mod allows you to define a build for all runs to start with, per-aspect.

### Options

`Enabled`: Enable or disable the mod.

`BlockStartingReward`: If true, no reward will drop in chamber 1.

`UpdateHistory`: If true, the mod will update `CurrentRun.LootTypeHistory` with all the boons you've set. If false, the game will behave as if you have not seen any gods yet. *True is recommended for most purposes.*

`AspectSettings` holds the per-aspect config.

### Dependencies

StartingBuildMod requires [ModUtil](https://github.com/SGG-Modding/ModUtil) 2.8.0 and [RCLib](https://github.com/Hades-Speedrunning/RCLib).
