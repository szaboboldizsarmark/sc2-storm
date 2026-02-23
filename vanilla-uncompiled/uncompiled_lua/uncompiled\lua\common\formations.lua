--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

--****************************************************************************
--**
--**  File     :  /cdimage/lua/formations.lua
--**  Author(s):
--**
--**  Summary  :
--**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
--
-- Basic create formation scripts
--

SurfaceFormations = {
    'AttackFormation',
    'GrowthFormation',
}

AirFormations = {
    'AttackFormation',
    'GrowthFormation',
}

ComboFormations = {
    'AttackFormation',
    'GrowthFormation',
}

local FormationPos = {} -- list to be returned

local RemainingCategory = { 'RemainingCategory', }

--=========================================--
--================ LAND DATA ==============--
--=========================================--

--=== LAND CATEGORIES DEFINITIONS ===--
local DFire	= categories.LAND * categories.DIRECTFIRE
local Const	= categories.LAND * categories.ENGINEER
local IFire	= categories.LAND * categories.ARTILLERY
local AntiA	= categories.LAND * categories.ANTIAIR
local MShld	= categories.LAND * categories.SHIELD
local DFExp	= categories.LAND * categories.EXPERIMENTAL

--=== LAND CATEGORIES SORTING ===--
local LandCategories = {
    DFire1 = DFire,
    Const1 = Const,
    IFire1 = IFire,
    AntiA1 = AntiA,
    MShld1 = MShld,
    DFExp1 = DFExp,
    RemainingCategory = categories.LAND - DFire - Const - IFire - AntiA - MShld - DFExp,
}

--=== SUB GROUP ORDERING ===--
local SGDFire		= { 'DFire1', }
local SGConst		= { 'Const1', }
local SGIFire		= { 'IFire1', }
local SGAntiA		= { 'AntiA1', }
local SGMShld		= { 'MShld1', }
local SGDFExp		= { 'DFExp1', }

--=== LAND BLOCK TYPES =--
local DFFirst			= { SGDFExp, SGDFire, SGIFire, SGAntiA, SGMShld, SGConst, RemainingCategory }
local ShieldFirst		= { SGMShld, SGAntiA, SGIFire, SGDFExp, SGDFire, SGConst, RemainingCategory }
local AAFirst			= { SGAntiA, SGDFExp, SGDFire, SGIFire, SGMShld, SGConst, RemainingCategory }
local ArtFirst			= { SGIFire, SGAntiA, SGDFExp, SGDFire, SGMShld, SGConst, RemainingCategory }

--=== Travelling Block ===--
local TravelSlot = { DFExp, DFire, AntiA, IFire, MShld, Const }
local TravelFormationBlock = {
    HomogenousRows = true,
    UtilBlocks = true,
    RowBreak = 0.5,
    { TravelSlot, TravelSlot, },
    { TravelSlot, TravelSlot, },
    { TravelSlot, TravelSlot, },
    { TravelSlot, TravelSlot, },
    { TravelSlot, TravelSlot, },
}

--=== LAND BLOCKS ===--

--=== 3 Wide Attack Block / 3 Units ===--
local ThreeWideAttackFormationBlock = {
    -- first row
    { DFFirst, DFFirst, DFFirst, },
}

--=== 4 Wide Attack Block / 12 Units ===--
local FourWideAttackFormationBlock = {
    -- first row
    { DFFirst, DFFirst, DFFirst, DFFirst, },
    -- second row
    { ShieldFirst, ShieldFirst, ShieldFirst, ShieldFirst, },
    -- third Row
    { AAFirst, ArtFirst, ArtFirst, AAFirst,  },
}

--=== 5 Wide Attack Block ===--
local FiveWideAttackFormationBlock = {
    -- first row
    { DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, },
    -- second row
    { DFFirst, ShieldFirst, DFFirst, ShieldFirst, DFFirst, },
    -- third row
    { ShieldFirst, ShieldFirst, DFFirst, ShieldFirst,  ShieldFirst, },
    -- fourth row
    { AAFirst, DFFirst, ArtFirst, DFFirst, AAFirst, },
}

--=== 6 Wide Attack Block ===--
local SixWideAttackFormationBlock = {
    -- first row
    { DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, },
    -- second row
    { DFFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, },
    -- third row
    { ShieldFirst, AAFirst, DFFirst, DFFirst, AAFirst,  ShieldFirst, },
    -- fourth row
    { AAFirst, ShieldFirst, ArtFirst, ArtFirst, ShieldFirst, AAFirst, },
    -- fifth row
    { DFFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, DFFirst, },
}

--=== 7 Wide Attack Block ===--
local SevenWideAttackFormationBlock = {
    -- first row
    { DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, },
    -- second Row
    { DFFirst, ShieldFirst, DFFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, },
    -- third row
    { ShieldFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, ShieldFirst, },
    -- fourth row
    { AAFirst, ShieldFirst, AAFirst, ArtFirst, ShieldFirst, AAFirst, DFFirst, },
    -- fifth row
    { DFFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst, DFFirst, },
    -- sixth row
    { ShieldFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst, ArtFirst, ShieldFirst, },
}

--=== 8 Wide Attack Block ===--
local EightWideAttackFormationBlock = {
    -- first row
    { DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, },
    -- second Row
    { DFFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, },
    -- third row
    { ShieldFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, ShieldFirst, },
    -- fourth row
    { DFFirst, AAFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, AAFirst, DFFirst, },
    -- fifth row
    { DFFirst, ArtFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst, DFFirst, },
    -- sixth row
    { ShieldFirst, AAFirst, ShieldFirst, ArtFirst, ArtFirst, ShieldFirst, AAFirst, ShieldFirst, },
    -- seventh row
    { DFFirst, ArtFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst, DFFirst, },
}

--=== 2 Row Attack Block - 8 units wide ===--
local TwoRowAttackFormationBlock = {
    -- first row
    { DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst },
    -- second row
    { ShieldFirst, AAFirst, ShieldFirst, ArtFirst, ArtFirst, ShieldFirst, AAFirst, ShieldFirst },
}

