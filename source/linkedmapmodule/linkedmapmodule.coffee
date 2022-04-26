############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("linkedmapmodule")
#endregion

############################################################
class Entry
    constructor:( @id, @content, @list) ->
        @list.idToEntry[@id] = this
        @previousEntry = null
        @nextEntry = null
        log "Entry constructed, id: "+@id

    append:(otherEntry) ->

        if @previousEntry?
            @previousEntry.nextEntry = otherEntry
            otherEntry.previousEntry = @previousEntry

        @previousEntry = otherEntry
        otherEntry.nextEntry = this
        return

    prepend:(otherEntry) ->
        
        if @nextEntry?
            @nextEntry.previousEntry = otherEntry
            otherEntry.nextEntry = @nextEntry
        @nextEntry = otherEntry
        otherEntry.previousEntry = this
        return

    remove: ->
        delete @list.idToEntry[@id]
        if @nextEntry? then @nextEntry.previousEntry = @previousEntry
        if @previousEntry? then @previousEntry.nextEntry = @nextEntry
        return

############################################################
export class LinkedMap
    constructor: ->
        @head = null
        @tail = null
        @size = 0
        @idToEntry = {}
        log "LinkedMap constructed!"

    ############################################################
    get:( id ) ->
        entry = @idToEntry[id]
        if entry? then return entry.content
        else return null

    remove:( id ) ->
        entry = @idToEntry[id]
        return unless entry?
        if entry == @head then @head = entry.previousEntry
        if entry == @tail then @tail = entry.nextEntry
        entry.remove()
        @size--
        checkForCorruption(this)
        return

    ############################################################
    append:( id, content, otherId ) ->
        log "append"
        if !otherId? then @appendToTail(id, content)
        else @appendToId(id, content, otherId)
        return

    appendToTail:( id, content ) ->
        log "appendToTail"
        if !@tail?
            entry = new Entry(id, content, this)
            @head = entry
            @tail = entry
        else
            entry = new Entry(id, content, this)
            @tail.append(entry)
            @tail = entry
        @size++
        checkForCorruption(this)
        return

    appendToId:( id, content, otherId ) ->
        log "appendToId"
        otherEntry = @idToEntry[otherId]
        if !otherEntry? then throw new Error("Entry to append to does not exist!")
        entry = new Entry(id, content, this)
        otherEntry.append(entry)
        if otherEntry == @tail then @tail = entry
        @size++
        checkForCorruption(this)
        return


    ############################################################
    prepend:( id, content, otherId ) ->
        if !otherId? then @prependToHead(id, content)
        else @prependToId(id, content, otherId)

    prependToHead:( id, content ) ->
        if !@head?
            entry = new Entry(id, content, this)
            @head = entry
            @tail = entry
        else
            entry = new Entry(id, content, this)
            @head.prepend(entry)
            @head = entry
        @size++
        checkForCorruption(this)
        return

    appendToId:( id, content, otherId ) ->
        otherEntry = @idToEntry[otherId]
        if !otherEntry? then throw new Error("Entry to prepend to does not exist!")
        entry = new Entry(id, content, this)
        otherEntry.prepend(entry)
        if otherEntry == @head then @head = entry
        @size++
        checkForCorruption(this)
        return

    
    ############################################################
    print: ->
        printString = "listState:\n"
        if @head?
            printString += "listHead Id: "+@head.id+"\n"
            printString += @head.toString()

            entry = @head.previousEntry
            while(entry?)
                printString += entry.toString()
                entry = entry.previousEntry
            printString +="listTail Id: "+@tail.id
            printString+= "\n"
        else printString += toJson({head: @head, tail: @tail})
        printString += "- - - - -\n"
        printString += toJson({size: @size})
        log printString+"\n"
        return

############################################################
checkForCorruption = (list) ->
    log "checkForCorruption"
    if list.size < 0 then throw new Error("Datastructure corrupted, size is negative!")
    if list.tail? and !list.head? then throw new Error("Datastructure corrupted, tail exists but head is missing!")
    if list.head? and !list.tail? then throw new Error("Datastructure corrupted, head exists but tail is missing!")
    if list.tail? and list.tail.previousEntry? then throw new Error("List tail had a previous Entry!")
    if list.head? and list.head.nextEntry? then throw new Error("List head had a next Entry!")
    return

