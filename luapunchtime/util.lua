local xxh32 = require("xxhash")
local bit = require "bit"
local band, shr = bit.band, bit.rshift

local Util = {}

function Util.clamp(x, min, max)
  if x < min then return min
  elseif x > max then return max
  else return x end
end

function Util.strSplit(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={} ; i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end

function Util.dateString(time)
  return os.date("%a %d%b%y %H:%M", time)
end

function Util.hourstring(dtime)
  hr = math.floor(dtime/3600)
  min = math.floor((dtime-hr*3600)/60)
  sec = dtime-hr*3600-min*60
  result = {}
  if hr > 0 then
    result[1] = hr
    result[2] = "h"
  end
  if min > 0 then
    table.insert(result, min)
    table.insert(result, "m ")
  end
  table.insert(result, sec)
  table.insert(result, "s")
  return table.concat(result)
end

function Util._colorHash(str)
  color = xxh32(str)
  return band(shr(color,16), 0xFF)/255, band(shr(color,8), 0xFF)/255, band(color, 0xFF)/255
end

function Util.colorHash(str)
  local mag = 4
  local split = Util.strSplit(str, ':')
  if #split > 1 then
    str = split[2]
    local r,g,b=Util._colorHash(split[1])
    g = g/2
    target_h = Util.rgbToHsl(r,g,b)
  end
  local r,g,b=Util._colorHash(str)
  local h,s,l=Util.rgbToHsl(r,g,b)
  if target_h ~= nil then
    local round_h = target_h - 1
    if math.abs(target_h - h) < math.abs(round_h - h) then
      h = target_h+(h-target_h)/mag
    else
      h = round_h+(h-round_h)/mag
      while h < 0 do
        h = h + 1
      end
    end
  end
  s = 0.6+s*0.2
  l = 0.1+l*0.2
  r,g,b=Util.hslToRgb(h,s,l)
  return {r,g,b,1}
end

function Util.rgbToHsl(r, g, b, a)
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, l
  l = (max + min) / 2
  if max == min then
    h, s = 0, 0
  else
    local d = max - min
    if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
    if max == r then
      h = (g - b) / d
      if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end
  return h, s, l, a or 1
end

function Util.hue2rgb(p, q, t)
  if t < 0   then t = t + 1 end
  if t > 1   then t = t - 1 end
  if t < 1/6 then return p + (q - p) * 6 * t end
  if t < 1/2 then return q end
  if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
  return p
end

function Util.hslToRgb(h, s, l, a)
  local r, g, b, q
  if s == 0 then
    r, g, b = l, l, l
  else
    if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
    local p = 2 * l - q
    r = Util.hue2rgb(p, q, h + 1/3)
    g = Util.hue2rgb(p, q, h)
    b = Util.hue2rgb(p, q, h - 1/3)
  end
  return r, g, b, a
end

return Util
