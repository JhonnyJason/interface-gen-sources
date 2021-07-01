pathmodule = {name: "pathmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["pathmodule"]?  then console.log "[pathmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
path = require("path")

############################################################
pathmodule.absolutePath = ""
pathmodule.dirname = ""
pathmodule.filename = ""
pathmodule.basename = ""

############################################################
pathmodule.initialize = ->
    log "pathmodule.initialize"
    return

############################################################
#region exposedStuff
pathmodule.digestPath = (source) ->
    pathmodule.absolutePath = path.resolve(source) 
    pathmodule.dirname = path.dirname(pathmodule.absolutePath)
    pathmodule.filename = path.basename(pathmodule.absolutePath)
    pathmodule.basename = pathmodule.filename.split(".")[0]

    log "- - -"
    log pathmodule.absolutePath
    log pathmodule.dirname
    log pathmodule.filename
    log pathmodule.basename
    log "= = ="
    return

pathmodule.getFilePath = (name) ->
    return path.resolve(pathmodule.dirname, name)

#endregion

module.exports = pathmodule