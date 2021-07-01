debugmodule = {name: "debugmodule"}

##############################################################################
debugmodule.initialize = () ->
    # console.log "debugmodule.initialize - nothing to do"
    return     
##############################################################################
debugmodule.modulesToDebug = 
    unbreaker: true
    # cliargumentsmodule: true
    # configmodule: true
    # mainprocessmodule: true
    networkinterfacemodule: true
    scifilesmodule: true
    # startupmodule: true
    
module.exports = debugmodule