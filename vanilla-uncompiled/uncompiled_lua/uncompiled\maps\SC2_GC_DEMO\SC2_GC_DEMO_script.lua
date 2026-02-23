---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings				= import('/maps/SC2_GC_DEMO/SC2_GC_DEMO_OpStrings.lua')
local OpDialog				= import('/maps/SC2_GC_DEMO/SC2_GC_DEMO_OpDialog.lua')
local OpNIS					= import('/maps/SC2_GC_DEMO/SC2_GC_DEMO_OpNIS.lua')
local ScenarioUtils			= import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework		= import('/lua/sim/ScenarioFramework.lua')
local ScenarioGameSetup		= import('/lua/sim/ScenarioFramework/ScenarioGameSetup.lua')
local ScenarioGameTuning	= import('/lua/sim/ScenarioFramework/ScenarioGameTuning.lua')
local ScenarioGameEvents	= import('/lua/sim/ScenarioFramework/ScenarioGameEvents.lua')
local ScenarioGameCleanup	= import('/lua/sim/ScenarioFramework/ScenarioGameCleanup.lua')
local ScenarioPlatoonAI 	= import('/lua/AI/ScenarioPlatoonAI.lua')
local SimObjectives			= import('/lua/sim/SimObjectives.lua')
local SimPingGroups			= import('/lua/sim/SimPingGroup.lua')
local RandomFloat			= import('/lua/system/utilities.lua').GetRandomFloat
local RandomInt				= import('/lua/system/utilities.lua').GetRandomInt

-- Gamescom specific stuff
local UserConRequest		= import('/lua/system/Utilities.lua').UserConRequest
local ScenarioCinematics	= import('/lua/sim/ScenarioFramework/ScenarioCinematics.lua')

---------------------------------------------------------------------
-- COMMON SCENARIO FRAMEWORK FUNCTIONS:
---------------------------------------------------------------------
-- PROTECT		== prevent damage, death, reclaim, capture, etc...
-- UNPROTECT	== allow damage, death, reclaim, capture, etc...
-- RESTRICT		== allow damage but prevent death. ***USE WITH CAUTION*** - review notes in: ScenarioFramework.lua
-- FORCE		== force death using the IssueKillSelf command.
-- DESTROY		== directly destroy - use for special cases only.

local ProtectUnit			= ScenarioFramework.ProtectUnit			-- usage example: ProtectUnit(unit)
local ProtectGroup			= ScenarioFramework.ProtectGroup		-- usage example: ProtectGroup(group)
local UnProtectUnit			= ScenarioFramework.UnProtectUnit		-- usage example: UnProtectUnit(unit)
local UnProtectGroup		= ScenarioFramework.UnProtectGroup		-- usage example: UnProtectGroup(group)
local RestrictUnitDeath		= ScenarioFramework.RestrictUnitDeath	-- usage example: RestrictUnitDeath(unit)
local RestrictGroupDeath	= ScenarioFramework.RestrictGroupDeath	-- usage example: RestrictGroupDeath(group)
local ForceUnitDeath		= ScenarioFramework.ForceUnitDeath		-- usage example: ForceUnitDeath(unit)
local ForceGroupDeath		= ScenarioFramework.ForceGroupDeath		-- usage example: ForceGroupDeath(group)
local DestroyUnit			= ScenarioFramework.DestroyUnit			-- usage example: DestroyUnit(unit)
local DestroyGroup			= ScenarioFramework.DestroyGroup		-- usage example: DestroyGroup(group)
local Defeat				= ScenarioGameCleanup.Defeat			-- usage example: Defeat()
local PlayerDeath			= ScenarioGameCleanup.PlayerDeath		-- usage example: PlayerDeath(playerUnit)

---------------------------------------------------------------------
-- GLOBAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
ScenarioInfo.ARMY_PLAYER = 1
ScenarioInfo.ARMY_ENEM01 = 2
ScenarioInfo.ARMY_ENEM02 = 3
ScenarioInfo.ARMY_ENEM03 = 4
ScenarioInfo.ARMY_TECH	= 5
ScenarioInfo.AssignedObjectives = {}

