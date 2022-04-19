import Modules from "./allmodules.js"

global.allModules = Modules

############################################################
run = ->
    promises = (m.initialize() for n,m of Modules when m.initialize?) 
    await Promise.all(promises)
    Modules.startupmodule.cliStartup()

############################################################
run()