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
#region patterns
routeDetect = /^[a-z]+[a-z0-9]*/i
versionDetect = /v\d+\.\d+\.\d+/
sideNoteDetect = /\S+/i
contentDetect = /\S+/i

############################################################
routeKey = "### /"
requestKey = "#### request"
responseKey = "#### response"
definitionStartKey = "```json"
definitionEndKey = "```"
jsonStart = "```json"
jsonEnd = "```"

#endregion

############################################################
#region lineTypes
lineTypes = [
    "title" # level 1
    "sectionHead" # level 2
    "routeHead" # level 3
    "requestHead" # level 4
    "responseHead" # level 4
    "jsonStart" # level 7
    "jsonEnd"  # level 7
    "contentLine" # level 7
    "emptyLine" # level 7
]

lineToBlockTypeMap = {
    "title": "topBlock"
    "sectionHead": "subSection"
    "routeHead": "routeBlock"
    "requestHead": "requestBlock"
    "responseHead": "responseBlock"
    "jsonStart": "contentBlock"
    "jsonEnd": "contentBlock"
    "contentLine": "contentBlock"
    "emptyLine": "emptySpaceBlock"
}
#endregion

############################################################
export class DocumentationFileParser
    constructor: ->
        try
            @parsed = false
            @path = ph.getDocumentationFilePath()
            @fileString = fs.readFileSync(@path, "utf-8")
            log "constructed DocumentationFileParser"
            @fileExists = true
            # Block Components
            @topBlock = null
            @subSections = []
            @routeBlocks = []
            @contentBlocks = []
            @emptySpaceBlocks = []
            # Common Structure Components
            @commonStructure = new LinkedMap()
            @versionHeadline = null
            @sectionHeadlines = []
            @routeHeadlines = []
            @requestObjects = []
            @responseObjects = []
            @commentObjects = []
            @emptySpaceObjects = []

            @routeObjects = []

        catch err
            log err
            log "documentation File not appropriately constructed!"
            @fileExists = false

    parse: ->
        if !@fileExists then throw new Error("Documentation File does not exist!")        
        @lines = @fileString.split("\n")
        @lineCursor = 0
        @lineObjects = []


        ## mark Block starts and ends for the whole document
        @document = new DocumentBlock()
        openBlocks = [@document]
        
        while @lineCursor < @lines.length
            line = @lines[@lineCursor]
            lineObj = new LineObject(line, @lineCursor)
            @lineObjects.push(lineObj)
            
            level = getLineLevel(lineObj)
            type = lineToBlockType(lineObj.type)
            currentBlock = openBlocks[openBlocks.length - 1]
            currentLevel = currentBlock.level
                
            # 7 is no specific level - specific levels go to 4 here these are nodes. 7 are leaves.
            if level > currentLevel and level != 7
                # the currentBlock is above us so we add the new Block beneath
                #region addNewBlock()
                block = new DocumentBlock(@lineCursor, type, level, currentBlock)
                currentBlock.add(block)
                openBlocks.push(block)
                @addBlock(block)
                #endregion
                
            else if level != 7
                # the currentBlock is not above us
                while level <= currentLevel
                    # closing Blocks until we reach one which is above us
                    block = openBlocks.pop()
                    block.close(@lineCursor)
                    currentLevel = openBlocks[openBlocks.length - 1].level

                currentBlock = openBlocks[openBlocks.length - 1]
                
                #region addNewBlock()
                block = new DocumentBlock(@lineCursor, type, level, currentBlock)
                currentBlock.add(block)
                openBlocks.push(block)
                @addBlock(block)
                #endregion
            
            else if level == 7
                # create or add Block for content or empty space
                if currentLevel != 7
                    # initially creating the new block for emptySpaces or content
                    #region addNewBlock()
                    block = new DocumentBlock(@lineCursor, type, level, currentBlock)
                    currentBlock.add(block)
                    openBlocks.push(block)
                    @addBlock(block)
                    #endregion

                else if currentBlock.type != type
                    # close the currentBlock if it is not of the same type
                    # when we have emptyLine then emptyLine then it is the same Block
                    block = openBlocks.pop()
                    block.close(@lineCursor)
                    currentBlock = openBlocks[openBlocks.length - 1]
                    
                    #region addNewBlock()
                    block = new DocumentBlock(@lineCursor, type, level, currentBlock)
                    currentBlock.add(block)
                    openBlocks.push(block)
                    @addBlock(block)
                    #endregion
            
            @lineCursor++
        
        # close all Open Block
        while openBlocks.length
            block = openBlocks.pop()
            block.close(@lineCursor)

        @createCommonStructure()

        # log "parsing ended!"
        # olog @document
        # olog @topBlock
        # olog @subSections
        # olog @routeBlocks
        @parsed = true
        return
    
    ########################################################
    addBlock: (block) ->
        if block.parent?
            if block.parent.type == "requestHead" or block.parent.type == "responseHead"
                return
        switch block.type
            when "topBlock" then @topBlock = block
            when "subSection" then @subSections.push(block)
            when "routeBlock" then @routeBlocks.push(block)
            when "contentBlock" then @contentBlocks.push(block)
            when "emptySpaceBlock" then @emptySpaceBlocks.push(block)
            else return
        return

    createCommonStructure: ->
        log "addCreateCommonStructure"
        idCount = 0
        all = []

        # - create the common pieces
        ## Scan for versionHeadline
        el = @createVersionHeadline()
        @versionHeadline = el
        all.push(el)

        # section headline is SectionSeparation
        for subSection in @subSections
            lineIndex = subSection.start
            lineObj = @lineObjects[lineIndex]
            el = new SectionHeadline(lineObj)
            @sectionHeadlines.push(el)
            all.push(el)
        
        # route headline is RouteHeadline
        for routeBlock in @routeBlocks
            routeObj = @createRouteObject(routeBlock)
            @routeObjects.push(routeObj)

            @routeHeadlines.push(routeObj.headline)
            all.push(routeObj.headline)

            @requestObjects.push(routeObj.requestObj)
            all.push(routeObj.requestObj)

            @responseObjects.push(routeObj.responseObj)
            all.push(routeObj.responseObj)

        # content Blocks
        for contentBlock in @contentBlocks
            el = @createCommentObject(contentBlock)
            continue unless el?

            @commentObjects.push(el)
            all.push(el)

        # emptySpace Blocks
        for emptySpaceBlock in @emptySpaceBlocks
            el = @createEmptySpaceObject(emptySpaceBlock)
            continue unless el?

            @emptySpaceObjects.push(el)
            all.push(el)
        
        sortComp = (elOne, elTwo) -> elOne.index - elTwo.index

        all.sort(sortComp)

        for el in all
            @commonStructure.appendToTail(el.id, el)

        return

    ########################################################
    getHeadEndIndex: ->
        if @subSections.length and @routeBlocks.length
            sectionStart = @subSections[0].start
            routeStart = @routeBlocks[0].start
            
            if sectionStart > routeStart then return routeStart
            else return sectionStart

        else if @subSections.length then return @subSections[0].start

        else if @routeBlocks.length then return @routeBlocks[0].start

        return @document.end


    createVersionHeadline: ->
        # title headline is VersionHeadline        
        if @topBlock? 
            titleIndex = @topBlock.start
            titleLineObj = @lineObjects[titleIndex]
            if versionDetect.test(titleLineObj.line) then return new VersionHeadline(titleLineObj)

        # otherwise it could be any contentLine in the head
        scanEnd = @getHeadEndIndex()
        scanIndex = 0
        while scanIndex < scanEnd
            lineObj = @lineObjects[scanIndex]
            if versionDetect.test(lineObj.line) then return new VersionHeadline(lineObj)
            scanIndex++


        return new VersionHeadline()

    createRouteObject: (routeBlock) ->
        result = {}
        headlineIndex = routeBlock.start
        headlineObj = @lineObjects[headlineIndex]
        result.headline = new RouteHeadline(headlineObj)
        result.routeName = result.headline.routeName
        result.sectionName = routeBlock.parent
        for child in routeBlock.children
            if child.type == "requestBlock" then requestBlock = child
            if child.type == "responseBlock" then responseBlock = child
        try
            result.requestObj = @createRequestObject(requestBlock)
            result.responseObj = @createResponseObject(responseBlock)
            result.requestArgs = result.requestObj.requestArgs
            result.sampleResponse = result.responseObj.definitionJson
            return result
        catch err then throw new Error("Error on parsing route "+result.headline.routeName+"\n"+err.message)
    
    createRequestObject: (requestBlock) ->
        obj = new RequestObject(requestBlock)

        jsonLines = []
        index = requestBlock.start + 2
        # first line is #### request
        # second line is ```json
        while index < requestBlock.end - 1
            line = @lineObjects[index].line
            # it is not certain when we get the ```
            # so we detect it and quit then
            if line.indexOf(jsonEnd) == 0 then break
            
            jsonLines.push(line)
            index++
        
        requestJson = jsonLines.join("\n")
        obj.setDefinitionJson(requestJson)        
        return obj

    createResponseObject: (responseBlock) ->
        obj = new ResponseObject(responseBlock)

        jsonLines = []
        index = responseBlock.start + 2
        # first line is #### request
        # second line is ```json
        while index < responseBlock.end - 1
            line = @lineObjects[index].line
            # it is not certain when we get the ```
            # so we detect it and quit then
            if line.indexOf(jsonEnd) == 0 then break
            
            jsonLines.push(line)
            index++
        
        responseJson = jsonLines.join("\n")
        obj.setDefinitionJson(responseJson)        

        return obj
    
    createCommentObject: (contentBlock) ->
        switch contentBlock.parent.type
            when  "responseBlock", "requestBlock" then return null
        
        obj = new CommentObject(contentBlock)
        
        contentLines = []
        index = contentBlock.start
        while index < contentBlock.end
            line = @lineObjects[index].line
            contentLines.push(line)
            index++
        
        content = contentLines.join("\n")
        obj.setContent(content)

        return obj

    createEmptySpaceObject: (emptySpaceBlock) ->
        switch emptySpaceBlock.parent.type
            when  "responseBlock", "requestBlock" then return null
            else return new EmptySpaceObject(emptySpaceBlock)
        
