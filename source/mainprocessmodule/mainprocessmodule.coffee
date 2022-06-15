##############################################################################
#region debug
import {createLogFunctions} from "thingy-debug"
{log, olog} = createLogFunctions("mainprocessmodule")

#endregion


############################################################
#region imports
import * as ph from "./pathhandlermodule.js"
import * as fp from "./filesparsermodule.js"
import * as ss from "./structuresyncmodule.js"

#endregion

############################################################
export execute = (e) ->
    log "execute"
    olog e
    
    global.interfaceName = e.name+"interface"
    ph.createValidPaths(e.root, e.name)
    fp.parseAllFiles()

    ss.syncStructures(e.mode)

    throw new Error("Death on Purpose!")

    ##TODO write files

    # interfaceObject = df.interfaceObject
    # if e.name? then name = e.name
    # else name = p.basename
    
    # ni.writeFile(interfaceObject, name)
    # sf.writeFiles(interfaceObject, name)
    # tf.writeFiles(interfaceObject, name)
    return

