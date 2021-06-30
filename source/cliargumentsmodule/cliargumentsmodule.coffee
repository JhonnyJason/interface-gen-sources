cliargumentsmodule = {name: "cliargumentsmodule"}
#region logPrintFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["cliargumentsmodule"]?  then console.log "[cliargumentsmodule]: " + arg
    return
#endregion

##############################################################
#region node_modules
meow = require("meow")
#endregion

##############################################################
cliargumentsmodule.initialize = () ->
    log "cliargumentsmodule.initialize"
    return

##############################################################
#region internal functions
getHelpText = ->
    log "getHelpText"
    return """
        Usage
            $ interface-gen <arg1>
    
        Options
            required:
                arg1, --source <path/to/source>, -s <path/to/source>
                
        Examples
            $  interface-gen definition.md
            ...
    """

getOptions = ->
    log "getOptions"
    return {
        flags:
            source: 
                type: "string" # or string
                alias: "s"
    }

extractMeowed = (meowed) ->
    log "extractMeowed"
    source = ""
    if meowed.input[0] then source = meowed.input[0]
    if meowed.flags.source then source = meowed.flags.source
    return {source}

throwErrorOnUsageFail = (extract) ->
    log "throwErrorOnUsageFail"
    if !extract.source then throw new Error("Usag error: no source has been defined!")
    if !(typeof extract.source == "string") then throw new Error("Usage error: defined source is not a string!")    
    return
#endregion

##############################################################
#region exposed functions
cliargumentsmodule.extractArguments = ->
    log "cliargumentsmodule.extractArguments"
    meowed = meow(getHelpText(), getOptions())
    extract = extractMeowed(meowed)
    throwErrorOnUsageFail(extract)
    return extract

#endregion exposed functions

module.exports = cliargumentsmodule