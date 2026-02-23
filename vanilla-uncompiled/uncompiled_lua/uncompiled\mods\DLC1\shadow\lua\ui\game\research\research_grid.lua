research_grid = {
	grid_line_texture_active = '/textures/ui/common/360/hd/ingame/research/line.dds',
	grid_line_texture_inactive = '/textures/ui/common/360/hd/ingame/research/line.dds',
	grid_line_height = 20;
	level_label_x_offset = 30,
	level_label_y_offset = 30,
	level_label_font = 'title_font_bold_1',

	-- $ There should be a better place to put these, since they will change over time.
	requiredEnergy = 180,
	requiredMass = 60,
	
	sounds = {
		buy = 'SC2/SC2/Interface/Research/snd_UI_Research_Buy_Unit',
		rollover = 'SC2/SC2/Interface/Research/snd_UI_Research_Rollover',
		failure = 'SC2/SC2/Interface/Research/snd_UI_Research_Buy_Failure',
	},

	state_colors = {
		researched = 'fffff4d7',
		unresearched = 'ffcaffd1',
		unavailable = 'ffffcaca',
		locked = '4bffffff',
		disabled = '4bffffff',
	},

	pc_researchtree = {
		grid_unit_width = 56,
		grid_unit_height = 56,
		element_width = 56,
		element_height = 56,
		icon_width = 44,
		icon_height = 44,
	},

	x360_researchtree = {
		grid_unit_width = 62,
		grid_unit_height = 44,
		element_width = 62,
		element_height = 44,
		icon_width = 40,
		icon_height = 40,
	},

	button_images = {
		pc = {
			up_researched = '/textures/ui/common/pc/ingame/research/grid/researched_u.dds',
			down_researched = '/textures/ui/common/pc/ingame/research/grid/researched_w.dds',
			up_unresearched = '/textures/ui/common/pc/ingame/research/grid/available_u.dds',
			down_unresearched = '/textures/ui/common/pc/ingame/research/grid/available_w.dds',
			up_unavailable = '/textures/ui/common/pc/ingame/research/grid/unavailable_u.dds',
			down_unavailable = '/textures/ui/common/pc/ingame/research/grid/unavailable_w.dds',
			up_locked = '/textures/ui/common/pc/ingame/research/grid/locked_u.dds',
			down_locked = '/textures/ui/common/pc/ingame/research/grid/locked_w.dds',
			over = '/textures/ui/common/pc/ingame/research/grid/over.dds',
			disabled = '/textures/ui/common/pc/ingame/research/grid/restricted.dds',
		},

		x360 = {
			up_researched = '/textures/ui/common/360/hd/ingame/research/grid/researched_u.dds',
			down_researched = '/textures/ui/common/360/hd/ingame/research/grid/researched_w.dds',
			up_unresearched = '/textures/ui/common/360/hd/ingame/research/grid/available_u.dds',
			down_unresearched = '/textures/ui/common/360/hd/ingame/research/grid/available_w.dds',
			up_unavailable = '/textures/ui/common/360/hd/ingame/research/grid/unavailable_u.dds',
			down_unavailable = '/textures/ui/common/360/hd/ingame/research/grid/unavailable_w.dds',
			up_locked = '/textures/ui/common/360/hd/ingame/research/grid/locked_u.dds',
			down_locked = '/textures/ui/common/360/hd/ingame/research/grid/locked_w.dds',
			over = '/textures/ui/common/360/hd/ingame/research/grid/over.dds',
			disabled = '/textures/ui/common/360/hd/ingame/research/grid/restricted.dds',
		},
	},

	initial_research = {
		UEF_COMMANDER = 'UCB_HEALTH',
		UEF_LAND = 'ULB_RANGE',
		UEF_AIR = 'UAB_RADAR',
		UEF_NAVAL = 'USB_HEALTH',
		UEF_STRUCTURES = 'UBB_BUILDCOST',
		ILLUMINATE_COMMANDER = 'ICB_DAMAGE',
		ILLUMINATE_LAND = 'ILB_BUILDCOST',
		ILLUMINATE_AIR = 'IAB_BUILDCOST',
		ILLUMINATE_STRUCTURES = 'IBA_PDHUNKER',
		CYBRAN_COMMANDER = 'CCB_VISION',
		CYBRAN_LAND = 'CLB_REGENERATION',
		CYBRAN_AIR = 'CAB_RATEOFFIRE',
		CYBRAN_NAVAL = 'CSB_SEAMOVESPEED',
		CYBRAN_STRUCTURES = 'CBB_BUILDTIME',
	},
}