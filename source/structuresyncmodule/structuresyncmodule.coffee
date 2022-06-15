############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("structuresyncmodule")
#endregion

############################################################
import * as filesParser from "./filesparsermodule.js"

############################################################
parsedDocumentation = null
parsedInterface = null
parsedHandlers = null

############################################################
routesMap = {}

############################################################
mapRoutesByName = ->
    log "mapRoutesByName"
    if parsedDocumentation? and parsedDocumentation.routeObjects?
        for routeObj in parsedDocumentation.routeObjects
            id = routeObj.routeName
            if !routesMap[id]? then routesMap[id] = {}
            routesMap[id].documentation = routeObj

    if parsedInterface? and parsedInterface.routeObjects?
        for routeObj in parsedInterface.routeObjects
            id = routeObj.routeName
            if!routesMap[id]? then routesMap[id] = {}
            routesMap.interface = routeObj

    if parsedHandlers? and parsedHandlers.routeObjects?
        for routeObj in parsedHandlers.routeObjects
            id = routeObj.routeName
            if !routesMap[id]? then routesMap[id] = {}
            routesMap.handler = routeObj

    return

############################################################
#region syncFunctions
syncUnionMode = ->
    log "syncUnionMode"
    for name,route of routesMap
        log name
        log Object.keys(route)
    
    log "not implemented yet!"
    return

syncIntersectIgnoreMode = ->
    log "syncIntersectIgnoreMode"
    for name,route of routesMap
        log name
        log Object.keys(route)

    log "not implemented yet!"
    return

syncIntersectCutMode = ->
    log "syncIntersectCutMode"
    for name,route of routesMap
        log name
        log Object.keys(route)

    log "not implemented yet!"
    return

#endregion

############################################################
export syncStructures = (mode) ->
    log "syncStructure"
    parsedDocumentation = filesParser.getParsedDocumentation()
    parsedInterface = filesParser.getParsedInterface()
    parsedHandlers = filesParser.getParsedHandlers()

    mapRoutesByName()

    switch mode
        when "union" then syncUnionMode()
        when "intersect-ignore" then syncIntersectIgnoreMode()
        when "intersect-cut" then syncIntersectCutMode()
        else throw new Error("Unknown Sync Mode: "+mode)

    return