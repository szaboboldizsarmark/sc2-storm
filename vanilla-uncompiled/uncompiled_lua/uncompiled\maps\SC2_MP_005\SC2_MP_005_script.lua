function OnPopulate()
	import('/lua/sim/ScenarioUtilities.lua').InitializeArmies()
	local camData = {
		MinSpinPitch	= 0.5,		-- 0.1 = default	The min pitch resulting from a spin.
		MaxZoomMult		= 1.1,		-- 1.1 = default	Extra zoom out buffer so we can see the borders of the map clearly.
		FarZoom			= -1,		-- -1 = default		Farthest mouse can zoom out from terrain, measured in LOD units, -1 to ignore.
	}
	import('/lua/sim/SimCamera.lua').SimCamera('WorldCamera'):UpdateDefaults(camData)
end

function OnStart(self)
	local strMusic = 'SC2/MUSIC/MP/Conditional_Music'
	LOG('MP: Music: [', strMusic, ']')
	Sync.PlayMusic = strMusic
end

function OnShiftF3()
	import('/lua/sim/ScenarioFramework/ScenarioTesting.lua').GroupPicker_Increment()
end

function OnCtrlF3()
	import('/lua/sim/ScenarioFramework/ScenarioTesting.lua').GroupPicker_Decrement()
end

function OnShiftF4()
	import('/lua/sim/ScenarioFramework/ScenarioTesting.lua').TestPicker_Increment()
end

function OnCtrlF4()
	import('/lua/sim/ScenarioFramework/ScenarioTesting.lua').TestPicker_Decrement()
end

function OnShiftF5()
	import('/lua/sim/ScenarioFramework/ScenarioTesting.lua').ExecuteCurrentTest()
end