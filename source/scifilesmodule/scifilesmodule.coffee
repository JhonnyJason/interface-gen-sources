scifilesmodule = {name: "scifilesmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["scifilesmodule"]?  then console.log "[scifilesmodule]: " + arg
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

routesTemplate ="""
{{#routes}}
############################################################
sciroutes.{{route}} = (req, res) ->
    try
        response = await h.{{route}}({{argsBlock}})
        res.send(response)
    catch err then res.send({error: err.stack})
    return

{{/routes}}
"""

handlersTemplate ="""
{{#routes}}
############################################################
scihandlers.{{route}} = ({{args}}) ->
    result = {}
    ###
    {{response}}
    ###
    return result


{{/routes}}
"""


############################################################
scifilesmodule.initialize = ->
    log "scifilesmodule.initialize"
    p = allModules.pathmodule
    return
    

############################################################
getRoutesName = (name) ->
    name = name.toLowerCase()
    if name.indexOf("routes") < 0 then name = name+"routes"
    return name

getHandlersName = (name) ->
    name = name.toLowerCase()
    if name.indexOf("handlers") < 0 then name = name+"handlers"
    return name


############################################################
scifilesmodule.writeFiles = (interfaceObject, name) ->
    log "scifilesmodule.writeFiles"
    routesName = getRoutesName(name)
    handlersName = getHandlersName(name)

    routesFile = M.render(routesTemplate, interfaceObject)
    handlersFile = M.render(handlersTemplate, interfaceObject)

    routesFilePath = p.getFilePath(routesName+".coffee")
    fs.writeFileSync(routesFilePath, routesFile)

    handlersFilePath = p.getFilePath(handlersName+".coffee")
    fs.writeFileSync(handlersFilePath, handlersFile)
    return

module.exports = scifilesmodule