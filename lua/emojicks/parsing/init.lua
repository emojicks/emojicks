--imports--
local ut = require"emojicks.util"
local _lpeg = require"lpeg"
local re_compile = require"re".compile
local setmetatable = setmetatable
local getmetatable = getmetatable
local byte = string.byte
local utf8_char = utf8.char
local upper = string.upper
local type = type
local rawset = rawset
local tostring = tostring
local P, V = _lpeg.P, _lpeg.V
local mt = {__index = _lpeg}
local print = print
--start-module--
local _ENV = setmetatable(_lpeg.locale(), mt)

local lpeg_mt = getmetatable(space)

---creates a pattern which is exactly `n` repetitions of `p`.
function exactly(n, p) 
    local patt = P(p)
    local out = patt
    for i = 1, n-1 do 
        out = out * patt
    end
    return out
end

---the following should be obvious by their name
function sepby(s, p) p = P(p) return p * (s * p)^0 end
function endby(s, p) p = P(p) return (p * s)^1 end
function between(b, s) s = P(s) return  b * ((s * b)^1) end
function anywhere (p)
    return P { p + 1 * V(1) }
end

--- equivalent <expr>-<cont> in regex 
function lazy(expr, cont)
    return P{cont + expr * V(1)}
end

function lpeg_mt:__band(n, p)
    if type(p) == 'number' then 
        n, p = p, n 
    end
    return exactly(n, p)
end

function callable(p)
    return function(...)
        return p:match(...)
    end 
end

local token_mt = {}
local function adjust_token(t) 
    return setmetatable(t, token_mt)
end

token_mt.__name = "token" 

local function tstring(s) 
    if type(s) == 'string' then return ("%q"):format(s)
    else return tostring(s)
    end
end 
function token_mt:__tostring()
    return ("[Tok:%s %s]"):format(self.tag:gsub("^.", upper,1), tstring(self[1]))
end

function token(tag, p)
    return Ct(Cg(Cc(tag), "tag") * p)/adjust_token
end

---- defs ----

--- constant defs
newline = "\n"
tab = "\t"
carriagereturn = "\r"

--- utf8 

-- decode a two-byte UTF-8 sequence
local function f2 (s)
    local c1, c2 = byte(s, 1, 2)
    return c1 * 64 + c2 - 12416
end

-- decode a three-byte UTF-8 sequence
local function f3 (s)
    local c1, c2, c3 = byte(s, 1, 3)
    return (c1 * 64 + c2) * 64 + c3 - 925824
end

-- decode a four-byte UTF-8 sequence
local function f4 (s)
    local c1, c2, c3, c4 = byte(s, 1, 4)
    return ((c1 * 64 + c2) * 64 + c3) * 64 + c4 - 63447168
end

local cont = R("\128\191")   -- continuation byte

local utf_patt = R("\0\127") /  byte
    + R("\194\223") * cont / f2
    + R("\224\239") * cont * cont / f3
    + R("\240\244") * cont * cont * cont / f4

unicode = utf_patt / utf8_char


--- compile re parsers

function compile(body)
    local defs = ut.locals(2)._ENV or _ENV
    return re_compile(body, defs)
end 

local parser_mt = {}
parser_mt.__index = _ENV
function new(name)
    return setmetatable({tag = name}, parser_mt)
end

function parser_mt:__newindex(key, value)
    if key == "parse" then 
        return rawset(self, key, token(self.tag, value))
    else 
        return rawset(self, key, value)
    end
end

function rule(r) return setmetatable({}, {__index = function(t, R) 
    local v = r(R)
    t[R] = v 
    return v 
end}) end

--end-module--
return _ENV