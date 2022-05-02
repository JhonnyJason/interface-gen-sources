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
import { createStateGuardian } from "./stateguardianmodule.js"

#endregion

############################################################
#region states
parserStates = [
    "PARSING_HEAD",
    "PARSING_VERSION",
    "PARSING_SIDENOTE",
    "PARSING_ROUTE",
    "PARSING_DONE"
]

fragmentTypes = [
    "title", # h1
    "sectionHead", # h2
    "routeHead", # h3
    "requestHead", # h4 request
    "responseHead", # h4 response
    "jsonStart",
    "jsonEnd", 
    "contentLine"
    "emptyLine",
]
#endregion

############################################################
export class DocumentationFileParser
    constructor: ->
        try
            @sectionMap = new LinkedMap()
            @sectionIdCount = 0
            
            @routesToId = {}

            @path = ph.getDocumentationFilePath()
            @fileString = fs.readFileSync(@path, "utf-8")
            log "constructed DocumentationFileParser"
            @fileExists = true

        catch err
            log err
            log "documentation File not appropriately constructed!"
            @fileExists = false

    parse: ->
        if !@fileExists then throw new Error("Documentation File does not exist!")        
        @lines = @fileString.split("\n")
        @lineCursor = 0
        @lineObjects = []


        ## open Section for the whole document
        @document = new DocumentSection()
        openSections = [@document]
        currentLevel = 0

        while @lineCursor < @lines.length
            line = @lines[@lineCursor]
            lineObj = new LineObject(line, @lineCursor)
            @lineObjects.push(lineObj)
            
            level = getLineTypeLevel(lineObj.type)
            if level > currentLevel and level != 7
                upperSection = openSections[currentLevel]
                section = new DocumentSection(@lineCursor, lineObj.type)
                upperSection.add(section)
                openSections.push(section)
                currentLevel++
            else if level != 7
                while level <= currentLevel
                    upperSection = openSections[currentLevel]
                    upperSection.close(@lineCursor)
                    currentLevel--
                upperSection = openSections[currentLevel]
                section = new DocumentSection(@lineCursor, lineObj.type)
                upperSection.add(section)
                openSections.push(section)
                currentLevel++

            @lineCursor++
        
        @document.close(@lineCursor)
        log "parsing ended!"
        olog @document
        return
      
############################################################
class DocumentSection
    constructor: (@start, @type) ->
        if !@start? then @start = 0
        @children = []
        @open = true

    close: (end) -> 
        @end = end
        @open = false

    add: (subSection) -> @children.push(subSection)

class DocumentNode
    constructor: (@parent, @fragment) ->
        if !@parent?
            @parent = null
            @fragment = null
            @document = this
            @level = 0
        else
            parent = @parent.parent
            @document = parent
            @level = 1
            while parent?
                parent = parent.parent
                @document = parent
                @level++
            
        @fragments = []
        @children = []

    addFragment: (fragment) ->
        switch fragment.type
            when "jsonStart", "jsonEnd", "emptyLine", "contentLine"
                @fragments.push(fragment)
                return this
            when "title", "sectionHead", "routeHead", "requestHead", "responseHead"
                if @level > getFragmentTypeLevel(fragment.type)
                    node = new DocumentNode(this, @document, @fragment)
                    @children.push(node)

        return 
    
class LineObject
    constructor: (@line, @index) ->
        @type = getLineType(@line)
    

############################################################
#region internalFunctions
getLineTypeLevel = (type) ->
    switch type
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

requestOrResponse = (line) ->
    if line.indexOf("request") > 4 then return "requestHead"
    else if line.indexOf("response") > 4 then return "responseHead"
    else return "contentLine"

