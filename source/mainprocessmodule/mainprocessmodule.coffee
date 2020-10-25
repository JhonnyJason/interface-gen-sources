mainprocessmodule = {name: "mainprocessmodule"}

#region modulesFromEnvironment
cfg = null
#endregion

#region logPrintFunctions
##############################################################################
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["mainprocessmodule"]?  then console.log "[mainprocessmodule]: " + arg
    return
olog = (o) -> log "\n" + ostr(o)
ostr = (o) -> JSON.stringify(o, null, 4)
print = (arg) -> console.log(arg)
#endregion
##############################################################################
mainprocessmodule.initialize = () ->
    log "mainprocessmodule.initialize"
    cfg = allModules.configmodule
    return 

#region internalFunctions
#endregion

#region exposedFunctions
mainprocessmodule.execute = () ->
    log "mainprocessmodule.execute"
    return
#endregion

module.exports = mainprocessmodule
