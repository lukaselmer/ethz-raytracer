### Random log ###
console.setRlog = (p = 0.01) ->
  @shoulLog = Math.random() <= p
console.rlog = (msg) ->
  return unless @shoulLog
  console.log(msg)
