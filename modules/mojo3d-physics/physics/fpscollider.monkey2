
Namespace mojo3d.physics

Private

Function F:String( f:Float )
	If f>=0 
		Local i:Int=Floor( f*100+.5 )
		Return String( i / 100 ) + "." + ("00"+String( i Mod 100 )).Slice( -2 )
	Else
		Local i:Int=Floor( -f*100+.5 )
		Return "-"+String( i / 100 ) + "." + ("00"+String( i Mod 100 )).Slice( -2 )
	Endif
End

Function V:String( V:Vec3f )
	'Return String(V)
	Return "("+F(V.x)+","+F(V.y)+","+F(V.z)+")"
End

Function P:String( P:Planef )
	Return "("+F(P.n.x)+","+F(P.n.y)+","+F(P.n.z)+","+F(P.d)+")"
End

Public

Struct QResult
	Field position:Vec3f
	Field onground:Bool
End

Function QCollide:QResult( collider:ConvexCollider,src:Vec3f,dst:Vec3f )
	
	Local start:=src
	
	Local plane0:Planef,plane1:Planef,state:=0,casts:=0
	
	Local qresult:QResult
	
	Local debug:=""
	
	Repeat

		If dst.Distance( src )<.001 Exit
		
		casts+=1
		
		Local world:=World.GetCurrent()
		
		Local cresult:=world.ConvexSweep( collider,src,dst )
		If Not cresult Exit

'		debug+=", "
		
		If cresult.normal.y>.7071 qresult.onground=True
			
		Local plane:=New Planef( cresult.point,cresult.normal )

		plane.d-=collider.Margin
		
		Local tline:=New Linef( src,dst-src )
		
		Local t:=plane.TIntersect( tline )
		
		If t>=1 dst=tline * t ; Exit
		
		If t>0 src=tline * t
		
		Select state

		Case 0
			
			dst=plane.Nearest( dst )
			
'			debug+="A "+P( plane )
				
			plane0=plane
				
			state=1
		
		Case 1

			Local v:=plane0.n.Cross( plane.n )
			
			If v.Length>.0001
				
				Local groove:=New Linef( src,v )
				
'				Local d0:=plane0.Distance( dst )
				
				dst=groove.Nearest( dst )
				
'				debug+="B "+P( plane )+" d0="+F(d0)+" sd0="+F(plane0.Distance(src))+" dd0="+F(plane0.Distance(dst))
				
				plane1=plane
				
				state=2
			
			Else
				
'				debug+="C "+P( plane )

				dst=plane.Nearest( dst )

				plane0=plane
				
				state=1
			
			Endif
				
		Case 2

'			Local d0:=plane0.Distance( dst )
'			Local d1:=plane1.Distance( dst )
'			debug+="D "+P( plane )+" d0="+F(d0)+" d1="+F(d1)
				
			dst=src
			
			Exit
		End

	Forever
	
'	If casts>2 Print debug.Slice( 2 )+" casts="+casts

	qresult.position=dst
	
	Return qresult

End

Public

Class FPSCollider Extends CapsuleCollider
	
	Method New( entity:Entity )
		Super.New( entity )
		
		_src=Entity.Position
	End
	
	Property Gravity:Float()
		
		Return _gravity
	
	Setter( gravity:Float )
		
		_gravity=gravity
	End
	
	Property YVelocity:Float()
		
		Return _yvel
		
	Setter( yvel:Float )
		
		_onground=False
			
		_yvel=yvel
	End
	
	Property OnGround:Bool()
		
		Return _onground
	End
	
	Method Reset()
		_src=Entity.Position
		_yvel=0
		_onground=False
	End
	
	Method OnBeginUpdate() Override
		
		_src=Entity.Position
	End
	
	Method OnUpdate( elapsed:Float ) Override
		
		Local qresult:=QCollide( Self,_src,Entity.Position )

		Entity.Position=qresult.position
		
		_src=Entity.Position
		
		If _onground _yvel=-Margin
			
		_yvel-=_gravity/60.0/60.0

		Entity.MoveY( _yvel )

		qresult=QCollide( Self,_src,Entity.Position )

		Entity.Position=qresult.position
		
		_yvel=Entity.Position.y-_src.y
		
		_onground=qresult.onground
	End
	
	Private
	
	Field _gravity:Float=30
	
	Field _yvel:Float
	
	Field _onground:Bool
	
	Field _src:Vec3f
	
End

