--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

--
-- Blueprint loading
--
--   During preloading of the map, we run loadBlueprints() from this file. It scans
--   the game directories and runs all .bp files it finds.
--
--   The .bp files call UnitBlueprint(), PropBlueprint(), etc. to define a blueprint.
--   All those functions do is fill in a couple of default fields and store off the
--   table in 'original_blueprints'.
--
--   Once that scan is complete, ModBlueprints() is called. It can arbitrarily mess
--   with the data in original_blueprints.
--
--   Finally, the engine registers all blueprints in original_blueprints to define the
--   "real" blueprints used by the game. A separate copy of these blueprints is made
--   available to the sim-side and user-side scripts.
--
-- How mods can affect blueprints
--
--   First, a mod can simply add a new blueprint file that defines a new blueprint.
--
--   Second, a mod can contain a blueprint with the same ID as an existing blueprint.
--   In this case it will completely override the original blueprint. Note that in
--   order to replace an original non-unit blueprint, the mod must set the "BlueprintId"
--   field to name the blueprint to be replaced. Otherwise the BlueprintId is defaulted
--   off the source file name. (Units don't have this problem because the BlueprintId is
--   shortened and doesn't include the original path).
--
--   Third, a mod can can contain a blueprint with the same ID as an existing blueprint,
--   and with the special field "Merge = true". This causes the mod to be merged with,
--   rather than replace, the original blueprint.
--
--   Finally, a mod can hook the ModBlueprints() function which manipulates the
--   blueprints table in arbitrary ways.
--      1. create a file /mod/s.../hook/system/Blueprints.lua
--      2. override ModBlueprints(all_bps) in that file to manipulate the blueprints
--
-- Reloading of changed blueprints
--
--   When the disk watcher notices that a .bp file has changed, it calls
--   ReloadBlueprint() on it. ReloadBlueprint() repeats the above steps, but with
--   original_blueprints containing just the one blueprint.
--
--   Changing an existing blueprint is not 100% reliable; some changes will be picked
--   up by existing units, some not until a new unit of that type is created, and some
--   not at all. Also, if you remove a field from a blueprint and then reload, it will
--   default to its old value, not to 0 or its normal default.
--

local sub = string.sub
local gsub = string.gsub
local lower = string.lower
local getinfo = debug.getinfo
local here = getinfo(1).source

local original_blueprints

local function InitOriginalBlueprints()
    original_blueprints = {
        Mesh = {},
        Unit = {},
		Ability = {},
        Prop = {},
        Projectile = {},
        TrailEmitter = {},
        Emitter = {},
        Beam = {},
        SkirmishEngineer = {},
        SkirmishFactory = {},
        SkirmishForm = {},
        PlatoonBlueprint = {},
        SkirmishResponse = {},
        SkirmishBase = {},
        SkirmishArchetype = {},
		AnimTree = {},
		RawAnim = {},
		AnimPack = {},
		Weapon = {},
		EntityCostume = {},
		EntityCostumeSet = {},
		Vendor = {},
		VendorCostumeItem = {},
		VendorWeaponItem = {},
    }
end

local function GetSource()
    -- Find the first calling function not in this source file
    local n = 2
    local there
    while true do
        there = getinfo(n).source
        if there!=here then break end
        n = n+1
    end
    if sub(there,1,1)=="@" then
        there = sub(there,2)
    end
    return DiskToLocal(there)
end


local function StoreBlueprint(group, bp)
    local id = bp.BlueprintId
    local t = original_blueprints[group]

    if t[id] and bp.Merge then
        bp.Merge = nil
        bp.Source = nil
        t[id] = table.merged(t[id], bp)
    else
        t[id] = bp
    end
end


--
-- Figure out what to name this blueprint based on the name of the file it came from.
-- Returns the entire filename. Either this or SetLongId() should really be got rid of.
--
local function SetBackwardsCompatId(bp)
    bp.Source = bp.Source or GetSource()
    bp.BlueprintId = lower(bp.Source)
end


--
-- Figure out what to name this blueprint based on the name of the file it came from.
-- Returns the full resource name except with ".bp" stripped off
--
local function SetLongId(bp)
    bp.Source = bp.Source or GetSource()
    if not bp.BlueprintId then
        local id = lower(bp.Source)
        id = gsub(id, "%.bp$", "")                          -- strip trailing .bp
        --id = gsub(id, "/([^/]+)/%1_([a-z]+)$", "/%1_%2")    -- strip redundant directory name
        bp.BlueprintId = id
    end
end


--
-- Figure out what to name this blueprint based on the name of the file it came from.
-- Returns just the base filename, without any blueprint type info or extension. Used
-- for units only.
--
local function SetShortId(bp)
    bp.Source = bp.Source or GetSource()
    bp.BlueprintId = bp.BlueprintId or
        gsub(lower(bp.Source), "^.*/([^/]+)_[a-z]+%.bp$", "%1")
end


--
-- If the bp contains a 'Mesh' section, move that over to a separate Mesh blueprint, and
-- point bp.MeshBlueprint at it.
--
-- Also fill in a default value for bp.MeshBlueprint if one was not given at all.
--
function ExtractMeshBlueprint(bp)
    local disp = bp.Display or {}
    bp.Display = disp

	if disp.MeshBlueprintVarieties then
		for k,mesh in disp.MeshBlueprintVarieties do
			if type(mesh)=='string' then
				if mesh!=lower(mesh) then
					--Should we allow mixed-case blueprint names?
					--LOG('Warning: ',bp.Source,' (MeshBlueprint): ','Blueprint IDs must be all lowercase')
					mesh = lower(disp.MeshBlueprint)
				end
		
				-- strip trailing .bp
				disp.MeshBlueprintVarieties[k] = gsub(mesh, "%.bp$", "")
			end
		end
	end			

    if disp.MeshBlueprint=='' then
        LOG('Warning: ',bp.Source,': MeshBlueprint should not be an empty string')
        disp.MeshBlueprint = nil
    end

    if type(disp.MeshBlueprint)=='string' then
        if disp.MeshBlueprint!=lower(disp.MeshBlueprint) then
            --Should we allow mixed-case blueprint names?
            --LOG('Warning: ',bp.Source,' (MeshBlueprint): ','Blueprint IDs must be all lowercase')
            disp.MeshBlueprint = lower(disp.MeshBlueprint)
        end

        -- strip trailing .bp
        disp.MeshBlueprint = gsub(disp.MeshBlueprint, "%.bp$", "")

        if disp.Mesh then
            LOG('Warning: ',bp.Source,' has mesh defined both inline and by reference')
        end
    end

    if disp.MeshBlueprint==nil then
        -- For a blueprint file "/units/uel0001/uel0001_unit.bp", the default
        -- mesh blueprint is "/units/uel0001/uel0001_mesh"
        if type(disp.Mesh)=='table' then
			local meshname, subcount = gsub(bp.Source, "_[a-z]+%.bp$", "_mesh")
			if subcount==1 then
				disp.MeshBlueprint = meshname
			end
            local meshbp = disp.Mesh
            meshbp.Source = meshbp.Source or bp.Source
            meshbp.BlueprintId = disp.MeshBlueprint
            -- roates:  Commented out so the info would stay in the unit BP and I could use it to precache by unit.
            -- disp.Mesh = nil
            MeshBlueprint(meshbp)
        end
    end
end

function ExtractWreckageBlueprint(bp)
	if not bp.Wreckage then return end

	if bp.Wreckage.UseCustomMesh then return end

    local meshid = bp.Display.MeshBlueprint
    if not meshid then return end

    local meshbp = original_blueprints.Mesh[meshid]
    if not meshbp then return end

    local wreckbp = table.deepcopy(meshbp)
    local sourceMeshBp = GetNonShadowedBlueprintSource(meshid)
    wreckbp.BlueprintId = sourceMeshBp .. '_wreck'    
    bp.Display.MeshBlueprintWrecked = wreckbp.BlueprintId
	for kLOD, vLOD in wreckbp.LODs do
		if vLOD.MaterialSets then
			for kSet, vSet in vLOD.MaterialSets do
				if vSet.Materials then
					for kMat, vMat in vSet.Materials do
						if (vMat.ShaderState != 'PortalCutoutState') and (vMat.ShaderState != 'PortalDepthState') then
							vMat.ShaderMacros = ( vMat.ShaderMacros or 'ambient_lighting, glow, diffuse_lighting, specular_lighting, ambient_occlusion, environment_mapping' ) ..  ', wreckage, wreckage_edge_highlight'
							vMat.EffectName = '/textures/Units/Shared/Wreckage.dds'
						end
					end
 				else
				    vSet.Materials = { ShaderMacros = 'ambient_lighting, glow, diffuse_lighting, specular_lighting, ambient_occlusion, environment_mapping, wreckage, wreckage_edge_highlight', Effectname = '/textures/Units/Shared/Wreckage.dds' }
				end
			end
		end
	end
    MeshBlueprint(wreckbp)
end

--
-- If the bp contains a 'Weapons' section, move that over to a separate Weapon blueprint, and
-- point bp.MeshBlueprint at it.
--
--
function ExtractWeaponBlueprint(bp)
	if not bp.Weapons then
		return
	end

	local modifiedWeaponsTable = {} -- store actual weapons in table
	local weaponIndex = 1 -- used for weapons with labels as key

	for k, weapon in bp.Weapons do
		-- if the key is a string, then it's the label of the weapon, so we need to create a new BP
		local label =  type(k) == "string" and k or false
		
		-- Command action defined for unit as a reference to unit
		if type(weapon) == 'string' then
			-- Make lowercase
			weapon = lower(weapon) 
			--LOG( 'Unit ability blueprint reference, ', repr(ability) )
			-- Search for currently stored blueprint reference
			for id, weaponbp in original_blueprints.Weapon do
				if weaponbp.Source == weapon then
					if label then
						-- if we have a new label, create a new blueprint
						local newWeaponbp = table.copy(weaponbp)
						newWeaponbp.Label = label
						newWeaponbp.BlueprintId = newWeaponbp.BlueprintId .. "_" .. label
						-- weapon should already have BlueprintId and Source
						WeaponBlueprint(newWeaponbp)
						modifiedWeaponsTable[weaponIndex] = newWeaponbp
					else
						modifiedWeaponsTable[weaponIndex] = weaponbp
					end
					weaponIndex = weaponIndex + 1
					--LOG( 'Remapping global weapon blueprint be inline in the unit bp ', repr(bp.Weapons[k]) )
					break
				end
			end
		-- Command action defined inline with a unit blueprint
		elseif type(weapon) == 'table' then
			if label then
				weapon.Label = label
			end

			if not weapon.BlueprintId then
				-- For a blueprint file "/units/uul0001/uul0001_unit.bp", the default
				-- weapon blueprint is "/units/uul0001/uul0001_weapon_label"
				local weaponname,subcount = gsub(bp.Source, "_[a-z]+%.bp$", "_weapon_" .. weapon.Label)
				if subcount==1 then
					weapon.BlueprintId = weaponname
				end
			end
			weapon.Source = weapon.Source or bp.Source

			--LOG( 'Unit Inline weapon blueprint defined, ', repr(weapon) )
			WeaponBlueprint(weapon)
			modifiedWeaponsTable[weaponIndex] = weapon
			weaponIndex = weaponIndex + 1
		end
	end

	local weaponsTableConvertedToResIds = {} -- store actual weapons in table
	for k, v in modifiedWeaponsTable do
		weaponsTableConvertedToResIds[k] = v.BlueprintId
	end

	--LOG( 'weaponsTableConvertedToResIds, ', repr(weaponsTableConvertedToResIds) )

	-- finally assigned fixed up weapons table
	bp.Weapons = weaponsTableConvertedToResIds
end

function ExtractCostStamp(bp)
	if not bp.Navigation.CostStamp then
		return
	end

	if type(bp.Navigation.CostStamp) == 'string' then

		if bp.Navigation.CostStamp == '' then
			LOG('Warning: ',bp.Source,': Navigation.CostStamp should not be an empty string. Required to be a table or a string path.')
			bp.Navigation.CostStamp = nil
			return
		end

		local importedCostStamp = {}
		local ok, msg = pcall(doscript, bp.Navigation.CostStamp, importedCostStamp )
		if not ok or table.empty(importedCostStamp) then
			LOG( msg )
			LOG('Warning: ',bp.Source,': Navigation.CostStamp of ', bp.Navigation.CostStamp, '. Unable to lookup cost stamp information.')
			bp.Navigation.CostStamp = nil
			return
		end

		bp.Navigation.CostStamp = table.copy(importedCostStamp.CostStamp)
	end

end

-- convert state names to ints
function GetStateEnum( enumTrans, stateName )
	-- if key doesn't exist, then increment size of num states, and add new entry
	local retVal = enumTrans[stateName]
	if not retVal then
		local newID = enumTrans._NumStates
		enumTrans[stateName]  = newID
		retVal = newID
		enumTrans._NumStates = enumTrans._NumStates + 1
	end

	return retVal
end


function GetAnimTreeState( childTable, parentID, flatList, enumTranslationTable )
	for childName, childData in childTable do
		local stateName = childName
		local stateId = GetStateEnum( enumTranslationTable, stateName )
		local type = childData.type
		local transitions = {}
		-- go through transitions and convert state names to values & prepare it to match blueprint spec
		if childData.transitions then
			table.resizeandclear(transitions, childData.transitions)
			local index = 1
			for k,v in childData.transitions do
				transitions[index] = {EventName = k, TargetStateID = GetStateEnum( enumTranslationTable, v.TargetStateID ) }
				index = index + 1
			end
		end
		local data = childData.data

		local newEntry = { 
							["StateName"] = stateName, 
							["StateID"] = stateId, 
							["ParentID"] = parentID,  
							["Transitions"] = transitions,
							["NodeType"] = type, 
							["NodeData"] = data,
						 }
		-- add 1 here because this data needs to be a 1 based array, while the states need to be 0 based
		-- I hate you Lua.
		flatList[stateId+1] = newEntry

		if childData.children then
			GetAnimTreeState( childData.children, stateId, flatList, enumTranslationTable )
		end
	end	
end


function FlattenAnimTreeBlueprint(animTree, enumTrans)
	if not animTree then return end
	local flatListOfStates = {}
	GetAnimTreeState( animTree, -1, flatListOfStates, enumTrans )
	-- validate blueprint
	for stateName,stateId in enumTrans do
		if stateName == "_NumStates" then
			continue
		end

		-- again, StateId is actually 1 smaller than the index it's stored at
		if not flatListOfStates[stateId+1] or flatListOfStates[stateId+1].StateID ~= stateId then
			error("Declared state ".. stateName .." in a transition, but never actually found that state in the tree" )
		end
	end

	return flatListOfStates
end


--
-- If the bp contains a 'AnimTree' section, move that over to a separate AnimTree blueprint, and
-- point bp.AnimTree at it.
--
-- Also fill in a default value for bp.AnimTree if one was not given at all.
--
function ExtractAnimTreeBlueprint(bp)
	if not bp.AnimTree then
		return
	end

	local animtree = bp.AnimTree

    -- Command action defined for unit as a reference to unit
	if type(animtree) == 'string' then
		-- Make lowercase
		local animtree = lower(animtree)

		--LOG( 'Unit animtree blueprint reference, ', repr(ability) )
		-- Search for currently stored blueprint reference
		for id, animtreebp in original_blueprints.AnimTree do
			if animtreebp.Source == animtree then
				bp.AnimTree = animtreebp
				bp.AnimTree.Source = animtree
				--LOG( 'Remapping global animtree blueprint be inline in the unit bp ', repr(bp.AnimTree[k]) )
				continue
			end
		end
	-- Command action defined inline with a unit blueprint
	elseif type(animtree) == 'table' then

		if not animtree.BlueprintId then
			-- For a blueprint file "/units/uul0001/uul0001_unit.bp", the default
			-- ability blueprint is "/units/uul0001/uul0001_animtree"
			local animtreename,subcount = gsub(bp.Source, "_[a-z]+%.bp$", "_animtree")
			if subcount==1 then
				animtree.BlueprintId = animtreename
			end
		end

		if not animtree.Source then
			animtree.Source = bp.Source
		end
		--LOG( 'Unit Inline animtree blueprint defined, ', repr(animtree) )
		AnimTreeBlueprint(animtree)	
	end

end

function MeshBlueprint(bp)
    SetLongId(bp)
    StoreBlueprint('Mesh', bp)
end

function GetUnitIconFileNames(blueprint)
    local iconName = '/textures/ui/common/icons/units/' .. blueprint.Display.IconName .. '_icon.dds'
    local upIconName = '/textures/ui/common/icons/units/' .. blueprint.Display.IconName .. '_build_btn_up.dds'
    local downIconName = '/textures/ui/common/icons/units/' .. blueprint.Display.IconName .. '_build_btn_down.dds'
    local overIconName = '/textures/ui/common/icons/units/' .. blueprint.Display.IconName .. '_build_btn_over.dds'
    
    if DiskGetFileInfo(iconName) == false then
        iconName = '/textures/ui/common/icons/units/default_icon.dds'
    end
    
    if DiskGetFileInfo(upIconName) == false then
        upIconName = iconName
    end

    if DiskGetFileInfo(downIconName) == false then
        downIconName = iconName
    end

    if DiskGetFileInfo(overIconName) == false then
        overIconName = iconName
    end
    
    return iconName, upIconName, downIconName, overIconName
end

-- add the filenames of the icons to the blueprint, creating a new RuntimeData table in the process where runtime things
-- can be stored in blueprints for convenience
function SetUnitIconBitmapPath(bp)
	bp.RuntimeData = {}
	if bp.Display.IconName then -- filter for icon name
		bp.RuntimeData.IconFileName, bp.RuntimeData.UpIconFileName, bp.RuntimeData.DownIconFileName, bp.RuntimeData.OverIconFileName  = GetUnitIconFileNames(bp)
	end
end


function UnitBlueprint(bp)
    SetShortId(bp)
	SetUnitIconBitmapPath(bp)
    StoreBlueprint('Unit', bp)
end

function PropBlueprint(bp)
    SetBackwardsCompatId(bp)
    StoreBlueprint('Prop', bp)
end

function ProjectileBlueprint(bp)
    SetBackwardsCompatId(bp)
    StoreBlueprint('Projectile', bp)
end

function WeaponBlueprint(bp)
	SetLongId(bp)
	StoreBlueprint('Weapon', bp)
end

function TrailEmitterBlueprint(bp)
    SetBackwardsCompatId(bp)
    StoreBlueprint('TrailEmitter', bp)
end

function EmitterBlueprint(bp)
    SetBackwardsCompatId(bp)
    StoreBlueprint('Emitter', bp)
end

function BeamBlueprint(bp)
    SetBackwardsCompatId(bp)
    StoreBlueprint('Beam', bp)
end

function AbilityBlueprint(bp)
	SetShortId(bp)
	StoreBlueprint('Ability', bp)
	--LOG( 'Loading AbilityBlueprint ', bp.BlueprintId, ' ',  bp.Source )
end

function SkirmishEngineerBlueprint(bp)
    StoreBlueprint('SkirmishEngineer', bp)
end

function SkirmishFactoryBlueprint(bp)
    StoreBlueprint('SkirmishFactory', bp)
end

function SkirmishFormBlueprint(bp)
    StoreBlueprint('SkirmishForm', bp)
end

function PlatoonBlueprint(bp)
    StoreBlueprint('PlatoonBlueprint', bp)
end

function SkirmishResponseBlueprint(bp)
    StoreBlueprint('SkirmishResponse', bp)
end

function SkirmishBaseBlueprint(bp)
    StoreBlueprint('SkirmishBase', bp)
end

function SkirmishArchetypeBlueprint(bp)
    StoreBlueprint('SkirmishArchetype', bp)
end


function AnimTreeBlueprint(bp)
	SetShortId(bp)
	LOG("Loading animtree: ", bp.BlueprintId )
	-- flatten anim tree
	-- if we don't have a translation table yet, make one.  This keeps us from
	-- having to define the enumeration in C++
	local enumTrans = {_NumStates = 0}
	bp.AnimTreeStates = FlattenAnimTreeBlueprint(bp.AnimTreeStates, enumTrans)
	local startState = enumTrans[bp.StartStateID]
	if not startState then
		error("Invalid Start State: " .. bp.StartStateID)
		return
	end
	-- this state's index in this tree is off by one due to Lua arrays starting at 1
	local children = bp.AnimTreeStates[startState+1].children
	if children and not table.empty(children) then
		error("Start state " .. bp.StartStateID .. " has children, needs to be leaf state!")
		return
	end
	bp.StartStateID = startState
	StoreBlueprint('AnimTree', bp)
end


function GetEventGroup( event ) 
	if event.Trigger == 'OnStart' then		
		return 1
	elseif event.Trigger == 'OnLoop' and event.Direction == 'Reverse' then
		return 2
	elseif event.Trigger == 'OnFrame' then
		return 3
	elseif event.Trigger == 'OnLoop' and eventDirection ~= 'Reverse' then
		return 4
	elseif event.Trigger == 'OnEnd' then
		return 5
	else
		WARN( "GetEventGroup could not determine a proper group for an event!" )
		return -1
	end
end

function RawAnimEventSorter( a, b )
	-- Proper sorting is: [ OnStart, OnLoop(Reverse), OnFrame(by frame--), OnLoop(Forward), OnEnd ]
	local groupA = GetEventGroup(a)
	local groupB = GetEventGroup(b)
	
	if groupA < groupB then
		return true
	elseif groupA > groupB then
		return false
	else
		if groupA == 3 then
			return a.Frame < b.Frame
		end
	end

	-- At this point it doesn't matter, they are in the same group and that group's sortings don't matter
	return true
end

function RawAnimBlueprint(bp)
	for rawAnimName, rawAnimBP in bp do
		rawAnimBP.Source = GetSource()
		rawAnimBP.BlueprintId = rawAnimName
		
		if original_blueprints.RawAnim[ rawAnimBP.BlueprintId ] ~= nil then
			WARN( "RawAnim blueprint [" .. rawAnimBP.BlueprintId .. "] was defined in multiple locations" )
		end
		
		-- Convert nice, clean, readable data from blueprint into the format needed by the engine
		-- class RRawAnimBlueprint { RAnimEventsBlueprint events, stuff }
		-- class RAnimEventsBlueprint { vector<RAnimEventBlueprint> events, stuff }
		-- class RAnimEventBlueprint { RAnimEventArgsBlueprint, stuff }
		
		-- Event args are stored in a flat list for clarity, but in engine RAnimEventArgsBlueprint
		-- is a member of RAnimEventBlueprint, so pull the appropriate args out into a subtable
		if rawAnimBP.Events then
			
			for index, event in rawAnimBP.Events do
				event.Args = {}
				event.Args['StringArg1'] = event.SoundName or event.EffectTemplate or event.CallbackFunc or event.AnimCommand or event.StringArg1
				event.Args['StringArg2'] = event.LuaStrArg or event.AnimStateName or event.BoneName or event.StringArg2
				event.Args['IntArg1'] = event.AnimStartFrame or event.FxDuration or event.IntArg1
				event.Args['IntArg2'] = event.IntArg2
				event.Args['VectorArg1'] = event.Offset or event.VectorArg1
				
				-- Convert frame number into seconds for use by the engine
				-- Frame -- is assuming 30 frames per second, so frame 45 would be 45 * (1.0/30.0) = 1.5 seconds
				if event.Frame ~= nil then
					event.Time = event.Frame * (1.0/30.0)
				end
			end
				
			-- The list of events in engine is stored in a master RAnimEventsBlueprint, so we need
			-- to add the extra layer of indirection here
			local events = rawAnimBP.Events
			
			table.sort( events, RawAnimEventSorter )
			rawAnimBP.Events = { Events = events }
		end
		StoreBlueprint('RawAnim', rawAnimBP)
	end
end
	
function AnimPackBlueprint(bp)
	for animPackName, animPackBP in bp do
		animPackBP.Source = GetSource()
		animPackBP.BlueprintId = animPackName
		
		if original_blueprints.AnimPack[ animPackBP.BlueprintId ] then
			WARN( "AnimPack blueprint [" .. animPackBP.BlueprintId .. "] was defined in multiple locations" )
		end
		
		StoreBlueprint('AnimPack', animPackBP)
	end
end

function EntityCostumeBlueprint(bp)
	for costumeName, costumeBP in bp do
		costumeBP.Source = GetSource()
		costumeBP.BlueprintId = costumeName
		
		if original_blueprints.EntityCostume[ costumeBP.BlueprintId ] then
			WARN( "Costume blueprint [" .. costumeBP.BlueprintId .. "] was defined in multiple locations" )
		end
		
		StoreBlueprint( 'EntityCostume', costumeBP )
	end
end

function EntityCostumeSetBlueprint(bp)
	for costumeSetName, costumeSetBP in bp do
		costumeSetBP.Source = GetSource()
		costumeSetBP.BlueprintId = costumeSetName 
		
		if original_blueprints.EntityCostumeSet[ costumeSetBP.BlueprintId ] then
			WARN( "CostumeSet blueprint [" .. costumeSetBP.BlueprintId .. "] was defined in multiple locations" )
		end
		
		StoreBlueprint( 'EntityCostumeSet', costumeSetBP )
	end
end

function VendorBlueprint(bp)
	for vendorName, vendorBP in bp do
		vendorBP.Source = GetSource()
		vendorBP.BlueprintId = vendorName
		
		if original_blueprints.Vendor[ vendorBP.BlueprintId ] then
			WARN( "Vendor blueprint [" .. vendorBP.BlueprintId .. "] was defined in multiple locations" )
		end
		
		StoreBlueprint( 'Vendor', vendorBP )
	end
end

function VendorCostumeItemBlueprint(bp)
	for costumeName, costumeBP in bp do
		costumeBP.Source = GetSource()
		costumeBP.BlueprintId = costumeName
		
		if original_blueprints.VendorCostumeItem[ costumeBP.BlueprintId ] then
			WARN( "Vendor Costume Item blueprint [" .. costumeBP.BlueprintId .. "] was defined in multiple locations" )
		end
		
		StoreBlueprint( 'VendorCostumeItem', costumeBP )
	end
end

function VendorWeaponItemBlueprint(bp)
	for weaponName, weaponBP in bp do
		weaponBP.Source = GetSource()
		weaponBP.BlueprintId = weaponName
		
		if original_blueprints.VendorWeaponItem[ weaponBP.BlueprintId ] then
			WARN( "Vendor Weapon Item blueprint [" .. weaponBP.BlueprintId .. "] was defined in multiple locations" )
		end
		
		StoreBlueprint( 'VendorWeaponItem', weaponBP )	
	end
end

function ExtractBlueprints()
    for id,bp in original_blueprints.Unit do
        ExtractMeshBlueprint(bp)
		ExtractWeaponBlueprint(bp)
        ExtractWreckageBlueprint(bp)
		ExtractAnimTreeBlueprint(bp)
		ExtractCostStamp(bp)
    end

    for id,bp in original_blueprints.Prop do
        ExtractMeshBlueprint(bp)
        ExtractWreckageBlueprint(bp)
    end

    for id,bp in original_blueprints.Projectile do
        ExtractMeshBlueprint(bp)
    end
end

function RegisterAllBlueprints(blueprints)

    local function RegisterGroup(g, fun)
        for id,bp in sortedpairs(g) do
            fun(g[id])
        end
    end

	RegisterGroup(blueprints.AnimTree, RegisterAnimTreeBlueprint)
	RegisterGroup(blueprints.Ability, RegisterAbilityBlueprint)
	RegisterGroup(blueprints.Weapon, RegisterWeaponBlueprint)
    RegisterGroup(blueprints.Mesh, RegisterMeshBlueprint)
    RegisterGroup(blueprints.Unit, RegisterUnitBlueprint)
    RegisterGroup(blueprints.Prop, RegisterPropBlueprint)
    RegisterGroup(blueprints.Projectile, RegisterProjectileBlueprint)
    RegisterGroup(blueprints.TrailEmitter, RegisterTrailEmitterBlueprint)
    RegisterGroup(blueprints.Emitter, RegisterEmitterBlueprint)
    RegisterGroup(blueprints.Beam, RegisterBeamBlueprint)
    RegisterGroup(blueprints.RawAnim, RegisterRawAnimBlueprint)
    RegisterGroup(blueprints.AnimPack, RegisterAnimPackBlueprint)
    RegisterGroup(blueprints.EntityCostume, RegisterEntityCostumeBlueprint)
    RegisterGroup(blueprints.EntityCostumeSet, RegisterEntityCostumeSetBlueprint)
    RegisterGroup(blueprints.Vendor, RegisterVendorBlueprint)
    RegisterGroup(blueprints.VendorCostumeItem, RegisterVendorCostumeItemBlueprint)
    RegisterGroup(blueprints.VendorWeaponItem, RegisterVendorWeaponItemBlueprint)
	RegisterGroup(blueprints.Weapon, PostInitWeaponBlueprint)
	
	-- Skirmish blueprints must be initialized after categories. Therefore, they must be after
	--     units, props, projectiles, etc
    RegisterGroup(blueprints.SkirmishEngineer, RegisterAiSkirmishEngineerBlueprint)
    RegisterGroup(blueprints.SkirmishFactory, RegisterAiSkirmishFactoryBlueprint)
    RegisterGroup(blueprints.SkirmishForm, RegisterAiSkirmishFormBlueprint)
    RegisterGroup(blueprints.PlatoonBlueprint, RegisterPlatoonBlueprint)
    RegisterGroup(blueprints.SkirmishResponse, RegisterAiSkirmishResponseBlueprint)
    RegisterGroup(blueprints.SkirmishBase, RegisterAiSkirmishBaseBlueprint)
    RegisterGroup(blueprints.SkirmishArchetype, RegisterAiSkirmishArchetypeBlueprint)
end


-- Hook for mods to manipulate the entire blueprint table
function ModBlueprints(all_blueprints)
end


-- Load all blueprints
function LoadBlueprints()
    LOG('Loading blueprints...')
    InitOriginalBlueprints()

    for i,dir in {'/effects', '/env', '/meshes', '/projectiles', '/props', '/lua/sim/abilities', '/abilities', '/anims', '/weapons', '/units', '/lua/ai', '/costumes', '/vendor' } do
        for k,file in DiskFindFiles(dir, '*.bp') do
            BlueprintLoaderUpdateProgress()
            safecall("loading blueprint "..file, doscript, file)
        end
    end

    for i,m in __active_mods do
        for k,file in DiskFindFiles(m.location, '*.bp') do
            BlueprintLoaderUpdateProgress()
            --LOG("applying blueprint mod "..file)
            safecall("loading mod blueprint "..file, doscript, file)
        end
    end

    BlueprintLoaderUpdateProgress()
    LOG('Extracting mesh blueprints.')
    ExtractBlueprints()

    BlueprintLoaderUpdateProgress()
    LOG('Modding blueprints.')
    ModBlueprints(original_blueprints)

    BlueprintLoaderUpdateProgress()
    LOG('Registering blueprints...')
    RegisterAllBlueprints(original_blueprints)
    original_blueprints = nil

    LOG('Blueprints loaded')
end

-- Reload a single blueprint
function ReloadBlueprint(file)
    InitOriginalBlueprints()

    safecall("reloading blueprint "..file, doscript, file)

    ExtractBlueprints()
    ModBlueprints(original_blueprints)
    RegisterAllBlueprints(original_blueprints)
    original_blueprints = nil
end