--=== 3 Row Attack Block - 10 units wide ===--
local ThreeRowAttackFormationBlock = {
    -- first row
    { DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst },
    -- second row
    { ShieldFirst, ShieldFirst, AAFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, AAFirst, ShieldFirst, ShieldFirst },
    -- third row
    { DFFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst, ArtFirst, ArtFirst, AAFirst, DFFirst },
}

--=== 4 Row Attack Block - 12 units wide ===--
local FourRowAttackFormationBlock = {
    -- first row
    { DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst },
    -- second row
    { ShieldFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, ShieldFirst },
    -- third row
    { DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst },
    -- fourth row
    { AAFirst, ShieldFirst, AAFirst, ArtFirst, ShieldFirst, ArtFirst, ArtFirst, ShieldFirst, ArtFirst, AAFirst, ShieldFirst, AAFirst },
}

--=== 5 Row Attack Block - 14 units wide ===--
local FiveRowAttackFormationBlock = {
    -- first row
    { DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst },
    -- second row
    { ShieldFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, ShieldFirst },
    -- third row
    { DFFirst, AAFirst, DFFirst, AAFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, AAFirst, DFFirst, AAFirst, DFFirst },
    -- fourth row
    { AAFirst, ShieldFirst, AAFirst, DFFirst, ShieldFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, AAFirst, ShieldFirst, AAFirst },
  	-- five row
    { ArtFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst, ArtFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst },
}

--=== 6 Row Attack Block - 16 units wide ===--
local SixRowAttackFormationBlock = {
    -- first row
    { DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst },
    -- second row
    { ShieldFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, ShieldFirst },
    -- third row
    { DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst },
    -- fourth row
    { AAFirst, ShieldFirst, AAFirst, DFFirst, ShieldFirst, AAFirst, ShieldFirst, DFFirst, ShieldFirst, AAFirst, DFFirst, ShieldFirst, DFFirst, AAFirst, ShieldFirst, AAFirst },
  	-- fifth row
    { ShieldFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, ShieldFirst },
  	-- sixth row
    { AAFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst, ArtFirst, AAFirst },
}

--=== 7 Row Attack Block - 18 units wide ===--
local SevenRowAttackFormationBlock = {
    -- first row
    { DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst },
    -- second row
    { ShieldFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, ShieldFirst },
    -- third row
    { DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst },
    -- fourth row
    { AAFirst, ShieldFirst, DFFirst, AAFirst, ShieldFirst, DFFirst, AAFirst, ShieldFirst, DFFirst, AAFirst, ShieldFirst, DFFirst, AAFirst, ShieldFirst, DFFirst, AAFirst, ShieldFirst, DFFirst },
  	-- fifth row
    { ShieldFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, ShieldFirst },
  	-- sixth row
    { AAFirst, ShieldFirst, DFFirst, AAFirst, ShieldFirst, DFFirst, AAFirst, ShieldFirst, DFFirst, AAFirst, ShieldFirst, DFFirst, AAFirst, ShieldFirst, DFFirst, AAFirst, ShieldFirst, DFFirst },
  	-- seventh row
    { ArtFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst, ArtFirst },
}

--=== 8 Row Attack Block - 18 units wide ===--
local EightRowAttackFormationBlock = {
    -- first row
    { DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst },
    -- second row
    { ShieldFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, ShieldFirst },
    -- third row
    { DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst },
    -- fourth row
    { AAFirst, ShieldFirst, DFFirst, AAFirst, ShieldFirst, DFFirst, AAFirst, ShieldFirst, DFFirst, ShieldFirst, AAFirst, DFFirst, ShieldFirst, AAFirst, DFFirst, ShieldFirst, AAFirst, DFFirst, ShieldFirst, AAFirst },
  	-- fifth row
    { ShieldFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, AAFirst, ShieldFirst },
  	-- sixth row
    { AAFirst, ShieldFirst, DFFirst, AAFirst, ShieldFirst, DFFirst, AAFirst, ShieldFirst, DFFirst, ShieldFirst, AAFirst, DFFirst, ShieldFirst, AAFirst, DFFirst, ShieldFirst, AAFirst, DFFirst, ShieldFirst, AAFirst },
  	-- seventh row
    { DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, DFFirst, DFFirst, DFFirst },
  	-- eight row
    { AAFirst, ShieldFirst, ArtFirst, AAFirst, ShieldFirst, ArtFirst, AAFirst, ShieldFirst, ArtFirst, ShieldFirst, AAFirst, ArtFirst, ShieldFirst, AAFirst, ArtFirst, ShieldFirst, AAFirst, ArtFirst, ShieldFirst, AAFirst },
}

--=== 9 Row Attack Block - 18+ units wide ===--
local NineRowAttackFormationBlock = {
    -- first row
    { DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst, DFFirst },
    -- second row
    { ShieldFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, DFFirst, DFFirst, ShieldFirst, ShieldFirst },
    -- third row
    { DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst },
    -- fourth row
    { AAFirst, ShieldFirst, DFFirst, AAFirst, ShieldFirst, DFFirst, AAFirst, ShieldFirst, DFFirst, ShieldFirst, AAFirst, DFFirst, ShieldFirst, AAFirst, DFFirst, ShieldFirst, AAFirst, DFFirst, ShieldFirst, AAFirst },
  	-- fifth row
    { ShieldFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, DFFirst, AAFirst, ShieldFirst },
  	-- sixth row
    { AAFirst, ShieldFirst, DFFirst, AAFirst, ShieldFirst, DFFirst, AAFirst, ShieldFirst, DFFirst, ShieldFirst, AAFirst, DFFirst, ShieldFirst, AAFirst, DFFirst, ShieldFirst, AAFirst, DFFirst, ShieldFirst, AAFirst },
  	-- seventh row
    { DFFirst, AAFirst, DFFirst, DFFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, ArtFirst, ArtFirst, AAFirst, DFFirst, DFFirst, DFFirst },
  	-- eight row
    { AAFirst, ShieldFirst, ArtFirst, AAFirst, ShieldFirst, ArtFirst, AAFirst, ShieldFirst, ArtFirst, ShieldFirst, AAFirst, ArtFirst, ShieldFirst, AAFirst, ArtFirst, ShieldFirst, AAFirst, ArtFirst, ShieldFirst, AAFirst },
}
--=========================================--
--================ AIR DATA ===============--
--=========================================--

