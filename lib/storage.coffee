# The interface to the pattr persistence system in Max
class Storage

  constructor: (@sequencer) ->


  load: (path, values...) ->
    sequencer = @sequencer

    if(path == 'dump') # we're done
      sequencer.redraw()
      return

    # paths look like:
    # track.1::basePitch 60.
    # track.1::pattern.1::sequence 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    # track.1::pattern.1::ptype gate
    # track.1::pattern.1::start 0
    # track.1::pattern.1::end 63
    matches =/^track\.(\d+)::(.*)/.exec(path)
    return unless matches?

    trackIndex = parseInt(matches[1]) - 1
    subpath = matches[2]
    track = sequencer.tracks[trackIndex]
    return unless track?

    val = values[0]

    switch subpath
      when 'basePitch'     then track.basePitch     = parseInt val
      when 'baseVelocity'  then track.baseVelocity  = parseInt val
      when 'durationScale' then track.durationScale = parseFloat val

      else
        matches = /^pattern\.(\d+)::(.*)/.exec(subpath)
        return unless matches?

        patternIndex = parseInt(matches[1]) - 1
        property = matches[2]
        pattern = track.patterns[patternIndex]
        return unless pattern?

        switch property
          when 'ptype'    then pattern.setType val
          when 'start'    then pattern.setStart val
          when 'end'      then pattern.setEnd val
          when 'sequence' then sequencer.setPattern trackIndex, patternIndex, values


  save: ->
    tracks = @sequencer.tracks
    for trackIndex in [0...TRACKS]
      track = tracks[trackIndex]
      outlet(3, track.basePitch, track.baseVelocity, track.durationScale, trackIndex+1)

      patterns = track.patterns
      for patternIndex in [0...PATTERNS]
        pattern = patterns[patternIndex]
        outlet(4,
          pattern.type, pattern.start, pattern.end, pattern.sequence,
          patternIndex+1, trackIndex+1
        )
