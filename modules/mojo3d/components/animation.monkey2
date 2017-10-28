
Namespace mojo3d

#rem monkeydoc @hidden
#end
Alias PositionKey:AnimationKey<Vec3f>

#rem monkeydoc @hidden
#end
Alias RotationKey:AnimationKey<Quatf>

#rem monkeydoc @hidden
#end
Alias ScaleKey:AnimationKey<Vec3f>

#rem monkeydoc @hidden
#end
Class Animation
	
	Method New( channels:AnimationChannel[],duration:Float,hertz:Float )
		
		_channels=channels
		
		_duration=duration
		
		_hertz=hertz
	End
	
	Property Channels:AnimationChannel[]()
		
		Return _channels
	End
	
	Property Duration:Float()
		
		Return _duration
	End
	
	Property Hertz:Float()
		
		Return _hertz
	End
	
	Private
	
	Field _channels:AnimationChannel[]
	Field _duration:Float
	Field _hertz:Float
	
End

#rem monkeydoc @hidden
#end
Class AnimationChannel
	
	Method New( posKeys:PositionKey[],rotKeys:RotationKey[],sclKeys:ScaleKey[] )
		
		_posKeys=posKeys
		_rotKeys=rotKeys
		_sclKeys=sclKeys
	End
	
	Property PositionKeys:PositionKey[]()
		
		Return _posKeys
	End
	
	Property RotationKeys:RotationKey[]()
		
		Return _rotKeys
	End
	
	Property ScaleKeys:ScaleKey[]()
	
		Return _sclKeys
	End
	
	Method GetPosition:Vec3f( time:Float )
		
		If Not _posKeys Return New Vec3f( 0 )
		
		Return GetKey( _posKeys,time )
	End
	
	Method GetRotation:Quatf( time:Float )
		
		If Not _rotKeys Return New Quatf( 0,0,0,1 )
		
		Return GetKey( _rotKeys,time )
	End
	
	Method GetScale:Vec3f( time:Float )
		
		If Not _sclKeys Return New Vec3f( 1 )
		
		Return GetKey( _sclKeys,time )
	End
	
	Method GetMatrix:AffineMat4f( time:Float )
		
		Local pos:=GetPosition( time )
		Local rot:=GetRotation( time )
		Local scl:=GetScale( time )
		
		Return New AffineMat4f( Mat3f.Rotation( rot ).Scale( scl ),pos )
	End
	
	Private
	
	Field _posKeys:PositionKey[]
	Field _rotKeys:RotationKey[]
	Field _sclKeys:ScaleKey[]
	
	Method Blend:Vec3f( a:Vec3f,b:Vec3f,alpha:Float )
		
		Return a.Blend( b,alpha )
	End
	
	Method Blend:Quatf( a:Quatf,b:Quatf,alpha:Float )
		
		Return a.Slerp( b,alpha )
	End
	
	Method GetKey<T>:T( keys:AnimationKey<T>[],time:Float )
		
		DebugAssert( keys )
		
		Local pkey:AnimationKey<T>
		
		For Local key:=Eachin keys
			
			If time<=key.Time
				
				If pkey Return Blend( pkey.Value,key.Value,(time-pkey.Time)/(key.Time-pkey.Time) )
				
				Return key.Value
				
			Endif
			
			pkey=key
		End
		
		Return pkey.Value
	End

End

#rem monkeydoc @hidden
#end
Class AnimationKey<T>
	
	Method New( time:Float,value:T )
		
		_time=time
		_value=value
	End
	
	Property Time:Float()
		
		Return _time
	End
	
	Property Value:T()
		
		Return _value
	End

	Private
		
	Field _time:float
	Field _value:T
End


