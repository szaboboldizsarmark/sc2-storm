--
--	Params for rendering selection indicators
--		ren_SelectionSizeFudge				: Fudge value used when unit is not valid
--		ren_SelectionHeightFudge			: Fudge height value used when unit is not valid
--		ren_UnitSelectionScale				: Global scale multiplier applied to the selection indicator
--		ren_SelectColor						: Vertex color to apply to the selection indicator 
--		ren_SelectBracketMinPixelSize		: Minimum size for the bracket thickness in pixels
--		ren_SelectBracketSize				: Default size for the bracket thickness in world units
--		ren_CircularSelectionBrackets		: Makes selection brackets operate as though they were radially symmetrical
--		ren_SelectBracketRotateSpeed		: Rotation speed of circular selection bracket
--		ren_HighlightScaleMultiplier		: Multiplies the highlight render selection with additional extent scale
--		ren_RenderExtraHighlightSelection	: Renders a sepearate indicator for the highlighted entity


RenderSelectParams = {        
	ren_SelectionSizeFudge				= 1.85, 
	ren_SelectionHeightFudge			= 0.12,
	ren_UnitSelectionScale				= 0.75,
	ren_SelectColor						= 0xffffffff,
	ren_SelectBracketMinPixelSize		= 3.0, 
    ren_SelectBracketSize				= 0.2,
	ren_CircularSelectionBrackets		= false,
	ren_SelectBracketRotateSpeed		= 0.0,
	ren_HighlightScaleMultiplier		= 1.2,
	ren_RenderExtraHighlightSelection	= true;
	
}