--=== AIR CATEGORIES DEFINITIONS ===--
local AFtr	= categories.AIR * categories.FIGHTER
local Bomb	= categories.AIR * categories.BOMBER
local AGun	= categories.AIR * categories.GROUNDATTACK
local ATrn	= categories.AIR * categories.TRANSPORTATION
local AExp	= categories.AIR * categories.EXPERIMENTAL

--=== AIR CATEGORIES SORTING ===--
local AirCategories = {
    AFtr1 = AFtr,
    Bomb1 = Bomb,
    AGun1 = AGun,
    ATrn1 = ATrn,
    AExp1 = AExp,
    RemainingCategory = categories.AIR - AFtr - Bomb - AGun - ATrn - AExp
}

--=== SUB GROUP ORDERING ===--
local SGAFtr = { 'AFtr1', }
local SGAGun = { 'AGun1', }
local SGATrn = { 'ATrn1', }
local SGBomb = { 'Bomb1', }
local SGAExp = { 'AExp1', }
local Remain = { 'RemainingCategory', }


--=== Air Block Arrangement ===--
local ChevronSlot = { SGAFtr, SGAExp, SGAGun, SGBomb, SGATrn, Remain }
local InitialChevronBlock = {
    RepeatAllRows = false,
    HomogenousBlocks = true,
    ChevronSize = 3,
    { ChevronSlot },
    { ChevronSlot, ChevronSlot },
}

local StaggeredChevronBlock = {
    RepeatAllRows = true,
    HomogenousBlocks = true,
    { ChevronSlot, ChevronSlot, ChevronSlot, },
    { ChevronSlot, ChevronSlot, },
}



--=========================================--
--============== NAVAL DATA ===============--
--=========================================--

--=== NAVAL CATEGORIES DEFINITIONS ===--
local SFri	= categories.NAVAL * categories.FRIGATE
local SCru	= categories.NAVAL * categories.CRUISER
local SDes	= categories.NAVAL * categories.DESTROYER
local SSub	= categories.NAVAL * categories.SUBMERSIBLE
local SBtl	= categories.NAVAL * categories.BATTLESHIP
local STrn	= categories.NAVAL * categories.CARRIER
local SExp	= categories.NAVAL * categories.EXPERIMENTAL

---- Naval formation blocks ------
local NavalSpacing = 1.2
local StandardNavalBlock = {
    { { {0, 0}, }, { 'STrn', 'SBtl', 'SCru', 'SDes', 'SFri', 'SSub' }, },
    { { {-1, 1.5}, {1, 1.5}, }, { 'SDes', 'SCru', 'SFri', 'SSub'}, },
    { { {-2.5, 0}, {2.5, 0}, }, { 'SCru', 'SBtl', 'SDes', 'SFri', 'SSub' }, },
    { { {-1, -1.5}, {1, -1.5}, }, { 'SFri', 'SBtl', 'SSub' }, },
    { { {-3, 2}, {3, 2}, {-3, 0}, {3, 0}, }, { 'SSub', }, },
}

--=== NAVAL CATEGORIES SORTING ===--
local NavalCategories = {
    SFri1 = SFri,
    SCru1 = SCru,
    SDes1 = SDes,
    SBtl1 = SBtl,
    STrn1 = STrn,
    SExp1 = SExp,
    RemainingCategory = categories.NAVAL - SFri - SCru - SDes - SSub - SBtl - STrn - SExp,
}

local SubCategories = {
    SubCount = SSub,
}

--=== SUB GROUP ORDERING ===--
local SGSFri = { 'SFri1', }
local SGSCru = { 'SCru1', }
local SGSDes = { 'SDes1', }
local SGSBtl = { 'SBtl1', }
local SGSTrn = { 'STrn1', }
local SGSExp = { 'SExp1', }
local SGSSub = { 'SubCount', }

--=== NAVAL BLOCK TYPES =--
local FrigatesFirst		= { SGSFri, SGSExp, SGSDes, SGSBtl, SGSCru, SGSTrn, RemainingCategory }
local CruisersFirst		= { SGSCru, SGSExp, SGSTrn, SGSBtl, SGSDes, SGSFri, RemainingCategory }
local DestroyersFirst	= { SGSDes, SGSExp, SGSFri, SGSBtl, SGSCru, SGSTrn, RemainingCategory }
local BattleshipsFirst	= { SGSBtl, SGSExp, SGSDes, SGSFri, SGSCru, SGSTrn, RemainingCategory }
local CarriersFirst		= { SGSTrn, SGSExp, SGSCru, SGSBtl, SGSDes, SGSFri, RemainingCategory }
local Subs				= { SGSSub, RemainingCategory }

--=== NAVAL BLOCKS ===--

--=== Three Naval Growth Formation Block ==--
local ThreeNavalGrowthFormation = {
    LineBreak = 0.5,
    -- first row
    { FrigatesFirst, FrigatesFirst, FrigatesFirst, },
    -- second row
    { DestroyersFirst, DestroyersFirst, DestroyersFirst, },
    -- third row
    { DestroyersFirst, CruisersFirst, DestroyersFirst, },
}

--=== Five Naval Growth Formation Block ==--
local FiveNavalGrowthFormation = {
    LineBreak = 0.5,
    -- first row
    { FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst },
    -- second row
    { FrigatesFirst, DestroyersFirst, DestroyersFirst, DestroyersFirst, FrigatesFirst },
    -- third row
    { DestroyersFirst, DestroyersFirst, BattleshipsFirst, DestroyersFirst, DestroyersFirst },
    -- fourth row
    { DestroyersFirst, DestroyersFirst, CarriersFirst, DestroyersFirst, DestroyersFirst },
    -- fifth row
    { DestroyersFirst, DestroyersFirst, CarriersFirst, DestroyersFirst, DestroyersFirst },

}

