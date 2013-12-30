Hummingbird.utils.wilsonScore = (pos, n) ->
  if n == 0
    return 0

  # z=1.96 corresponds to confidence=0.95
  # z=2.17 corresponds to confidence=0.97
  z = 1.96

  phat = 1.0 * pos / n
  (phat + z*z/(2*n) - z * Math.sqrt((phat*(1-phat)+z*z/(4*n))/n))/(1+z*z/n)
