
startupmodule = {name: "startupmodule"}

#region modulesFromEnvironment
#region node_modules
chalk       = require('chalk')
clear       = require('clear')
figlet      = require('figlet')
#endregion

#region localModules
mainProcess = null
cfg = null 
cliArguments = null
#endregion
#endregion

#region logPrintFunctions
##############################################################################
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["startupmodule"]?  then console.log "[startupmodule]: " + arg
    return
olog = (o) -> log "\n" + ostr(o)
ostr = (o) -> JSON.stringify(o, null, 4)
printSuccess = (arg) -> console.log(chalk.green(arg))
printError = (arg) -> console.log(chalk.red(arg))
print = (arg) -> console.log(arg)
#endregion
##############################################################################
startupmodule.initialize = () ->
    log "startupmodule.initialize"
    mainProcess = allModules.mainprocessmodule
    cfg = allModules.configmodule
    cliArguments = allModules.cliargumentsmodule
    return

#region internalFunctions
printBanner = ->
    clear()
    print(
        chalk.green(
            figlet.textSync(cfg.cli.name, { horizontalLayout: 'full' })
        )
    )
#endregion

#region exposedFunctions
startupmodule.cliStartup = ->
    log "startupmodule.cliStartup"
    printBanner()
    try
        e = cliArguments.extractArguments()
        await mainProcess.execute()
        printSuccess('All done!');
    catch err
        printError("Error!")
        printError(err)
        if err.stack then printError(err.stack)
        process.exit(-1)
#endregion exposed functions

module.exports = startupmodule

