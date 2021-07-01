networkinterfacemodule = {name: "networkinterfacemodule"}
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
fs = require("fs")
M = require("mustache")

############################################################
p = null

############################################################
template = """
{{name}} = {}

############################################################
{{#routes}}
{{name}}.{{route}} = ({{args}}) ->
    requestObject = { {{args}} }
    interfaceServers = allModules.configmodule.interfaceServers
    requestURL = interfaceServers["{{name}}"]+"/{{route}}"
    return @postData(requestURL, requestObject)

{{/routes}}
#endregion

    
module.exports = {{name}}
"""

############################################################
networkinterfacemodule.initialize = ->
    log "networkinterfacemodule.initialize"
    p = allModules.pathmodule
    return
    
############################################################
getInterfaceName = (name) ->
    name = name.toLowerCase()
    if name.indexOf("interface") < 0 then name = name+"interface"
    return name

############################################################
#region exposedFunctions
networkinterfacemodule.writeFile = (interfaceObject, name) ->
    log "networkinterfacemodule.writeFile"
    name = getInterfaceName(name)
    interfaceObject.name = name

    interfaceFile = M.render(template, interfaceObject)
    
    filePath = p.getFilePath(name+".coffee")
    fs.writeFileSync(filePath, interfaceFile)
    return

#endregion

module.exports = networkinterfacemodule