--=== Seven Naval Growth Formation Block ==--
local SevenNavalGrowthFormation = {
    LineBreak = 0.5,
    -- first row
    { FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst },
    -- second row
    { FrigatesFirst, FrigatesFirst, DestroyersFirst, DestroyersFirst, DestroyersFirst, FrigatesFirst, FrigatesFirst },
    -- third row
    { DestroyersFirst, DestroyersFirst, DestroyersFirst, BattleshipsFirst, DestroyersFirst, DestroyersFirst, DestroyersFirst },
    -- fourth row
    { DestroyersFirst, BattleshipsFirst, DestroyersFirst, CarriersFirst, DestroyersFirst, BattleshipsFirst, DestroyersFirst },
    -- fifth row
    { DestroyersFirst, CruisersFirst, DestroyersFirst, BattleshipsFirst, DestroyersFirst, CruisersFirst, DestroyersFirst },
    -- sixth row
    { DestroyersFirst, CruisersFirst, DestroyersFirst, CarriersFirst, DestroyersFirst, CruisersFirst, DestroyersFirst },
    -- seventh row
    { DestroyersFirst, CruisersFirst, DestroyersFirst, CarriersFirst, DestroyersFirst, CruisersFirst, DestroyersFirst },
}

--==============================================--
--============ Naval Attack Formation===========--
--==============================================--

--=== Five Wide Naval Attack Formation Block ==--
local FiveWideNavalAttackFormation = {
    LineBreak = 0.5,
    -- first row
    { FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst},
    -- second row
    { DestroyersFirst, DestroyersFirst, CarriersFirst, DestroyersFirst, DestroyersFirst},
}

--=== Seven Wide Naval Attack Formation Block ==--
local SevenWideNavalAttackFormation = {
    LineBreak = 0.5,
    -- first row
    { FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst, },
    -- second row
    { DestroyersFirst, BattleshipsFirst, DestroyersFirst, BattleshipsFirst, DestroyersFirst, BattleshipsFirst, DestroyersFirst},
		-- third row
    { DestroyersFirst, CruisersFirst, CarriersFirst, CarriersFirst, CruisersFirst, CruisersFirst, DestroyersFirst},
}

--=== Nine Wide Naval Attack Formation Block ==--
local NineWideNavalAttackFormation = {
    LineBreak = 0.5,
    -- first row
    { FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst },
    -- second row
    { DestroyersFirst, DestroyersFirst, DestroyersFirst, BattleshipsFirst, BattleshipsFirst, BattleshipsFirst, DestroyersFirst, DestroyersFirst, DestroyersFirst },
    -- third row
    { DestroyersFirst, CruisersFirst, DestroyersFirst, CarriersFirst, CarriersFirst, CarriersFirst, DestroyersFirst, CruisersFirst, DestroyersFirst },
}

--==============================================--
--============ Sub Growth Formation===========--
--==============================================--
--=== Three Wide Growth Subs Formation ===--
local ThreeWideSubGrowthFormation = {
    LineBreak = 0.5,
    { Subs, Subs, Subs, },
    { Subs, Subs, Subs, },
}

--=== Five Wide Subs Formation ===--
local FiveWideSubGrowthFormation = {
    LineBreak = 0.5,
    { Subs, Subs, Subs, Subs, Subs,},
    { Subs, Subs, Subs, Subs, Subs,},
    { Subs, Subs, Subs, Subs, Subs,},
}

--=== Seven Wide Subs Formation ===--
local SevenWideSubGrowthFormation = {
    LineBreak = 0.5,
    { Subs, Subs, Subs, Subs, Subs,},
    { Subs, Subs, Subs, Subs, Subs,},
    { Subs, Subs, Subs, Subs, Subs,},
    { Subs, Subs, Subs, Subs, Subs,},
}


--==============================================--
--============ Sub Attack Formation===========--
--==============================================--

--=== Five Wide Subs Formation ===--
local FiveWideSubAttackFormation = {
    LineBreak = 0.5,
    { Subs, Subs, Subs, Subs, Subs },
    { Subs, Subs, Subs, Subs, Subs },
}

--=== Seven Wide Subs Formation ===--
local SevenWideSubAttackFormation = {
    LineBreak = 0.5,
    { Subs, Subs, Subs, Subs, Subs, Subs, Subs },
    { Subs, Subs, Subs, Subs, Subs, Subs, Subs },
    { Subs, Subs, Subs, Subs, Subs, Subs, Subs },
}

--=== Nine Wide Subs Formation ===--
local NineWideSubAttackFormation = {
    LineBreak = 0.5,
    { Subs, Subs, Subs, Subs, Subs, Subs, Subs, Subs, Subs },
    { Subs, Subs, Subs, Subs, Subs, Subs, Subs, Subs, Subs },
    { Subs, Subs, Subs, Subs, Subs, Subs, Subs, Subs, Subs },
    { Subs, Subs, Subs, Subs, Subs, Subs, Subs, Subs, Subs },
}

local EightNavalFormation = {
    LineBreak = 0.5,
    { FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst, FrigatesFirst },
    -- second row
    { DestroyersFirst, CruisersFirst, CruisersFirst, BattleshipsFirst, BattleshipsFirst, CruisersFirst, CruisersFirst, DestroyersFirst },
    -- third row
    { DestroyersFirst, BattleshipsFirst, CruisersFirst, CruisersFirst, CruisersFirst, CruisersFirst, BattleshipsFirst, DestroyersFirst },
    -- fourth row
    { DestroyersFirst, CruisersFirst, CarriersFirst, CarriersFirst, CarriersFirst, CarriersFirst, CruisersFirst, DestroyersFirst },
}

local EightNavalSubFormation = {
    LineBreak = 0.5,
    { Subs, Subs, Subs, Subs, Subs, Subs, Subs },
}

--============ Formation Pickers ============--
function PickBestTravelFormationIndex( typeName, distance )
    if typeName == 'AirFormations' then
        return 0;
    else
        return 1;
    end
end

function PickBestFinalFormationIndex( typeName, distance )
    return -1;
end