############################################################
#region stateEnteringFunctions
enterParsingHeadState = (df) ->
    log "enterParsingHead"
    df.state = "PARSING_HEAD"
    id = ""+df.sectionIdCount++
    section = new DocumentSection("head", id)
    df.sectionMap.appendToTail(id, section)
    df.currentSection = section
    
    lines = df.fileString.split("\n")
    df.lines = lines
    log lines.length
    df.lineCursor = 0

    while df.lineCursor < lines.length
        line = lines[df.lineCursor]
        #check for state transitions
        isVersionLine = checkIfIsVersionLine(line)
        # if isVersionLine then log "isVersionLine!"
        # olog {isVersionLine}
        if isVersionLine
            # exitParsingHeadState(df)
            enterParsingVersionState(df)
            return
        
        isRouteLine = checkIfIsRouteLine(line)
        # if isRouteLine then log "isRouteLine!"
        # olog {isRouteLine}
        if isRouteLine
            # exitParsingHeadState(df)
            enterParsingRouteState(df)
            return
        
        # # do internal action 
        section.add(line)
        df.lineCursor++

    enterParsingDoneState(df)    
    return

enterParsingVersionState = (df) ->
    log "enterParsingVersionState"
    df.state = "PARSING_VERSION"
    id = ""+df.sectionIdCount++
    section = new DocumentSection("version", id)
    df.sectionMap.appendToTail(id, section)
    df.currentSection = section
    
    versionLine = df.lines[df.lineCursor]
    df.version = versionLine.match(versionDetect)

    section.add(versionLine)
    df.lineCursor++

    section.versionLineTemplate = versionLine.replace(df.version, "{{{version}}}")
    section.version = df.version
    log "- parsed versionLine"
    log section.versionLineTemplate
    log section.version

    while df.lineCursor < lines.length
        line = df.lines[df.lineCursor]
        #check for state transitions
        isRouteLine = checkIfIsRouteLine(line)
        # if isRouteLine then log "isRouteLine!"
        # olog {isRouteLine}
        if isRouteLine
            # exitParsingHeadState(df)
            enterParsingRouteState(df)
            return

        isSideNoteLine = checkIfSideNoteLine(line)
        if isSideNoteLine
            # exitParsingVersionState(df)
            enterParsingSideNodeState(df)
            return
        
        section.add(line)
        df.lineCursor++

    enterParsingDoneState(df)
    return

enterParsingRouteState = (df) ->
    log "parsingRouteState"
    df.state = "PARSING_ROUTE"
    id = ""+df.sectionIdCount++
    section = new DocumentSection("route", id)
    df.sectionMap.appendToTail(id, section)
    df.currentSection = section
    
    routeLine = df.lines[df.lineCursor]
    section.add(routeLine)
    df.lineCursor++

    section.routeObject = {}
    routeLine = routeLine.slice(routeKey.length)
    routeName = routeLine.match(routeDetect)
    section.routeObject.route = routeName
    df.routesToId[routeNem] = id

    log "- parsed RouteLine"
    log section.routeObject.route

    while df.lineCursor < lines.length
        line = df.lines[df.lineCursor]
        #check for state transitions
        isRequestLine = checkIfIsRequestLine(line)
        if isRequestLine
            parseRequest(df, section)
            continue
        isResponseLine = checkIfIsResponseLine(line)
        if isResponseLine 
            parseResponse(df, section)
            continue
        
        # TODO

        isSideNoteLine = checkIfSideNoteLine(line)
        if isSideNoteLine
            # exitParsingVersionState(df)
            enterParsingSideNodeState(df)
            return
        
        section.add(line)
        df.lineCursor++

    enterParsingDoneState(df)
    return

enterParsingSideNoteState = (df) ->
    log "parsingSideNoteState"
    return

#endregion

parseRequest = (df, section) ->
    log "parseRequest"
    cursod = df.lineCursor
    l = df.lines.length

    startIndex = df.lineCursor
    # endIndex = 
    return

parseResponse = (df, section) ->
    log "parseRequest"
    
    return


############################################################
#region checkingFunctions
checkIfIsVersionLine = (line) ->
    return versionDetect.test(line)

checkIfIsRouteLine = (line) ->
    return 0 == line.indexOf(routeKey)

checkIfIsRequestLine = (line) ->
    return 0 == line.indexOf(requestKey)

checkIfIsResponseLine = (line) ->
    return 0 == line.indexOf(responseKey)

checkIfIsSideNoteLine = (line) ->
    return sideNoteDetect.test(line)

#endregion

#endregion





############################################################
file = ""
slices = []

############################################################
interfaceObject = {routes:[]}

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
