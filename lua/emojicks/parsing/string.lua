--imports--
local parsing = require"emojicks.parsing"
--start-module--
local _ENV = parsing.new "string"

parse = parsing.compile 
[[
    string <- '"' {~ (content*) ~}  '"'
    content <- quote / newln / tab / cr / back / (!'"' %unicode)

    quote <- '\"' -> '"'
    newln <- '\n' -> newline
    tab   <- '\t' -> tab
    cr    <- '\r' -> carriagereturn
    back  <- '\\' -> '\'
]]

--end-module--
return _ENV