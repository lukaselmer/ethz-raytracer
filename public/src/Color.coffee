class Color
  constructor: (r, g, b) ->
    if r instanceof Vector
      g = r.elements[1]
      b = r.elements[2]
      r = r.elements[0]
    r = 0 if r < 0
    g = 0 if g < 0
    b = 0 if b < 0
    r = 1 if r > 1
    g = 1 if g > 1
    b = 1 if b > 1
    @val = $V([r, g, b])
  add: (color) ->
    new Color(@val.add(color.val))
  multiply: (scale) ->
    new Color(@val.multiply(scale))
  multiplyColor: (color) ->
    new Color(@val.elements[0] * color.val.elements[0], @val.elements[1] * color.val.elements[1],
      @val.elements[2] * color.val.elements[2])
  toArray: ->
    @val.dup().elements
  toVector: ->
    @val.dup()
