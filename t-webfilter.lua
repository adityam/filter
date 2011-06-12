thirddata           = thirddata           or {}
thirddata.webfilter = thirddata.webfilter or {}

local webfilter = thirddata.webfilter

local http  = require("socket.http")
local ltn12 = require("ltn12")
local url   = require("socket.url")

local report_webfilter = logs.new("thirddata.webfilter") 
local trace_webfilter  = false

trackers.register("thirddata.webfilter", function(v) trace_webfilter = v end)

local match = string.match
local gsub  = string.gsub

local tinsert = table.insert
local tconcat = table.concat


function webfilter.processwebfilter(name, transform, prefix, suffix, figuresetup)
    local content = webfilter.transform[transform](name) 
    local url = prefix .. content .. suffix

    if trace_webfilter then
      report_webfilter("downloading url %s", url)
    end
    
    local specification = resolvers.splitmethod(url) 

    local file       = resolvers.finders['http'](specification) or ""

    if trace_webfilter then
      if file and file ~= "" then
        report_webfilter("saving file %s", file)
      else
        report_webfilter("download failed")
      end
    end

    context.externalfigure({file}, {figuresetup})
end

-- Useful data transformation

thirddata.webfilter.transform = {}

-- The default transformation:
-- Dedent the buffer and remove empty lines
local function default(name, separator)

  if trace_webfilter then
    report_webfilter("joining %s buffer with separator %s", name, separator or "no")
  end

  local content  = buffers.getcontent(name)
  local lines    = string.splitlines(content)
  local indent   = match(lines[1], '^ +') or ''
  local result   = {}
  local pattern  = '^' .. indent
  for i=1,#lines do
    lines[i] = gsub(lines[i],pattern,"")
    -- remove empty lines
    if gsub(lines[i], '^%s*$', '') ~= "" then
      tinsert(result,lines[i])
    end
  end
  content = tconcat(result,separator or ",")
  return content
end

local ampersand = function(s) return default(s, "&") end

-- Transform for http://www.websequence.com

local function websequence (name)
  local content   = buffers.getcontent(name)
  local style    = "modern-blue" -- TODO: make configurable
  local body     = "style=" .. style .. "&message=" .. url.escape(content)
  local response = {}
  local status, message = http.request {
    method = 'POST',
    url    = "http://www.websequencediagrams.com",
    source = ltn12.source.string(body),
    sink   = ltn12.sink.table(response),
    headers = {
      ["Content-Length"] = string.len(body),
    },
  }

  local quot  = lpeg.P('"') 
  local other = 1 - quot

  local img = other^0 * quot * lpeg.Cs(other^0) * quot * other 

  local location = lpeg.match(img,response[1])
  return location
end


thirddata.webfilter.transform['default']     = default
thirddata.webfilter.transform['ampersand']   = ampersand
thirddata.webfilter.transform['websequence'] = websequence

