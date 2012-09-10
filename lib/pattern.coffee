# A pattern corresponds to the 8x8 grid of buttons on the Launchpad.
#
# It consists of 64 steps with integer values (typically 0-4 for off,green,yellow,orange,red lights),
# a start step, and an end step.
#
class Pattern

  constructor: (type = '?', @defaultValue = 0) ->
    @sequence = (@defaultValue for i in [0...STEPS])
    @start = 0
    @end = STEPS - 1
    @_updateLength()
    @setType(type)


  setType: (type) ->
    @type = type
    @_process = Pattern.processors[type] or NOOP


  setStart: (index) ->
    if 0 <= index < STEPS
      @start = parseInt(index)
      @end = @start if @start > @end
      @_updateLength()

  setEnd: (index) ->
    if 0 <= index < STEPS
      @end = parseInt(index)
      @start = @end if @start > @end
      @_updateLength()

  _updateLength: ->
    @length = @end - @start + 1


  getStep: (index) ->
    @sequence[index]

  setStep: (index, value) ->
    @sequence[index] = value if 0 <= index < STEPS


  # Given a clock index (in steps) return the active step in this pattern,
  # taking into account the start and end step.
  #
  stepIndexForClock: (clock) ->
    if clock >= 0 then (clock % @length) + @start else -1

  getStepForClock: (clock) ->
    @getStep(@stepIndexForClock clock)


  # Given a note in the form of a JS object:
  # {
  #   pitch: <MIDI pitch (0-127)>,
  #   velocity: <MIDI velocity (0-127)>,
  #   duration: <pulses/quarter note beats (float)>
  # }
  # modify the note for this pattern's value at the given clock index.
  # Returns the note.
  #
  processNote: (note, clock) ->
    value = @getStepForClock(clock)
    @_process(note, value) if value > 0
    note

  @processors =
    gate:     (note, value) -> note.duration *= value
    pitch:    (note, value) -> note.pitch += value
    velocity: (note, value) -> note.velocity *= (1 + 0.2*value)
    octave:   (note, value) -> note.pitch += (if value <= 2 then value*12 else (value-2)*-12)
