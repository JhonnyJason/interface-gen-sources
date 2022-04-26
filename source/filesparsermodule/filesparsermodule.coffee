############################################################
#region debug
import { createLogFunctions, debugOn } from "thingy-debug"
{log, olog} = createLogFunctions("filesparsermodule")
#endregion

############################################################
import { DocumentationFile } from "./documentationparser.js"

############################################################
export initialize = ->
    log "initialize"
    debugOn("documentationparser")
    #Implement or Remove :-)
    return

############################################################
export parseAllFiles = ->
    log "parseAllFiles"
    
    documentation = new DocumentationFile()
    if documentation.exists then documentation.parse()
    else log "No documentation file found!"

    

    return