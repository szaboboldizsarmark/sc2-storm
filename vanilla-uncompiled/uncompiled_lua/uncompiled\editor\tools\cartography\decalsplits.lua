CartographicInfo = {
	Batches = {
		Batch1 = {
			texture = '/textures/environment/moonAlbedo000.dds',
			technique = 'DecalGlow',
		},
		Batch2 = {
			texture = '/textures/environment/Decal_test_Albedo001.dds',
			technique = 'Decal',
		},
		Batch3 = {
			texture = '/textures/environment/Decal_test_Albedo001.dds',
			technique = 'DecalGlow',
		},
	},
	
	Decals = {
		-- Decals texture 1
		moonAlbedo000 = {
			texture = '/textures/environment/moonAlbedo000.dds',
			relative_u = 1,
			relative_v = 1,
		},
	    
		-- Decals texture 2
		Decal_test_Albedo000 = {
			texture = '/textures/environment/Decal_test_Albedo000.dds',
			relative_u = 4,
			relative_v = 4,
		},

		--Decals texture 3
		Decal_test_Albedo001 = {
			texture = '/textures/environment/Decal_test_Albedo001.dds',
			-- UV Coordinates 
			-- Upper left u,v
			-- Size Width, Height
			{
				0,0,64,64,
			},
			{
				0,64,64,64,
			},
			{
				0,128,64,64,
			},
			{
				0,192,64,64,
			},
			{
				64,0,64,64,
			},
			{
				64,64,64,64,
			},
			{
				64,128,64,64,
			},
			{
				64,192,64,64,
			},
			{
				128,0,64,64,
			},
			{
				128,64,64,64,
			},
			{
				128,128,64,64,
			},
			{
				128,192,64,64,
			},
			{
				192,0,64,64,
			},
			{
				192,64,64,64,
			},
			{
				192,128,64,64,
			},
			{
				192,192,64,	64,
			},
		},
	},
}
		