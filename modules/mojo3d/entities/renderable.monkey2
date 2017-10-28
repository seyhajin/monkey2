
Namespace mojo3d

Class Renderable Extends Entity Abstract

	Method New( parent:Entity=Null )
	
		Super.New( parent )
		
		Show()
	End
	
	Property CastsShadow:bool()
	
		Return _castsShadow
	
	Setter( castsShadow:Bool )
	
		_castsShadow=castsShadow
	End
	
	Protected
	
	Method New( renderable:Renderable,parent:Entity )
	
		Super.New( renderable,parent )
		
		_castsShadow=renderable.CastsShadow
		
		Show()
	End
	
	Method OnShow() Override
		
		Scene.Renderables.Add( Self )
	End
	
	Method OnHide() Override
		
		Scene.Renderables.Remove( Self )
	End
	
	Internal
	
	Method OnRender( rq:RenderQueue ) Abstract
	
	Private
	
	Field _castsShadow:Bool=True
	
End
