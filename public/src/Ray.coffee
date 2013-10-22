class Ray
  constructor: (@line, @refraction, @power) ->
  isInside: () ->
    @refraction != 1