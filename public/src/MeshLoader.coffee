class MeshLoader
  constructor: (@resp, @position, @scale) ->
    @obj = new Mesh(@position, @scale)

  createMesh: () ->
    this.loadMesh(@obj, @resp)
    @obj.generateTriangles()
    @obj.computeNormals()
    @obj

  loadMesh: (mesh, data) ->
    # v float float float
    vertex_pattern = /v( +[\d|\.|\+|\-|e]+)( +[\d|\.|\+|\-|e]+)( +[\d|\.|\+|\-|e]+)/
    # f vertex vertex vertex
    face_pattern1 = /f( +\d+)( +\d+)( +\d+)/
    # f vertex/uv vertex/uv vertex/uv
    face_pattern2 = /f( +(\d+)\/(\d+))( +(\d+)\/(\d+))( +(\d+)\/(\d+))/
    # f vertex/uv/normal vertex/uv/normal vertex/uv/normal
    face_pattern3 = /f( +(\d+)\/(\d+)\/(\d+))( +(\d+)\/(\d+)\/(\d+))( +(\d+)\/(\d+)\/(\d+))/
    # f vertex//normal vertex//normal vertex//normal
    face_pattern4 = /f( +(\d+)\/\/(\d+))( +(\d+)\/\/(\d+))( +(\d+)\/\/(\d+))/

    lines = data.split("\n")
    i = 0
    while i < lines.length
      line = lines[i]
      line = line.trim()
      result = undefined
      if line.length == 0 || line.charAt(0) == "#" || line.charAt( 0 ) == '//'
        i++
        continue
      else if (result = vertex_pattern.exec(line)) isnt null
        # ["v 1.0 2.0 3.0", "1.0", "2.0", "3.0"]
        mesh.V.push $V([parseFloat(result[1]), parseFloat(result[2]), parseFloat(result[3])])
      else if (result = face_pattern1.exec(line)) isnt null
        # ["f 1 2 3", "1", "2", "3"]
        mesh.F.push $V([parseInt(result[1]) - 1, parseInt(result[2]) - 1, parseInt(result[3]) - 1])
      else if (result = face_pattern2.exec(line)) isnt null
        # ["f 1/1 2/2 3/3", " 1/1", "1", "1", " 2/2", "2", "2", " 3/3", "3", "3"]
        mesh.F.push $V([parseInt(result[2]) - 1, parseInt(result[5]) - 1, parseInt(result[8]) - 1])
      else if (result = face_pattern3.exec(line)) isnt null
        # ["f 1/1/1 2/2/2 3/3/3", " 1/1/1", "1", "1", "1", " 2/2/2", "2", "2", "2", " 3/3/3", "3", "3", "3"]
        mesh.F.push $V([parseInt(result[2]) - 1, parseInt(result[6]) - 1, parseInt(result[10]) - 1])
        # ["f 1//1 2//2 3//3", " 1//1", "1", "1", " 2//2", "2", "2", " 3//3", "3", "3"]
      else mesh.F.push $V([parseInt(result[2]) - 1, parseInt(result[5]) - 1, parseInt(result[8]) - 1])  if (result = face_pattern4.exec(line)) isnt null
      i++

  @loadMeshData: (path) ->
    console.log "Reading OBJ file: " + path
    req = new XMLHttpRequest()
    req.open "GET", path, false
    req.send null
    req.response
