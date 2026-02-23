-- defines meshes and textures for commands

commandMeshResources = {
	-- Below is an example of how to use the command markers prop blueprints instead of an explicit mesh.
	-- FormMove = { '', '', '/props/markers/commands/uef_rally/uef_rally_prop.bp', '/props/markers/commands/uef_rally/UEF_Rally_A001.sca' },
	FormMove = { '',  '', '/props/markers/commands/move/move_prop.bp', '/props/markers/commands/move/move_Aidle01.sca'},
	Move = { '',  '', '/props/markers/commands/move/move_prop.bp', '/props/markers/commands/move/move_Aidle01.sca'},
	CoordinatedMove = { '',  '', '/props/markers/commands/move/move_prop.bp', '/props/markers/commands/move/move_Aidle01.sca'},
	Attack = { '',  '', '/props/markers/commands/attack/attack_prop.bp', '/props/markers/commands/attack/attack_Aidle01.sca'},
	FormAttack = { '',  '', '/props/markers/commands/attack/attack_prop.bp', '/props/markers/commands/attack/attack_Aidle01.sca'},
	AggressiveMove = { '',  '', '/props/markers/commands/attack/attack_prop.bp', '/props/markers/commands/attack/attack_Aidle01.sca'},
	FormAggressiveMove = { '',  '', '/props/markers/commands/attack/attack_prop.bp', '/props/markers/commands/attack/attack_Aidle01.sca'},
	Guard = { '',  '', '/props/markers/commands/assist/assist_prop.bp', '/props/markers/commands/assist/assist_Aidle01.sca'},
	Capture = { '',  '', '/props/markers/commands/capture/capture_prop.bp', '/props/markers/commands/capture/capture_Aidle01.sca'},
	Ferry = { '/meshes/game/Ferry_lod0.scm', '/meshes/game/Ferry_albedo.dds' },
	Nuke = { '/meshes/game/Launch_Missile02_lod0.scm', '/meshes/game/Launch_Missile02_albedo.dds' },
	EMP = { '',  '', '/props/markers/commands/attack/attack_prop.bp', '/props/markers/commands/attack/attack_Aidle01.sca'},
	Tactical = { '/meshes/game/Launch_Missile01_lod0.scm', '/meshes/game/Launch_Missile01_albedo.dds' },
	TransportLoadUnits = { '/meshes/game/Load_lod0.scm', '/meshes/game/Load_albedo.dds' },
	TransportReverseLoadUnits = { '/meshes/game/Load_lod0.scm', '/meshes/game/Load_albedo.dds' },
	TransportUnloadUnits = { '/meshes/game/Unload_lod0.scm', '/meshes/game/Unload_albedo.dds' },
	OverCharge = { '/meshes/game/Overcharge_lod0.scm', '/meshes/game/Overcharge_albedo.dds' },
	Patrol = { '',  '', '/props/markers/commands/patrol/patrol_prop.bp', '/props/markers/commands/patrol/patrol_Aidle01.sca'},
	FormPatrol = { '',  '', '/props/markers/commands/patrol/patrol_prop.bp', '/props/markers/commands/patrol/patrol_Aidle01.sca'},
	Reclaim = { '',  '', '/props/markers/commands/reclaim/reclaim_prop.bp', '/props/markers/commands/reclaim/reclaim_Aidle01.sca'},
	Repair = { '',  '', '/props/markers/commands/repair/repair_prop.bp', '/props/markers/commands/repair/repair_Aidle01.sca'},
	Sacrifice = { '/meshes/game/Sacrifice_lod0.scm', '/meshes/game/Sacrifice_albedo.dds' },
	Teleport = { '/meshes/game/Teleport_lod0.scm', '/meshes/game/Teleport_albedo.dds' },
	ping_alert = { '/props/Markers/M_ObjectiveArrow_lod0.scm', '/meshes/game/ping_alert_Albedo.dds' },
	ping_attack = { '/props/Markers/M_ObjectiveArrow_lod0.scm', '/meshes/game/ping_attack_Albedo.dds' },
	ping_move = { '/props/Markers/M_ObjectiveArrow_lod0.scm', '/meshes/game/ping_move_Albedo.dds' },
}

rallyMeshes = {
	uef = {
		Move = { '',  '', '/props/markers/commands/uef_rally/uef_rally_prop.bp', '/props/markers/commands/uef_rally/uef_rally_a001.sca'},
		Patrol = { '',  '', '/props/markers/commands/uef_rally/uef_rally_prop.bp', '/props/markers/commands/uef_rally/uef_rally_a001.sca'},
		Guard = { '',  '', '/props/markers/commands/uef_rally/uef_rally_prop.bp', '/props/markers/commands/uef_rally/uef_rally_a001.sca'},
	},
	illuminate = {
		Move = { '',  '', '/props/markers/commands/illuminate_rally/illuminate_rally_prop.bp', '/props/markers/commands/illuminate_rally/illuminate_rally_a001.sca'},
		Patrol = { '',  '', '/props/markers/commands/illuminate_rally/illuminate_rally_prop.bp', '/props/markers/commands/illuminate_rally/illuminate_rally_a001.sca'},
		Guard = { '',  '', '/props/markers/commands/illuminate_rally/illuminate_rally_prop.bp', '/props/markers/commands/illuminate_rally/illuminate_rally_a001.sca'},
	},
	cybran = {
		Move = { '',  '', '/props/markers/commands/cybran_rally/cybran_rally_prop.bp', '/props/markers/commands/cybran_rally/cybran_rally_a001.sca'},
		Patrol = { '',  '', '/props/markers/commands/cybran_rally/cybran_rally_prop.bp', '/props/markers/commands/cybran_rally/cybran_rally_a001.sca'},
		Guard = { '',  '', '/props/markers/commands/cybran_rally/cybran_rally_prop.bp', '/props/markers/commands/cybran_rally/cybran_rally_a001.sca'},
	},
}