--================ THE GUTS ====================--
--============ Formation Functions =============--
--==============================================--
function AttackFormation( formationUnits )
    FormationPos = {}

    local landUnitsList = CategorizeLandUnits( formationUnits )
    local landBlock
    if landUnitsList.UnitTotal <= 16 then -- 8 wide
        landBlock = TwoRowAttackFormationBlock
    elseif landUnitsList.UnitTotal <= 30 then -- 10 wide
        landBlock = ThreeRowAttackFormationBlock
    elseif landUnitsList.UnitTotal <= 48 then -- 12 wide
        landBlock = FourRowAttackFormationBlock
    elseif landUnitsList.UnitTotal <= 70 then -- 14 wide
        landBlock = FiveRowAttackFormationBlock
    elseif landUnitsList.UnitTotal <= 96 then -- 16 wide
        landBlock = SixRowAttackFormationBlock
    elseif landUnitsList.UnitTotal <= 126 then -- 18 wide
        landBlock = SevenRowAttackFormationBlock
    elseif landUnitsList.UnitTotal <= 160 then -- 20 wide
        landBlock = EightRowAttackFormationBlock
    else
        landBlock = NineRowAttackFormationBlock
    end
    BlockBuilderLand(landUnitsList, landBlock, LandCategories)

    local seaUnitsList = CategorizeSeaUnits( formationUnits )
    seaUnitsList.UnitTotal = seaUnitsList.UnitTotal - seaUnitsList.SubCount
    local seaBlock
    local subBlock
    local subUnitsList = {}
    subUnitsList.UnitTotal = seaUnitsList.SubCount
    subUnitsList.SubCount = seaUnitsList.SubCount
    local seaCounter = seaUnitsList.UnitTotal
    if seaUnitsList.UnitTotal < subUnitsList.UnitTotal then
        seaCounter = subUnitsList.UnitTotal
    end
    if seaCounter <= 10 then
        seaBlock = FiveWideNavalAttackFormation
        subBlock = FiveWideSubGrowthFormation
    elseif seaCounter <= 25 then
        seaBlock = SevenWideNavalAttackFormation
        subBlock = SevenWideSubAttackFormation
    elseif seaCounter <= 50 then
        seaBlock = NineWideNavalAttackFormation
        subBlock = NineWideSubAttackFormation
    else
        seaBlock = NineWideNavalAttackFormation
        subBlock = NineWideSubAttackFormation
    end
    BlockBuilderLand( seaUnitsList, seaBlock, NavalCategories, 1.5 )
    BlockBuilderLand( subUnitsList, subBlock, SubCategories, 1.5 )

    local airUnitsList = CategorizeAirUnits( formationUnits )
    BlockBuilderAir(airUnitsList, StaggeredChevronBlock)

    return FormationPos
end

function GrowthFormation( formationUnits )
    FormationPos = {}

    local landUnitsList = CategorizeLandUnits( formationUnits )
    local landBlock
    if landUnitsList.UnitTotal <= 3 then
        landBlock = ThreeWideAttackFormationBlock
    elseif landUnitsList.UnitTotal <= 12 then
        landBlock = FourWideAttackFormationBlock
    elseif landUnitsList.UnitTotal <= 20 then
        landBlock = FiveWideAttackFormationBlock
    elseif landUnitsList.UnitTotal <= 30 then
        landBlock = SixWideAttackFormationBlock
    elseif landUnitsList.UnitTotal <= 42 then
        landBlock = SevenWideAttackFormationBlock
    elseif landUnitsList.UnitTotal <= 56 then
        landBlock = EightWideAttackFormationBlock
    else
        landBlock = EightWideAttackFormationBlock
    end
    BlockBuilderLand(landUnitsList, landBlock, LandCategories)

    local seaUnitsList = CategorizeSeaUnits( formationUnits )
    seaUnitsList.UnitTotal = seaUnitsList.UnitTotal - seaUnitsList.SubCount
    local seaBlock
    local subBlock
    local subUnitsList = {}
    subUnitsList.UnitTotal = seaUnitsList.SubCount
    subUnitsList.SubCount = seaUnitsList.SubCount
    local seaCounter = seaUnitsList.UnitTotal
    if seaUnitsList.UnitTotal < subUnitsList.UnitTotal then
        seaCounter = subUnitsList.UnitTotal
    end
    if seaCounter <= 9 then
        seaBlock = ThreeNavalGrowthFormation
        subBlock = ThreeWideSubGrowthFormation
    elseif seaCounter <= 25 then
        seaBlock = FiveNavalGrowthFormation
        subBlock = FiveWideSubGrowthFormation
    elseif seaCounter <= 49 then
        seaBlock = SevenNavalGrowthFormation
        subBlock = SevenWideSubGrowthFormation
    else
        seaBlock = SevenNavalGrowthFormation
        subBlock = SevenWideSubGrowthFormation
    end
    BlockBuilderLand( seaUnitsList, seaBlock, NavalCategories, 1.5 )
    BlockBuilderLand( subUnitsList, subBlock, SubCategories, 1.5 )

    local airUnitsList = CategorizeAirUnits( formationUnits )
    BlockBuilderAir(airUnitsList, StaggeredChevronBlock)

    return FormationPos
end

function BlockFormation( formationUnits )
    local rotate = true
    local smallUnitsList = {}
    local largeUnitsList = {}
    local smallUnits = 0
    local largeUnits = 0

    for i,u in formationUnits do
        local footPrintSize = u:GetFootPrintSize()
        if footPrintSize > 3  then
            largeUnitsList[largeUnits] = { u }
            largeUnits = largeUnits + 1
        else
            smallUnitsList[smallUnits] = { u }
            smallUnits = smallUnits + 1
        end
    end

    local FormationPos = {}
    local n = smallUnits + largeUnits
    local width = math.ceil(math.sqrt(n))
    local length = n / width

    -- Put small units (Size 1 through 3) in front of the formation
    for i in smallUnitsList do
        local offsetX = (( math.mod(i,width)  - math.floor(width/2) ) * 2) + 1
        local offsetY = ( math.floor(i/width) - math.floor(length/2) ) * 2
        local delay = 0.1 + (math.floor(i/width) * 3)
        table.insert(FormationPos, { offsetX, -offsetY, categories.ALLUNITS, delay, rotate })
    end

    -- Put large units (Size >= 4) in the back of the formation
    for i in largeUnitsList do
        local adjIndex = smallUnits + i
        local offsetX = (( math.mod(adjIndex,width)  - math.floor(width/2) ) * 2) + 1
        local offsetY = ( math.floor(adjIndex/width) - math.floor(length/2) ) * 2
        local delay = 0.1 + (math.floor(adjIndex/width) * 3)
        table.insert(FormationPos, { offsetX, -offsetY, categories.ALLUNITS, delay, rotate })
    end

    return FormationPos
