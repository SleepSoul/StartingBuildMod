--[[
    StartingBuildMod
    Author: SleepSoul (Discord: SleepSoul#6006)
    Dependencies: ModUtil, RCLib
    Define a build, per-aspect, to be applied by default upon starting a run.
]]

ModUtil.Mod.Register( "StartingBuildMod" )

ModUtil.Path.Wrap( "SpawnRoomReward", function ( baseFunc, lootData, args )
    if StartingBuildMod.config.Enabled and CurrentRun.CurrentRoom.Name == "RoomOpening" then
        CurrentRun.LootTypeHistory = CurrentRun.LootTypeHistory or {}

        local aspect = RCLib.GetAspectName() or nil
        local settings = StartingBuildMod.config.AspectSettings[aspect] or {}
        if type( settings.Build ) == "string" then
            settings.Build = StartingBuildMod.Presets[settings.Build]
        end

        if not IsEmpty( settings ) then
            local startingBoons = settings.Build or {}
            local startingHammers = settings.Hammers or {}

            if not IsEmpty( startingBoons ) then
                for _, boon in ipairs( startingBoons ) do
                    local boonName = RCLib.EncodeBoon( boon.Name ) or nil
                    local boonLevel = boon.Level or "1"
                    local boonRarity = boon.Rarity or "Common"

                    if boonName == nil then
                        DebugPrint({ Text = "Cannot add " .. boon.Name .. ", invalid" })
                    else
                        for i = 1, boonLevel do
                            AddTraitToHero({ TraitName = boonName, Rarity = boonRarity })
                        end

                        if StartingBuildMod.config.UpdateHistory then
                            local boonData = TraitData[boonName] or {}
                            local godCode = RCLib.EncodeBoonSet( boonData.God )
                            if godCode then
                                if CurrentRun.LootTypeHistory[godCode] == nil then CurrentRun.LootTypeHistory[godCode] = 0 end
                                CurrentRun.LootTypeHistory[godCode] = CurrentRun.LootTypeHistory[godCode] + 1
                            end
                        end

                        UpdateHeroTraitDictionary()
                        SortPriorityTraits()
                        DebugPrint({ Text = "Added Level " .. boonLevel .. " " .. boonRarity .. " " .. boon.Name })
                    end
                end
            end

            if not IsEmpty( startingHammers ) then
                for _, hammer in ipairs( startingHammers ) do
                    local hammerName = RCLib.EncodeHammer( hammer ) or nil

                    if hammerName == nil then
                        DebugPrint({ Text = "Cannot add " .. hammer .. ", invalid" })
                    else
                        AddTraitToHero({ TraitName = hammerName })
                        DebugPrint({ Text = "Added " .. hammer })
                    end
                    
                    if StartingBuildMod.config.UpdateHistory then
                        if CurrentRun.LootTypeHistory.WeaponUpgrade == nil then CurrentRun.LootTypeHistory.WeaponUpgrade = 0 end
                        CurrentRun.LootTypeHistory.WeaponUpgrade = CurrentRun.LootTypeHistory.WeaponUpgrade + 1
                    end
                end
            end

            if settings.MaxHealth then
                AddMaxHealth( settings.MaxHealth - 50, nil )
            end
        end

        if not StartingBuildMod.config.BlockStartingReward then
            return baseFunc( lootData, args )
        end

        return
    end

    return baseFunc( lootData, args )
end, StartingBuildMod )
