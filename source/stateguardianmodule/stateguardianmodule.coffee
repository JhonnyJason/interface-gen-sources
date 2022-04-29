############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("stateguardianmodule")
#endregion

############################################################
stateGuardians = []

############################################################
class StateGuardian
    constructor: (states, @id) ->
        # log "constructor: " + states
        @idToState = ["initial"]
        @stateToId = { initial: 0 }
        @currentStateId = 0
        @currentStateName = "initial"
        @stateTransitionMap = []
        @idToEnterFunctions = []
        @idToExitFunctions = []
        return unless states
        id = 1
        for state in states
            @idToState[id] = state
            @idToApplyFuctions[id] = undefined
            @stateToId[state] = id
            id++
        for fromStateId of @idToState
            @stateTransitionMap[fromStateId] = []
            for toStateId of @idToState
                @stateTransitionMap[fromStateId][toStateId] = undefined
        
    # setStateTo: (state) ->
    #     id = @getStateId(state)
    #     name = @idToState[id]

    #     @currentStateName = name
    #     @currentStateId =  id

    #     if @idToApplyFuctions[id]? then @idToApplyFuctions[id]() 
    #     @printCurrentState()

    stateTransitionTo: (state) ->
        if state == @currentStateId || state == @currentStateName then return
        @printCurrentState()
        log "stateTransitionTo: " + state
        if !(@currentStateId?) || !(@currentStateName?) 
            log "Error: cannot do state Transition from non valid initial State!"
            @printCurrentState()
            return     
        toStateId = @getStateId(state)
        if (@stateTransitionMap[@currentStateId][toStateId])?
            (@stateTransitionMap[@currentStateId][toStateId])()
            @setStateTo(toStateId)

    addState: (state) -> return
    removeState: (state) -> return
    setVerbosityLevel: (verbosity) -> return

    addStateTransition: (fromState, toState, transitionFunction) ->
        fromStateId = @getStateId(fromState)
        toStateId = @getStateId(toState)
        log "state Transition: " + fromStateId + " -> " + toStateId
        @stateTransitionMap[fromStateId][toStateId] = transitionFunction

    setApplyStateFunction: (state, func) ->
        stateId = @getStateId(state)
        @idToApplyFuctions[stateId] = func

    getStateId: (state) ->
        if typeof state == "string"
            id = @stateToId[state]
            if id? then return id
            log "Error state " + state + " was not found!"
            return 
        else if typeof state == "number"
            if @idToState.length > state then return state
            log "Error id " + state + "was not found!"
            return 

    printAllStates: -> 
        printstring = ""
        for state in @idToState
            printstring += "state: " + state + " id: " + @stateToId[state] + "\n"
        log printstring

    printCurrentState: -> 
        log "currentStateId: " + @currentStateId
        log "currentStateName: " + @currentStateName


############################################################
export createStateGuardian = (states) ->
    log "createStateGuardian"
    id = stateGuardians.length
    stateGuardian = new StateGuardian(states, id)
    stateGuardians.push(stateGuardian)
    return stateGuardian