end

-- local function for performing lerp
local function lerp( alpha, a, b )
    return a + ((b-a) * alpha)
end

function CircleFormation( formationUnits )
    local rotate = false
    local FormationPos = {}
    local numUnits = table.getn(formationUnits)
    local sizeMult = 2.0 + math.max(1.0, numUnits / 3.0)

    -- make circle around center point
    for i in formationUnits do
        offsetX = sizeMult * math.sin( lerp( i/numUnits, 0.0, math.pi * 2.0 ) )
        offsetY = sizeMult * math.cos( lerp( i/numUnits, 0.0, math.pi * 2.0 ) )
        table.insert(FormationPos, { offsetX, offsetY, categories.ALLUNITS, 0, rotate })
    end

    return FormationPos
end

function GuardFormation( formationUnits )
    local rotate = false
    local FormationPos = {}
    local numUnits = table.getn(formationUnits)

    local naval = false
    local sizeMult = 3
    for k,v in formationUnits do
        if not v:IsDead() and EntityCategoryContains( categories.NAVAL * categories.MOBILE, v ) then
            naval = true
            sizeMult = 8
            break
        end
    end

    local ringChange = 5
    local unitCount = 1

    -- make circle around center point
    for i in formationUnits do
        if unitCount == ringChange then
            ringChange = ringChange + 5
            if naval then
                sizeMult = sizeMult + 8
            else
                sizeMult = sizeMult + 3
            end
            unitCount = 1
        end
        offsetX = sizeMult * math.sin( lerp( unitCount/ringChange, 0.0, math.pi * 2.0 )) -- + math.pi / 16 )
        offsetY = sizeMult * math.cos( lerp( unitCount/ringChange, 0.0, math.pi * 2.0 )) -- + math.pi / 16 )
        --LOG('*FORMATION DEBUG: X=' .. offsetX .. ', Y=' .. offsetY )
        table.insert(FormationPos, { offsetX - 10, offsetY, categories.ALLUNITS, 0, rotate })
        unitCount = unitCount + 1
    end

    return FormationPos
end




--=========== LAND BLOCK BUILDING =================--
function BlockBuilderLand(unitsList, formationBlock, categoryTable, spacing)
    spacing = spacing or 1
    local numRows = table.getn(formationBlock)
    local i = 1
    local whichRow = 1
    local whichCol = 1
    local currRowLen = table.getn(formationBlock[whichRow])
    local rowType = false
    local formationLength = 0
    local inserted = false
    while unitsList.UnitTotal >= i do
        if whichCol > currRowLen then
            if whichRow == numRows then
                whichRow = 1
                if formationBlock.RowBreak then
                    formationLength = formationLength + 1 + formationBlock.RowBreak
                else
                    formationLength = formationLength + 1
                end
            else
                whichRow = whichRow + 1
                if formationBlock.LineBreak then
                    formationLength = formationLength + 1 + formationBlock.LineBreak
                else
                    formationLength = formationLength + 1
                end
                rowType = false
            end
            whichCol = 1
            currRowLen = table.getn(formationBlock[whichRow])
        end
        local currColSpot = GetColSpot(currRowLen, whichCol) -- Translate whichCol to correct spot in row
        local currSlot = formationBlock[whichRow][currColSpot]
        for numType, type in currSlot do
            if inserted then
                break
            end
            for numGroup, group in type do
                if not formationBlock.HomogenousRows or (rowType == false or rowType == type) then
                    if unitsList[group] > 0 then
                        --local xPos = (math.ceil(whichCol/2)/2) - 0.25
                        local xPos
                        if math.mod( currRowLen, 2 ) == 0 then
                            xPos = math.ceil(whichCol/2) - .5
                            if not (math.mod(whichCol, 2) == 0) then
                                xPos = xPos * -1
                            end
                        else
                            if whichCol == 1 then
                                xPos = 0
                            else
                                xPos = math.ceil( ( (whichCol-1) /2 ) )
                                if not (math.mod(whichCol, 2) == 0) then
                                    xPos = xPos * -1
                                end
                            end
                        end
                        if formationBlock.HomogenousRows and not rowType then
                            rowType = type
                        end
                        table.insert(FormationPos, {xPos*spacing, -formationLength*spacing, categoryTable[group], formationLength, true})
                        inserted = true
                        unitsList[group] = unitsList[group] - 1
                        break
                    end
                end
            end
        end
        if inserted then
            i = i + 1
            inserted = false
        end
        whichCol = whichCol + 1
    end
    return FormationPos
end

function GetColSpot(rowLen, col)
    local len = rowLen
    if math.mod(rowLen,2) == 1 then
        len = rowLen + 1
    end
    local colType = 'left'
    if math.mod(col, 2) == 0 then
        colType = 'right'
    end
    local colSpot = math.floor(col / 2)
    local halfSpot = len/2
    if colType == 'left' then
        return halfSpot - colSpot
    else
        return halfSpot + colSpot
    end
end





