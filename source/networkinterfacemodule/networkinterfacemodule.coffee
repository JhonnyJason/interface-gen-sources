##############################################################################
#region debug
import {createLogFunctions} from "thingy-debug"
{log, olog} = createLogFunctions("networkinterfacemodule")

#endregion

############################################################
#region imports
import fs from "fs"
import M from "mustache"

############################################################
import *  as p from "./pathmodule.js"

#endregion

############################################################
#region templates
template = """
import { postData } from "thingy-network-base"

############################################################
#region routes
{{#routes}}
export {{route}} = (sciURL, {{args}}) ->
    requestObject = { {{args}} }
    requestURL = sciURL+"/{{route}}"
    return postData(requestURL, requestObject)

{{/routes}}
#endregion
"""
#endregion

############################################################
getInterfaceName = (name) ->
    name = name.toLowerCase()
    if name.indexOf("interface") < 0 then name = name+"interface"
    return name

############################################################
export writeFile = (interfaceObject, name) ->
    log "writeFile"
    name = getInterfaceName(name)
    interfaceObject.name = name

    interfaceFile = M.render(template, interfaceObject)
    
    filePath = p.getFilePath(name+".coffee")
    fs.writeFileSync(filePath, interfaceFile)
    return