
Namespace mojo3d

Class Entity Extension
	
	Property Animator:Animator()
		
		Return GetComponent<Animator>()
	End
	
End

#rem monkeydoc The Animator class.
#end
Class Animator Extends Component
	
	Const Type:=New ComponentType( "Animator",0,ComponentTypeFlags.Singleton )
	
	Method New( entity:Entity )
		Super.New( entity,Type )
	End
	
	Method New( entity:Entity,animator:Animator )
		Self.New( entity )

		_skeleton=animator._skeleton.Slice( 0 )
		For Local i:=0 Until _skeleton.Length
			_skeleton[i]=_skeleton[i].LastCopy
		End
		_animations=animator._animations
		_playing=animator._playing
		_paused=animator._paused
		_speed=animator._speed
		_time=animator._time
	End
	
	Property Skeleton:Entity[]()
		
		Return _skeleton
		
	Setter( skeleton:Entity[] )
		
		_skeleton=skeleton
	End
	
	Property Animations:Stack<Animation>()
		
		Return _animations
		
	Setter( animations:Stack<Animation> )
		
		_animations=animations
	End
	
	Property Playing:Bool()
		
		Return _playing<>Null
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
	
	Method Animate( animationId:Int,speed:Float=1.0 )
		
		DebugAssert( animationId>=0 And animationId<_animations.Length,"Animation id out of range" )
		
		_playing=_animations[animationId]
		
		_speed=speed
		
		_time=0
	End
	
	Method Stop()
		
		_playing=Null
	End
	
	Protected
	
	Method OnCopy:Animator( entity:Entity ) Override
		
		Return New Animator( entity,Self )
	End
	
	Method OnUpdate( elapsed:Float ) Override
		
		If _paused  Or Not _playing Return
		
		Local hertz:=_playing.Hertz
		Local timeScale:=1.0/hertz

		_time+=elapsed * _speed
		
		If _time>=_playing.Duration * timeScale _time-=_playing.Duration * timeScale Else If _time<0 _time+=_playing.Duration * timeScale
			
		For Local i:=0 Until _playing.Channels.Length
			
			Local channel:=_playing.Channels[i]
			If Not channel continue
			
			_skeleton[i].LocalPosition=channel.GetPosition( _time * hertz )
			_skeleton[i].LocalBasis=New Mat3f( channel.GetRotation( _time * hertz ) )
			_skeleton[i].LocalScale=channel.GetScale( _time * hertz )
		End
	End
	
	Private
	
	Field _skeleton:Entity[]
	Field _animations:=New Stack<Animation>
	Field _playing:Animation
	Field _paused:Bool=False
	Field _speed:Float=1
	Field _time:Float=0
	
End
