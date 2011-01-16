thirddata           = thirddata           or {}
thirddata.webfilter = thirddata.webfilter or {}

local webfilter = thirddata.webfilter

local http  = require("socket.http")
local ltn12 = require("ltn12")
local url   = require("socket.url")

local trace_webfilter = false
trackers.register("thirddata.webfilter", function(v) trace_webfilter = v end)
local report_webfilter = logs.new("thirddata.webfilter") 

local elements  = interfaces.complete.elements
local interface = storage.shared.currentinterface

local e_start = elements.start[interface]
local e_stop  = elements.stop [interface]

local match = string.match
local gsub  = string.gsub

local tinsert = table.insert
local tconcat = table.concat

function webfilter.definewebfilter(name)
  local start_command ="\\bgroup\\obeylines\\dodoubleargument\\dostartwebfilter[" .. name .. "]" 
  local stop_command  ="\\doprocesswebfilter"
  if trace_webfilter then
    report_webfilter("defining web filter", name)
  end
  context.setvalue(e_start .. name, start_command)
  context.setvalue(e_stop  .. name, stop_command)
end

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
local function default(name)
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
  content = tconcat(result,",")
  return content
end

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
thirddata.webfilter.transform['websequence'] = websequence

