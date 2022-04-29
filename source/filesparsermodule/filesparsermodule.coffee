############################################################
#region debug
import { createLogFunctions, debugOn } from "thingy-debug"
{log, olog} = createLogFunctions("filesparsermodule")
#endregion

############################################################
import { DocumentationFileParser } from "./documentationparser.js"

############################################################
export initialize = ->
    log "initialize"
    debugOn("documentationparser")
    #Implement or Remove :-)
    return

############################################################
export parseAllFiles = ->
    log "parseAllFiles"
    
    documentationParser = new DocumentationFileParser()
    if documentationParser.fileExists then documentationParser.parse()
    else log "No documentation file found!"

    

    return