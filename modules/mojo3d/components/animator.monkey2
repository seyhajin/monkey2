
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
	
	Method Animate( animationId:Int,speed:Float=1.0,transition:Float=0.0 )
		
		DebugAssert( animationId>=0 And animationId<_animations.Length,"Animation id out of range" )
		
		Local anim:=_animations[animationId]
		If anim<>_playing
			If _playing And transition>0
				_playing0=_playing
				_speed0=_speed
				_time0=_time
				_transdur=transition
				_transtime=0
				_trans=True
			Else
				_trans=False
			Endif
			_playing=anim
			_speed=speed
			_time=0
		Endif
		
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
		
		Local blend:=0.0
		
		If _trans
			_transtime+=elapsed
			If _transtime<_transdur
				blend=_transtime/_transdur
			Else
				_trans=False
			Endif
		Endif
		
		_time=UpdateTime( _playing,_time,_speed,elapsed )
		
		If _trans
			_time0=UpdateTime( _playing0,_time0,_speed0,elapsed )
			UpdateSkeleton( _playing0,_time0,_playing,_time,blend )
		Else
			UpdateSkeleton( _playing,_time,Null,0,0 )
		Endif
		
	End
	
	Private
	
	Field _skeleton:Entity[]
	Field _animations:=New Stack<Animation>
	Field _paused:Bool=False
	
	Field _transtime:Float
	Field _transdur:Float
	Field _trans:Bool
	
	Field _playing0:Animation
	Field _speed0:Float
	Field _time0:Float
	
	Field _playing:Animation
	Field _speed:Float
	Field _time:Float

	Method UpdateTime:Float( playing:Animation,time:Float,speed:Float,elapsed:Float )

		Local period:=1.0/playing.Hertz
	
		time+=elapsed * speed
	
		If time>=playing.Duration * period time-=playing.Duration * period Else If time<0 time+=playing.Duration * period
			
		Return time
	End
	
	Method UpdateSkeleton( playing0:Animation,time0:Float,playing1:Animation,time1:Float,alpha:Float )
		
		time0*=playing0?.Hertz
		time1*=playing1?.Hertz
		
		For Local i:=0 Until _skeleton.Length
			
			Local chan0:=playing0 ? playing0.Channels[i] Else Null
			Local chan1:=playing1 ? playing1.Channels[i] Else Null
			
			If playing0 And playing1
				
				Local pos0:=chan0 ? chan0.GetPosition( time0 ) Else New Vec3f
				Local rot0:=chan0 ? chan0.GetRotation( time0 ) Else New Quatf
				Local scl0:=chan0 ? chan0.GetScale( time0 ) Else New Vec3f( 1 )
				
				Local pos1:=chan1 ? chan1.GetPosition( time1 ) Else New Vec3f
				Local rot1:=chan1 ? chan1.GetRotation( time1 ) Else New Quatf
				Local scl1:=chan1 ? chan1.GetScale( time1 ) Else New Vec3f( 1 )

				_skeleton[i].LocalPosition=pos0.Blend( pos1,alpha )
				_skeleton[i].LocalBasis=rot0.Slerp( rot1,alpha )
				_skeleton[i].LocalScale=scl0.Blend( scl1,alpha )
			
			Else If playing0
				
				Local pos0:=chan0 ? chan0.GetPosition( time0 ) Else New Vec3f
				Local rot0:=chan0 ? chan0.GetRotation( time0 ) Else New Quatf
				Local scl0:=chan0 ? chan0.GetScale( time0 ) Else New Vec3f( 1 )
			
				_skeleton[i].LocalPosition=pos0
				_skeleton[i].LocalBasis=rot0
				_skeleton[i].LocalScale=scl0

			Else If playing1

				Local pos1:=chan1 ? chan1.GetPosition( time1 ) Else New Vec3f
				Local rot1:=chan1 ? chan1.GetRotation( time1 ) Else New Quatf
				Local scl1:=chan1 ? chan1.GetScale( time1 ) Else New Vec3f( 1 )

				_skeleton[i].LocalPosition=pos1
				_skeleton[i].LocalBasis=rot1
				_skeleton[i].LocalScale=scl1
			
			Endif
		
		Next
	End

End
