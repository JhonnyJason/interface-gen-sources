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

############################################################
#region modulesFromEnvironment
cfg = null
definitionFile = null
networkInterface = null
sciFiles = null

#endregion

############################################################
mainprocessmodule.initialize = ->
    log "mainprocessmodule.initialize"
    cfg = allModules.configmodule
    definitionFile = allModules.definitionfilemodule
    networkInterface = allModules.networkinterfacemodule
    sciFiles = allModules.scifilesmodule
    return 

############################################################
#region exposedFunctions
mainprocessmodule.execute = (e) ->
    log "mainprocessmodule.execute"

    definitionFile.digestFile(e.source)

    interfaceObject = definitionFile.interfaceObject
    olog interfaceObject

    throw "death on purpose!"

    log "- - -"
    log e.name
    log "= = ="

    networkInterface.writeFile(interfaceObject, e.name)
    sciFiles.writeFiles(interfaceObject, e.name)
    return

#endregion

module.exports = mainprocessmodule