---------------------------------------------------------------------
-- GENERAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
local ARMY_PLAYER = ScenarioInfo.ARMY_PLAYER
local ARMY_ENEM01 = ScenarioInfo.ARMY_ENEM01
local ARMY_ENEM02 = ScenarioInfo.ARMY_ENEM02
local ARMY_ENEM03 = ScenarioInfo.ARMY_ENEM03
local ARMY_TECH = ScenarioInfo.ARMY_TECH

---------------------------------------------------------------------
-- OPERATION FLOW:
---------------------------------------------------------------------
function OnPopulate(scenario)
	-- construct the camera data
	---NOTE: for other available settings review: //depot/sc2/main/data/lua/system/CameraDefaults.lua
	local camData = {
		MinSpinPitch	= 0.5,		-- 0.1 = default	The min pitch resulting from a spin.
		MaxZoomMult		= 0.7,		-- 1.1 = default	Extra zoom out buffer so we can see the borders of the map clearly.
		FarZoom			= -1,		-- -1 = default		Farthest mouse can zoom out from terrain, measured in LOD units, -1 to ignore.
	}

	-- pass the data through
	ScenarioGameSetup.CAMPAIGN_OnPopulate(camData)

	LOG('CAMPAIGN OPERATION FLOW:::: OnPopulate: Set Army Colors')
	SetArmyColorIndex( 'ARMY_PLAYER', 0)
	SetArmyColorIndex( 'ARMY_ENEM01', 1)
	SetArmyColorIndex( 'ARMY_ENEM02', 2)
	SetArmyColorIndex( 'ARMY_ENEM03', 3)

	LOG('CAMPAIGN OPERATION FLOW:::: OnPopulate: Make Specific UserConRequests')
	UserConRequest('sallyshears')
	--UserConRequest('ui_RenderUnitBars')

	--LOG('CAMPAIGN OPERATION FLOW:::: OnPopulate: Pre-load and blow up')
	--local preloadGroup = ScenarioUtils.CreateArmyGroup('ARMY_TECH', 'PRELOAD_GROUP')
	--HandlePreloadGroup(preloadGroup)
end

---------------------------------------------------------------------
--function HandlePreloadGroup(group)
--	ForkThread(
--		function()
--			WaitSeconds(1.0)
--			IssueClearCommands(group)
--			IssueKillSelf(group)
--			WaitSeconds(5.0)
--		end
--	)
--end

---------------------------------------------------------------------
function OnStart(self)
	ScenarioGameSetup.CAMPAIGN_OnStart()

	LOG('CAMPAIGN OPERATION FLOW:::: OnStart: Hide non-player Score Displays')
	for i = 4, table.getn(ArmyBrains) do
		SetArmyShowScore(i, false)
		SetIgnorePlayableRect(i, true)
	end
end

---------------------------------------------------------------------
function OnInitCamera(scen)
	LOG('Gamescom DEMO:::: begin normal gameplay intro...')
	-- construct the data table
	local data = {
		funcSetup		= P1_Setup,				-- if valid, the function to be called while the load screen is up
		funcNIS			= OpNIS.NIS_OPENING,	-- if valid, the non-critical NIS sequence to be launched
		funcMain		= P1_Main,				-- if valid, the function to be called after the NIS
		areaStart		= 'AREA_01',			-- if valid, the area to be used for setting the starting playable area
	}

	data.bSkipWaits = true

	-- pass the data through
	ScenarioGameSetup.CAMPAIGN_OnInitCamera(data)
end