--============ AIR BLOCK BUILDING =============--
function BlockBuilderAir(unitsList, airBlock)
    local numRows = table.getn(airBlock)
    local i = 1
    local whichRow = 1
    local whichCol = 1
    local chevronPos = 1
    local currRowLen = table.getn(airBlock[whichRow])
    local longestRow = 1
    local longestLength = 0
    local chevronSize = airBlock.ChevronSize or 5
    while i < numRows do
        if table.getn(airBlock[i]) > longestLength then
            longestLength = table.getn(airBlock[i])
            longestRow = i
        end
        i = i + 1
    end
    local chevronType = false
    local formationLength = 0
    local spacing = 1

    if unitsList.AExper > 0 then
        spacing = 2
    end

    i = 1
    while unitsList.UnitTotal >= i do
        if chevronPos > chevronSize then
            chevronPos = 1
            chevronType = false
            if whichCol == currRowLen then
                if whichRow == numRows then
                    if airBlock.RepeatAllRows then
                        whichRow = 1
                        currRowLen = table.getn(airBlock[whichRow])
                    end
                else
                    whichRow = whichRow + 1
                    currRowLen = table.getn(airBlock[whichRow])
                end
                formationLength = formationLength + 1
                whichCol = 1
            else
                whichCol = whichCol + 1
            end
        end
        local currSlot = airBlock[whichRow][whichCol]
        local inserted = false
        for numType, type in currSlot do
            if inserted then
                break
            end
            for numGroup, group in type do
                if not airBlock.HomogenousBlocks or chevronType == false or chevronType == type then
                    if unitsList[group] > 0 then
                        local xPos, yPos = GetChevronPosition(chevronPos, whichCol, currRowLen, formationLength)
                        if airBlock.HomogenousBlocks and not chevronType then
                            chevronType = type
                        end
                        table.insert(FormationPos, {xPos*spacing, yPos*spacing, AirCategories[group], yPos, true})
                        unitsList[group] = unitsList[group] - 1
                        inserted = true
                        break
                    end
                end
            end
        end
        if inserted then
            i = i + 1
        end
        chevronPos = chevronPos + 1
    end
    return FormationPos
end

function GetChevronPosition(chevronPos, currCol, currRowLen, formationLen)
    local offset = math.floor(chevronPos/2) * .375
    local xPos = offset
    if math.mod(chevronPos,2) == 0 then
        xPos = -1 * offset
    end
    local yPos = -offset
    yPos = yPos + ( formationLen * -1.5 )
    local firstBlockOffset = -2
    if math.mod(currRowLen,2) == 1 then
        firstBlockOffset = -1
    end
    local blockOff = math.floor(currCol/2) * 2
    if math.mod(currCol,2) == 1 then
        blockOff = -blockOff
    end
    xPos = xPos + blockOff + firstBlockOffset
    return xPos, yPos
end





--=========== NAVAL UNIT BLOCKS ============--
function NavalBlocks( unitsList, navyType )
    local Carriers = true
    local Battleships = true
    local Cruisers = true
    local Destroyers = true
    local unitNum = 1
    for i,v in navyType do
        for k,u in v[2] do
            if u == 'Carriers' and Carriers and unitsList.CarrierCount > 0 then
                for j, coord in v[1] do
                    if unitsList.CarrierCount ~= 0 then
                        table.insert(FormationPos, { coord[1]*NavalSpacing, coord[2]*NavalSpacing, categories.NAVAL * categories.AIRSTAGINGPLATFORM * ( categories.TECH3 + categories.EXPERIMENTAL ), 0, true })
                        unitsList.CarrierCount = unitsList.CarrierCount - 1
                        unitNum = unitNum + 1
                    end
                end
                Carriers = false
                break
            elseif u == 'Battleships' and Battleships and unitsList.BattleshipCount > 0 then
                for j, coord in v[1] do
                    if unitsList.BattleshipCount ~= 0 then
                        table.insert(FormationPos, { coord[1]*NavalSpacing, coord[2]*NavalSpacing, BattleshipNaval, 0, true })
                        unitsList.BattleshipCount = unitsList.BattleshipCount - 1
                        unitNum = unitNum + 1
                    end
                end
                Battleships = false
                break
            elseif u == 'Cruisers' and Cruisers and unitsList.CruiserCount > 0 then
                for j, coord in v[1] do
                    if unitsList.CruiserCount ~= 0 then
                        table.insert(FormationPos, { coord[1]*NavalSpacing, coord[2]*NavalSpacing, CruiserNaval, 0, true })
                        unitNum = unitNum + 1
                        unitsList.CruiserCount = unitsList.CruiserCount - 1
                    end
                end
                Cruisers = false
                break
            elseif u == 'Destroyers' and Destroyers and unitsList.DestroyerCount > 0 then
                for j, coord in v[1] do
                    if unitsList.DestroyerCount > 0 then
                        table.insert(FormationPos, { coord[1]*NavalSpacing, coord[2]*NavalSpacing, DestroyerNaval, 0, true })
                        unitNum = unitNum + 1
                        unitsList.DestroyerCount = unitsList.DestroyerCount - 1
                    end
                end
                Destroyers = false
                break
            elseif u == 'Frigates' and unitsList.FrigateCount > 0 then
                for j, coord in v[1] do
                    if unitsList.FrigateCount > 0 then
                        table.insert(FormationPos, { coord[1]*NavalSpacing, coord[2]*NavalSpacing, FrigateNaval, 0, true })
                        unitNum = unitNum + 1
                        unitsList.FrigateCount = unitsList.FrigateCount - 1
                    end
                end
                break
            elseif u == 'Frigates' and unitsList.LightCount > 0 then
                for j,coord in v[1] do
                    if unitsList.LightCount > 0 then
                        table.insert(FormationPos, { coord[1]*NavalSpacing, coord[2]*NavalSpacing, LightAttackNaval, 0, true })
                        unitNum = unitNum + 1
                        unitsList.LightCount = unitsList.LightCount - 1
                    end
                end
                break
            elseif u == 'Submarines' and unitsList.SubCount > 0 then
                for j,coord in v[1] do
                    if ( unitsList.SubCount + unitsList.NukeSubCount ) > 0 then
                        table.insert(FormationPos, { coord[1]*NavalSpacing, coord[2]*NavalSpacing, SubNaval + NukeSubNaval, 0, true })
                        unitNum = unitNum + 1
                        unitsList.SubCount = unitsList.SubCount - 1
                    end
                end
                break
            end
        end
    end

    local sideTable = { 0, -2, 2 }
    local sideIndex = 1
    local length = -3

    i = unitNum

    -- Figure out how many left we have to assign
    local numLeft = unitsList.UnitTotal - i + 1
    if numLeft == 2 then
        sideIndex = 2
    end

    while i <= unitsList.UnitTotal do
        if unitsList.CarrierCount > 0 then
            table.insert(FormationPos, { sideTable[sideIndex]*NavalSpacing, length*NavalSpacing, categories.NAVAL * categories.AIRSTAGINGPLATFORM * ( categories.TECH3 + categories.EXPERIMENTAL ), 0, true  })
            unitNum = unitNum + 1
            unitsList.CarrierCount = unitsList.CarrierCount - 1
        elseif unitsList.BattleshipCount > 0 then
            table.insert(FormationPos, { sideTable[sideIndex]*NavalSpacing, length*NavalSpacing, BattleshipNaval, 0, true })
            unitNum = unitNum + 1
            unitsList.BattleshipCount = unitsList.BattleshipCount - 1
        elseif unitsList.CruiserCount > 0 then
            table.insert(FormationPos, { sideTable[sideIndex]*NavalSpacing, length*NavalSpacing, CruiserNaval, 0, true })
            unitNum = unitNum + 1
            unitsList.CruiserCount = unitsList.CruiserCount - 1
        elseif unitsList.DestroyerCount > 0 then
            table.insert(FormationPos, { sideTable[sideIndex]*NavalSpacing, length*NavalSpacing, DestroyerNaval, 0, true })
            unitNum = unitNum + 1
            unitsList.DestroyerCount = unitsList.DestroyerCount - 1
        elseif unitsList.FrigateCount > 0 then
            table.insert(FormationPos, { sideTable[sideIndex]*NavalSpacing, length*NavalSpacing, FrigateNaval, 0, true })
            unitNum = unitNum + 1
            unitsList.FrigateCount = unitsList.FrigateCount - 1
        elseif unitsList.LightCount > 0 then
            table.insert(FormationPos, { sideTable[sideIndex]*NavalSpacing, length*NavalSpacing, LightAttackNaval, 0, true })
            unitNum = unitNum + 1
            unitsList.LightCount = unitsList.LightCount - 1
        elseif ( unitsList.SubCount + unitsList.NukeSubCount ) > 0 then
            table.insert(FormationPos, { sideTable[sideIndex]*NavalSpacing, length*NavalSpacing, SubNaval + NukeSubNaval, 0, true })
            unitNum = unitNum + 1
            unitsList.SubCount = unitsList.SubCount - 1
        elseif ( unitsList.MobileSonarCount ) > 0 then
            table.insert(FormationPos, { sideTable[sideIndex]*NavalSpacing, length*NavalSpacing, MobileSonar + DefensiveBoat, 0, true } )
            unitNum = unitNum + 1
            unitsList.MobileSonarCount = unitsList.MobileSonarCount - 1
        elseif ( unitsList.RemainingCategory ) > 0 then
            table.insert(FormationPos, { sideTable[sideIndex]*NavalSpacing, length*NavalSpacing, NavalCategories.RemainingCategory, 0, true } )
            unitNum = unitNum + 1
            unitsList.RemainingCategory = unitsList.RemainingCategory - 1
        end

        -- Figure out the next viable location for the naval unit
        numLeft = numLeft - 1
        sideIndex = sideIndex + 1
        if sideIndex == 4 then
            length = length - 2
            if numLeft == 2 then
                sideIndex = 2
            else
                sideIndex = 1
            end
        end

        i = i + 1
    end
    return FormationPos
