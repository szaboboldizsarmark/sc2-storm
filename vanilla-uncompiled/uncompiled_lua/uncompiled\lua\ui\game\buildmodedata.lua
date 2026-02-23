-- Maps specific builders to what keys will do in build mode

--UEF
local UEFEngineer1 = {
    ['L'] = 'uub0001',
    ['A'] = 'uub0002',
    ['S'] = 'uub0003',
    ['M'] = 'uub0701',
    ['E'] = 'uub0702',
    ['R'] = 'uub0801',
    ['P'] = 'uub0101',
    ['T'] = 'uub0102',
}

local UEFEngineer2 = {
    ['M'] = 'uub0704',
    ['F'] = 'uub0104',
    ['L'] = 'uub0105',
    ['D'] = 'uub0203',
    ['N'] = 'uub0107',
    ['S'] = 'uub0202',
    ['R'] = 'uub0301',
    ['W'] = 'uub0302',
}

local UEFEngineer3 = {
    ['L'] = 'uub0011',
    ['A'] = 'uub0012',
    ['S'] = 'uux0104',
    ['D'] = 'uux0115',
    ['N'] = 'uux0114',
}

local UEFLandFactory1 = {
    ['E'] = 'uul0002',
    ['T'] = 'uul0101',
    ['A'] = 'uul0103',
    ['R'] = 'uul0102',
    ['I'] = 'uul0105',
    ['M'] = 'uul0104',
    ['S'] = 'uul0201',
    ['N'] = 'uul0203',
}

local UEFLandFactory2 = {
    ['T'] = 'uum0111',
    ['A'] = 'uum0121',
    ['I'] = 'uum0141',
    ['S'] = 'uum0211',
}

local UEFAirFactory1 = {
    ['E'] = 'uul0002',
    ['F'] = 'uua0101',
    ['R'] = 'uua0102',
    ['G'] = 'uua0103',
    ['T'] = 'uua0901',
}

local UEFAirFactory2 = {
    ['T'] = 'uum0111',
    ['A'] = 'uum0121',
    ['I'] = 'uum0141',
    ['S'] = 'uum0211',
}

local UEFSeaFactory1 = {
    ['E'] = 'uul0002',
    ['C'] = 'uus0102',
    ['S'] = 'uus0104',
    ['P'] = 'uus0105',
}

local UEFSeaFactory2 = {
    ['T'] = 'uum0111',
    ['A'] = 'uum0121',
    ['I'] = 'uum0141',
    ['S'] = 'uum0211',
    ['U'] = 'uum0131',
}

--Illuminate
local IlluminateEngineer1 = {
    ['L'] = 'uib0001',
    ['A'] = 'uib0002',
    ['M'] = 'uib0701',
    ['E'] = 'uib0702',
    ['R'] = 'uib0801',
    ['P'] = 'uib0101',
    ['T'] = 'uib0102',
}

local IlluminateEngineer2 = {
    ['M'] = 'uib0704',
    ['T'] = 'uib0106',
    ['D'] = 'uib0203',
    ['N'] = 'uib0107',
    ['S'] = 'uib0202',
    ['R'] = 'uib0301',
}

local IlluminateEngineer3 = {
    ['E'] = 'uib0011',
    ['S'] = 'uix0113',
    ['L'] = 'uix0114',
}

local IlluminateLandFactory1 = {
    ['E'] = 'uil0002',
    ['T'] = 'uil0101',
    ['A'] = 'uil0103',
    ['R'] = 'uil0102',
    ['I'] = 'uil0105',
    ['M'] = 'uil0104',
    ['D'] = 'uil0202',
    ['N'] = 'uil0203',
}

local IlluminateLandFactory2 = {
    ['T'] = 'uim0111',
    ['A'] = 'uim0121',
    ['I'] = 'uim0141',
    ['S'] = 'uim0211',
}

local IlluminateAirFactory1 = {
    ['E'] = 'uil0002',
    ['F'] = 'uia0104',
    ['G'] = 'uia0103',
    ['T'] = 'uia0901',
}

local IlluminateAirFactory2 = {
    ['T'] = 'uim0111',
    ['A'] = 'uim0121',
    ['I'] = 'uim0141',
    ['S'] = 'uim0211',
}

--Cybran
local CybranEngineer1 = {
    ['L'] = 'ucb0001',
    ['A'] = 'ucb0002',
    ['S'] = 'ucb0003',
    ['M'] = 'ucb0701',
    ['E'] = 'ucb0702',
    ['R'] = 'ucb0801',
    ['P'] = 'ucb0101',
    ['T'] = 'ucb0102',
}

local CybranEngineer2 = {
	['M'] = 'ucb0704',
    ['L'] = 'ucb0105',
    ['N'] = 'ucb0204',
    ['S'] = 'ucb0202',
    ['R'] = 'ucb0303',
}

local CybranEngineer3 = {
    ['L'] = 'ucb0011',
    ['A'] = 'ucb0012',
    ['K'] = 'ucx0113',
    ['P'] = 'ucx0115',
    ['M'] = 'ucx0114',
}