############################################################
#region classDefinitions
class DocumentBlock
    constructor: (@start, @type, @level, @parent) ->
        if !@start? or !@type? or !@level?
            @start = 0
            @type = "document"
            @level = 0
        @children = []
        @open = true
        # to debug
        # @parent = null

    close: (end) -> 
        @end = end
        delete @open

    add: (subBlock) -> @children.push(subBlock)
    
class LineObject
    constructor: (@line, @index) ->
        @type = getLineType(@line)

############################################################
class VersionHeadline
    constructor: (@lineObj) ->
        if @lineObj?
            @version = @lineObj.line.match(versionDetect)
            @lineTemplate = @lineObj.line.replace(@version, "{{{version}}}")
            @index = @lineObj.index
        else
            @version = "v0.0.0"
            @lineTemplate = "# {{{version}}}"
            @lineObj = null
            @index = -1

        @type = "VersionHeadline"
        @id = @type # only exists once
        
        # log @version
        # log @lineTemplate

SH_count = 0
class SectionHeadline
    constructor: (@lineObj) ->
        @headline = @lineObj.line
        @index = @lineObj.index
        @type = "SectionHeadline"
        @id = @type+SH_count++

RH_count = 0
class RouteHeadline
    constructor: (@lineObj) ->
        @index = @lineObj.index
        @type = "RouteHeadline"
        @id = @ŧype+RH_count++
        routeNamePart = @lineObj.line.slice(routeKey.length) 
        @routeName = routeNamePart.match(routeDetect)
        @headlineTemplate = @lineObj.line.replace(@routeName, "{{{routeName}}}")
        
        # log @routeName
        # log @headlineTemplate
         