---------------------------------------------------------------------
-- PART 1:
---------------------------------------------------------------------
function P1_Setup()
	LOG('----- P1_Setup: Setting up needed units and visual activity for.')
	ScenarioInfo.PartNumber = 1

	LOG('----- P1_Setup: Setup for the player CDR.')
	ScenarioInfo.PLAYER_CDR = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'PLAYER_CDR')
	ScenarioInfo.PLAYER_CDR:SetCustomName('Gamescom Viper Scorpion')
	RestrictUnitDeath(ScenarioInfo.PLAYER_CDR)

	ScenarioInfo.PLAYER_AIR_FACTORY = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'PLAYER_AIR_FACTORY')
	ScenarioInfo.PLAYER_LAND_FACTORY = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'PLAYER_LAND_FACTORY')
	ScenarioInfo.PLAYER_EXP_LAND_FACTORY = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'PLAYER_EXP_LAND_FACTORY')
	ScenarioInfo.PLAYER_EXP_AIR_FACTORY = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'PLAYER_EXP_AIR_FACTORY')
	ScenarioInfo.PLAYER_ILL_EXP_FACTORY = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'PLAYER_ILL_EXP_FACTORY')
	--ScenarioInfo.PLAYER_UNIT_CANNON = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'PLAYER_UNIT_CANNON')
	ScenarioInfo.PLAYER_ILL_EXP_FACTORY:SetDoNotTarget(true)
	ProtectUnit(ScenarioInfo.PLAYER_ILL_EXP_FACTORY)

	ScenarioInfo.P1_PLAYER_Engineers = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Engineers')

	ScenarioInfo.P1_BOMBERS = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_BOMBERS')
	ScenarioInfo.P1_GUNSHIPS = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_GUNSHIPS')

	-- Create player army 2
	ScenarioInfo.P2_LAND = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P2_LAND')
	ScenarioInfo.P2_GUNSHIPS = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P2_GUNSHIPS')
	ScenarioInfo.P2_EXP = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P2_EXP')

	-- Create player army 3
	ScenarioInfo.P3_EXP = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P3_EXP')
	ScenarioInfo.PLAYER_KING = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'PLAYER_KING')
	ScenarioInfo.PLAYER_KING:DisableShield()

	-- Create arty so we can disable weapons
	ScenarioInfo.ENEM01_ARTY = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'ENEM01_ARTY')

	-- Create bases, and reduce their health
	ScenarioInfo.ENEM01_BASE = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'ENEM01_BASE')
	ScenarioInfo.ENEM02_BASE = ScenarioUtils.CreateArmyGroup('ARMY_ENEM02', 'ENEM02_BASE')
	ScenarioInfo.ENEM03_BASE = ScenarioUtils.CreateArmyGroup('ARMY_ENEM03', 'ENEM03_BASE')

	-- Create and protect Brain
	ScenarioInfo.EXP_BRAIN = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'EXP_BRAIN')
	ScenarioInfo.EXP_BRAIN:SetDoNotTarget(true)
	ProtectUnit(ScenarioInfo.EXP_BRAIN)

	for i, unit in ScenarioInfo.ENEM01_BASE do
		local hitpoints = RandomInt(100,500)
		unit:SetMaxHealth( hitpoints )
		unit:AdjustHealth( unit, hitpoints )
	end

	for i, unit in ScenarioInfo.ENEM02_BASE do
		local hitpoints = RandomInt(100,1000)
		unit:SetMaxHealth( hitpoints )
		unit:AdjustHealth( unit, hitpoints )
	end

	-- Set starting mass, energy, and research
	ArmyBrains[ARMY_PLAYER]:GiveResource('MASS', 50000)
	ArmyBrains[ARMY_PLAYER]:GiveResource('ENERGY', 50000)
	ArmyBrains[ARMY_PLAYER]:GiveResource('RESEARCH', 250)

	-- Set research
	local completedResearch = {
		'ULB_RANGE', 'ULU_ASSAULTBOT',
		'ULU_ARTILLERY', 'ULP_DOUBLEBARREL',
		'ULB_DAMAGE', 'ULU_KINGKRIPTOR',
		'ULU_FATBOY', 'UAU_GUNSHIP',
		'UAB_VETERANCYEXPERIENCERATE', 'UAP_CLUSTERBOMBS',
		'UAU_AC1000TERROR', 'UBU_NOAHUNITCANNON',
		'IAU_CZAR', 'ILU_URCHINOW','ILU_UNIVERSALCOLOSSUS',
	}
	ArmyBrains[ARMY_PLAYER]:CompleteResearch( completedResearch )

	--Commented out until bug is fixed; currently hard locks 360 sb 8/5/09
	local restrictedResearch = {
	'UBU_DISRUPTORSTATION', 'UBU_ICBMLAUNCHFACILITY',
	'UBU_SHIELDGENERATOR', 'UBU_TMLICBMCOMBODEFENSE',
	'UBU_MASSCONVERTOR', 'UAU_C230STARKING',
	'UAU_AIRFORTRESS', 'ULP_SHIELDS',
	'ULU_SHIELDGENERATOR', 'UCP_ARTILLERY',
	'UCP_TML', 'USU_ATLANTIS',
	}
	ArmyBrains[ARMY_PLAYER]:ResearchRestrict( restrictedResearch, true )

	-- Restrict/allow certain experimentals and units
	ScenarioFramework.AddRestriction(ARMY_PLAYER, categories.uul0201)

	ScenarioFramework.AddRestriction(ARMY_PLAYER, categories.uux0103)
	ScenarioFramework.AddRestriction(ARMY_PLAYER, categories.uux0104)
	ScenarioFramework.AddRestriction(ARMY_PLAYER, categories.uux0112)
	ScenarioFramework.AddRestriction(ARMY_PLAYER, categories.uux0115)

	ScenarioFramework.AddRestriction(ARMY_PLAYER, categories.uub0105)
	ScenarioFramework.AddRestriction(ARMY_PLAYER, categories.uub0302)
	ScenarioFramework.AddRestriction(ARMY_PLAYER, categories.uub0704)
	ScenarioFramework.AddRestriction(ARMY_PLAYER, categories.uub0704)

	ScenarioFramework.AddRestriction(ARMY_PLAYER, categories.uum0111)
	ScenarioFramework.AddRestriction(ARMY_PLAYER, categories.uum0121)
	ScenarioFramework.AddRestriction(ARMY_PLAYER, categories.uum0131)
	ScenarioFramework.AddRestriction(ARMY_PLAYER, categories.uum0211)

	-- Turn off weapons on artillery so they don't waste our army
	for k, unit in ScenarioInfo.ENEM01_ARTY do
		local wpnLBL = 'Artillery01'
		local wpn = unit:GetWeapon(wpnLBL)

		if wpn then
			unit:SetWeaponEnabledByLabel( wpnLBL, false )
		end
	end

	-- Set faster build times for all factories
	ScenarioInfo.PLAYER_CDR:SetBuildRate( 10 )
	ScenarioInfo.PLAYER_AIR_FACTORY:SetBuildRate( 1.25 )
	ScenarioInfo.PLAYER_LAND_FACTORY:SetBuildRate( 2 )
	ScenarioInfo.PLAYER_EXP_LAND_FACTORY:SetBuildRate( 5 )
	ScenarioInfo.PLAYER_EXP_AIR_FACTORY:SetBuildRate( 5 )
	ScenarioInfo.PLAYER_ILL_EXP_FACTORY:SetBuildRate( 3 )
	--ScenarioInfo.PLAYER_UNIT_CANNON:SetBuildRate( 10 )
