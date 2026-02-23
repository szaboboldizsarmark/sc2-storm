-- Class methods:
-- Set(string filename)
-- Play()
-- Stop()
-- Loop(bool loop)
-- number GetFrameRate()
-- int GetNumFrames()

local Control = import('control.lua').Control

Movie = Class(moho.movie_methods, Control) {

    __init = function(self, parent, filename, sound, voice)
        InternalCreateMovie(self, parent)
        if filename then
            self:Set(filename, sound, voice)
        end
    end,

    ResetLayout = function(self)
        Control.ResetLayout(self)
        self.Width:SetFunction(function() return self.MovieWidth() end)
        self.Height:SetFunction(function() return self.MovieHeight() end)
    end,

    OnInit = function(self)
        Control.OnInit(self)
    end,
    
    Set = function(self,filename,sound,voice) -- sound and voice are optional        
		if self.loadThread then
			KillThread( self.loadThread )
			self.loadThread = nil
		end
		
        local ok = self:InternalSet(filename)
        if ok then            
            self.loadThread = ForkThread(
                function()
                    while self do
                        if self:IsLoaded() then                               
                            self:OnLoaded()
                            return
                        end
                        WaitTicks(1)
                    end
                end
            )
        else
            -- Force calls to OnStopped()
            self:OnStopped()
        end
    end,   

    GetLength = function(self)
        return self:GetNumFrames() / self:GetFrameRate()
    end,

    -- callback scripts
    OnFinished = function(self) end,
    OnStopped = function(self) end,

    -- Called when a subtitle changes. string should be LOC()'d for display
    OnSubtitle = function(self,string) end,

    -- Called when the movie is loaded and ready to play immediately
    OnLoaded = function(self)
    end,  
}