ReqO_count = 0
class RequestObject
    constructor: (@blockObj) ->
        @index = @blockObj.start
        @type = "RequestObject"
        @id = @type+ReqO_count++
    
    setDefinitionJson: (json) ->
        @definitionJson = json
        # log @definitionJson
        try
            @definitionObj = HJSON.parse(json)
            @requestArgs = Object.keys(@definitionObj)       
            # olog @requestArgs
        catch err then throw new Error("Syntax error in Request Block!") 

ResO_count = 0
class ResponseObject
    constructor: (@blockObj) ->
        @index = @blockObj.start
        @type = "ResponseObject"
        @id = @type+ResO_count++
    
    setDefinitionJson: (json) ->
        @definitionJson = json
        # log @definitionJson
        try
            @definitionObj = HJSON.parse(json)
            @responseArgs = Object.keys(@definitionObj)            
            # olog @responseArgs
        catch err then throw new Error("Synthax error in Response Block!"+"\n->"+err.message)

CO_count = 0
class CommentObject
    constructor: (@blockObj) ->
        @index = @blockObj.start
        @type = "CommentObject"
        @id = @type+CO_count++
        
    setContent: (content) ->
        lines = content.split("\n")
        lines = lines.map((line) -> "# "+line)
        @content = content
        @comment = lines.join("\n")
        
        log @content
        log @comment


ESO_count = 0
class EmptySpaceObject
    constructor: (@blockObj) ->
        @index = @blockObj.start
        @type = "EmptySpaceObject"
        @id = @type+ESO_count++
        @size = @blockObj.end - @blockObj.start

#endregion

############################################################
#region internalFunctions
getLineLevel = (lineObj) ->
    switch lineObj.type
        when "title" then return 1
        when "sectionHead" then return 2
        when "routeHead" then return 3
        when "requestHead", "responseHead" then return 4
        else return 7
    return

getLineType = (line) ->
    if !contentDetect.test(line) then return "emptyLine"
    index = 0
    (index++) while line.charAt(index) == "#"
    if line.charAt(index) == " " then switch index
        when 1 then return "title"
        when 2 then return "sectionHead"
        when 3 then return "routeHead"
        when 4 then return requestOrResponse(line)
        else return "contentLine" 
    
    if line.indexOf(jsonStart) == 0 then return "jsonStart"
    if line.indexOf(jsonEnd) == 0 then return "jsonEnd"
    return "contentLine"

lineToBlockType = (lineType) -> return lineToBlockTypeMap[lineType]

requestOrResponse = (line) ->
    if line.indexOf("request") > 4 then return "requestHead"
    else if line.indexOf("response") > 4 then return "responseHead"
    else return "contentLine"

#endregion



############################################################
#region oldCode
file = ""
slices = []

############################################################
interfaceObject = {routes:[]}
    
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

#endregion