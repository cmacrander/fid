module.exports =

    # Some reference frequencies for setting the fundamental.
    frequencies:
        c0: 16.35,
        c1: 32.70,
        c2: 65.41,
        c3: 130.81,
        c4: 261.63

    # The grammar of the active language of this editor will be stored here.
    grammar: undefined

    # The available scopes will be listed here.
    allScopes: []

    # Interval ratios, for reference.
    # Minor Second    25/24
    # Major Second    9/8
    # Minor Third 6/5
    # Major Third 5/4
    # Fourth  4/3
    # Diminished Fifth    45/32
    # Fifth   3/2
    # Minor Sixth 8/5
    # Major Sixth 5/3
    # Minor Seventh   9/5
    # Major Seventh   15/8
    # Octave   2/1

    # What intervals from the tonic are played for specified pieces of syntax.
    dictionary:
        'comment.block.coffee': 5 / 4  # major third
        'comment.line.number-sign.coffee': 5 / 4
        'constant.character.character-class.regexp': 1
        'constant.character.control.regexp': 1
        'constant.character.escape.backslash.regexp': 1
        'constant.character.escape.coffee': 1
        'constant.character.numeric.regexp': 1
        'constant.language.boolean.false.coffee': 1
        'constant.language.boolean.true.coffee': 1
        'constant.language.coffee': 1
        'constant.language.null.coffee': 1
        'constant.numeric.coffee': 1
        'constant.other.character-class.range.regexp': 1
        'constant.other.character-class.set.regexp': 1
        'entity.name.function.coffee': 1
        'entity.name.type.class.coffee': 1
        'entity.name.type.instance.coffee': 1
        'entity.name.type.object.coffee': 4 / 3  # forth
        'entity.other.inherited-class.coffee': 1
        'keyword.control.anchor.regexp': 1
        'keyword.control.coffee': 1
        'keyword.control.inheritance.coffee': 1
        'keyword.operator.coffee': 9 / 5  # minor seventh
        'keyword.operator.negation.regexp': 1
        'keyword.operator.new.coffee': 1
        'keyword.operator.or.regexp': 1
        'keyword.operator.quantifier.regexp': 1
        'keyword.other.back-reference.regexp': 1
        'keyword.other.coffee': 1
        'keyword.reserved.coffee': 1
        'meta.assertion.look-ahead.regexp': 1
        'meta.assertion.negative-look-ahead.regexp': 1
        'meta.brace.curly.coffee': 3 / 2  # fifth
        'meta.brace.round.coffee': 3 / 2
        'meta.brace.square.coffee': 3 / 2
        'meta.class.coffee': 1
        'meta.class.instance.constructor': 1
        'meta.delimiter.method.period.coffee': 8 / 5  # minor sixth
        'meta.delimiter.object.comma.coffee': 8 / 5
        'meta.function.coffee': 1
        'meta.group.assertion.regexp': 1
        'meta.group.regexp': 1
        'meta.inline.function.coffee': 1
        'meta.variable.assignment.destructured.array.coffee': 1
        'meta.variable.assignment.destructured.object.coffee': 1
        'punctuation.definition.character-class.regexp': 1
        'punctuation.definition.comment.coffee': 1
        'punctuation.definition.group.regexp': 1
        'punctuation.definition.string.begin.coffee': 15 / 8  # major seventh
        'punctuation.definition.string.begin.js': 1
        'punctuation.definition.string.end.coffee': 2  # octave
        'punctuation.section.embedded.coffee': 1,
        'punctuation.separator.key-value': 1
        'punctuation.terminator.statement.coffee': 1
        'source.coffee': 1  # tonic
        'source.coffee.embedded.source': 1
        'storage.type.annotation.coffeescript': 1
        'storage.type.class.coffee': 1
        'storage.type.function.coffee': 1
        'string.quoted.double.coffee': 1
        'string.quoted.double.heredoc.coffee': 1
        'string.quoted.heredoc.coffee': 1
        'string.quoted.script.coffee': 1
        'string.quoted.single.coffee': 1
        'string.regexp.coffee': 1
        'support.class.coffee': 1
        'support.function.coffee': 1
        'support.function.console.coffee': 1
        'support.function.method.array.coffee': 1
        'support.function.static.array.coffee': 1
        'support.function.static.math.coffee': 1
        'support.function.static.number.coffee': 1
        'support.function.static.object.coffee': 1
        'variable.assignment.coffee': 9 / 5
        'variable.language.coffee': 4 / 3
        'variable.other.readwrite.instance.coffee': 4 / 3
        'variable.parameter.function.coffee': 1

    # Initializing function. Atom packages must define it.
    activate: (state) ->
        atom.workspaceView.command "fid:begin", => @begin()
        atom.workspaceView.command "fid:debug", => @debug()
        atom.workspaceView.command "fid"

    # Turn on the music.
    begin: ->
        editor = @getEditor()

        # Read details about the current grammar.
        @grammar = editor.getGrammar()
        @allScopes = (pattern.name for pattern in @grammar.rawPatterns)
        console.log @allScopes

        # Set up listeners. Not all are used, but remain here for reference,
        # because the documentation on how to do this is very poor.
        editor.buffer.on 'contents-modified', @contentsModified.bind @
        editor.buffer.on 'changed', @bufferChanged.bind @
        # This is the one currently used.
        atom.workspaceView.eachEditorView (editorView) =>
            editorView.on 'cursor:moved', @cursorMoved.bind @

    getEditor: ->
        # This assumes the active pane item is an editor
        atom.workspace.activePaneItem

    # Returns indentation level, according to the editor's settings. If tab
    # size is four, and you're indented 8 spaces, your indentation level is 2.
    getIndentation: ->
        editor = @getEditor()
        row = editor.getCursor().getBufferRow()
        editor.indentationForBufferRow row

    # this must be FAST, called synchronously while typing
    bufferChanged: (changeEvent) ->
        # changeEvent: {
        #     newRange: Range,
        #     newText: str,
        #     oldRange: Range,
        #     oldText: str
        # }
        # console.log "changed", x, y, z

    contentsModified: (isModified) ->
        # isModified is just like the close button on a tab: circle (true) if
        # buffer modified, x (false) if not modified from last save.
        # console.log "contents-modified", isModified

    cursorMoved: (moveEvent) ->
        # moveEvent is a jQuery event with things like .target (a DOM node) and
        # .type ('cursor:moved').

        # Get the text of the current line.
        editor = @getEditor()
        line = editor.getCursor().getCurrentBufferLine()

        # Tokenize ("read") the line and look for the token that matches the
        # current word. It will contain a list of the syntactic categories that
        # apply.
        tokens = @grammar.tokenizeLine(line).tokens

        # Count up the size of tokens from left to right until we get to the
        # current position of the cursor. That's the token that's currently
        # being typed.
        column = editor.getCursor().getBufferColumn()
        c = 0
        token = undefined
        for t in tokens
            c += t.bufferDelta
            if c is column
                token = t

        console.log column, token?.value, token?.scopes

        # Turn the token into music.
        if token?
            @playToken token

    playToken: (token) ->
        # Base the tonic on the indentation level. Each level is another
        # octave higher. Level 0 is C3.
        tonic = (Math.pow(2, @getIndentation())) * @frequencies.c3

        # Look through the syntactic categories that apply to this token.
        # Play a note for each one that has a defintion, thus building chords.
        for s in token.scopes
            if s of @dictionary
                interval = @dictionary[s]
                @playNote tonic * interval, 200

    ######################## audio stuff

    audioContext: new webkitAudioContext()

    # Hz, ms
    playNote: (frequency, duration) ->
        oscillator = @audioContext.createOscillator()

        oscillator.type = 0;  # sine wave
        oscillator.frequency.value = frequency
        oscillator.connect @audioContext.destination
        oscillator.noteOn && oscillator.noteOn(0)

        setTimeout (-> oscillator.noteOff && oscillator.noteOff(0)), duration

    debug: ->
        # editor = @getEditor()
        # console.log "editor:", editor
        # console.log "word:", editor.getWordUnderCursor()
        # cursor = editor.getCursor()
        # console.log "cursor:", cursor
        # row = cursor.getBufferRow()
        # console.log "row:", row
        # console.log "indent by row:", editor.indentationForBufferRow row
        # line = cursor.getCurrentBufferLine()
        # console.log "line:", line
        # console.log "indent by line:", editor.indentLevelForLine line
