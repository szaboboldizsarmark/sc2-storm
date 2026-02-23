--****************************************************************************
--**
--**  File     :  /lua/ai/skirmish/system/SAIInitializeSystems.lua
--**
--**  Summary  :  Gets skirmish AI systems ready for matches
--**
--**  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

-- This file is called from SimInit if the came is a skirmish game.
-- It sets up any of the necessary systems for the skirmish and loads
-- any data sets we need 
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

for k,v in ScenarioUtils.GetMarkersByType('Defensive Point') do
    AddMarker( 'DefensivePoint', v.position, k )
end

for k,v in ScenarioUtils.GetMarkersByType('Base Marker') do
    AddMarker( 'BaseMarker', v.position, k )
end

for k,v in ScenarioUtils.GetMarkersByType('Rally Point') do
    AddMarker( 'RallyPoint', v.position, k )
end

for k,v in ScenarioUtils.GetMarkersByType('Naval Area') do
    AddMarker( 'NavalArea', v.position, k )
end

for k,v in ScenarioUtils.GetMarkersByType('Naval Rally Point') do
    AddMarker( 'NavalRallyPoint', v.position, k )
end

for k,v in ScenarioUtils.GetMarkersByType('Mass') do
    AddMarker( 'MassMarker', v.position, k )
end

for k,v in ScenarioUtils.GetMarkersByType('Expansion Area') do
    AddMarker( 'ExpansionArea', v.position, k )
end

for k,v in ScenarioUtils.GetMarkersByType('Default Path Node') do
    AddMarker( 'PathNode', v.position, k )
end