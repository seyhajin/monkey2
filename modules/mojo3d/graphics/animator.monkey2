
Namespace mojo3d.graphics

#rem monkeydoc The Animator class.
#end
Class Animator
	
	Method New( animations:Animation[],entities:Entity[] )

#rem		
		For Local i:=0 Until animations.Length
			Print "anim["+i+"].Channels="+animations[i].Channels.Length
			Print "anim["+i+"].Duration="+animations[i].Duration
			Print "anim["+i+"].Hertz="+animations[i].Hertz
		Next			
		Print "entities="+entities.Length
#end		
		_animations=animations
		
		_entities=entities
	End
	
	Property Animations:Animation[]()
		
		Return _animations
	End
	
	Property Entities:Entity[]()
		
		Return _entities
	End
	
	Method Animate( animationId:Int,time:Float )
		
		Local animation:=_animations[animationId]

		For Local i:=0 Until animation.Channels.Length
			
			Local channel:=animation.Channels[i]
			If Not channel continue
			
			_entities[i].LocalPosition=channel.GetPosition( time )
			_entities[i].LocalBasis=New Mat3f( channel.GetRotation( time ) )
			_entities[i].LocalScale=channel.GetScale( time )
		End
		
	End
	
	Private

	Field _animations:Animation[]

	Field _entities:Entity[]
	
End
