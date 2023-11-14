--[[
    StartingBuildMod
    Author: SleepSoul (Discord: SleepSoul#6006)
    Dependencies: ModUtil, RCLib
    Define a build, per-aspect, to be applied by default upon starting a run. Compatible with RunControl 1.2.0 or higher.
]]

ModUtil.Mod.Register( "StartingBuildMod" )

if ModUtil.Path.Get( "RunControl.ModIndex" ) then
    table.insert( RunControl.ModIndex, "StartingBuildMod" )
end

StartingBuildMod.CurrentRunData = {}

function StartingBuildMod.AddBoon( boon )
    local boonCode = RCLib.EncodeBoon( boon.Name )
    local boonLevel = boon.Level or 1
    local boonRarity = boon.Rarity or "Common"

    if boonCode and RCLib.InferItemType( boonCode ) == "Trait" then
        for i = 1, boonLevel do -- Poms are just duplicates of the same boon
            AddTraitToHero({ TraitName = boonCode, Rarity = boonRarity })
        end

        local boonData = RCLib.InferItemData( boonCode )
        local godCode = RCLib.EncodeBoonSet( boonData.God )

        if StartingBuildMod.config.UpdateHistory and godCode then
            StartingBuildMod.IncrementGodCount( godCode )
        end
    end
end

function StartingBuildMod.AddHammer( hammerName )
    local hammerCode = RCLib.EncodeHammer( hammerName )

    if hammerCode then
        AddTraitToHero({ TraitName = hammerCode })
        if StartingBuildMod.config.UpdateHistory then
            StartingBuildMod.IncrementGodCount( "WeaponUpgrade" )
        end
    end
end

function StartingBuildMod.IncrementGodCount( godCode ) -- Increment CurrentRun.LootTypeHistory as the game would if a god were picked up naturally
    if not godCode then return end
    IncrementTableValue( CurrentRun.LootTypeHistory, godCode )
    IncrementTableValue( GameState.LootPickups, godCode )
    if not IsEmpty( CurrentRun.RoomHistory ) then
        depth = TableLength( CurrentRun.RoomHistory )
    end
    table.insert( CurrentRun.LootChoiceHistory, {
        Depth = depth,
        UpgradeName = godCode,
        UpgradeChoices = {}
    } )
end

ModUtil.Path.Wrap( "StartRoom", function( baseFunc, ... )
    if StartingBuildMod.config.Enabled then
        CurrentRun.LootTypeHistory = CurrentRun.LootTypeHistory or {}
        CurrentRun.LootChoiceHistory = CurrentRun.LootChoiceHistory or {}

        local settings = RCLib.GetFromList( StartingBuildMod.CurrentRunData, { dataType = "startingBuild" } ) -- RunControl takes priority

        if IsEmpty( settings ) then
            local aspect = RCLib.GetAspectName()
            settings = StartingBuildMod.config.AspectSettings[aspect] or {} -- Use this only if RunControl doesn't give us anything
        end
        if type( settings.Boons ) == "string" then
            settings.Boons = StartingBuildMod.Presets[settings.Boons] or {}
        end

        if not IsEmpty( settings ) then
            local startingBoons = settings.Boons or {}
            local startingHammers = settings.Hammers or {}

            for _, boon in ipairs( startingBoons ) do
                StartingBuildMod.AddBoon( boon )
            end

            for _, hammer in ipairs( startingHammers ) do
                StartingBuildMod.AddHammer( hammer )
            end

            if settings.MaxHealth then
                AddMaxHealth( settings.MaxHealth - 50, nil )
            end
        end
    end

    return baseFunc( ... )
end, StartingBuildMod )

ModUtil.Path.Wrap( "SpawnRoomReward", function( baseFunc, ... )
    if CurrentRun.CurrentRoom.Name ~= "RoomOpening" or not StartingBuildMod.config.Enabled or not StartingBuildMod.config.BlockStartingReward then
        return baseFunc( ... )
    end
end, StartingBuildMod )