local CybranLandFactory1 = {
    ['E'] = 'ucl0002',
    ['A'] = 'ucl0103',
    ['R'] = 'ucl0102',
    ['M'] = 'ucl0104',
    ['S'] = 'ucl0201',
}

local CybranLandFactory2 = {
    ['T'] = 'ucm0111',
    ['A'] = 'ucm0121',
    ['I'] = 'ucm0141',
    ['S'] = 'ucm0211',
}

local CybranAirFactory1 = {
    ['E'] = 'ucl0002',
    ['F'] = 'uca0104',
    ['G'] = 'uca0103',
    ['T'] = 'uca0901',
}

local CybranAirFactory2 = {
    ['T'] = 'ucm0111',
    ['A'] = 'ucm0121',
    ['I'] = 'ucm0141',
    ['S'] = 'ucm0211',
}

local CybranSeaFactory1 = {
    ['E'] = 'ucl0002',
    ['D'] = 'ucs0103',
    ['S'] = 'ucs0105',
    ['C'] = 'ucs0901',
}

local CybranSeaFactory2 = {
    ['T'] = 'ucm0111',
    ['A'] = 'ucm0121',
    ['I'] = 'ucm0141',
    ['S'] = 'ucm0211',
    ['U'] = 'ucm0131',
}

--Keys for tabs and units with a single tab
buildModeKeys = {
--UEF
 	--ACU
    ['uul0001'] = {
        [1] = UEFEngineer1,
        [2] = UEFEngineer2,
        [3] = UEFEngineer3,
    },
 	--Engineer
    ['uul0002'] = {
        [1] = UEFEngineer1,
        [2] = UEFEngineer2,
        [3] = UEFEngineer3,
    },
 	--Land Factory
    ['uub0001'] = {
        [1] = UEFLandFactory1,
        [2] = UEFLandFactory2,
    },
 	--Air Factory
    ['uub0002'] = {
        [1] = UEFAirFactory1,
        [2] = UEFAirFactory2,
    },
 	--Sea Factory
    ['uub0003'] = {
        [1] = UEFSeaFactory1,
        [2] = UEFSeaFactory2,
    },
 	--Land Exp
    ['uub0011'] = {
        ['F'] = 'uux0101',
        ['K'] = 'uux0111',
    },
 	--Air Exp
    ['uub0012'] = {
        ['A'] = 'uux0102',
        ['C'] = 'uux0103',
        ['F'] = 'uux0112',
    },
 	--Atlantis
    ['uux0104'] = {
        [1] = UEFAirFactory1,
    },
 	--Air Fortress
    ['uux0112'] = {
        [1] = UEFAirFactory1,
    },
 	--Unit Cannon
    ['uux0114'] = {
        [1] = UEFLandFactory1,
    },
 	--ACU Head
    ['uum0001'] = {
        ['A'] = 'uul0001',
    },

--Illuminate
 	--ACU
    ['uil0001'] = {
        [1] = IlluminateEngineer1,
        [2] = IlluminateEngineer2,
        [3] = IlluminateEngineer3,
    },
 	--Engineer
    ['uil0002'] = {
        [1] = IlluminateEngineer1,
        [2] = IlluminateEngineer2,
        [3] = IlluminateEngineer3,
    },
 	--Land Factory
    ['uib0001'] = {
        [1] = IlluminateLandFactory1,
        [2] = IlluminateLandFactory2,
    },
 	--Air Factory
    ['uib0002'] = {
        [1] = IlluminateAirFactory1,
        [2] = IlluminateAirFactory2,
    },
 	--Exp Factory
    ['uib0012'] = {
        ['U'] = 'uix0101',
        ['W'] = 'uix0102',
        ['A'] = 'uix0103',
        ['C'] = 'uix0111',
        ['D'] = 'uix0112',
        ['P'] = 'uix0115',
    },
 	--ACU Head
    ['uim0001'] = {
        ['A'] = 'uil0001',
    },

--Cybran
 	--ACU
    ['ucl0001'] = {
        [1] = CybranEngineer1,
        [2] = CybranEngineer2,
        [3] = CybranEngineer3,
    },
 	--Engineer
    ['ucl0002'] = {
        [1] = CybranEngineer1,
        [2] = CybranEngineer2,
        [3] = CybranEngineer3,
    },
 	--Land Factory
    ['ucb0001'] = {
        [1] = CybranLandFactory1,
        [2] = CybranLandFactory2,
    },
 	--Air Factory
    ['ucb0002'] = {
        [1] = CybranAirFactory1,
        [2] = CybranAirFactory2,
    },
 	--Sea Factory
    ['ucb0003'] = {
        [1] = CybranSeaFactory1,
        [2] = CybranSeaFactory2,
    },
 	--Land Exp
    ['ucb0011'] = {
        ['M'] = 'ucx0101',
        ['S'] = 'ucx0103',
        ['C'] = 'ucx0111',
    },
 	--Air Exp
    ['ucb0012'] = {
        ['T'] = 'ucx0102',
        ['S'] = 'ucx0112',
    },
 	--ACU Head
    ['ucm0001'] = {
        ['A'] = 'ucl0001',
    },
}