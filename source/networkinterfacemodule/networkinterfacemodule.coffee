############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["networkinterfacemodule"]?  then console.log "[networkinterfacemodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
import fs from "fs"
import * as M from "mustache"

############################################################
p = null

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
export initialize = ->
    log "initialize"
    p = allModules.pathmodule
    return
    
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