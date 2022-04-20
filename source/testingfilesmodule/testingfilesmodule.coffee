##############################################################################
#region debug
import {createLogFunctions} from "thingy-debug"
{log, olog} = createLogFunctions("testingfilesmodule")

#endregion

############################################################
import fs from "fs"
import M from "mustache"

############################################################
import * as p from "./pathmodule.js"

############################################################
#region templates
localRequestTemplate = """
{{=<% %>=}}
<% #routes %>
### 
POST {{local}}/<%{route}%>
content-type: application/json

{
<%{requestBlock}%>
}
<% /routes %>
<%={{ }}=%>
"""

############################################################
deployRequestTemplate = """
{{=<% %>=}}
<% #routes %>
### 
POST {{deploy}}/<%{route}%>
content-type: application/json

{
<%{requestBlock}%>
}
<% /routes %>
<%={{{ }}}=%>
"""

#endregion


############################################################
#region internalFunctions
getLocalRequestsFileName = (name) ->
    name = name.toLowerCase()
    
    l = "interface".length # get rid of "interface" postfix
    if name.indexOf("interface") > 0 then name = name.slice(0,name.length-l)

    if name.indexOf("local") < 0 then name = name+"local"
    return name

############################################################
getDeployRequestsFileName = (name) ->
    name = name.toLowerCase()

    l = "interface".length # get rid of "interface" postfix
    if name.indexOf("interface") > 0 then name = name.slice(0,name.length-l)

    if name.indexOf("deploy") < 0 then name = name+"deploy"
    return name


############################################################
writeLocalRequestsFile = (interfaceObject, name) ->
    fileName = getLocalRequestsFileName(name)

    file = M.render(localRequestTemplate, interfaceObject)
    
    filePath = p.getFilePath(fileName+".http")
    fs.writeFileSync(filePath, file)
    return

writeDeployRequestsFile = (interfaceObject, name) ->
    fileName = getDeployRequestsFileName(name)

    file = M.render(deployRequestTemplate, interfaceObject)

    filePath = p.getFilePath(fileName+".http")
    fs.writeFileSync(filePath, file)
    return


#endregion

############################################################
export writeFiles = (interfaceObject, name) ->
    log "writeFiles"
    writeLocalRequestsFile(interfaceObject, name)
    writeDeployRequestsFile(interfaceObject, name)
    return
