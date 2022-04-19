##############################################################################
#region logPrintFunctions
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
#region modulesFrom Environment
import chalk from 'chalk'

##############################################################################
#region localModules
mainProcess = null
cfg = null 
cliArguments = null
#endregion
#endregion

##############################################################################
export initialize = () ->
    log "startupmodule.initialize"
    mainProcess = allModules.mainprocessmodule
    cfg = allModules.configmodule
    cliArguments = allModules.cliargumentsmodule
    return

##############################################################################
export cliStartup = ->
    log "cliStartup"
    try
        e = cliArguments.extractArguments()
        await mainProcess.execute(e)
        printSuccess('All done!');
    catch err
        printError("Error!")
        printError(err)
        if err.stack then printError(err.stack)
        process.exit(-1)
