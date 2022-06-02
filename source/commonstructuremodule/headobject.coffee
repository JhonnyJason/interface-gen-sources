############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("headobject")
#endregion

############################################################
#region internal classes
class DocumentationHeadObject
    constructor: (@headLines) ->
        @headBlock = @headLines.join("\n")
        @titleLine = @headLines[0]
        @descriptionLines = @headLines.slice(1)
    
    toInterface: ->
        lines = "# "+line for line in @headLines
        return new InterfaceHeadObject(lines)

    toHandlers: ->
        lines = "# "+line for line in @headLines
        return new HandlersHeadObject(lines)        


class InterfaceHeadObject
    constructor: (@headLines) ->
        @headBlock = @headLines.join("\n")
        @titleLine = @headLines[0]
        @descriptionLines = headLines.slice(1)

    toHandlers: -> new HandlersHeadObject(@headLines)        

    toDocumentation: ->
        lines = line.slice(2) for line in @headLines
        return new DocumentationHeadObject(lines)        


class HandlersHeadObject
    constructor: (@headLines) ->
        @headBlock = @headLines.join("\n")
        @titleLine = @headLines[0]
        @descriptionLines = headLines.slice(1)

    toDocumentation: ->
        lines = line.slice(2) for line in @headLines
        return new DocumentationHeadObject(lines)        

    toInterface: -> new InterfaceHeadObject(@headLines)

#endregion

############################################################
export class HeadObject
    constructor: ->
        @documentation = null
        @interface = null
        @handlers = null

    ############################################################
    setDocumentationHeadLines: (headLines) ->
        @documentation = new DocumentationHeadObject(headLines)
        return
    
    setInterfaceHeadLines: (headLines) ->
        @interface = new InterfaceHeadObject(headLines)
        return

    setHandlersHeadLines: (headLines) ->
        @handlers = new HandlersHeadObject(headLines)
        return


    ############################################################
    overWriteAll: (dominant) ->
        switch dominant
            when "documentation"
                @interface = @docmentation.toInterface()
                @handlers = @documentation.toHandlers()
            when "interface"
                @documentation = @interface.toDocumentation()
                @handlers = @interface.toHandlers()
            when "handlers"
                @documentation = @handlers.toDocumentation()
                @interface = @handlers.toInterface()
        return

    syncUnion: (dominant) -> @overWriteAll(dominant)    
    syncIntersectIgnore: (dominant) -> @overWriteAll(dominant)
    syncIntersectCut: (dominant) -> @overWriteAll(dominant)
    
    ############################################################
    getDocumentationBlock: -> @documentation.headBlock
    getInterfaceBlock: -> @interface.headBlock
    getHandlersBlock: -> @handlers.headBlock