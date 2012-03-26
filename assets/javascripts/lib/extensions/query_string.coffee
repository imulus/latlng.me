@queryString = do ->
  pairs = {}
  for pair in window.location.search.replace('?', '').split('&')
    p = pair.split('=')
    if p[0]? and p[1]?
      pairs[p[0]] = p[1]
  return pairs