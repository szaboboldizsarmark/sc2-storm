-- The global sync table is copied to the user layer every time the main and sim threads are
-- synchronized on the sim beat (which is like a tick but happens even when the game is paused)
Sync = {}

-- UnitData that has been synced. We keep a separate copy of this so when we change
-- focus army we can resync the data.
UnitData = {}

function ResetSyncTable()
    Sync = {
    
    -- Stactic Sync Tables
        UnitData = {},
        ReleaseIds = {},
		
--[[	
	-- Transitory Sync tables 
	
		-- Contains the current score for each army.
		Score = {},			

        -- A list of camera control operations that we'd like the user layer to perform. 
        CameraRequests = {},
        
		-- Audio sync tables.
        Sounds = {},	
        Voice = {},	        

        -- Table of army indices set to "victory" or "defeat".
        -- It's the user layer's job to determine if any UI needs to be shown for the focus army. 
        GameResult = {},

        -- Player to player queries that can affect the Sim.
        PlayerQueries = {},
        QueryResults = {},

        -- Contain operation data when op is complete.
        OperationComplete = {},
        
        -- Force sets the selection to an entity.
        SetSelection = {},
]]--
    }
end


SimUnitUpgrades = {}

function AddUnitUpgrade( unitId, upgrade, slot, upgId )
    local unitUpg = SimUnitUpgrades[unitId]
    if unitUpg then
		if unitUpg[slot] then
			local numBones = table.getn(upgrade.Bones)

			-- Search for first slot and bone that isn't assigned.
			for kBone, vBone in upgrade.Bones do
				local boneFound = false

				for kSlotAssigned, vSlotAssigned in unitUpg[slot] do
					if vBone == vSlotAssigned.bone then
						-- We found this bone being used by a slot already, move on to the next bone.
						boneFound = true
						continue
					end
				end

				-- Since the bone wasn't found, we have found the correct slot, populate it.
				if not boneFound then
					SimUnitUpgrades[unitId][slot][kBone] = {}
					SimUnitUpgrades[unitId][slot][kBone].bone = upgrade.Bones[kBone]
					SimUnitUpgrades[unitId][slot][kBone].unitId = upgId
					SyncUnitUpgrades()
					return kBone
				end
			end
		else
			SimUnitUpgrades[unitId][slot] = {}	
			SimUnitUpgrades[unitId][slot][1] = {}
			SimUnitUpgrades[unitId][slot][1].bone = upgrade.Bones[1]
			SimUnitUpgrades[unitId][slot][1].unitId = upgId
			SyncUnitUpgrades()
			return 1
		end
    else
		SimUnitUpgrades[unitId] = {}
		SimUnitUpgrades[unitId][slot] = {}
		SimUnitUpgrades[unitId][slot][1] = {}
		SimUnitUpgrades[unitId][slot][1].bone = upgrade.Bones[1]
		SimUnitUpgrades[unitId][slot][1].unitId = upgId
		SyncUnitUpgrades()
		return 1
    end
end

function RemoveUnitUpgrade( unitId, upgradeId )
	local upgradeSlots = SimUnitUpgrades[unitId]
    if upgradeSlots then
		for kSlot, vSlot in upgradeSlots do
			for k, v in vSlot do
				if v.unitId == upgradeId then
					SimUnitUpgrades[unitId][kSlot][k] = {}
					SyncUnitUpgrades()
					return
				end
			end
		end
	end
end

function RemoveAllUnitUpgrades(unit)
    local id = unit:GetEntityId()
    SimUnitUpgrades[id] = nil
    SyncUnitUpgrades()
end

function SyncUnitUpgrades()
    import('/lua/user/UserUpgrade.lua').SetUpgradeTable(SimUnitUpgrades)
    Sync.UserUnitUpgrades = SimUnitUpgrades
end

function SyncPlayableRect(rect)
    local Camera = import('/lua/sim/SimCamera.lua').SimCamera
    local cam = Camera("WorldCamera")
    cam:SyncPlayableRect(rect)
end

function LockInput()
    Sync.LockInput = true
end

function UnlockInput()
    Sync.UnlockInput = true
end

function OnPostLoad()
    local focus = GetFocusArmy()
    for entityID, data in UnitData do 
        if data.OwnerArmy == focus then
            Sync.UnitData[entityID] = data.Data
        end
    end
    Sync.IsSavedGame = true
end

function NoteFocusArmyChanged(new, old)
    --LOG('NoteFocusArmyChanged(new=' .. repr(new) .. ', old=' .. repr(old) .. ')')
    import('/lua/sim/SimPing.lua').OnArmyChange()
    for entityID, data in UnitData do 
        if data.OwnerArmy == old then
            Sync.ReleaseIds[entityID] = true
        elseif data.OwnerArmy == new then
            Sync.UnitData[entityID] = data.Data
        end
    end
    Sync.FocusArmyChanged = {new = new, old = old}
end

function FloatingEntityText(entityId, text)
    if not entityId and text then
        WARN('Trying to float entity text with no entityId or no text.')
        return false
    else
        if GetEntityById(entityId):GetArmy() == GetFocusArmy() then
            if not Sync.FloatingEntityText then Sync.FloatingEntityText = {} end
            table.insert(Sync.FloatingEntityText, {entity = entityId, text = text})
        end
    end
end

function StartCountdown(entityId)
    if not entityId then
        WARN('Trying to start countdown text with no entityId.')
        return false
    else
        if GetEntityById(entityId):GetArmy() == GetFocusArmy() then
            if not Sync.StartCountdown then Sync.StartCountdown = {} end
            table.insert(Sync.StartCountdown, {entity = entityId})
        end
    end
end

function CancelCountdown(entityId)
    if not entityId then
        WARN('Trying to Cancel Countdown text with no entityId.')
        return false
    else
        if GetEntityById(entityId):GetArmy() == GetFocusArmy() then
            if not Sync.CancelCountdown then Sync.CancelCountdown = {} end
            table.insert(Sync.CancelCountdown, {entity = entityId})
        end
    end
end

function PrintText(text, fontSize, fontColor, duration, location)
    if not text and location then
        WARN('Trying to print text with no string or no location.')
        return false
    else
        if not Sync.PrintText then Sync.PrintText = {} end
        table.insert(Sync.PrintText, {text = text, size = fontSize, color = fontColor, duration = duration, location = location})
    end
end

function CreateDialogue(text, buttonText, position)
    return import('/lua/sim/SimDialogue.lua').Create(text, buttonText, position)
end

function CreateSimSyncSound( sound )
	if not Sync.Sounds then
		Sync.Sounds = {}
	end
	table.insert(Sync.Sounds, sound)
end

function CreateSimSyncVoice( voice )
	if not Sync.Voice then
		Sync.Voice = {}
	end
	table.insert(Sync.Voice, voice )
end

function CreateSimSyncGameResult( index, result )
	if not Sync.GameResult then
		Sync.GameResult = {}
	end
	table.insert( Sync.GameResult, { index, result } )
end

function CreateSimSyncPlayerQuery( data )
	if not Sync.PlayerQueries then
		Sync.PlayerQueries = {}
	end
	table.insert(Sync.PlayerQueries, data)
end

function CreateSimSyncPlayerQueryResults( data )
	if not Sync.QueryResults then
		Sync.QueryResults = {}
	end
	table.insert(Sync.QueryResults, data)
end

function CreateSimSyncCameraRequest( req )
	if not Sync.CameraRequests then
		Sync.CameraRequests = {}
	end
	table.insert(Sync.CameraRequests, req)
end