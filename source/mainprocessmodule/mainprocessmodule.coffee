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
p = null
cfg = null
definitionFile = null
networkInterface = null
sciFiles = null
testingFiles = null
#endregion

############################################################
mainprocessmodule.initialize = ->
    log "mainprocessmodule.initialize"
    p = allModules.pathmodule
    cfg = allModules.configmodule
    definitionFile = allModules.definitionfilemodule
    networkInterface = allModules.networkinterfacemodule
    sciFiles = allModules.scifilesmodule
    testingFiles = allModules.testingfilesmodule
    return 

############################################################
#region exposedFunctions
mainprocessmodule.execute = (e) ->
    log "mainprocessmodule.execute"

    definitionFile.digestFile(e.source)

    interfaceObject = definitionFile.interfaceObject
    if e.name? then name = e.name
    else name = p.basename
    
    networkInterface.writeFile(interfaceObject, name)
    sciFiles.writeFiles(interfaceObject, name)
    testingFiles.writeFiles(interfaceObject, name)
    return

#endregion

module.exports = mainprocessmodule