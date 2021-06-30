mainprocessmodule = {name: "mainprocessmodule"}
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
#region modulesFromEnvironment
cfg = null
#endregion

##############################################################################
mainprocessmodule.initialize = () ->
    log "mainprocessmodule.initialize"
    cfg = allModules.configmodule
    return 

##############################################################################
#region internalFunctions
#endregion

##############################################################################
#region exposedFunctions
mainprocessmodule.execute = (e) ->
    log "mainprocessmodule.execute"
    src = e.source
    log src
    return
#endregion

module.exports = mainprocessmodule
