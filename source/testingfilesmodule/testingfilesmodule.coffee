testingfilesmodule = {name: "testingfilesmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["testingfilesmodule"]?  then console.log "[testingfilesmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
fs = require("fs")
M = require("mustache")

############################################################
p = null

############################################################
#region templates
localRequestTemplate = """
{{=<% %>=}}
### 
POST {{local}}/<% route %>
content-type: application/json

{
<% requestBlock %>
}
<%={{ }}=%>
"""

############################################################
deployRequestTemplate = """
{{=<% %>=}}
### 
POST {{deploy}}/<% route %>
content-type: application/json

{
<% requestBlock %>
}
<%={{ }}=%>
"""

#endregion

############################################################
testingfilesmodule.initialize = () ->
    log "testingfilesmodule.initialize"
    p = allModules.pathmodule
    return


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
testingfilesmodule.writeFiles = (interfaceObject, name) ->
    log "testingfilesmodule.writeFiles"
    writeLocalRequestsFile(interfaceObject, name)
    writeDeployRequestsFile(interfaceObject, name)
    return

module.exports = testingfilesmodule
