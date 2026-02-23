--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------


UserDecal = Class(moho.userDecal_methods) {
    __init = function(self)
        _c_CreateDecal(self)
    end,
    
    -- SetPositionByScreen(vector2)
    -- SetTexture(string)
    -- SetScale(vector3)
}