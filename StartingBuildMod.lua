--[[
    StartingBuildMod
    Author: SleepSoul (Discord: SleepSoul#6006)
    Dependencies: ModUtil, RCLib
    Define a build, per-aspect, to be applied by default upon starting a run.
]]

ModUtil.Mod.Register( "StartingBuildMod" )

function StartingBuildMod.AddBoon( boon )
    local boonCode = RCLib.EncodeBoon( boon.Name )
    local boonLevel = boon.Level or 1
    local boonRarity = boon.Rarity or "Common"

    if boonCode and RCLib.InferItemType( boonCode ) == "Trait" then
        for i = 1, boonLevel do -- Poms are just duplicates of the same boon
            AddTraitToHero({ TraitName = boonCode, Rarity = boonRarity })
        end

        if StartingBuildMod.config.UpdateHistory then
            local boonData = RCLib.InferItemData( boonCode )
            local godCode = RCLib.EncodeBoonSet( boonData.God )
            StartingBuildMod.IncrementGodCount( godCode )
        end

        UpdateHeroTraitDictionary()
        SortPriorityTraits()
    end
end

function StartingBuildMod.AddHammer( hammerName )
    local hammerCode = RCLib.EncodeHammer( hammerName )

    if hammerCode then
        AddTraitToHero({ TraitName = hammerCode })
        if StartingBuildMod.config.UpdateHistory then
            StartingBuildMod.IncrementGodCount( "WeaponUpgrade" )
        end
        
        UpdateHeroTraitDictionary()
        SortPriorityTraits()
    end
end

function StartingBuildMod.IncrementGodCount( godCode ) -- Increment CurrentRun.LootTypeHistory as the game would if a god were picked up naturally
    if not godCode then return end
    if CurrentRun.LootTypeHistory[godCode] == nil then CurrentRun.LootTypeHistory[godCode] = 0 end
    CurrentRun.LootTypeHistory[godCode] = CurrentRun.LootTypeHistory[godCode] + 1
end

ModUtil.Path.Wrap( "SpawnRoomReward", function ( baseFunc, ... )
    if StartingBuildMod.config.Enabled and CurrentRun.CurrentRoom.Name == "RoomOpening" then
        CurrentRun.LootTypeHistory = CurrentRun.LootTypeHistory or {}

        local aspect = RCLib.GetAspectName()
        local settings = StartingBuildMod.config.AspectSettings[aspect] or {}
        if type( settings.Boons ) == "string" then
            settings.Boons = StartingBuildMod.Presets[settings.Boons]
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

        if StartingBuildMod.config.BlockStartingReward then return end
    end

    return baseFunc( ... )
end, StartingBuildMod )
