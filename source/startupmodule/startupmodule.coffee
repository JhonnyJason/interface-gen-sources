##############################################################################
#region debug
import {createLogFunctions} from "thingy-debug"
{log, olog} = createLogFunctions("startupmodule")

#endregion

##############################################################################
#region modulesFrom Environment
import chalk from 'chalk'

##############################################################################
import * as mp from "./mainprocessmodule.js"
import * as ca from "./cliargumentsmodule.js"

#endregion

##############################################################################
printSuccess = (arg) -> console.log(chalk.green(arg))
printError = (arg) -> console.log(chalk.red(arg))

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
        e = ca.extractArguments()
        await mp.execute(e)
        printSuccess('All done!');
    catch err
        printError("Error!")
        printError(err)
        if err.stack then printError(err.stack)
        process.exit(-1)
