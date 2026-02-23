--*******************************************************************
-- CAMPAIGN SELECTION STRINGS:
--*******************************************************************
OPERATION_NAME = '<LOC SCENARIO_0497>Camera, Commands, and Building'
OPERATION_NUMBER = '1. '
OPERATION_DESC = '<LOC SCENARIO_0498>In this tutorial operation, you will learn how to change your view of the battlefield, issue orders to your units, and build structures.'

--*******************************************************************
-- OBJECTIVES STRINGS:
--*******************************************************************

--*** Camera objectives
TUT01_Obj_CameraPan_NAME = '<LOC SCENARIO_0499>Pan and Scan'
TUT01_Obj_CameraPan_DESC = '<LOC SCENARIO_0500>Using the indicated controls, explore the area surrounding the ACU using the Pan interface.'
TUT01_Obj_CameraPan_UI = {
	'<LOC SCENARIO_0501>To pan the camera, use the Arrow Keys on the keyboard or move the Mouse cursor to the edges of the screen.',
	'<LOC SCENARIO_0502>To pan the camera, use the Left Stick.',
}

TUT01_Obj_CameraRotate_NAME = '<LOC SCENARIO_0503>Spin Me Round'
TUT01_Obj_CameraRotate_DESC = '<LOC SCENARIO_0504>Using the indicated controls, rotate around the ACU using the Rotate interface.'
TUT01_Obj_CameraRotate_UI = {
	'<LOC SCENARIO_0505>To rotate the camera, hold down the Space Bar and move the Mouse left and right.',
	'<LOC SCENARIO_0506>To rotate the camera, move the Right Stick left and right.',
}

TUT01_Obj_CameraTilt_NAME = '<LOC SCENARIO_0507>A New Angle'
TUT01_Obj_CameraTilt_DESC = '<LOC SCENARIO_0508>Using the indicated controls, change the angle of your view using the Tilt interface.'
TUT01_Obj_CameraTilt_UI ={
	'<LOC SCENARIO_0509>To change the pitch of the camera, hold down the Space Bar and move the Mouse forward and back.',
	'<LOC SCENARIO_0510>To change the pitch of the camera, hold the Right Trigger and move the Right Stick forward and back.',
}

TUT01_Obj_CameraZoom_NAME = '<LOC SCENARIO_0511>Zoom!'
TUT01_Obj_CameraZoom_DESC = '<LOC SCENARIO_0512>Using the indicated controls, Zoom the view in and out.'
TUT01_Obj_CameraZoom_UI = {
	'<LOC SCENARIO_0513>To zoom in and out, use the Mouse Wheel.',
	'<LOC SCENARIO_0514>To zoom in and out, move the Right Stick forward and back.',
}

--*** Selection objectives
TUT01_Obj_SelectSingle_NAME = '<LOC SCENARIO_0515>Select Me'
TUT01_Obj_SelectSingle_DESC = '<LOC SCENARIO_0516>Using the indicated controls, select the Armored Command Unit.'
TUT01_Obj_SelectSingle_UI = {
	'<LOC SCENARIO_0517>To select a unit, move the cursor over the unit and press the Left Mouse button.',
	'<LOC SCENARIO_0518>To select a unit, move the cursor over the unit and press the A button.',
}

--*** Commands objectives
TUT01_Obj_CommandsMove_NAME = '<LOC SCENARIO_0519>Get Movin\''
TUT01_Obj_CommandsMove_DESC = '<LOC SCENARIO_0520>Using the indicated controls, use the Move command to send your ACU or the Rock Head Tanks to the exit of the facility.'
TUT01_Obj_CommandsMove_UI = {
	'<LOC SCENARIO_0521>To issue a Move order, select the unit or units and Right Click on a valid destination.',
	'<LOC SCENARIO_0522>To issue a Move order, select the unit or units and press the X button on a valid destination.',
}

TUT01_Obj_CommandsAttack_NAME = '<LOC SCENARIO_0523>Energy Assassin'
TUT01_Obj_CommandsAttack_DESC = '<LOC SCENARIO_0524>Using the indicated controls, order your units to attack the Energy Production facilities.'
TUT01_Obj_CommandsAttack_UI = {
	'<LOC SCENARIO_0525>To issue an Attack order, select the unit or units and Right Click on a valid target.',
	'<LOC SCENARIO_0526>To issue an Attack order, select the unit or units and press the X button on a valid target.',
}

TUT02_Obj_Capture_NAME = '<LOC SCENARIO_0527>Capture Me'
TUT02_Obj_Capture_DESC = '<LOC SCENARIO_0528>Using the Capture special ability, take control of that enemy warehouse.'
TUT02_Obj_Capture_UI = {
	'<LOC SCENARIO_0529>To Capture a unit, Left Click the "Capture" icon in the Special Abilities menu and Left Click again on the unit you want to capture.',
	'<LOC SCENARIO_0530>To Capture a unit, press "Right" on the D-Pad to switch to "Capture" mode and press X when the cursor is on the unit you want to capture.'
}

--*** Combat objectives
TUT01_Obj_Combat_NAME = '<LOC SCENARIO_0531>Tank Attack'
TUT01_Obj_Combat_DESC = '<LOC SCENARIO_0532>Order all of your units to attack the enemy Rock Head Tanks.'


