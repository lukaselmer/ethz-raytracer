class Camera
  constructor: (@position, @direction, @upDirection, @distance, @fieldOfView, @width, @height) ->
    this.calibrateCamera()

  calibrateCamera: () ->
    @direction = @direction.toUnitVector()
    @rightDirection = @direction.cross(@upDirection)
    @imagePaneHeight = 2 * Math.tan(@fieldOfView / 2) * @distance
    @imagePaneWidth = @imagePaneHeight / @height * @width
    @imageCenter = @position.add(@direction.multiply(@distance))
