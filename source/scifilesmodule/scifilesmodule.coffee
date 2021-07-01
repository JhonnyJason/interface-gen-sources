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
p = null

############################################################
scifilesmodule.initialize = ->
    log "scifilesmodule.initialize"
    p = allModules.pathmodule
    return
    
############################################################
scifilesmodule.writeFiles = (interfaceObject, name) ->
    log "scifilesmodule.writeFiles"
    return

module.exports = scifilesmodule