end



--========= UNIT SORTING ==========--
function CategorizeAirUnits( formationUnits )
    local unitsList = {
        ---- Air Lists
        AFtr1 = 0,
    	Bomb1 = 0,
    	AGun1 = 0,
    	ATrn1 = 0,
    	AExp1 = 0,
    	RemainingCategory = 0,
        UnitTotal = 0,
    }
    for i,u in formationUnits do
        for aircat,_ in AirCategories do
            if EntityCategoryContains(AirCategories[aircat], u) then
                unitsList[aircat] = unitsList[aircat] + 1
                if AirCategories[aircat] == "RemainingCategory" then
                    LOG('*FORMATION DEBUG: Missed unit: ' .. u:GetUnitId())
                end
                unitsList.UnitTotal = unitsList.UnitTotal + 1
                break
            end
        end
    end
    --LOG('UnitsList=', repr(unitsList))
    return unitsList
end

function CategorizeSeaUnits( formationUnits)
    local unitsList = {
        ---- Naval Lists
        SFri1 = 0,
		SCru1 = 0,
		SDes1 = 0,
		SBtl1 = 0,
		STrn1 = 0,
    	SExp1 = 0,
        SubCount = 0,
    	RemainingCategory = 0,
        UnitTotal = 0,
    }
    --== NAVAL UNITS ==--
    for i,u in formationUnits do
        for navcat,_ in NavalCategories do
            if EntityCategoryContains(NavalCategories[navcat], u) then
                unitsList[navcat] = unitsList[navcat] + 1
                if NavalCategories[navcat] == "RemainingCategory" then
                    LOG('*FORMATION DEBUG: Missed unit: ' .. u:GetUnitId())
                end
                unitsList.UnitTotal = unitsList.UnitTotal + 1
                break
            end
        end
        --categorize subs
        for subcat,_ in SubCategories do
            if EntityCategoryContains(SubCategories[subcat], u) then
                unitsList[subcat] = unitsList[subcat] + 1
                if SubCategories[subcat] == "RemainingCategory" then
                    LOG('*FORMATION DEBUG: Missed unit: ' .. u:GetUnitId())
                end
                unitsList.UnitTotal = unitsList.UnitTotal + 1
                break
            end
        end
    end
    return unitsList
end

function CategorizeLandUnits( formationUnits )
    local unitsList = {
        ---- Land Numbers
        DFire1 = 0,
        Const1 = 0,
        IFire1 = 0,
        AntiA1 = 0,
        MShld1 = 0,
        DFExp1 = 0,
        RemainingCategory = 0,
        UnitTotal = 0,
    }
    for i,u in formationUnits do
        for landcat,_ in LandCategories do
            if EntityCategoryContains(LandCategories[landcat], u) then
                unitsList[landcat] = unitsList[landcat] + 1
                if LandCategories[landcat] == "RemainingCategory" then
                    LOG('*FORMATION DEBUG: Missed unit: ' .. u:GetUnitId())
                end
                unitsList.UnitTotal = unitsList.UnitTotal + 1
                break
            end
        end

    end

    return unitsList
end
