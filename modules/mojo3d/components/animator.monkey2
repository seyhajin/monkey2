
Namespace mojo3d

#rem monkeydoc The Animator class.
#end
Class Animator Extends Component
	
	Const Type:=New ComponentType( "Animator",0,ComponentTypeFlags.Singleton )
	
	Method New( entity:Entity )
		
		Super.New( entity,Type )
	End
	
	Property Animations:Animation[]()
		
		Return _animations
		
	Setter( animations:Animation[] )
		
		_animations=animations
	End
	
	Property Entities:Entity[]()
	
		Return _entities
	
	Setter( entities:Entity[] )
		
		_entities=entities
	End
	
	Property Paused:Bool()
		
		Return _paused
	
	Setter( paused:Bool )
		
		_paused=paused
	End
	
	Property Speed:Float()
		
		Return _speed
	
	Setter( speed:Float )
		
		_speed=speed
	End
	
	Property Time:Float()
		
		Return _time
	
	Setter( time:Float )
		
		_time=time
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
	
	Method OnUpdate( elapsed:Float ) Override
		
		If _paused  or not _animations Return
		
		Local anim:=_animations[0]
		
		_time+=anim.Hertz*elapsed
		
		If _time>=anim.Duration _time-=anim.Duration Else If _time<0 _time+=anim.Duration
			
		Animate( 0,_time )
	End
	
	Private

	Field _animations:Animation[]

	Field _entities:Entity[]
	
	Field _paused:Bool=True
	
	Field _speed:Float=1
	
	Field _time:Float=0
	
End
