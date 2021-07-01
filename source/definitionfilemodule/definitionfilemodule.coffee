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
fs = require("fs")
HJSON = require("hjson")

############################################################
p = null

############################################################
file = ""
slices = []

############################################################
interfaceObject = {routes:[]}

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
    p = allModules.pathmodule
    return
    
############################################################
#region internalFunctions
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

    addRoute(route, Object.keys(requestDefinition), responseDefinitionString)

    return

############################################################
addRoute = (routeName, requestArgs, sampleResponse) ->
    routeObject =
        route: routeName
        args: requestArgs.join(", ")
        # response: sampleResponse
    interfaceObject.routes.push(routeObject) 
    return
#endregion

############################################################
#region exposedFunctions
definitionfilemodule.digestFile = (source) ->
    p.digestPath(source)
    
    file = fs.readFileSync(p.absolutePath, 'utf8')
    
    sliceFile()
    extractInterface()
    return

############################################################
definitionfilemodule.interfaceObject = interfaceObject

#endregion 

module.exports = definitionfilemodule