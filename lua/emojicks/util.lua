--imports--
local getlocal = debug.getlocal
--start-module--
local _ENV = {}
function locals(at)
    local out = {}
    local count = 1
    while true do 
        local next, val = getlocal(at + 1, count)
        if next ~= nil and next:sub(1,1) ~= "(" then 
            count = count + 1
            out[next] = val
        elseif next == nil or next:sub(1,1) == "(" then
            return out
        end
    end
end
--end-module--
return _ENV