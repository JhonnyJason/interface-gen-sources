############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("documentationparser")
#endregion

############################################################
#region imports
import fs from "fs"
import * as HJSON from "hjson"

############################################################
import * as ph from "./pathhandlermodule.js"
import { LinkedMap } from "./linkedmapmodule.js"

#endregion

############################################################
export class DocumentationFile
    constructor: ->
        try 
            @data = new LinkedMap()
            @path = ph.getDocumentationFilePath()
            @fileString = fs.readFileSync(@path, "utf-8")
            log "constructed DocumentationFile"
            @exists = true
        catch err
            log err
            log "documentation File not appropriately constructed!"
            @exists = false

    parse: ->
        if !@exists then throw new Error("Documentation File does not exist!")
        log "real implementation here!"
        @lines = @fileString.split("\n")
        log @lines.length
        
        for line,idx in @lines
            id = ""+idx
            cObj = { id, line }
            @data.append(id, cObj)

        log @data.size
        return


############################################################
file = ""
slices = []

############################################################
interfaceObject = {routes:[]}

############################################################
#region patterns
routeDetect = /^[a-z0-9]+/i

############################################################
routeKey = "### /"
requestKey = "#### request"
responseKey = "#### response"
definitionStartKey = "```json"
definitionEndKey = "```"

#endregion
    
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
        requestBlock: "\""+requestArgs.join("\": \"...\", \n\"")+"\": \"...\""
        argsBlock: createArgsBlock(requestArgs)
        response: sampleResponse
    interfaceObject.routes.push(routeObject) 
    return

############################################################
createArgsBlock = (argsArray) ->
    return argsArray.map( (el) -> "req.body."+el ).join(", ")

#endregion
