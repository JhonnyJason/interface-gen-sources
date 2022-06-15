############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("handlersparser")
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
argsDetect = /^[a-z]+[a-z0-9]*(, *[a-z]+[a-z0-9]*)*/i
routeDetect = /^[a-z]+[a-z0-9]*/i
versionDetect = /v\d+\.\d+\.\d+/
contentDetect = /\S+/i

############################################################
separatorLineKey = "#####"
commentKey = "# "

############################################################
separatorLine = "############################################################"
sectionHeadCommentKey = "# ##"

############################################################
serviceDefinitionLine = "service = null"
setServiceLine = "export setService = (serviceToSet) -> service = serviceToSet"


############################################################
functionKey = "export "
functionCenter = " = ("
functionEnd = ") ->"

#endregion

############################################################
#region line and block types
lineTypes = [
    # "importLine" # level 1
    "separatorLine" # level 1
    "sectionHeadComment" # level 2
    "functionHead" # level 2
    "contentLine" # level 3
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
#region templates
functionHeadlineTemplate = 'export {{{routeName}}} = ({{{args}}}) ->'

#endregion

############################################################
export class HandlersFileParser
    constructor: ->
        try
            @path = ph.getHandlersFilePath()
            log "reading handlers file from: "+@path
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
            @importLine = null
            @sectionHeads = []
            @functionObjects = []
            @commentObjects = []
            @emptySpaceObjects = []

            @routeObjects = []

        catch err
            log err
            log "InterfaceFileParser not appropriately constructed!"
            @fileExists = false

    parse: ->
        return
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
                
            # 7 is no specific level - specific levels are up to 3 here, these are nodes. 7 are leaves.
            if level > currentLevel and level != 7
                # log "level > currentLevel and level != 7"
                # the currentBlock is above us so we add the new Block beneath
                #region addNewBlock()
                # olog currentBlock
                block = new DocumentBlock(@lineCursor, type, level, currentBlock)
                currentBlock.add(block)
                openBlocks.push(block)
                @addBlock(block)
                #endregion
                
            else if level != 7
                # log "level != 7"
                # the currentBlock is not above us
                while level <= currentLevel
                    # closing Blocks until we reach one which is above us
                    block = openBlocks.pop()
                    block.close(@lineCursor)
                    currentLevel = openBlocks[openBlocks.length - 1].level

                currentBlock = openBlocks[openBlocks.length - 1]
                
                #region addNewBlock()
                # olog currentBlock
                block = new DocumentBlock(@lineCursor, type, level, currentBlock)
                currentBlock.add(block)
                openBlocks.push(block)
                @addBlock(block)
                #endregion
            
            else if level == 7
                # log "level == 7"
                # log currentLevel
                # create or add Block for content or empty space
                if currentLevel != 7
                    # initially creating the new block for emptySpaces or content
    
                    # We are in function content and reach a leave - then close function Block
                    if currentLevel == 3
                        #close content Block - level 3
                        block = openBlocks.pop()
                        block.close(@lineCursor)
                        currentBlock = openBlocks[openBlocks.length - 1]
                        if currentBlock.type == "functionBlock"
                            #close function Block - level 2
                            block = openBlocks.pop()
                            block.close(@lineCursor)
                            currentBlock = openBlocks[openBlocks.length - 1]


                    #region addNewBlock()
                    # olog currentBlock
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
                    # olog currentBlock
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
        all = []
        sectionFunctionMap = Array(@lines.length).fill(null)

        # - create the common pieces
        ## Scan for versionHeadline
        el = @createVersionHeadline()
        @versionHeadline = el
        all.push(el)

        el = @createImportLine()
        @importLine = el
        all.push(el)

        # section Head is separation line plus Section Headline Comment
        for block in @sectionBlocks
            el = @createSectionHead(block)
            @sectionHeads.push(el)
            all.push(el)

            sectionFunctionMap[block.start] = el
            if el.sectionName? then sectionFunctionMap[block.start+1] = el


        #function blocks are function headline plus Content
        for block in @functionBlocks
            routeObj = @createRouteObject(block)
            @routeObjects.push(routeObj)

            @functionObjects.push(routeObj.functionObj)
            all.push(routeObj.functionObj)

            # olog routeObj
            idx = block.start
            while idx < block.end
                sectionFunctionMap[idx] = el
                idx++


        # comment Blocks
        for block in @commentBlocks
            # check if it is description of SectionHead
            sectionObject = sectionFunctionMap[block.start - 1]
            if sectionObject? and sectionObject.type == "SectionHead"
                lines = []
                idx = block.start
                end = block.end

                while idx < end
                    lines.push(@lines[idx])
                    idx++
                
                sectionObject.setCommentLines(lines)
                continue

            # check if it is description of a FunctionObject
            functionObject = sectionFunctionMap[block.end + 1]
            if functionObject? and functionObject.type == "FunctionObject"
                lines = []
                idx = block.start
                end = block.end

                while idx < end
                    lines.push(@lines[idx])
                    idx++
                
                functionObject.setCommentLines(lines)
                continue
            
            # default comment
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
        
        # sort by index 
        sortComp = (elOne, elTwo) -> elOne.index - elTwo.index
        all.sort(sortComp)

        # create the common structure out of it
        for el in all
            @commonStructure.appendToTail(el.id, el)

        return

    ########################################################
    getHeadEndIndex: ->
        if @sectionBlocks.length and @functionBlocks.length
            sectionStart = @sectionBlocks[0].start
            functionStart = @functionBlocks[0].start
            
            if sectionStart > functionStart then return functionStart
            else return sectionStart

        else if @sectionBlock.length then return @sectionBlocks[0].start

        else if @functionBlocks.length then return @functionBlocks[0].start

        return @document.end

    createVersionHeadline: ->
        scanEnd = @getHeadEndIndex()
        scanIndex = 0
        while scanIndex < scanEnd
            lineObj = @lineObjects[scanIndex]
            if versionDetect.test(lineObj.line) then return new VersionHeadline(lineObj)
            scanIndex++
        scanIndex = 0

        return new VersionHeadline()
    
    createImportLine: ->
        scanEnd = @getHeadEndIndex()
        scanIndex = 0
        while scanIndex < scanEnd
            lineObj = @lineObjects[scanIndex]
            if lineObj.line.indexOf(importPostLine) == 0 then return new ImportLine(lineObj)
            scanIndex++

        return new ImportLine()

    createSectionHead: (sectionBlock) ->
        separatorLine = @lines[sectionBlock.start]
        if separatorLine.indexOf(separatorLineKey) != 0 then throw new Error("Section Block did not start with saparator line!")

        sectionHead = new SectionHead(sectionBlock)

        headlineObj = @lineObjects[sectionBlock.start + 1]
        if headlineObj.type == "sectionHeadComment" then sectionHead.addHeadline(headlineObj)
        
        return sectionHead

    createRouteObject: (functionBlock) ->
        # olog functionBlock
        functionObj = new FunctionObject(functionBlock)

        headlineIndex = functionBlock.start
        headline = @lineObjects[headlineIndex].line
        functionObj.setHeadline(headline)
        
        bodyStart = headlineIndex + 1
        bodyEnd = functionBlock.end
        index = bodyStart
        bodyLines = []
        while index <  bodyEnd
            line = @lineObjects[index].line
            if contentDetect.test(line) then bodyLines.push(line)
            index++
        # log bodyLines.length
        if bodyLines.length != 3 then throw new Error("Invalid Function body size!\n"+bodyLines.join("\n"))
        functionObj.setBodyLines(bodyLines)

        return {functionObj}
        
    createCommentObject: (commentBlock) ->
        obj = new CommentObject(commentBlock)
        
        commentLines = []
        index = commentBlock.start
        while index < commentBlock.end
            line = @lines[index]
            commentLines.push(line)
            index++
        
        content = commentLines.join("\n")
        obj.setContent(content)

        return obj

    createEmptySpaceObject: (emptySpaceBlock) ->
        return new EmptySpaceObject(emptySpaceBlock)
        
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
class ImportLine
    constructor: (@lineObj) ->
        if @lineObj?
            @index = @lineObj.index
        else
            @lineObj = null
            @index = -1

        @line = 'import { postData } from "thingy-network-base"'
        @type = "ImportLine"
        @id = @type # only exists once
        
class VersionHeadline
    constructor: (@lineObj) ->
        if @lineObj?
            @version = @lineObj.line.match(versionDetect)[0]
            @lineTemplate = @lineObj.line.replace(@version, "{{{version}}}")
            @index = @lineObj.index
        else
            @version = "v0.0.0"
            @lineTemplate = "# {{{version}}}"
            @lineObj = null
            @index = -2

        @type = "VersionHeadline"
        @id = @type # only exists once
        
        # log @version
        # log @lineTemplate

SH_count = 0
class SectionHead
    constructor: (@blockObj) ->
        @index = @blockObj.start
        @type = "SectionHead"
        @id = @type+SH_count++
        @headlineTemplate = "# #\#{{{sectionName}}}"
        @sectionName = null

    addHeadline: (@lineObj) ->
        headline = @lineObj.line
        # sectionHeadNamePart = headline.slice(sectionHeadCommentKey+1)
        # @sectionName = sectionHeadNamePart.match(routeDetect)[0]
        @sectionName = headline.slice(sectionHeadCommentKey+1)
        @headlineTemplate = headline.replace(@sectionName, "{{{sectionName}}}")
        
        # log headline
        # log @sectionName
        # log @headlineTemplate
         
    setCommentLines: (lines) ->
        @commentLines = lines
        #TODO

FO_count = 0
class FunctionObject
    constructor: (@blockObj) ->
        @index = @blockObj.start
        @type = "FunctionObject"
        @id = @type+FO_count++
        @commentBlock = null
    
    setHeadline: (headline) ->
        @headline = headline
        try
            if headline.indexOf(functionKey) != 0 then throw new Error("Function key missing!")
            part = headline.slice(functionKey.length)
            @routeName = part.match(routeDetect)[0]
            if !@routeName then throw new Error("RouteName missing!")
            part = part.slice(@routeName.length)
            if part.indexOf(functionCenter) != 0 then throw new Error("Corrupt center part!")
            part = part.slice(functionCenter.length)
            @args = part.match(argsDetect)[0]
            if !@args then throw new Error("args missing!")
            part = part.slice(@args.length)
            if part.indexOf(functionEnd) != 0 then throw new Error("Corrupt function end!")
            part = part.slice(functionEnd.length)
            if contentDetect.test(part) then throw new Error("Conent after function end detected!")
            template = headline.replace(@routeName, "{{{routeName}}}")
            template = template.replace(@args, "{{{args}}}")
            @headlineTemplate = template
            
            # log @routeName
            # log @args
            # log @headlineTemplate

        catch err then throw new Error("Headline is corrupt!\nheadline="+headline+"\n- "+err.message)

    setBodyLines: (bodyLines) ->
        @bodyLines = bodyLines
        line0 = @bodyLines[0]
        line1 = @bodyLines[1]
        line2 = @bodyLines[2]
        try
            if line0.indexOf(functionBodyLine0Key) != 0 then throw new Error("Body Line 0 is corrupt! (key)")
            if line1.indexOf(functionBodyLine1Key) != 0 then throw new Error("Body Line 1 is corrupt! (key)")
            if line2.indexOf(functionBodyLine2) != 0 then throw new Error("Body Line 2 is corrupt!")

            # check body line 0 for corruption
            line0 = line0.slice(functionBodyLine0Key.length)
            if line0.indexOf(@args) != 0 then throw new Error("Body Line 0 is corrupt! (args)")
            line0 = line0.slice(@args.length)
            if line0.indexOf(functionBodyLine0Ending) != 0 then throw new Error("Body Line 0  is corrupt! (ending)")
            line0 = line0.slice(functionBodyLine0Ending.length)
            if contentDetect.test(line0) then throw new Error("Content after body Line 0 detected!")

            #check body line 1 for corruption
            line1 = line1.slice(functionBodyLine1Key.length)
            if line1.indexOf(@routeName) != 0 then throw new Error("Body Line 1 is corrupt! (routeName)")
            line1 = line1.slice(@routeName.length)
            if line1.indexOf(functionBodyLine1Ending) != 0 then throw new Error("Body Line 1 is corrupt! (ending)")
            line1 = line1.slice(functionBodyLine1Ending.length)
            if contentDetect.test(line1) then throw new Error("Content after body Line 1 detected!")

            #check body line 2 for corruption
            line2 = line2.slice(functionBodyLine2.length)
            if contentDetect.test(line2) then throw new Error("Content after body Line 2 detected!")


        catch err then throw new Error("Body of function is corrupt!\nheadline="+@headline+"\n- "+err.message)
        return
    
    setCommentLines: (lines) -> 
        @commentLines = lines
        #TODO

CO_count = 0
class CommentObject
    constructor: (@blockObj) ->
        @index = @blockObj.start
        @type = "CommentObject"
        @id = @type+CO_count++
        
    setContent: (content) ->
        @lines = content.split("\n")
        @content = content
        return

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
        # when "separatorLine", "importLine" then return 1
        when "functionHead", "sectionHeadComment" then return 2
        when "contentLine" then return 3
        else return 7
    return

getLineType = (line) ->
    if !contentDetect.test(line) then return "emptyLine"
 
    if line.indexOf(separatorLineKey) == 0 then return "separatorLine"
    if line.indexOf(sectionHeadCommentKey) == 0 then return "sectionHeadComment"
    if line.indexOf(functionKey) == 0 then return "functionHead"    
    if line.indexOf(commentKey) == 0 then return "commentLine"
    if line.indexOf(importPostLine) == 0 then return "importLine"

    return "contentLine"

lineToBlockType = (lineType) -> return lineToBlockTypeMap[lineType]

#endregion
