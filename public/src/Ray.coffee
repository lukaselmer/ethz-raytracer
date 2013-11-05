class Ray
  constructor: (@line, @refraction, @power, @eye) ->
  isInside: () ->
    @refraction != 1
