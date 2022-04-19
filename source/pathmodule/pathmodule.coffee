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
import path from "path"

############################################################
obj = {}
obj.absolutePath = ""
obj.dirname = ""
obj.filename = ""
obj.basename = ""


############################################################
export digestPath = (source) ->
    obj.absolutePath = path.resolve(source) 
    obj.dirname = path.dirname(pathmodule.absolutePath)
    obj.filename = path.basename(pathmodule.absolutePath)
    obj.basename = pathmodule.filename.split(".")[0]

    log "- - -"
    log obj.absolutePath
    log obj.dirname
    log obj.filename
    log obj.basename
    log "= = ="
    return

export getFilePath = (name) ->
    return path.resolve(pathmodule.dirname, name)

export default obj