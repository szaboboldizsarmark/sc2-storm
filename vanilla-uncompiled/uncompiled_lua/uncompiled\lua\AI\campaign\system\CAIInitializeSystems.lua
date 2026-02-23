--****************************************************************************
--**
--**  File     :  /lua/system/CAIInitializeSystems.lua
--**
--**  Summary  :  Gets campaign AI systems ready for campaign matches
--**
--**  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

-- This file is called from SimInit if the came is a campaign game.
-- It sets up any of the necessary systems for the campaign and loads
-- any data sets we need (such as builders)


-- Doscript all the blueprint systems
doscript '/lua/ai/campaign/system/CAIFactoryBuilderBlueprint.lua'
doscript '/lua/ai/campaign/system/CAIEngineerBuilderBlueprint.lua'
doscript '/lua/ai/campaign/system/CAIConditionBlueprint.lua'
doscript '/lua/ai/campaign/system/CAIOperationAIBlueprint.lua'
doscript '/lua/ai/campaign/system/CAIPlatoonThreadBlueprint.lua'

-- Traverses sub-directories
--for i,dir in {'/lua/AI/fancy/directory'} do
--    for k,file in DiskFindFiles(dir,'*.lua') do
--        import(file)
--    end
--end

LOG('*AI DEBUG: Loading Conditions')
-- Load the Campaign Condition blueprints
-- Only the given directory
for k,file in DiskFindFiles( '/lua/AI/Campaign/Conditions/', '*.lua' ) do
    LOG(repr(file))
    import(file)
end

LOG('*AI DEBUG: Loading Platoon Threads')
-- Load the Campaign Platoon Threads
-- Only the given directory
for k,file in DiskFindFiles( '/lua/AI/Campaign/PlatoonThreads/', '*.lua' ) do
    LOG(repr(file))
    import(file)
end

LOG('*AI DEBUG: Loading OpAI')
-- Load the Campaign OpAI Builders
-- Only the given directory
for k,file in DiskFindFiles( '/lua/AI/Campaign/OpAI/', '*.lua' ) do
    LOG(repr(file))
    import(file)
end

LOG('*AI DEBUG: Loading Engineer Builders')
-- Load the Campaign OpAI Builders
-- Only the given directory
for k,file in DiskFindFiles( '/lua/AI/Campaign/EngineerBuilders/', '*.lua' ) do
    LOG(repr(file))
    import(file)
end

LOG('*AI DEBUG: Loading Factory Builders')
-- Load the Campaign OpAI Builders
-- Only the given directory
for k,file in DiskFindFiles( '/lua/AI/Campaign/FactoryBuilders/', '*.lua' ) do
    LOG(repr(file))
    import(file)
end

