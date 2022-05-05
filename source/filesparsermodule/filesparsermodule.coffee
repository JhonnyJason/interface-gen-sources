############################################################
#region debug
import { createLogFunctions, debugOn } from "thingy-debug"
{log, olog} = createLogFunctions("filesparsermodule")
#endregion

############################################################
import { DocumentationFileParser } from "./documentationparser.js"
import { InterfaceFileParser } from "./interfaceparser.js"

############################################################
export initialize = ->
    log "initialize"

    # debugOn("documentationparser")
    debugOn("interfaceparser")

    return

############################################################
export parseAllFiles = ->
    log "parseAllFiles"
    
    documentationParser = new DocumentationFileParser()
    if documentationParser.fileExists then documentationParser.parse()
    else log "No documentation file found!"

    interfaceParser  = new InterfaceFileParser()
    if interfaceParser.fileExists then interfaceParser.parse()
    else log "No interface file found!"

    return