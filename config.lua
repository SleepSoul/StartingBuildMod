local config = {
    Enabled = true,
    BlockStartingReward = true,
    UpdateHistory = true,

    AspectSettings = {
        ErisRail = {
            Hammers = {
                "RocketBomb",
            },
            Build = "ZAP"
        },
    }
}
StartingBuildMod.config = config

StartingBuildMod.Presets = {
    None = {},
    MercifulEndBuild = {
        { Name = "CurseOfAgony", Rarity = "Epic", Level = 3 },
        { Name = "ImpendingDoom", Rarity = "Epic", Level = 3 },
        { Name = "DivineFlourish" },
        { Name = "DivineDash" },
        { Name = "MercifulEnd" },
    },
    BeowulfBuild = {
        { Name = "DeadlyStrike" },
        { Name = "FloodFlare", Rarity = "Epic", Level = 3 },
        { Name = "MirageShot", Rarity = "Legendary" },
    },
    ZAP = {
        { Name = "LightningStrike", Rarity = "Epic" },
        { Name = "DeadlyFlourish", Rarity = "Epic" },
        { Name = "TidalDash", Rarity = "Epic", },
        { Name = "StaticDischarge", Rarity = "Epic", },
    },
}