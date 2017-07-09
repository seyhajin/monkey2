
Namespace mojo3d.graphics

Class Renderable Extends Entity Abstract

	Method New( parent:Entity=Null )
		Super.New( parent )
	End
	
	Method New( renderable:Renderable,parent:Entity )
		Super.New( renderable,parent )
	End
	
	'***** INTERNAL *****
	
	Method OnRender( device:GraphicsDevice ) Abstract
	
End
