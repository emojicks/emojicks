--imports--
local parsing = require"emojicks.parsing"
--start-module--
local _ENV = parsing.new "atom"

parse = parsing.compile 
[[
    atom   <- {(%a / symbol) (%w / symbol)*} 
    symbol <- [!#$%&|*+-/:<=>?@^_~]
]]

--end-module--
return _ENV