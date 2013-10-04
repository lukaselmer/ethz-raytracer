# TODO
# you can declare global variables here
# ...


# 0. set up the scene described in the exercise sheet (this is called before the rendering loop)
this.loadScene = () ->
  # TODO...

this.trace = (color, pixelX, pixelY) ->
  # 1. shoot a ray determined from the camera parameters and the pixel position in the image
  # 2. intersect the ray to scene elements and determine the closest one
  # 3. check if the intersection point is illuminated by each light source
  # 4. shade the intersection point using the meterial attributes and the lightings
  # 5. set the pixel color into the image buffer using the computed shading (for now set dummy color into the image buffer)
  color.setElements([  pixelX / width, pixelY / height, pixelX * pixelY / (width * height) ]);
