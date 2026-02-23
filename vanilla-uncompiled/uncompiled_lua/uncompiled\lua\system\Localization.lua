--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

local loc_table

-- Special tokens that can be included in a loc string via {g Player} etc. The
-- Player name gets replaced with the current selected player name.
LocGlobals = {
    PlayerName="Player",
    LBrace="{",
    RBrace="}",
    LT="<",
    GT=">"
}

-- This maps a subtitle channel to a given language
LocSubtitleChannels = {
	us = 0,	
	fr = 1,
	it = 2,
	de = 3,
	es = 4,	
	ru = 5,
	pl = 6,
	jp = 7,
}

local function dbFilename(la)
    return '/loc/' .. la .. '/strings_db.lua'
end

-- Check whether the given language is installed; if so, return it;
-- otherwise return some language that is installed.
local function okLanguage(la)
	
	if HasCommandLineArg( '/language' ) then
		args = GetCommandLineArg( '/language', 1 )
		la = args[1]
	end
	
	local dbfiles = DiskFindFiles('/loc', '*strings_db.lua')	
	
	if IsXbox() then
		if table.getn(dbfiles) == 1 then
			la = string.gsub(dbfiles[1], ".*/(.*)/.*", "%1")
			return la
		else 
			return GetXboxLanguageId()
		end
	end

    if la!='' and exists(dbFilename(la)) then
        return la
    end
    
    if table.getn(dbfiles) > 1 then
		return 'us'
	end
    
    la = string.gsub(dbfiles[1], ".*/(.*)/.*", "%1")
    return la
end

local function loadLanguage(la)
    local la = okLanguage(la)
    
    -- Set the subtitle channel to use.
    UISetMovieSubtitleChannel(LocSubtitleChannels[la])
    
    UISetLanguageId( la )
    
    if la == 'jp' then
		UISetEnableWhitespaceWordWrap( false )
    end    
    
    -- Special case handling for german audio in movies.
    if ( la == 'de' ) then
		UISetMovieAudioTrack(LocSubtitleChannels[la])
		
		--and in FMOD, since we're using a localized FEV rather than the normal localize-to-bank system FMOD is supposed to use.
		SetLocalizedFEV( 'SC2_VO_DE.fev' )
	end
    
    if ( la == 'us' ) then
		return
	end

    -- reload strings file...
    local newdb = {}
    doscript(dbFilename(la), newdb)
    __language = la
    loc_table = newdb      

    if HasLocalizedVO(la) then
        AudioSetLanguage(la)
    else
        AudioSetLanguage('us')
    end
end


-- Called from string.gsub in LocExpand() to expand a single {k v} element
local function LocSubFn(op, ident)
    if op=='i' then
        local s = loc_table[ident]
        if s then
            return LocExpand(s)
        else
            WARN('missing localization key for include: '..ident)
            return "{unknown key: "..ident.."}"
        end
    elseif op=='g' then
        local s = LocGlobals[ident]
        if iscallable(s) then
            s = s()
        end
        if s then
            return s
        else
            WARN('missing localization global: '..ident)
            return "{unknown global: "..ident.."}"
        end
    else
        WARN('unknown localization directive: '..op..':'..ident)
        return "{invalid directive: "..op.." "..ident.."}"
    end
end


-- Given some text from the loc DB, recursively apply formatting directives
function LocExpand(s)
    -- Look for braces {} in text
    return (string.gsub(s, "{(%w+) ([^{}]*)}", LocSubFn))
end


-- If s is a string with a localization tag, like "<LOC HW1234>Hello World",
-- return a localized version of it.
--
-- Note - we use [[foo]] string syntax here instead of "foo", so the localizing
-- script won't try to mess with *our* strings.
function LOC(s)
    if s == nil then
        return s
    end

    if string.sub(s,1,5) != [[<LOC ]] then
        -- This string doesn't have a <LOC key> tag
        return LocExpand(s)
    end

    local i = string.find(s,">")
    if not i then
        -- Missing the second half of <LOC> tag
        WARN(_TRACEBACK('String has malformed loc tag: ',s))
        return s
    end

    local key = string.sub(s,6,i-1)

    local r = loc_table[key]
    if not r then
        r = string.sub(s,i+1)
        if r=="" then
            r = key
        end
    end
    r = LocExpand(r)
    return r
end


-- Like string.format, but applies LOC() to all string args first.
function LOCF(...)
    for k,v in arg do
        if type(v)=='string' then
            arg[k] = LOC(v)
        end
    end
    return string.format(unpack(arg))
end


-- Call LOC() on all elements of a table
function LOC_ALL(t)
    r = {}
    for k,v in t do
        r[k] = LOC(v)
    end
    return r
end


-- Change the current language
function language(la)
    loadLanguage(la)
    SetPreference('options_overrides.language', __language)
end


loadLanguage(__language)
