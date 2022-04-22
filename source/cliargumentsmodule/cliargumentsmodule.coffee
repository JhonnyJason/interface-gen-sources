##############################################################################
#region debug
import {createLogFunctions} from "thingy-debug"
{log, olog} = createLogFunctions("cliargumentsmodule")

#endregion

##############################################################
import meow from 'meow'

##############################################################
#region internal functions
getHelpText = ->
    log "getHelpText"
    return """
        Usage
            $ interface-gen <arg1> <arg2> <arg3>
    
        Options
            required:
                arg1, --name <interface-name>, -n <interface-name>
                    specific interface name to be used for the generated files
                    
            optional:
                arg2, --root <path-to-root-dir>, -r <path-to-root-dir>
                    specific root directory where all the files would be found
                    defaults to the current working directory

                arg3, --mode <operation-mode>, -m <operation-mode>
                    mode how the interface could be generated
                    defaults to "union"

        Examples
            $  interface-gen sample ../sample-interface-dir intersect-ignore
            ...
    """

getOptions = ->
    log "getOptions"
    return {
        importMeta: import.meta,
        flags:
            name:
                type: "string"
                alias: "n"
            root:
                type: "string"
                alias: "r"
            mode:
                type: "string"
                alias: "m"
    }

##############################################################
extractMeowed = (meowed) ->
    log "extractMeowed"
    name = ""
    mode = "union"
    root = process.cwd()

    if meowed.input[0] then name = meowed.input[0]
    if meowed.input[1] then root = meowed.input[1]
    if meowed.input[2] then mode = meowed.input[2]

    if meowed.flags.name then name = meowed.flags.name
    if meowed.flags.root then root = meowed.flags.root
    if meowed.flags.mode then mode = meowed.flags.mode

    aliasMap = 
        "u": "union"
        "ii": "intersect-ignore"
        "ic": "intersect-cut"

    if aliasMap[mode]? then mode = aliasMap[mode] 

    return {name, root, mode}

throwErrorOnUsageFail = (extract) ->
    log "throwErrorOnUsageFail"
    if !extract.name then throw new Error("Usage error: Interface name is not specified!")

    legalModes = 
        "union": true
        "intersect-ignore": true
        "intersect-cut": true

    if !legalModes[extract.mode] then throw new Error("Usag error: Invalid mode specified!")
    return
#endregion

##############################################################
export extractArguments = ->
    log "extractArguments"
    meowed = meow(getHelpText(), getOptions())
    extract = extractMeowed(meowed)
    throwErrorOnUsageFail(extract)
    return extract

