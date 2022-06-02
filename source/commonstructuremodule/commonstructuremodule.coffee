############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("commonstructuremodule")
#endregion

############################################################
import { HeadObject } from "./headobject.js"
import { SectionObject } from "./sectionobject.js"
import { RouteObject } from "./routeobject.js"


############################################################
export class CommonStructure
    constructor: ->
        @headNoise = ""
        @headObject = null
        @sectionNames = []
        @sectionObjects = {}
        @routeObjects = {}
        @versions = {
            documentation: ""
            interface: ""
            handlers: ""
        }

    # ############################################################
    # setHeadNoiseLines: (noiseLines) -> @headNoise = noiseLines.join("\n")

    # setDocumentationVersion: (version) ->
    #     @versions.documentationFile = version
    #     return
    
    # setDocumentationHeadLines: (headLines) ->
    #     if !@headObject then @headObject = new HeadObject()
    #     @headObject.setDocumetationHeadLines(headLines)
    #     return

    # setDocumentationSectionLines: (name, sectionLines) ->
    #     if !@sectionObjects[name]? 
    #         @sectionObjects[name] = new SectionObject(name)
    #         @sectionNames.push(name)
    #     @sectionObjects[name].setDocumentationSectionLines(sectionLines)
    #     return
    
    # setDocumentationRouteLines: (name, routeLines, sectionName) ->
    #     if !routeObjects[name]? 
    #         @routeObjects[name] = new RouteObject(name)
    #         if sectionName then @sectionObjects[sectionName].addRoute(name)
    #     @routeObjects[name].setDocumentationRoute(routeLines)
    #     return
    

    # ############################################################
    # setInterfaceVersion: (version) ->
    #     @versions.interfaceFile = version
    #     return
    
    # setInterfaceHeadLines: (headLines) ->
    #     if !@headObject then @headObject = new HeadObject()
    #     @headObject.setInterfaceHeadLines(headLines)
    #     return

    # setInterfaceSectionLines: (name, sectionLines) ->
    #     if !@sectionObjects[name]? 
    #         @sectionObjects[name] = new SectionObject(name)
    #         @sectionNames.push(name)
    #     @sectionObjects[name].setInterfaceSectionLines(sectionLines)
    #     return
    
    # setInterfaceRouteLines: (name, routeLines, sectionName) ->
    #     if !routeObjects[name]? 
    #         @routeObjects[name] = new RouteObject(name)
    #         if sectionName then @sectionObjects[sectionName].addRoute(name)
    #     @routeObjects[name].setInterfaceRouteLines(routeLines)
    #     return
    

    # ############################################################
    # setHandlersVersion: (version) ->
    #     @versions.interfaceFile = version
    #     return
    
    # setHandlersHeadLines: (headLines) ->
    #     if !@headObject then @headObject = new HeadObject()
    #     @headObject.setHandlersHeadLines(headLines)
    #     return

    # setHandlersSectionLines: (name, sectionLines) ->
    #     if !@sectionObjects[name]? 
    #         @sectionObjects[name] = new SectionObject(name)
    #         @sectionNames.push(name)
    #     @sectionObjects[name].setHandlersSectionLines(sectionLines)
    #     return
    
    # setHandlersRouteLines: (name, routeLines, sectionName) ->
    #     if !routeObjects[name]? 
    #         @routeObjects[name] = new RouteObject(name)
    #         if sectionName then @sectionObjects[sectionName].addRoute(name)
    #     @routeObjects[name].setHandlersRouteLines(routeLines)
    #     return

    # ############################################################
    # getDominant: ->
    #     if @versions.document == @versions.interface == @versions.handlers 
    #         throw new Error("All version numbers are equal, thus we cannot update!")
    #     docBiggerThanInterface = versionIsBigger(@versions.documentation, @versions.interface)
    #     docBiggerThanHandlers = versionIsBigger(@versions.documentation,@versions.handlers) 
    #     interfaceBiggerThanHandlers = versionIsBigger(@versions.interface, @versions.handlers)
        
    #     if docBiggerThanInterface and interfaceBiggerThanHandlers then return "documentation"
    #     if docBiggerThanInterface and docBiggerThanHandlers then return "documentation"
        
    #     if !docBiggerThanInterface and interfaceBiggerThanHandlers then return "interface"
    #     if interfaceBiggerThanHandlers and docBiggerThanHandlers then return "interface"

    #     return "handlers"
    
    # ############################################################
    # syncUnion: -> 
    #     dominant = @getDominant()
    #     @headObject.syncUnion(dominant)
    #     section.syncUnion(dominant) for n,section of @sectionObjects 
    #     route.syncUnion(dominant) for n,route of @routeObjects

    # syncIntersectIgnore: -> log "Not Implemented yet!"
    # syncIntersectCut: -> log "NotImplemented yet!"

    # ############################################################
    # generateDocumentation: -> log "Not Implemented yet!"
    # generateInterface: -> log "Not Implemented yet!"
    # generateHandlers: -> log "Not Implemented yet!"
    # generateRoutes: -> log "Not Implemented yet!"
    # generateDeployTester: -> log "Not Implemented yet!"
    # generateLocalTester: -> log "Not Implemented yet!"


# ############################################################
# versionIsBigger = (ver1, ver2) ->
#     ver1Nums = ver1.split(".")
#     ver2Nums = ver2.split(".")
#     num1