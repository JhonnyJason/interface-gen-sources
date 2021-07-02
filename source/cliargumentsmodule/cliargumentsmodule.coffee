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
            $ interface-gen <arg1> <arg2>
    
        Options
            required:
                arg1, --source <path/to/source>, -s <path/to/source>
                    source of the interface definition in md

            optional:
                arg2, --name <interface-name>, -n <interface-name>
                    specific interface name to be used for the generated files
                    defaults to filename of the source.

        Examples
            $  interface-gen definition.md sampleinterface
            ...
    """

getOptions = ->
    log "getOptions"
    return {
        flags:
            source:
                type: "string" # or string
                alias: "s"
            name:
                type: "string"
                alias: "n"
    }

extractMeowed = (meowed) ->
    log "extractMeowed"
    source = ""
    name = ""
    if meowed.input[0] then source = meowed.input[0]
    if meowed.input[1] then name = meowed.input[1]
    if meowed.flags.source then source = meowed.flags.source
    if meowed.flags.name then name = meowed.flags.name
    return {source,name}

throwErrorOnUsageFail = (extract) ->
    log "throwErrorOnUsageFail"
    if !extract.source then throw new Error("Usag error: no source has been defined!")
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