--*******************************************************************
-- PART 2 STRINGS:
--*******************************************************************

--*** Build objectives
TUT02_Obj_BuildFactory_NAME = '<LOC SCENARIO_0533>Land Zone'
TUT02_Obj_BuildFactory_DESC = '<LOC SCENARIO_0534>Using the Build interface, construct a Land Factory.'
TUT02_Obj_BuildFactory_UI = {
	'<LOC SCENARIO_0535>To build a structure, select your ACU or an Engineer. Click the icon of the structure you want to build from the Build Menu. Place it on valid terrain to begin construction.',
	'<LOC SCENARIO_0536>To build a structure, select your ACU or an Engineer and press Y to access their Build Radial. Select the structure you want to build and place it on valid terrain to begin construction.',
}

TUT02_Obj_BuildMass_NAME = '<LOC SCENARIO_0537>Amass Mass'
TUT02_Obj_BuildMass_DESC = '<LOC SCENARIO_0538>Using the Build interface, construct a Mass Extractor.'

TUT02_Obj_BuildEnergy_NAME = '<LOC SCENARIO_0539>Energize'
TUT02_Obj_BuildEnergy_DESC = '<LOC SCENARIO_0540>Using the Build interface, construct an Energy Production Facility.'

--*** Unit build objective
TUT02_Obj_MobileBuild_NAME = '<LOC SCENARIO_0541>Giving Tanks'
TUT02_Obj_MobileBuild_DESC = '<LOC SCENARIO_0542>Using the Land Factory\'s Build interface, add two Rock Head Tanks to your army.'
TUT02_Obj_MobileBuild_UI = {
	'<LOC SCENARIO_0543>To build a Rock Head Tank, select a Land Factory. Click on the Rock Head Tank icon to build one unit. Click it multiple times to queue up multiple units.',
	'<LOC SCENARIO_0544>To build a Rock Head Tank, select a Land Factory. Press Y to access the Build Radial. Select the Rock Head Tank icon and press A to build one unit. Press A multiple times to queue up multiple units.',
}

--*** Add-on objective
TUT02_Obj_BuildAddon_NAME = '<LOC SCENARIO_0545>Add Add-Ons'
TUT02_Obj_BuildAddon_DESC = '<LOC SCENARIO_0546>Using the Build interface, add a Tactical Missile Launcher and Shield to your Land Factory.'
TUT02_Obj_BuildAddon_UI = {
	'<LOC SCENARIO_0547>To build an Add-On, select a Land Factory. Select the Add-On Tab. Click on the icon for the Add-On you want to build.',
	'<LOC SCENARIO_0548>To build an Add-On, select a Land Factory. Press Y to access the Build Radial. Press Y again to switch to the Add-On Radial. Select the Add-On you want to build and press A.',
}


--*** Combat1 objective
TUT02_Obj_Combat1_NAME = '<LOC SCENARIO_0549>Base of Operations'
TUT02_Obj_Combat1_DESC = '<LOC SCENARIO_0550>An enemy base is producing Rock Head Tanks that are harassing your own base. Destroy its factories to end the simulation.'


--*******************************************************************
-- HINTS:
--*******************************************************************
TUT01_Queue_Hint_UI = {
	'<LOC SCENARIO_0551>To queue orders, hold down Shift when issuing each one.',
	'<LOC SCENARIO_0552>To queue orders, hold down Right Trigger when issuing each one.',
}

TUT01_Multiselect_UI = {
	'<LOC SCENARIO_0553>To select multiple units, hold the Left Mouse Button and move the mouse to drag a selection box over the units.',
	'<LOC SCENARIO_0554>To select multiple units, press RB to select all units on screen.',
}

TUT01_Multiselect2_UI = {
	'<LOC SCENARIO_0555>To select all of a specific type of unit, Double-Click the Left Mouse button on one of that type of unit.',
	'<LOC SCENARIO_0556>To select all of a specific type of unit, Double-tap the A button on one of that type of unit.',
}

TUT01_Idle_UI = {
	'<LOC SCENARIO_0559>Idle builder units are indicated with an exclamation point in the Idle Builders UI.',
	'<LOC SCENARIO_0560>Idle builder units are indicated with an exclamation point in the Build Radial.',
}

TUT01_Rally_UI = {
	'<LOC SCENARIO_0561>To set a Rally Point for a factory, select the factory and Right Click on a valid destination. The next unit built will automatically move to that location.',
	'<LOC SCENARIO_0562>To set a Rally Point for a factory, select the factory and press the X button on a valid destination. The next unit built will automatically move to that location.',
}

TUT01_Objectives_UI = {
	'<LOC SCENARIO_0563>To view your current objective, Left Click on its icon.',
	'<LOC SCENARIO_0564>To view your current objective, press the BACK button.',
}

TUT01_Reset_UI = {
	'<LOC SCENARIO_0565>If you ever want to return to the default view of the battlefield, you can press V to reset the camera.',
	'<LOC SCENARIO_0566>If you ever want to return to the default view of the battlefield, you can press the Right Trigger to reset the camera.',
}
