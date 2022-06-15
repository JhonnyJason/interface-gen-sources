############################################################
#region debug
import { createLogFunctions, debugOn } from "thingy-debug"
{log, olog} = createLogFunctions("filesparsermodule")
#endregion

############################################################
import { DocumentationFileParser } from "./documentationparser.js"
import { InterfaceFileParser } from "./interfaceparser.js"
import { HandlersFileParser } from "./handlersparser.js"

############################################################
documentationParser = null
interfaceParser = null
handlersParser = null

############################################################
export initialize = ->
    log "initialize"

    # debugOn("documentationparser")
    # debugOn("interfaceparser")
    # debugOn("handlersparser")

    return

############################################################
export parseAllFiles = ->
    log "parseAllFiles"
    
    documentationParser = new DocumentationFileParser()
    if documentationParser.fileExists then documentationParser.parse()
    else log "No documentation file found!"

    interfaceParser = new InterfaceFileParser()
    if interfaceParser.fileExists then interfaceParser.parse()
    else log "No interface file found!"

    handlersParser = new HandlersFileParser()
    if handlersParser.fileExists then handlersParser.parse()
    else log "No handlers file found!"

    return

############################################################
export getParsedDocumentation = -> 
    return documentationParser if documentationParser.parsed
    return null

export getParsedInterface = -> 
    return interfaceParser if interfaceParser.parsed
    return null

export getParsedHandlers = ->  
    return handlersParser if handlersParser.parsed
    return null
