definitionfilemodule = {name: "definitionfilemodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["definitionfilemodule"]?  then console.log "[definitionfilemodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
#region modulesFromEnvironment
path = require("path")
fs = require("fs")
HJSON = require("hjson")

############################################################
absolutePath = ""
dirname = ""
filename = ""
file = ""
slices = []

############################################################
interfaceObject = {}

############################################################
routeDetect = /^[a-z0-9]+/i

routeKey = "### /"
requestKey = "#### request"
responseKey = "#### response"
definitionStartKey = "```json"
definitionEndKey = "```"

#endregion

############################################################
definitionfilemodule.initialize = () ->
    log "definitionfilemodule.initialize"
    return
    
############################################################
#region internalFunctions
getPathData = (source) ->
    absolutePath = path.resolve(source) 
    dirname = path.dirname(absolutePath)
    filename = path.basename(absolutePath)
    
    log "- - -"
    log absolutePath
    log dirname
    log filename
    log "= = ="

    return

############################################################
sliceFile = ->
    index = file.indexOf(routeKey)
    
    while index >= 0
        index += routeKey.length
        nextIndex = file.indexOf(routeKey, index)
        if nextIndex < 0 then slices.push(file.slice(index))        
        else slices.push(file.slice(index, nextIndex))
        index = nextIndex
    
    return

############################################################
extractInterface = ->
    extractFromSlice(slice) for slice in slices
    return

extractFromSlice = (slice) ->
    route = routeDetect.exec(slice)


    requestIndex = slice.indexOf(requestKey)
    if requestIndex < 0 then throw new Error("File Corrupt! Expected '#### request' in route slice!")
    requestIndex += requestKey.length

    requestDefinitionStart = slice.indexOf(definitionStartKey, requestIndex)
    if requestDefinitionStart < 0 then throw new Error("File Corrupt! Expected '```json' to start request definition!")
    requestDefinitionStart += definitionStartKey.length

    requestDefinitionEnd = slice.indexOf(definitionEndKey, requestDefinitionStart)
    if requestDefinitionEnd < 0 then throw new Error("File Corrupt! Expected '```' to end request definition!")


    responseIndex = slice.indexOf(responseKey, requestDefinitionEnd)
    if responseIndex < 0 then throw new Error("File Corrupt! Expected '#### response' definition in route slice!")
    responseIndex += responseKey.length

    responseDefinitionStart = slice.indexOf(definitionStartKey, responseIndex)
    if responseDefinitionStart < 0 then throw new Error("File Corrupt! Expected '```json' to start response definition!")
    responseDefinitionStart += definitionStartKey.length

    responseDefinitionEnd = slice.indexOf(definitionEndKey, responseDefinitionStart)
    if responseDefinitionEnd < 0 then throw new Error("File Corrupt! Expected '```' to end response definition!")


    requestDefinitionString = slice.slice(requestDefinitionStart, requestDefinitionEnd)
    requestDefinition = HJSON.parse(requestDefinitionString)
    

    responseDefinitionString = slice.slice(responseDefinitionStart, responseDefinitionEnd)

    interfaceObject[route] = Object.keys(requestDefinition)

    return

#endregion

############################################################
#region exposedFunctions
definitionfilemodule.digestFile = (source) ->
    getPathData(source)
    
    file = fs.readFileSync(absolutePath, 'utf8')
    
    sliceFile()
    extractInterface()
    return

definitionfilemodule.interfaceObject = interfaceObject
#endregion 

module.exports = definitionfilemodule