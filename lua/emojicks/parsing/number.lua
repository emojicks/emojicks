--imports--
local parsing = require"emojicks.parsing"
local ipairs = ipairs
local setmetatable = setmetatable
--start-module--
local _ENV = parsing.new 'number'

local bases = {2, 8, 16, 10}
local sign = S'+-'^-1
local exponent_marker = S'eE' 

local Ndigit = {
     [2] = S'01'
    ,[8] = R'07'
    ,[10] = digit
    ,[16] = xdigit 
}

local Nradix = {
     [2]  = P'0b'
    ,[8]  = P'0o'
    ,[10] = P'0d'^-1 
    ,[16] = P'0x'
}

local suffix = (exponent_marker * sign * Ndigit[10]^1)

local Nprefix = rule(function(R) return Cc(R) * Nradix[R] end)

local Nnumeral = rule(function(R) return Ndigit[R]^1 end)

local Npreamble = rule(function(R) return C(sign) * Nprefix[R] end)

local NInteger = rule(function(R) 
    return Cc'integer' * Npreamble[R] * C(Nnumeral[R])
end)

local NDecimal = rule(function(R) return S'' end)
NDecimal[10] =
     Cc'decimal'
    *Npreamble[10]
    *C(
        (Ndigit[10]^1 * "." * Ndigit[10]^0  +  P"." * Ndigit[10]^1) * suffix^-1
    +   Nnumeral[10] * suffix
     )

NRational = rule(function(R) 
    return 
     Cc'rational'
    *Npreamble[R]
    *Ct(
        C(Nnumeral[R])
    *   '/'
    *   (Nradix[R]^-1) * C(Nnumeral[R])
    )
end)

local Number = rule(function(R) 
    return NDecimal[R] + NRational[R] + NInteger[R]
end)

local number_mt = {}
local function adjust_number(ct)
    return setmetatable(ct, number_mt)
end

function number_mt:__tostring()
    if self[1] == 'decimal' then 
        return ("[Decimal %s%s%s]"):format(self[2], self[4], self[5] or '')
    elseif self[1] == "integer" then 
        return ("[base-%s Integer %s%s]"):format(self[3], self[2], self[4])
    elseif self[1] == "rational" then 
        return ("base-%s Rational %s(%s/%s)"):format(self[3], self[2], self[4][1], self[4][2])
    end
end

local numbers 
for _, base in ipairs(bases) do 
    if numbers then 
        numbers = numbers + Ct(Number[base])/adjust_number
    else numbers = Ct(Number[base])/adjust_number
    end
end

parse = numbers

--end-module--
return _ENV