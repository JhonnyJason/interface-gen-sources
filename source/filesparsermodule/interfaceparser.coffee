############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("interfaceparser")
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
contentDetect = /\S+/i

############################################################
functionKey = "export "
separatorLineKey = "#####"
commentKey = "# "
sectionHeadCommentKey = "# ##"

importPostLine = 'import { postData } from "thingy-network-base"'
separatorLine = "############################################################"
#endregion

############################################################
#region lineTypes
lineTypes = [
    "separatorLine" # level 1
    "functionHead" # level 2
    "contentLine" # level 7
    "commentLine" # level 7
    "emptyLine" # level 7
]

lineToBlockTypeMap = {
    "separatorLine": "sectionBlock"
    "functionHead": "functionBlock"
    "contentLine": "contentBlock"
    "commentLine": "commentBlock"
    "emptyLine": "emptySpaceBlock"
}

#endregion

############################################################
functionTemplate = """
    export {{{routeName}}} = (sciURL, {{{args}}}) ->
        requestObject = { {{{args}}} }
        requestURL = sciURL+"/{{{routeName}}}"
        return postData(requestURL, requestObject)
    """

############################################################
export class InterfaceFileParser
    constructor: ->
        try
            @path = ph.getInterfaceFilePath()
            log "reading interface file from: "+@path
            @fileString = fs.readFileSync(@path, "utf-8")
            log "constructed InterfaceFileParser"
            @fileExists = true
            # Block Components
            @document = null
            @sectionBlocks = []
            @functionBlocks = []
            @contentBlocks = []
            @commentBlocks = []
            @emptySpaceBlocks = []
            # Common Structure Components
            @commonStructure = new LinkedMap()
            @versionHeadline = null
            @importPostLine = null
            @sectionObjects = []
            @functionObjects = []
            @commentObjects = []
            @emptySpaceObjects = []

            @routeObjects = []

        catch err
            log err
            log "InterfaceFileParser not appropriately constructed!"
            @fileExists = false

    parse: ->
        if !@fileExists then throw new Error("Interface File does not exist!")        
        @lines = @fileString.split("\n")
        @lineCursor = 0
        @lineObjects = []

        # mark Block starts and ends for the whole document
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
        # olog @sectionBlocks
        # olog @functionBlocks
        # olog @contentBlocks
        # olog @commentBlocks
        # olog @emptySpaceBlocks
        return
    
    ########################################################
    addBlock: (block) ->
        if block.parent?
            if block.parent.type == "functionBlock"
                return
        switch block.type
            when "sectionBlock" then @sectionBlocks.push(block)
            when "functionBlock" then @functionBlocks.push(block)
            when "contentBlock" then @contentBlocks.push(block)
            when "commentBlock" then @commentBlocks.push(block)
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

        el = @createImportPostLine()
        @importPostLine = el
        all.push(el)

        # section headline is SectionSeparation
        for block in @sectionBlocks
            el = @createSectionObject(block)
            @sectionObjects.push(el)
            all.push(el)
        
        # route headline is RouteHeadline
        for block in @functionBlocks
            routeObj = @createRouteObject(block)
            @routeObjects.push(routeObj)

            @functionObjects.push(routeObj.functionObj)
            all.push(routeObj.functionObj)

        # comment Blocks
        for block in @commentBlocks
            el = @createCommentObject(block)
            continue unless el?

            @commentObjects.push(el)
            all.push(el)

        # emptySpace Blocks
        for block in @emptySpaceBlocks
            el = @createEmptySpaceObject(block)
            continue unless el?

            @emptySpaceObjects.push(el)
            all.push(el)
        
        sortComp = (elOne, elTwo) -> elOne.index - elTwo.index

        all.sort(sortComp)

        for el in all
            @commonStructure.appendToTail(el.id, el)

        return


    ########################################################
    createVersionHeadline: ->
        # title headline is VersionHeadline        
        if @topBlock? 
            titleIndex = @topBlock.start
            titleLineObj = @lineObjects[titleIndex]
            if versionDetect.test(titleLineObj.line) then return new VersionHeadline(titleLineObj)
        
        # otherwise it could be any contentLine in the head
        if @subSections.length and @routeBlocks.length
            sectionStart = @subSections[0].start
            routeStart = @routeBlocks[0].start
            
            if sectionStart > routeStart then scanEnd = routeStart
            else scanEnd = sectionStart

            scanIndex = 0
            while scanIndex < scanEnd
                lineObj = @lineObjects[scanIndex]
                if versionDetect.test(lineObj.line) then return new VersionHeadline(lineObj)
                scanIndex++

        else if @subSections.length
            scanEnd = @subSections[0].start

            scanIndex = 0
            while scanIndex < scanEnd
                lineObj = @lineObjects[scanIndex]
                if versionDetect.test(lineObj.line) then return new VersionHeadline(lineObj)
                scanIndex++


        else if @routeBlocks.length
            scanEnd = @routeBlocks[0].start

            scanIndex = 0
            while scanIndex < scanEnd
                lineObj = @lineObjects[scanIndex]
                if versionDetect.test(lineObj.line) then return new VersionHeadline(lineObj)
                scanIndex++

        return new VersionHeadline()
    
    createImportPostLine: ->
        log "createImportPostLine"
        log "TODO..."
        lineObj = @lineObjects[1]
        return new ImportPostLine(lineObj)

    createSectionObject: (sectionBlock) ->
        log "createSectionObject"
        log "TODO..."
        return new SectionObject(lineObj)

    createRouteObject: (functionBlock) ->
        result = {}
        headlineIndex = routeBlock.start
        headlineObj = @lineObjects[headlineIndex]
        result.headline = new RouteHeadline(headlineObj)
        for child in routeBlock.children
            if child.type == "requestBlock" then requestBlock = child
            if child.type == "responseBlock" then responseBlock = child
        try
            result.requestObj = @createRequestObject(requestBlock)
            result.responseObj = @createResponseObject(responseBlock)
            return result
        catch err then throw new Error("Error on parsing route "+result.headline.routeName+"\n"+err.message)
    
    createFunctionObject: (functionBlock) ->
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
    
    createCommentObject: (commentBlock) ->
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
        @parent = null

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
         
FO_count = 0
class FunctionObject
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
        when "separatorLine" then return 1
        when "sectionHeadComment" then return 2
        when "functionHead" then return 2
        else return 7
    return

getLineType = (line) ->
    if !contentDetect.test(line) then return "emptyLine"
 
    if line.indexOf(separatorLineKey) == 0 then return "separatorLine"
    if line.indexOf(sectionHeadCommentKey) == 0 then return "sectionHeadComment"
    if line.indexOf(functionKey) == 0 then return "functionHead"    
    if line.indexOf(commentKey) == 0 then return "commentLine"

    return "contentLine"

lineToBlockType = (lineType) -> return lineToBlockTypeMap[lineType]

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