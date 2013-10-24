class Camera
  constructor: (@position, @direction, @upDirection, @distance, @fieldOfView, @width, @height) ->
    this.calibrateCamera()

  calibrateCamera: () ->
    @direction = @direction.toUnitVector()
    @rightDirection = @direction.cross(@upDirection) #.toUnitVector()
    #@upDirection = @rightDirection.cross(@direction).toUnitVector()
    @imagePaneHeight = 2 * Math.tan(@fieldOfView / 2) * @distance
    @imagePaneWidth = @imagePaneHeight / @height * @width

    @imageCenter = @position.add(@direction.multiply(@distance))
  #@imageTop = @imageCenter.add(@upDirection.multiply(@imagePaneHeight / 2))
  #@imageBottom = @imageCenter.add(@upDirection.multiply(-1 * @imagePaneHeight / 2))
  #@imageLeft = @imageCenter.add(@rightDirection.multiply(-1 * @imagePaneWidth / 2))
  #@imageRight = @imageCenter.add(@rightDirection.multiply(@imagePaneWidth / 2))

  getCenter: () ->
    @imageCenter
    #@position.add(@direction)
