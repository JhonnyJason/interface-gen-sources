############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("routeobject")
#endregion

############################################################
import * as M from "mustache"

############################################################
export class RouteObject
    constructor: (@name) ->
        @titleLine = null
        @descriptionLines = []
        @routeNames = []

    addRoute: (name) -> @routeNames.push(name)