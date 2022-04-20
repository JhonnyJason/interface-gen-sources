##############################################################################
#region debug
import {createLogFunctions} from "thingy-debug"
{log, olog} = createLogFunctions("mainprocessmodule")

#endregion


############################################################
#region imports
import * as p from "./pathmodule.js"
import * as df from "./definitionfilemodule.js"
import * as ni from "./networkinterfacemodule.js"
import * as sf from "./scifilesmodule.js"
import * as tf from "./testingfilesmodule.js"
#endregion

############################################################
export execute = (e) ->
    log "execute"

    df.digestFile(e.source)

    interfaceObject = df.interfaceObject
    if e.name? then name = e.name
    else name = p.basename
    
    ni.writeFile(interfaceObject, name)
    sf.writeFiles(interfaceObject, name)
    tf.writeFiles(interfaceObject, name)
    return

