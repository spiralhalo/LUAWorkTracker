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
  return os.date("%a, %d %b %Y", time)
end

function Util.hourstring(dtime)
  hr = math.floor(dtime/3600)
  min = math.floor((dtime-hr*3600)/60)
  sec = dtime-hr*3600-min*60
  result = {}
  if hr > 0 then
    table.insert(result, hr)
    if hr > 1 then
      table.insert(result, " hours ")
    else
      table.insert(result, " hour ")
    end
  end
  if min > 0 then
    table.insert(result, min)
    if min > 1 then
      table.insert(result, " minutes ")
    else
      table.insert(result, " minute ")
    end
  end
  table.insert(result, sec)
  if sec > 1 then
    table.insert(result, " seconds")
  else
    table.insert(result, " second")
  end
  return table.concat(result)
end

return Util
