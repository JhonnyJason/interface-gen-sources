############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("sectionobject")
#endregion

############################################################
import * as M from "mustache"

############################################################
export class SectionObject
    constructor: (@name) ->
        @titleLine = null
        @descriptionLines = []
        @routeNames = []

    addRoute: (name) -> @routeNames.push(name)