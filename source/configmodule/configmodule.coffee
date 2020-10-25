configmodule = {name: "configmodule"}

#region exposedProperties
configmodule.cli =
    name: ""
#endregion

#region logPrintFunctions
##############################################################################
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["configmodule"]?  then console.log "[configmodule]: " + arg
    return
#endregion
##############################################################################
configmodule.initialize = () ->
    log "configmodule.initialize"
    return

#region exposed functions
#endregion

module.exports = configmodule