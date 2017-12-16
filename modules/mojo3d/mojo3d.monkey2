
Namespace mojo3d

#Import "<std>"
#Import "<mojo>"
#Import "<opengl>"

#Import "assets/"

#Import "components/animation"
#Import "components/animator"
#Import "components/behaviour"
#Import "components/flybehaviour"

#Import "entities/camera"
#Import "entities/light"
#Import "entities/model"
#Import "entities/particlebuffer"
#Import "entities/particlematerial"
#Import "entities/particlesystem"
#Import "entities/renderable"
#Import "entities/sprite"

#Import "render/deferredrenderer"
#Import "render/forwardrenderer"
#Import "render/material"
#Import "render/renderer"
#Import "render/renderqueue"
#Import "render/spritebuffer"
#Import "render/posteffect"

#Import "render/materials/pbrmaterial"
#Import "render/materials/spritematerial"
#Import "render/materials/watermaterial"

#Import "render/effects/fogeffect"
#Import "render/effects/monochromeeffect"
#Import "render/effects/bloomeffect"

#Import "scene/component"
#Import "scene/dynamicobject"
#Import "scene/entity"
#Import "scene/entityexts"
#Import "scene/scene"

#Import "loader/loader"
#Import "loader/gltf2"
#Import "loader/gltf2loader"

#Import "geometry/mesh"
#Import "geometry/meshprims"
'#Import "geometry/util3d"

Using std..
Using mojo..
Using opengl..

Function Main()
	
#If __DESKTOP_TARGET__
	
	SetConfig( "MOJO_OPENGL_PROFILE","compatibility" )

	SetConfig( "MOJO3D_DEFAULT_RENDERER","deferred" )
	
#Elseif __WEB_TARGET__

	SetConfig( "MOJO_OPENGL_PROFILE","es" )

	SetConfig( "MOJO3D_DEFAULT_RENDERER","deferred" )
	
#Elseif __MOBILE_TARGET__
	
	SetConfig( "MOJO_OPENGL_PROFILE","es" )

	SetConfig( "MOJO3D_DEFAULT_RENDERER","forward" )
	
	SetConfig( "MOJO3D_FORWARD_RENDERER_DIRECT",1 )
	SetConfig( "MOJO_DEPTH_BUFFER_BITS",16 )
	
#endif
	
End
