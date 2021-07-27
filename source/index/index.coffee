Modules = require("./allmodules")

global.allModules = Modules

console.log(JSON.stringify(Modules))

run = ->
    promises = (m.initialize() for n,m of Modules)
    await Promise.all(promises) 
    Modules.startupmodule.cliStartup()
    return

run()