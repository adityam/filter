thirddata                = thirddata				or {}
thirddata.externalfilter = thirddata.externalfilter or {}

local externalfilter = thirddata.externalfilter

local trace_externalfilter = false
trackers.register("thirddata.externalfilter", function(v) trace_externalfilter = v end)

local report_externalfilter = logs.new("thirddata.externalfilter") 


local newline      = lpeg.P("\n\r") + lpeg.P("\r\n") + lpeg.P("\n") + lpeg.P("\r")
local splitter     = lpeg.Ct(lpeg.splitat(newline))
local space        = lpeg.P(" ")
local any          = lpeg.Cs(1)
local spaceparser  = space^0 * lpeg.C(any^0)

function externalfilter.httpget(filter, name, separator)
  local content    = buffers.getcontent(name)
  local lines      = lpeg.match(splitter, content)
  for i=1,#lines do
	lines[i] = lpeg.match(spaceparser, lines[i])
  end

  content = table.concat(lines, separator)

  local url        = filter .. content

  if trace_externalfilter then
	report_externalfilter("downloading url %s", url)
  end
  
  local specification = resolvers.splitmethod(url) 

  local file       = resolvers.finders['http'](specification) or ""

  if trace_externalfilter then
	if file and file ~= "" then
	  report_externalfilter("saving file %s", file)
	else
	  report_externalfilter("download failed")
	end
  end

  return tex.sprint(tex.ctxcatcodes,file)
end

