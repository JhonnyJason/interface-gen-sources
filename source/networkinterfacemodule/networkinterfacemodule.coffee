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
p = null

############################################################
networkinterfacemodule.initialize = ->
    log "networkinterfacemodule.initialize"
    p = allModules.pathmodule
    return
    
############################################################
#region exposedFunctions
networkinterfacemodule.writeFile = (interfaceObject, name) ->
    log "networkinterfacemodule.writeFile"
    return

#endregion

module.exports = networkinterfacemodule