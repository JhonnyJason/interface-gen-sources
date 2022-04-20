##############################################################################
#region debug
import {createLogFunctions} from "thingy-debug"
{log, olog} = createLogFunctions("pathmodule")

#endregion

############################################################
import path from "path"

############################################################
obj = {}
obj.absolutePath = ""
obj.dirname = ""
obj.filename = ""
obj.basename = ""


############################################################
export digestPath = (source) ->
    log "digestPath"
    log source

    obj.absolutePath = path.resolve(source) 
    obj.dirname = path.dirname(obj.absolutePath)
    obj.filename = path.basename(obj.absolutePath)
    obj.basename = obj.filename.split(".")[0]

    olog obj

    return

export getFilePath = (name) ->
    return path.resolve(obj.dirname, name)

############################################################
export default obj