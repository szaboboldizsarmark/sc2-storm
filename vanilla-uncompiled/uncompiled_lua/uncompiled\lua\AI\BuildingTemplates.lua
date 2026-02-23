--SC2 FIX NEED: file contains specific unit references that are no longer valid - needs reolution - bfricks 9/19/08
--****************************************************************************
--**
--**  File     :  /lua/buildingtemplates.lua
--**  Author(s):  Dru Staltman
--**
--**  Summary  :
--**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
----------------------------------------
-- Base Templates                       --
----------------------------------------

BuildingIdToType = {

    -- ==== UEF UNITS ==== --
    uub0001 = 'LandFactory',
    uub0002 = 'AirFactory',
    uub0003 = 'SeaFactory',

    uub0011 = 'AssaultGantry',
    uub0012 = 'UtilityGantry',

    uub0101 = 'LandDefenseTower',
    uub0102 = 'AirDefenseTower',

    uub0104 = 'ArtilleryStructure',
    uub0105 = 'LongRangeArtilleryStructure',
    uub0107 = 'StrategicMissileLauncher',
    
    uub0201 = 'Wall',
    uub0202 = 'ShieldGenerator',
    uub0203 = 'ComboMissileDefense',

    uub0301 = 'Radar',
    uub0302 = 'Sonar',

    uub0701 = 'Resource',
    uub0702 = 'EnergyProduction',
    uub0704 = 'MassFabrication',

    uub0801 = 'ResearchStation',

    uux0114 = 'NoahCannon',
    uux0115 = 'DisruptorStation',
    
    uux0104 = 'Atlantis',
    
    uul0001 = 'ACU',

    -- === CYBRAN UNITS ==== --
    ucb0001 = 'LandFactory',
    ucb0002 = 'AirFactory',
    ucb0003 = 'SeaFactory',

    ucb0011 = 'LandGantry',
    ucb0012 = 'AirGantry',

    ucb0101 = 'LandDefenseTower',
    ucb0102 = 'AirDefenseTower',

    ucb0105 = 'LongRangeArtilleryStructure',

    ucb0202 = 'ShieldGenerator',
    ucb0204 = 'MissileLaunchAndDefense',

    ucb0303 = 'DualIntelStation',

    ucb0701 = 'Resource',
    ucb0702 = 'EnergyProduction',
	ucb0704 = 'MassFabrication',

    ucb0801 = 'ResearchStation',

    ucx0114 = 'Magnetron',
    ucx0115 = 'ProtoBrain',
    
    ucx0113 = 'Krakken',
    
    ucl0001 = 'ACU',

    -- === ILLUMINATE UNITS === --
    uib0001 = 'LandFactory',
    uib0002 = 'AirFactory',
    uib0003 = 'SeaFactory',

    uib0011 = 'ExperimentalGantry',

    uib0101 = 'LandDefenseTower',
    uib0102 = 'AirDefenseTower',

    uib0106 = 'TacticalMissile',
    uib0107 = 'StrategicMissileLauncher',

    uib0202 = 'ShieldGenerator',
    uib0203 = 'ComboMissileDefense',

    uib0301 = 'Radar',

    uib0701 = 'Resource',
    uib0702 = 'EnergyProduction',
    uib0704 = 'MassFabrication',

    uib0801 = 'ResearchStation',

    uix0113 = 'SpaceTemple',
    uix0114 = 'LoyaltyGun',
    
    uil0001 = 'ACU',
}

BuildingTypeToId = {

    -- ==== UEF UNITS ==== --
    {
        LandFactory = 'uub0001',
        AirFactory = 'uub0002',
        SeaFactory = 'uub0003',

        AssaultGantry = 'uub0011',
        UtilityGantry = 'uub0012',

        ArtilleryStructure = 'uub0104',
        LongRangeArtilleryStructure = 'uub0105',
        StrategicMissileLauncher = 'uub0107',
        
        Wall = 'uub0201',
        ShieldGenerator = 'uub0202',
        ComboMissileDefense = 'uub0203',

        Radar = 'uub0301',
        Sonar = 'uub0302',

        Resource = 'uub0701',
        EnergyProduction = 'uub0702',
        MassFabrication = 'uub0704',

        ResearchStation = 'uub0801',

        LandDefenseTower = 'uub0101',
        AirDefenseTower = 'uub0102',

        NoahCannon = 'uux0114',
        DisruptorStation = 'uux0115',
        
        Atlantis = 'uux0104',
        
        ACU = 'uul0001',
    },

    -- ==== CYBRAN UNITS ==== --
    {
        LandFactory = 'ucb0001',
        AirFactory = 'ucb0002',
        SeaFactory = 'ucb0003',

        LandGantry = 'ucb0011',
        AirGantry = 'ucb0012',

        LandDefenseTower = 'ucb0101',
        AirDefenseTower = 'ucb0102',

        LongRangeArtilleryStructure = 'ucb0105',

        ShieldGenerator = 'ucb0202',
        MissileLaunchAndDefense = 'ucb0204',

        DualIntelStation = 'ucb0303',

        Resource = 'ucb0701',
        EnergyProduction = 'ucb0702',
		MassFabrication = 'ucb0704',

        ResearchStation = 'ucb0801',

        Magnetron = 'ucx0114',
        ProtoBrain =  'ucx0115',
        
        Krakken = 'ucx0113',
        
        ACU = 'ucl0001',
    },

    -- ==== ILLUMINATE UNITS ==== --
    {
        LandFactory = 'uib0001',
        AirFactory = 'uib0002',
        SeaFactory = 'uib0003',

        ExperimentalGantry = 'uib0011',

        LandDefenseTower = 'uib0101',
        AirDefenseTower = 'uib0102',

        TacticalMissile = 'uib0106',
        StrategicMissileLauncher = 'uib0107',

        ShieldGenerator = 'uib0202',
        ComboMissileDefense = 'uib0203',

        Radar = 'uib0301',

        Resource = 'uib0701',
        EnergyProduction = 'uib0702',
        MassFabrication = 'uib0704',

        ResearchStation = 'uib0801',

        SpaceTemple = 'uix0113',
        LoyaltyGun = 'uix0114',
        
        ACU = 'uil0001',
    },
}

BuildingTemplates = {
}

RebuildStructuresTemplate = {
}
