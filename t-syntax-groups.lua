-- helper methods

colorscheme = colorscheme or {} -- namespace handle
settings_to_array = utilities.parsers.settings_to_array

function scalechannel(val)
    -- converts context rgb and alpha channel values to 
    -- to css hex codeable values
    return math.min(math.round(val*255),255)
end

-- map used to translate context transparency mode numbers into corresponding
-- css mix-blend-mode strings. Most modes and strings are identical
-- some are written with hyphen inbetween. Two seem not to be supported
-- they are mapped to the closest looking mode according to figure 1.6 in [1]
-- on page 16 and preceeding table on page 15.
--
-- [1] Hagen Hans, Coloring ConTeXt explaining luatex and mkiv, PRAGMA ADE, 2016
--     online: http://www.pragma-ade.com/general/manuals/colors-mkiv.pdf
--
blendmodemap = {
     [1] = "normal","multiply","screen","overlay",
     "luminosity","normal", -- mapped to closest supported by css
     "color-doge","color-burn","darken","lighten",
     "difference","exclusion","hue","saturation",
     "color","luminosity"
}

function colorscheme.cssformatcolor(str,transparency)
	-- converts colorvalue string and transparencycomponents string
	-- into proper css RGBA hex color value and mix-blend-mode value

	-- TODO maybe replace access to colorvalue and transparency 
	--      by access to public luainterface 
	--      this has to be done by somebody with more indeep luatex mkiv
	--      and lmtx/lmtx mkiv knowledge respective than me
	local colorvals = {} -- pars colorvalue string to get all components

	-- split colorvalue string
	for channel in string.gmatch(str,"([^%s]+)") do
        table.insert(colorvals,tonumber(channel))
    end

    local alphachannel = {} -- parsed component string if not empty

    -- split transparency string 
    -- currently is formated as a=<modenumber> st=<opacity value>
    -- TODO verify that a is mode and st is opacity and not vice versa
    for value in string.gmatch(transparency,"([^%s=]+)") do
        table.insert(alphachannel,tonumber(value))
    end
    -- select blend mode if alphachannel has at least the four elements
    -- ['a','<modenumber>','st','<opacity value>']
    -- directly output css mix-blend-mode attribute string to context
    -- and convert opacity number to alpha channel hex value
    if #alphachannel >= 4 and alphachannel[1] == "a" and alphachannel[3] == "st" then
        context("mix-blend-mode: ",blendmodemap[math.floor(alphachannel[2])])
        alphavalue = string.format("%02X",scalechannel(alphachannel[4]))
    end
 
    -- assemble css color attribute value dependent upon color model used to define
    -- context color. Model can be distinguished by number of entries in colorvals array
    -- #colorvals == 4 -> CMYK
    -- #colorvals == 3 -> RGB
    -- #colorvals == 2 -> ??? TODO how has more knowledge on this context color mode
    -- #colorvals == 1 -> grey/BW
    -- #colorvals < 1  -> invalid: black
    -- #colorvals > 4  -> invalid: black
    --
    -- append alphavalue string if not empty and output resulting string to context
    context("color: ")
    context.letterhash()
    if #colorvals == 3 then
			context("%02X%02X%02X%s;",scalechannel(colorvals[1]),scalechannel(colorvals[2]),scalechannel(colorvals[3]),alphavalue)
    elseif #colorvals == 4 then
        brightness = 1-colorvals[4]
			context("%02X%02X%02X%s;",scalechannel((1-colorvals[1])*brightness),scalechannel((1-colorvals[2])*brightness),scalechannel((1-colorvals[3]) * brightness,alphavalue ))
    elseif #colorvals == 1 then
        colorvals[1] = scalechannel(colorvals[1])
        context("%02X%02X%02X%s;",colorvals[1],colorvals[1],colorvals[1],alphavalue)
    else
        context("000000%s",alphavalue)
    end
end

local reporter = logs.reporter("module","t-vim")

function verify_css_styles_path(jobname)
    local exportpath = string.format("%s-export",jobname)
    if not lfs.isdir(exportpath) then
        lfs.mkdir(exportpath)
        if not lfs.isdir(exportpath) then
             return "."
        end
	end
    local stylespath = file.join(exportpath,"styles")
    if not lfs.isdir(stylespath) then
        lfs.mkdir(stylespath)
        if not lfs.isdir(stylespath) then
             return exportpath
        end
	end
    return stylespath
end

function colorscheme.css_export_path(jobname,name)
     -- assembles proper path for storing css file for colorsceme 
     -- TODO likely could also be done in context directly but failed to make it work as expected
     context(file.join(verify_css_styles_path(jobname),jobname.."-t-syntaxgroup-".. name ..".css"))
end

function colorscheme.append_css_file(l,jobname,name)
    -- appends colorscheme css file into cssfile export parameter
    -- this is called when a new vimtyping environment is defined to ensure
    -- that the exporter consideres the appropriate cssfile for the selected
    -- colorscheme.

    -- split content of cssfile export parameter into list of individual file names
    local currentcssfiles = settings_to_array(l,false)

    -- path to css file for colorscheme denoted by name
    local cssfilepath = jobname.."-t-syntaxgroup-".. name ..".css"
    if not table.contains(currentcssfiles,cssfilepath) then
        -- insert colorschem css file into list and output resulting string to
        -- context
    	table.insert(currentcssfiles,cssfilepath)
    	l = table.concat(table.unique(currentcssfiles),", ")
	end
    context("%s",l)
end

