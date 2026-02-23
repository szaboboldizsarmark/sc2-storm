--****************************************************************************
--**
--**  File     : /data/lua/ui//campaign/campaignmanager.lua
--**  Author(s): Chris Blackwell
--**
--**  Summary  : manages campaign logic.
--**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

local UIUtil = import('/lua/ui/uiutil.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Prefs = import('/lua/user/prefs.lua')

--*******************************************************************
-- this is syncd from the sim, so it should be authoritative
campaignMode = false

--*******************************************************************
campaignSequence = {
    TEMP_SC2 = {
        'SC2_CA_U01',
        'SC2_CA_U02',
        'SC2_CA_U03',
        'SC2_CA_U04',
        'SC2_CA_U05',
        'SC2_CA_U06',
        'SC2_CA_I01',
        'SC2_CA_I02',
        'SC2_CA_I03',
        'SC2_CA_I04',
        'SC2_CA_I05',
        'SC2_CA_I06',
        'SC2_CA_C01',
        'SC2_CA_C02',
        'SC2_CA_C03',
        'SC2_CA_C04',
        'SC2_CA_C05',
        'SC2_CA_C06',
        'SC2_CA_zTEMPLATE',
        'SC2_CA_zSAMPLE',
        'SC2_E3_DEMO',
        'SC2_GC_DEMO',
        'DEVTEST_Cinematics',
        'DEVTEST_Perf',
    },

    UEF = {
		'SC2_CA_U01',
        'SC2_CA_U02',
        'SC2_CA_U03',
        'SC2_CA_U04',
        'SC2_CA_U05',
        'SC2_CA_U06',
    },

    Illuminate = {
		'SC2_CA_I01',
        'SC2_CA_I02',
        'SC2_CA_I03',
        'SC2_CA_I04',
        'SC2_CA_I05',
        'SC2_CA_I06',
    },

    Cybran = {
		'SC2_CA_C01',
        'SC2_CA_C02',
        'SC2_CA_C03',
        'SC2_CA_C04',
        'SC2_CA_C05',
        'SC2_CA_C06',
    },

    Tutorial = {
		'SC2_CA_TUT_01',
		'SC2_CA_TUT_02',
    },

}

--*******************************************************************
diffIntToDiffKey = {
    'easy',
    'medium',
    'hard',
}

--*******************************************************************
diffKeyToDiffInt = {
    easy = 1,
    medium = 2,
    hard = 3,
}

--*******************************************************************
-- Campaign table format:
--	campaignID - one for each campaign
--	completedOperationID - each operation completed will have an entry
--	difficulty - one entry for each difficulty completed
--	allPrimary  - bool true if all primary objectives completed for this difficulty
--	allSecondary - bool true if all secondary objectives completed for this difficulty
local function GetCampaignTable()
    local cmpt = Prefs.GetFromCurrentProfile('campaign')
    if not cmpt then cmpt = {} end
    return cmpt
end

--*******************************************************************
local function SetCampaignTable(newTable)
    Prefs.SetToCurrentProfile('campaign', newTable)
    SavePreferences()
end

--*******************************************************************
function ResetCampaign(campaignID)
    local cmpt = GetCampaignTable()
    cmpt[campaignID] = nil
    SetCampaignTable(cmpt)
end

--*******************************************************************
function GetCampaignSequence(campaignID)
    local retTable = {}
    if campaignSequence[campaignID] then
        for i, v in campaignSequence[campaignID] do
            table.insert(retTable, v)
        end
        return retTable
    else
        return false
    end
end

--*******************************************************************
-- Returns the last completed operation ID in a campaign
-- If diff. is not supplied, returns the highest completed op in the sequence of all difficulties
function GetLastCompletedOperation(campaign, difficulty)
    if campaignSequence[campaign] then
        local campTable = GetCampaignTable()
        if campTable[campaign] then
            local lastID = false
            for _, opID in campaignSequence[campaign] do
                if difficulty then
                    if campTable[campaign][opID][difficulty].allPrimary != nil then
                        lastID = opID
                    end
                else
                    for _, diff in diffKeyToDiffInt do
                        if campTable[campaign][opID][diff].allPrimary != nil then
                            lastID = opID
                            break
                        end
                    end
                end
            end
            return lastID
        end
    end
    return false
end

--*******************************************************************
-- Returns the next opID in the sequence of the campaign specified
function GetNextOperation(campaign, opKey, diff)
    if campaignSequence[campaign] then
        local found = false
        for _, opID in campaignSequence[campaign] do
            if found then
                return {opID = opID, campaignID = campaign, difficulty = diff}
            end
            if opID == opKey then
                found = true
            end
        end
    end
    return false
end

--*******************************************************************
-- Operation victory table contains the following fields
--  string opKey		- unique identifier for the current operation (ie SCCA_E01 would be a good key)
--  bool success		- instructs UI which dialog to show
--  int difficulty		- 1,2,3 currently supported
--  bool allPrimary		- true if all primary objectives completed, otherwise, false
--  bool allSecondary	- true if all secondary objectives completed, otherwise, false
--  int factionVideo	- Opt.  If present, display this factions end game video
--  table completedObjectives - Opt. If present, contains a list of all completed objectives from this operation
function OperationVictory(ovTable, skipDialog)

	-- Make sure input is unlocked- NIS is no longer active.
	local gamemain = import('/lua/ui/game/gamemain.lua')
	if gamemain.IsNISMode() then
		gamemain.NISMode('off')
	else
		UISetLockInput(false)
	end

    local resultText
    if ovTable.success == true then
        resultText = "<LOC CAMPMGR_0000>Operation completed"
    else
        resultText = "<LOC CAMPMGR_0001>Operation failed"
    end

    local cmpt = GetCampaignTable()

    local camp = ovTable.campaignID
    if camp then
        if not cmpt[camp] then
            cmpt[camp] = {}
        end
        if not cmpt[camp][ovTable.opKey] then
            cmpt[camp][ovTable.opKey] = {{}, {}, {}}
        end

        if not cmpt[camp][ovTable.opKey][ovTable.difficulty] then
            cmpt[camp][ovTable.opKey][ovTable.difficulty] = {}
        end

		if ( cmpt[camp][ovTable.opKey][ovTable.difficulty].allPrimary != true ) then
			cmpt[camp][ovTable.opKey][ovTable.difficulty].allPrimary = ovTable.allPrimary
		end

		if ( cmpt[camp][ovTable.opKey][ovTable.difficulty].allSecondary != true ) then
			cmpt[camp][ovTable.opKey][ovTable.difficulty].allSecondary = ovTable.allSecondary
		end

		if ( cmpt[camp][ovTable.opKey].allPrimary != true ) then
			cmpt[camp][ovTable.opKey].allPrimary = ovTable.allPrimary
		end

		if ( cmpt[camp][ovTable.opKey].allSecondary != true ) then
			cmpt[camp][ovTable.opKey].allSecondary = ovTable.allSecondary
		end

		if not cmpt[camp][ovTable.opKey].completedObjectives then
			cmpt[camp][ovTable.opKey].completedObjectives = {}
		end

		if( ovTable.completedObjectives ) then
			for k, objective in ovTable.completedObjectives do
				if not table.find(cmpt[camp][ovTable.opKey].completedObjectives, objective) then
				  	table.insert(cmpt[camp][ovTable.opKey].completedObjectives, objective)
				end
			end
		end

        if cmpt[camp][ovTable.opKey][ovTable.difficulty].ScoreSummary.OverallPoints < ovTable.ScoreSummary.OverallPoints and cmpt[camp][ovTable.opKey][ovTable.difficulty].ScoreSummary.OverallPoints > 0 then
            cmpt[camp][ovTable.opKey][ovTable.difficulty].ScoreImproved = true
        else
            cmpt[camp][ovTable.opKey][ovTable.difficulty].ScoreImproved = false
        end
        
        -- update the high scores medal count (for campaign selection medals)
        local highMedals = cmpt[camp][ovTable.opKey][ovTable.difficulty].ScoreSummary.HighMedals
        if not highMedals or highMedals < ovTable.ScoreSummary.OverallMedals then
	        ovTable.ScoreSummary.HighMedals = ovTable.ScoreSummary.OverallMedals
	    else
			ovTable.ScoreSummary.HighMedals = highMedals
        end

        cmpt[camp][ovTable.opKey].success = ovTable.success
        cmpt[camp][ovTable.opKey][ovTable.difficulty].ScoreSummary = ovTable.ScoreSummary

        SetCampaignTable(cmpt)
    else
        WARN("OperationVictory: Operation ID not found - " .. ovTable.opKey)
    end

    if not skipDialog then
        SetFrontEndData('NextOpBriefing', GetNextOperation(camp, ovTable.opKey, ovTable.difficulty))
        import('/lua/ui/game/worldview.lua').UnlockInput()
        if not ovTable.factionVideo then
            if ovTable.success then
                PlaySound(Sound({Bank = 'SC2/Interface', Cue = 'UI_END_Game_Victory'}))
            else
                PlaySound(Sound({Bank = 'SC2/Interface', Cue = 'UI_END_Game_Fail'}))
            end

			UIShowDialog( resultText, "<LOC _Ok>OK", "CampaignSummary", "", "", "", "", false )

        else
            import('/lua/ui/game/missiontext.lua').PlayEndGameMovie(ovTable.factionVideo, function()
				----SC2 DEV NOTE: I have temporarily modified this to skip the score dialog - the management and structure of campaign ending
				----					needs to be resolved. - bfricks 2/3/09
                ExitGame()
            end)
        end
    end
end

--*******************************************************************
-- insta win all the campaigns
function InstaWin()
    for camp, ops in campaignSequence do
        for index, op in ops do
            for diff = 1,3 do
                local ov = {
                    campaignID = camp,
                    opKey = op,
                    success = true,
                    difficulty = diff,
                    allPrimary = true,
                    allSecondary = true,
                }
                OperationVictory(ov, true)
            end
        end
    end
end

--*******************************************************************
function LaunchBriefing(nextOpData)
	ERROR("SC2 ERROR: LaunchBriefing has been called, but is no longer supported properly - bfricks 2/3/09")
    --local opID = nextOpData.opID
    --if DiskGetFileInfo('/maps/'..opID..'/'..opID..'_operation.lua') then
    --	local opData = import('/maps/'..opID..'/'..opID..'_operation.lua')
    --    import('/lua/ui/campaign/operationbriefing.lua').CreateUI(opID, opData.operationData, nextOpData.campaignID, nextOpData.difficulty)
    --    return true
    --end
    return false
end
--*******************************************************************
-- supplied a campaign ID and operation ID, returns whether the user can select the operation or not
function IsOperationSelectable(campaign, operation)
    if campaignSequence[campaign] then
        local campTable = GetCampaignTable()
        if campTable[campaign][operation] then
            return true
        end

        local lastCompletedOp = GetLastCompletedOperation(campaign)
        if GetNextOperation(campaign, lastCompletedOp).opID == operation then
            for i, v in campTable[campaign][lastCompletedOp] do
                if v.allPrimary == true then
                    return true
                end
            end
        end
    end
    return false
end

--*******************************************************************
-- supplied a campaign ID and operation ID, returns whether the user has finished the operation or not
function IsOperationFinished(campaign, operation, difficulty)
    local campTable = GetCampaignTable()
    if campaignSequence[campaign] and campTable[campaign][operation] then
        if difficulty then
            if campTable[campaign][operation][difficulty].allPrimary == true then
                return true
            end
        else
            for i, v in campTable[campaign][operation] do
                if v.allPrimary == true then
                    return true
                end
            end
        end
    end
    return false
end

-- supplied a campaign ID and difficulty ID, returns if the campaign score was imporved since the last time it was played
function DidCampaignScoreImprove(campaign, difficulty)
    local operID = GetLastCompletedOperation(campaign, difficulty)
    local campTable = GetCampaignTable()

    return campTable[campaign][operID][difficulty].ScoreImproved
end

-- supplied a difficulty ID, returns the total campaign score of all campaigns
function CalculateTotalCampaignScore( difficulty )
    -- get the score of each seperate campaign and add up the scores
	local TotalCampaignScore = 0
	TotalCampaignScore = CalculateSingleCampaignScore( 'UEF', difficulty )
	TotalCampaignScore = TotalCampaignScore + CalculateSingleCampaignScore('Illuminate', difficulty)
	TotalCampaignScore = TotalCampaignScore + CalculateSingleCampaignScore('Cybran', difficulty)

	return TotalCampaignScore
end

-- supplied a campaign ID and difficulty ID, returns the campaign score of the specified campaign
function CalculateSingleCampaignScore( campaign, difficulty )
	local CampaignScore = 0
	-- iterate over all the campaign games played and add up the scores to return the current campaign score
	local campTable = GetCampaignTable()

	if campTable then
		if campTable[campaign] then
			for i, v in campTable[campaign] do
				if v[difficulty] then
					if v[difficulty].ScoreSummary then
						CampaignScore = CampaignScore + v[difficulty].ScoreSummary.OverallPoints
					end
				end
			end
		end
	end

	return CampaignScore
end

--This function is really only good for testing the last time the user played through the operation
function WasOperationSuccessful(camp, op)
    local cmpt = GetCampaignTable()
    if cmpt != nil then
		if cmpt[camp] != nil then
			if cmpt[camp][op] != nil then
				if cmpt[camp][op].success != nil then
					return cmpt[camp][op].success
				end
			end
		end
    end

	return false
end

-- neededObj is expected to contain
--   -camp   the name of the campaign
--   -map    the name of the map
--   -objs   a list of objectives on that map

function AreObjectivesComplete( neededObj )
    local cmpt = GetCampaignTable()
    if cmpt[neededObj.camp] != nil then
		if cmpt[neededObj.camp][neededObj.map] != nil then
			local completedObjs = cmpt[neededObj.camp][neededObj.map].completedObjectives
			if completedObjs != nil then
				for i, needObj in neededObj.objs do
					local found = false

					for k, compObj in completedObjs do
						if string.find(compObj, needObj) then
							LOG('..........OBJ COMPLETE:[', needObj, ']')
							found = true
							break
						end
					end

					if not found then
						LOG('..........OBJ INCOMPLETE:[', needObj, ']')
						return false
					end
				end
				--Found them all!
				return true

			end
		end
    end
    --One of the tables we needed didn't exist - probably means that the player hasn't played that map yet
	LOG('..........NOT FINISHED YET..........')
    return false
end
