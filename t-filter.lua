thirddata                = thirddata				or {}
thirddata.externalfilter = thirddata.externalfilter or {}

local externalfilter = thirddata.externalfilter

local trace_externalfilter = false
trackers.register("thirddata.externalfilter", function(v) trace_externalfilter = v end)

local report_externalfilter = logs.new("thirddata.externalfilter") 


-- based on a post by Hans
-- http://www.mail-archive.com/ntg-context@ntg.nl/msg39598.html

externalfilter.mt = { __index = function (t,k) t[k] = k; return k; end } 

--~ externalfilter.urireplace = { 
--~   ["!"] = "%21" , ["*"] = "%2A" , ["'"] = "%27" , ["("] = "%28" , [")"] = "%29" ,
--~   [";"] = "%3B" , [":"] = "%3A" , ["@"] = "%40" , ["&"] = "%26" , ["="] = "%3D" ,
--~   ["+"] = "%2B" , ["$"] = "%24" , [","] = "%2C" , ["/"] = "%2F" , ["?"] = "%3F" ,
--~   ["#"] = "%23" , ["["] = "%5B" , ["]"] = "%5D" , [" "] = "%20" , ["%"] = "%25" ,
--~ }

local newline      = lpeg.P("\n\r") + lpeg.P("\r\n") + lpeg.P("\n") + lpeg.P("\r")
local splitter     = lpeg.Ct(lpeg.splitat(newline))
local space        = lpeg.P(" ")
local any          = lpeg.Cs(1)
local spaceparser  = space^0 * lpeg.C(any^0)

function externalfilter.httpget(filter, name, separator)
  local content    = buffers.content(name)
  local lines      = lpeg.match(splitter, content)
  --~ setmetatable(extras, externalfilter.mt)
  --~ local substitute = any / extras
  --~ local parser     = lpeg.Cs((substitute)^0)

  for i=1,#lines do
	lines[i] = lpeg.match(spaceparser, lines[i])
	--~ lines[i] = lpeg.match(parser, lines[i])
  end

  content = table.concat(lines, separator)

  local url        = filter .. content

  if trace_externalfilter then
	report_externalfilter("downloading url %s", url)
  end

  local file       = resolvers.finders['http'](url) or ""

  if trace_externalfilter then
	if file and file ~= "" then
	  report_externalfilter("saving file %s", file)
	else
	  report_externalfilter("download failed")
	end
  end

  return tex.sprint(tex.ctxcatcodes,file)
end