end

function P1_Main()
	-- Set Rally Point for each factory
	IssueClearFactoryCommands( {ScenarioInfo.PLAYER_LAND_FACTORY} )
	IssueFactoryRallyPoint( {ScenarioInfo.PLAYER_LAND_FACTORY}, ScenarioUtils.MarkerToPosition( 'FACTORY_ROLLOFF_01' )  )

	IssueClearFactoryCommands( {ScenarioInfo.PLAYER_AIR_FACTORY} )
	IssueFactoryRallyPoint( {ScenarioInfo.PLAYER_AIR_FACTORY}, ScenarioUtils.MarkerToPosition( 'FACTORY_ROLLOFF_02' ) )

	IssueClearFactoryCommands( {ScenarioInfo.PLAYER_ILL_EXP_FACTORY} )
	IssueFactoryRallyPoint( {ScenarioInfo.PLAYER_ILL_EXP_FACTORY}, ScenarioUtils.MarkerToPosition( 'FACTORY_ROLLOFF_03' ) )

	-- Triggers to spawn in more units, cue music
	ScenarioFramework.CreateAreaTrigger(Enemy01_Reveal, ScenarioUtils.AreaToRect('ENEM_01'),
		categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER])

--	ScenarioFramework.CreateAreaTrigger(Enemy02_Reveal, ScenarioUtils.AreaToRect('ENEM_02'),
--		categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER])
end

function Enemy01_Reveal()
	-- Intel for locations
	--ScenarioFramework.CreateIntelAtLocation(75, 'ENEM01_INTEL', ARMY_PLAYER, 'Vision')
	LOG('Play battle music')
	Sync.PlayMusic = 'UI_demo_battle'
end

--function Enemy02_Reveal()
--	-- Intel for locations
--	--ScenarioFramework.CreateIntelAtLocation(75, 'ENEM02_INTEL', ARMY_PLAYER, 'Vision')
--
--end

---------------------------------------------------------------------
-- DEBUG FUNCTIONS:
---------------------------------------------------------------------
function OnShiftF3()
	-- Debug function calls
end