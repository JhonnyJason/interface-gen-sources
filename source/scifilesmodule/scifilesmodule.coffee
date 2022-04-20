##############################################################################
#region debug
import {createLogFunctions} from "thingy-debug"
{log, olog} = createLogFunctions("scifilesmodule")

#endregion

############################################################
#region imports
import fs from "fs"
import M from  "mustache"

############################################################
import  * as p from "./pathmodule.js"

#endregion

############################################################
#region templates
routesTemplate ="""
    import * as h from "./{{{name}}}handlers"

    {{#routes}}
    ############################################################
    sciroutes.{{route}} = (req, res) ->
        try
            response = await h.{{route}}({{argsBlock}})
            res.send(response)
        catch err then res.send({error: err.stack})
        return

    {{/routes}}
    """

handlersTemplate ="""
    {{#routes}}
    ############################################################
    scihandlers.{{route}} = ({{args}}) ->
        result = {}
        ###
        {{{response}}}
        ###
        return result


    {{/routes}}
    """

handlerFunctionSignatureTemplate = "scihandlers.{{route}} = ({{args}}) ->"

#endregion

############################################################
#region internalFunctions
getRoutesFileName = (name) ->
    name = name.toLowerCase()

    l = "interface".length # get rid of "interface" postfix
    if name.indexOf("interface") > 0 then name = name.slice(0,name.length-l)

    if name.indexOf("routes") < 0 then name = name+"routes"
    return name

getHandlersFileName = (name) ->
    name = name.toLowerCase()

    l = "interface".length # get rid of "interface" postfix
    if name.indexOf("interface") > 0 then name = name.slice(0,name.length-l)

    if name.indexOf("handlers") < 0 then name = name+"handlers"
    return name

############################################################
writeRoutesFile = (interfaceObject, name) ->
    routesName = getRoutesFileName(name)

    routesFile = M.render(routesTemplate, interfaceObject)

    routesFilePath = p.getFilePath(routesName+".coffee")
    fs.writeFileSync(routesFilePath, routesFile)
    return

writeHandlersFile = (interfaceObject, name) ->
    handlersName = getHandlersFileName(name)
    handlersFilePath = p.getFilePath(handlersName+".coffee")

    newInterfaceObject = null

    try
        oldFile = fs.readFileSync(handlersFilePath, "utf8")
        
        routes = getMissingRoutes(interfaceObject.routes, oldFile)
        newInterfaceObject = {routes}

        handlersFile = oldFile+M.render(handlersTemplate, newInterfaceObject)
    catch err
        handlersFile = M.render(handlersTemplate, interfaceObject)


    fs.writeFileSync(handlersFilePath, handlersFile)
    return

############################################################
getMissingRoutes = (routes, file) ->
    missing = []
    for route in routes
        funSignature = M.render(handlerFunctionSignatureTemplate, route)
        if file.indexOf(funSignature) < 0 then missing.push(route)
    return missing

#endregion

############################################################
export writeFiles = (interfaceObject, name) ->
    log "writeFiles"
    writeRoutesFile(interfaceObject, name)
    writeHandlersFile(interfaceObject, name)
    return
