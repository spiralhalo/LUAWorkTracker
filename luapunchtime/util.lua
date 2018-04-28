local Util = {}

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
  return os.date("%a, %d %b %Y %X", time)
end

function Util.hourstring(dtime)
  hr = math.floor(dtime/3600)
  min = math.floor((dtime-hr*3600)/60)
  sec = dtime-hr*3600-min*60
  result = {}
  if hr > 0 then
    table.insert(result, hr)
    table.insert(result, " h ")
  end
  if min > 0 then
    table.insert(result, min)
    table.insert(result, " m ")
  end
  table.insert(result, sec)
  table.insert(result, " s")
  return table.concat(result)
end

return Util
