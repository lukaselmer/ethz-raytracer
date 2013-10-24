### Random log ###
console.setRlog = (p = 0.0001) ->
  @shoulLog = Math.random() <= p
console.rlog = (msg) ->
  return unless @shoulLog
  console.log(msg)

Math.square = (num) -> num * num

Math.solveN2 = (a, b, c) ->
  under_root = ((b * b) - (4 * a * c))
  return null if under_root < 0 or a is 0 or b is 0 # or c is 0

  root = Math.sqrt(under_root)
  t1 = (-b + root) / (2 * a)
  t2 = (-b - root) / (2 * a)
  return [t2, t2] if t1 < RayConfig.intersectionDelta
  return [t1, t1] if t2 < RayConfig.intersectionDelta
  [t1, t2]
