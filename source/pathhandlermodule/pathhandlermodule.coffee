##############################################################################
#region debug
import {createLogFunctions} from "thingy-debug"
{log, olog} = createLogFunctions("pathhandlermodule")

#endregion

############################################################
import path from "path"
import fs from "fs"

############################################################
#region variables
absoluteBasePath = ""

############################################################
documentationFilePath = ""
interfaceFilePath = ""
routesFilePath = ""
handlersFilePath = ""
localTestingFilePath = ""
deployTestingFilePath = ""

#endregion

############################################################
#region internal functions
getFilePath = (name) -> path.resolve(absoluteBasePath, name)

isDirectory = (testedPath) ->
    try
        stats = fs.lstatSync(testedPath);
        return stats.isDirectory()
    catch e then return false

#endregion

############################################################
#region exports
export createValidPaths = (root, name) ->
    absoluteBasePath = path.resolve(root)

    if !isDirectory(absoluteBasePath) then throw new Error("Error: Specified root path does not exist as directory!")

    documentationFilePath = getFilePath(name+"interface.md")
    intefaceFilePath = getFilePath(name+"interface.coffee")
    routesFilePath = getFilePath(name+"routes.coffee")
    handlersFilePath = getFilePath(name+"handlers.coffee")
    localTestingFilePath = getFilePath(name+"local.http")
    deployTestingFilePath = getFilePath(name+"deploy.http")

    return

############################################################
export getDocumentationFilePath = -> documentationFilePath
export getInterfaceFilePath = -> interfaceFilePath
export getRoutesFilePath = -> routesFilePath
export getHandlersFilePath = -> handlersFilePath
export getLocalTestingFilePath = -> localTestingFilePath
export getDeployTestingFilePath = -> deployTestingFilePath


#endregion