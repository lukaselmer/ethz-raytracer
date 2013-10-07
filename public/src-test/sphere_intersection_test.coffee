GreeterTest = TestCase("GreeterTest")

GreeterTest.prototype.testGreet = () ->
  loadScene()
  color = $V([0, 0, 0])
  trace(color, 0, 0)
