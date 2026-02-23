--[[
Contains the mapping of restriction types to restriction data in the following format:

type = {
    categories = {"cat1", "cat2", etc...},
    name = "name to display in list",
    tooltip = tooltipID,
}
--]]

restrictedUnits = {
	EXPERIMENTALS = {
        categories = { "EXPERIMENTAL", "EXPERIMENTALFACTORY" },
        name = "<LOC restricted_units_data_0011>No Experimentals",
        ui_index = 1,
    },
    AIR = {
        categories = {"uca0103","uca0104","uca0105d1","uca0901","ucx0102","ucx0112","ucx0115","ucb0002","ucb0012","ucb0102","ucm0121",
        	"uia0103","uia0104","uia0901","uil0105","uix0112","uib0002","uib0102","uim0121","uix0105d1",
        	"uua0101","uua0102","uua0103","uua0901","uul0105","uux0102","uux0103","uux0112","uub0002","uub0012","uub0102","uum0121"},
        name = "<LOC restricted_units_data_0006>No Air",
        ui_index = 2,
    },
    LAND = {
        categories = {"ucl0002","ucl0102","ucl0103","ucl0104","ucl0204","ucx0101","ucx0103","ucx0104d1","ucx0111","ucx0117d1","ucb0001","ucb0011",
        	"uil0002","uil0101","uil0103","uil0104","uil0105","uil0106d1","uil0202","uil0203","uix0101","uix0102","uix0103","uix0111","uix0115","uib0001",
        	"uul0002","uul0003d1","uul0101","uul0102","uul0103","uul0104","uul0105","uul0201","uul0203","uux0101","uux0111","uux0113d1","uux0114","uub0001","uub0011"},
        name = "<LOC restricted_units_data_0005>No Land",
        ui_index = 3,
    },
    NAVAL = {
        categories = {"ucs0103","ucs0105","ucs0901","ucx0113","ucb0003","ucm0131",
        	"uus0102","uus0104","uus0105","uux0104","uux0105d1","uub0003","uum0131"},
        name = "<LOC restricted_units_data_0004>No Naval",
        ui_index = 4,
    },
    NUKE = {
        categories = {"ucb0204", "ucb0205d1", "uib0107", "uib0203", "uub0107","uub0203"},
        name = "<LOC restricted_units_data_0012>No Nukes",
        ui_index = 5,
    },
    SHIELDS = {
        categories = {"ucb0202", "uib0202", "uub0202",
        	"ucl0204","uul0201",
        	"ucm0211", "uim0211", "uum0211", "uux0116d1",},
        name = "<LOC restricted_units_noshield>No Shield Structures",
        ui_index = 6,
    },
    INTEL = {
        categories = {"ucb0303", "uib0301", "uub0301", "uub0302",
        	"ucm0141", "uim0141", "uum0141", "uix0118d1"},
        name = "<LOC restricted_units_data_0014>No Intel Structures",
        ui_index = 7,
    },
    ADDONS = {
        categories = {"UPGRADEMODULE"},
        name = "<LOC restricted_units_data_0015>No Structure Add-ons",
        ui_index = 8,
    },
    ALL_RESEARCH_UNITS = {
		name = "<LOC restricted_units_data_0016>No Research / All Units Unlocked",
		ui_index = 9,
	},
    ALL_RESEARCH = {
		name = "<LOC restricted_units_data_0017>No Research / All Research and Units Unlocked",
		ui_index = 10,
	},
    SLOW_RESEARCH = {
		name = "<LOC restricted_units_data_0018>Slow Research (No Research Stations)",
        categories = {"uub0801", "ucb0801", "uib0801", "ucx0115", "uub0705d1",},
		ui_index = 11,
	},
    MASSCONVERT = {
        categories = {"ucb0704", "uib0704", "uub0704"},
        name = "<LOC restricted_units_data_nomass>No Mass Conversion",
        ui_index = 12,
    },
    NO_DLC = {
		name = "<LOC restricted_units_data_nodlc>No DLC Units",
        categories = {"uca0105d1", "ucb0205d1", "ucb0401d1", "ucx0104d1","ucx0117d1",
        	"uil0106d1","uix0104d1","uix0105d1","uix0118d1",
        	"uub0705d1","uul0003d1","uux0105d1","uux0113d1","uux0116d1",},
		ui_index = 13,
	},
    ARTILLERY = {
		name = "<LOC restricted_units_data_noartillery>No Artillery Structures",
        categories = {"ucb0105", "uix0104d1", "uub0105", "uux0114", "uux0115",},
		ui_index = 14,
	},
}