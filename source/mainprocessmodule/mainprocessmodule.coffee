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
path = require("path")
fs = require("fs")

############################################################
HJSON = require("hjson")

############################################################
cfg = null
#endregion

############################################################
mainprocessmodule.initialize = () ->
    log "mainprocessmodule.initialize"
    cfg = allModules.configmodule
    return 

############################################################
#region internalFunctions
extractEndpointDefinition = (slice) ->
    routeDetect = /^[a-z0-9]+/i
    route = routeDetect.exec(slice)
    log route

    requestKey = "#### request"
    responseKey = "#### response"
    definitionStartKey = "```json"
    definitionEndKey = "```"

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
    olog requestDefinition

    responseDefinitionString = slice.slice(responseDefinitionStart, responseDefinitionEnd)
    # responseDefinition = JSON.parse(responseDefinitionString)

    return

#endregion

############################################################
#region exposedFunctions
mainprocessmodule.execute = (e) ->
    log "mainprocessmodule.execute"

    src = path.resolve(e.source) # we want to deal with absolute paths only

    log src
    log e.name

    routeKey = "### /"

    ## TODO check if file exists?
    definitionFile = fs.readFileSync(src, 'utf8')
    slices = []

    index = definitionFile.indexOf(routeKey)
    while index >= 0
        index += routeKey.length
        nextIndex = definitionFile.indexOf(routeKey, index)
        if nextIndex < 0 then slices.push(definitionFile.slice(index))        
        else slices.push(definitionFile.slice(index, nextIndex))
        index = nextIndex

    log "- - -"
    extractEndpointDefinition(slice) for slice in slices

    return

#endregion

module.exports = mainprocessmodule