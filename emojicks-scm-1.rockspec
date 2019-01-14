package = "emojicks"
version = "scm-1"

source  = {
    url = 'git://github.com/emojicks/emojicks.git'
}

description = {
    summary = ''
   ,homepage = 'https://github.com/emojicks/emojicks'
   ,license = 'MIT'
   ,maintainer = ''
   ,detailed = ""
}

dependencies = {
     'lua >= 5.3'
    ,'lpeg >= 0.10, ~= 0.11'
}


build = {
    type = "builtin"
   ,modules = {}
}