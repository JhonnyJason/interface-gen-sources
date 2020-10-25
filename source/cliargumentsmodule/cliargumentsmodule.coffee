cliargumentsmodule = {name: "cliargumentsmodule"}

#region node_modules
meow = require("meow")
#endregion

#region logPrintFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["cliargumentsmodule"]?  then console.log "[cliargumentsmodule]: " + arg
    return
#endregion
##############################################################
cliargumentsmodule.initialize = () ->
    log "cliargumentsmodule.initialize"
    return

#region internal functions
getHelpText = ->
    log "getHelpText"
    return """
        Usage
            $ 
    
        Options
            optional:
                
        Examples
            $  -c
            ...
    """

getOptions = ->
    log "getOptions"
    return {
        flags:
            option: #optionsname
                type: "boolean" # or string
                alias: "o"
    }

extractMeowed = (meowed) ->
    log "extractMeowed"

    option = false
    if meowed.flags.option then option = true

    return {option}

#endregion

#region exposed functions
cliargumentsmodule.extractArguments = ->
    log "cliargumentsmodule.extractArguments"
    options = getOptions()
    meowed = meow(getHelpText(), getOptions())
    extract = extractMeowed(meowed)
    return extract

#endregion exposed functions

module.exports = cliargumentsmodule