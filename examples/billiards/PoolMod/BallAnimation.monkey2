#Import "PoolMod"

Class ObjectAnimation
	Field P:PVector2D
	Field color:Color

	Method Reset:Void() Abstract
	Method Render:Void(canvas:Canvas) Abstract
End

Class AImageLineStained Extends ObjectAnimation
	Field angle:Float
	Field Length:Float
	Field image:Image
	
	Method New(P:PVector2D,vx:Float,vy:Float,image:Image,color:Color)
		Self.P=P
		Self.angle=-(ATan2(vy,vx))
		Self.Length=Sqrt(vx*vx+vy*vy)
		Self.image=image
		Self.color=color
	End

	Method Reset:Void() Override
	End

	Method Render:Void(canvas:Canvas) Override
		canvas.Color = color
		canvas.DrawImage(image,P.x,P.y,angle,Length,1.0)
	End
End

Class APixelLine Extends ObjectAnimation
	Field vx:Float
	Field vy:Float

	Method New(P:PVector2D,vx:Float,vy:Float,color:Color)
		self.P = P
		self.vx= vx
		self.vy= vy
		self.color=color
	End Method
	
	Method Reset:Void() Override
	End Method

	Method Rotate:Void(vx:Float,vy:float)
	End Method
	
	Method Render:Void(canvas:Canvas) Override
		canvas.Color = color
		canvas.DrawLine(P.x,P.y,P.x+vx,P.y+vy)
	End Method
	
End Class

Class AImageArcStained Extends ObjectAnimation
	Field image:Image

	Method New(P:PVector2D,image:Image,color:Color)

		self.P=P
		self.image=image
		self.color = color
		
	End Method
	
	Method Reset:Void() Override
	End Method
	
	Method Rotate:Void(vx:Float,vy:float)
	End Method
	
	Method Render:Void(canvas:Canvas) Override
		canvas.Color = color
		canvas.DrawImage(image,P.x,P.y) ',0)
	End Method
	
End Class

Class APixelArc Extends ObjectAnimation
	Field radius:Float
	Field startAngle:Float
	Field endAngle:Float
	Field stp:Float

	Method New(P:PVector2D,radius:Float,startAngle:Float,endAngle:Float,color:Color)
		Self.P=P
		self.radius=radius
		self.startAngle=startAngle
		self.endAngle=endAngle
		self.color = color
		Self.stp=1.0/(RTA * radius)
	End Method
	
	Method Reset:Void() Override
	End Method
	
	Method Rotate:Void(vx:Float,vy:float)
	End Method
	
	Method Render:Void(canvas:Canvas) Override
	
		canvas.Color = color
		
		If(startAngle = endAngle)
			Return
		Endif
		
		Local angle:Float=endAngle - startAngle
		Local AccumAngle:Float=startAngle
		Local rad2:Float=radius*2.0
		
		While(AccumAngle < startAngle+angle)
			canvas.DrawRect(P.x+Cos(AccumAngle*ATR)*radius-0.5,P.y+Sin(AccumAngle*ATR) * radius-0.5,1.0,1.0)
			AccumAngle += stp
		Wend
		
	End Method
	
End Class

Class Vec2D
	Field x:Float
	Field y:Float
	Field len:Float
	Field dx:Float
	Field dy:Float

	Method New(x1:Float, y1:Float, x2:Float, y2:Float)
		x = x1
		y = y1
		
		Local vx:Float = x2 - x1
		Local vy:Float = y2 - y1
		
		If (vx<>0.0) Or (vy <> 0.0)
			len = Sqrt(vx*vx + vy*vy)
			dx = vx / len
			dy = vy / len
		Else
			len = 0.0
			dx  = 0.0
			dy  = 0.0
		Endif
		
	End Method
	
End Class


Class Wall
	Field name:String=""
	Field image:Image
	Field x1:Float
	Field y1:Float
	Field color:Color
End

Class Arc Extends Wall
	Field radius:Float
	Field startAngle:Float
	Field endAngle:Float
	Field cx:Float
	Field cy:Float
	
	Method New(x1:Float,y1:Float,radius:Float,startAngle:Float,endAngle:Float,colx:Float,coly:Float,image:Image,color:Color)
		Self.name="Arc"
		Self.image=image
		Self.radius=radius
		Self.startAngle=startAngle
		Self.endAngle=endAngle
		Self.x1=x1
		Self.y1=y1
		Self.cx=colx
		Self.cy=coly
		Self.color=color
	End

End

Class Line Extends Wall
	Field x2:Float
	Field y2:Float
	
	Method New(x1:Float,y1:Float,x2:Float,y2:Float,image:Image,color:Color)
		Self.name="Line"
		Self.image=image
		Self.x1=x1
		Self.y1=y1
		Self.x2=x2
		Self.y2=y2
		Self.color=color
	End

End

Class ABall3D Extends ObjectAnimation
	Field oldP:PVector2D=New PVector2D()
	Field textColor:Color
	Field ball3d:Ball3d
	Field image:Image
	Method New(P:PVector2D,radius:Float,image:Image,ballColor:Color,textColor:Color,number:Int)
		Self.P=P
		Self.oldP.x=P.x
		Self.oldP.y=P.y
		Self.color= ballColor
		Self.textColor= textColor
		If number<16 ball3d = New Ball3d(number,radius-1.0)
		Self.image=image
	End

	Method Rotate:Void(vx:Float,vy:Float)
		If ball3d ball3d.Rotate(vx,vy)
	End
	
	Method Reset:Void() Override
		If ball3d ball3d.Reset()
	End
	
	Method Render:Void(canvas:Canvas) Override
		canvas.Color = New Color(0.0,0.0,0.0)
		canvas.Alpha = .3
		canvas.DrawImage(Self.image,P.x+3.0,P.y-1.0,0)
		canvas.Alpha = 1.0
		canvas.Color = color
		canvas.DrawImage(image,P.x,P.y,0)
		canvas.Color = textColor
		If ball3d ball3d.Display(canvas,P.x,P.y)
	End
End

Class Ball3d
	Field distance:Float
	Field radius:Float
	Field nodeList:List<Node3d>
	Global numbers:Int[][][]
	
	Method Decorate:Void(n:Int)
		If(n=0)
			Return
		End
		Local s:String=String(n)
		Local len:Float=(s.Length)
		For Local i:Float=0.0 Until len
			Local t:Int=s[i]-48
			For Local yaw:Float=0.0 Until 8.0
				For Local pitch:Float=0.0 Until 5.0
					If numbers[t][yaw][pitch]
						Local node:Node3d= New Node3d()
						node.z= -Cos((-20.0 + yaw*7.0)*ATR)*Cos((-20.0+pitch*7.0)*ATR)*(radius-1.0)
						node.y=  Cos((-20.0 * len+i*32.0+yaw*7.0)*ATR)*Sin((-20.0*len+i*30.0+pitch*8.0)*ATR)*(radius-1.0)
						node.x=  Sin((-20.0 + yaw*7.0)*ATR)*(radius-1.0)
						node.sx=node.x
						node.sy=node.y
						node.sz=node.z
						node.link=nodeList.AddLast(node)
						Local node2:Node3d=New Node3d()
						node2.x=node.x
						node2.y=-node.y
						node2.z=-node.z
						node2.sx=node2.x
						node2.sy=node2.y
						node2.sz=node2.z
						node2.link=nodeList.AddLast(node2)
					End
				End
			End
		End
		If(n>8)
			For Local i2:Float=0.0 Until 360.0
				Local node3:Node3d= New Node3d()
				node3.x=Cos(0.0)*Cos(i2*ATR)*radius
				node3.y=Cos(0.0)*Sin(i2*ATR)*radius
				node3.z=Sin(0.0)*radius
				node3.sx=node3.x
				node3.sy=node3.y
				node3.sz=node3.z
				node3.link=nodeList.AddLast(node3)
			End
		End
	End
	
	Method New(n:Int,rad:Float)
		distance=500.0
		radius=rad
		nodeList=New List<Node3d>()
		If Not numbers.Length
			numbers=New Int[][][](New Int[][](New Int[](0,0,1,1,0),New Int[](0,1,0,0,1),New Int[](0,1,0,0,1),New Int[](0,1,0,0,1),New Int[](0,1,0,0,1),New Int[](0,1,0,0,1),New Int[](0,0,1,1,0),New Int[](0,0,0,0,0)),
							 	  New Int[][](New Int[](0,0,1,0,0),New Int[](0,1,1,0,0),New Int[](0,0,1,0,0),New Int[](0,0,1,0,0),New Int[](0,0,1,0,0),New Int[](0,0,1,0,0),New Int[](0,1,1,1,0),New Int[](0,0,0,0,0)),
							  	  New Int[][](New Int[](0,1,1,1,0),New Int[](0,1,0,0,1),New Int[](0,0,0,0,1),New Int[](0,0,0,1,0),New Int[](0,0,1,0,0),New Int[](0,1,0,0,0),New Int[](0,1,1,1,1),New Int[](0,0,0,0,0)),
							  	  New Int[][](New Int[](0,1,1,1,0),New Int[](0,0,0,0,1),New Int[](0,0,0,0,1),New Int[](0,0,1,1,0),New Int[](0,0,0,0,1),New Int[](0,0,0,0,1),New Int[](0,1,1,1,0),New Int[](0,0,0,0,0)),
							  	  New Int[][](New Int[](0,0,0,1,0),New Int[](0,0,1,1,0),New Int[](0,1,0,1,0),New Int[](1,0,0,1,0),New Int[](1,1,1,1,1),New Int[](0,0,0,1,0),New Int[](0,0,0,1,0),New Int[](0,0,0,0,0)),
							  	  New Int[][](New Int[](0,1,1,1,1),New Int[](0,1,0,0,0),New Int[](0,1,0,0,0),New Int[](0,0,1,1,0),New Int[](0,0,0,0,1),New Int[](0,0,0,0,1),New Int[](0,1,1,1,0),New Int[](0,0,0,0,0)),
							  	  New Int[][](New Int[](0,0,1,1,0),New Int[](0,1,0,0,0),New Int[](0,1,0,0,0),New Int[](0,1,0,1,0),New Int[](0,1,0,0,1),New Int[](0,1,0,0,1),New Int[](0,0,1,1,0),New Int[](0,0,0,0,0)),
							  	  New Int[][](New Int[](0,1,1,1,1),New Int[](0,0,0,0,1),New Int[](0,0,0,1,0),New Int[](0,0,1,0,0),New Int[](0,0,1,0,0),New Int[](0,0,1,0,0),New Int[](0,0,1,0,0),New Int[](0,0,0,0,0)),
							  	  New Int[][](New Int[](0,0,1,1,0),New Int[](0,1,0,0,1),New Int[](0,1,0,0,1),New Int[](0,0,1,1,0),New Int[](0,1,0,0,1),New Int[](0,1,0,0,1),New Int[](0,0,1,1,0),New Int[](0,0,0,0,0)),
							  	  New Int[][](New Int[](0,0,1,1,0),New Int[](0,1,0,0,1),New Int[](0,1,0,0,1),New Int[](0,0,1,1,1),New Int[](0,0,0,0,1),New Int[](0,1,0,0,1),New Int[](0,0,1,1,0),New Int[](0,0,0,0,0)))
		End
		Decorate(n)
	End

	Method Rotate_z(a:Float)
		If nodeList.Empty Return
		Local cx:Float=Cos(a*ATR)
		Local cy:Float=Sin(a*ATR)
		Local link:List<Node3d>.Node=nodeList.First.link
		While link.Value
			Local node:Node3d=link.Value
			Local tx:Float=node.x*cx-node.y*cy
			Local ty:Float=node.x*cy+node.y*cx
			node.y=ty
			node.x=tx
			link=link.Succ
		End
	End
	
	Method Rotate_y(a:Float)
		If nodeList.Empty Return
		Local cx:Float=Cos(a*ATR)
		Local cy:Float=Sin(a*ATR)
		Local link:List<Node3d>.Node = nodeList.FirstNode()
		While link.Value
			Local node:Node3d=link.Value
			Local tz:Float=node.z*cx-node.x*cy
			Local tx:Float=node.z*cy+node.x*cx
			node.z=tz
			node.x=tx
			link=link.Succ
		End
	End
	
	Method Rotate(vx:Float,vy:Float)
		Local roll:Float=Sqrt(vx*vx+vy*vy)
		Local rot:Float= ATan2(vy,vx) * RTA
		Self.Rotate_z(-rot)
		Self.Rotate_y(roll*radius)
		Self.Rotate_z(rot)
	End
	
	Method Reset()
		If nodeList.Empty Return
		Local link:List<Node3d>.Node=nodeList.FirstNode()
		While link.Value
			Local node:Node3d=link.Value
			node.x=node.sx
			node.y=node.sy
			node.z=node.sz
			link=link.Succ
		End
	End
	
	Method Display:Void(canvas:Canvas,x:Float,y:Float)
		If nodeList.Empty Return
		Local link:List<Node3d>.Node=nodeList.FirstNode()
		While link.Value
			Local node:Node3d=link.Value
			If(node.z>-1.0) canvas.DrawOval(x+node.x,y+node.y,1.0,1.0)
			link=link.Succ
		End
	End
End

Class Node3d
	Field z:Float
	Field y:Float
	Field x:Float
	Field sx:Float
	Field sy:Float
	Field sz:Float
	Field link:List<Node3d>.Node
End

Class RailAnimation
	Field jobList:List<Ball>
	Field settledList:List<RailBall>
	Field movingList:List<RailBall>
	Field stopPVector2Ds:Vec2D[]
	Field finalStop:Int=0
	Field showStops:Int=0
	Field index:Int=0

	Method New()
		jobList= New List<Ball>
		settledList= New List<RailBall>
		movingList= New List<RailBall>
		stopPVector2Ds=New Vec2D[](New Vec2D(375.0,340.0,366.0,370.0),New Vec2D(366.0,370.0,355.0,380.0),New Vec2D(355.0,380.0,325.0,380.0),
						 		   New Vec2D(325.0,380.0,305.0,380.0),New Vec2D(305.0,380.0,285.0,380.0),New Vec2D(285.0,380.0,265.0,380.0),
						 		   New Vec2D(265.0,380.0,245.0,380.0),New Vec2D(245.0,380.0,225.0,380.0),New Vec2D(225.0,380.0,205.0,380.0),
						 		   New Vec2D(205.0,380.0,185.0,380.0),New Vec2D(185.0,380.0,165.0,380.0),New Vec2D(165.0,380.0,145.0,380.0),
						 		   New Vec2D(145.0,380.0,125.0,380.0),New Vec2D(125.0,380.0,105.0,380.0),New Vec2D(105.0,380.0, 85.0,380.0),
						 		   New Vec2D( 85.0,380.0, 65.0,380.0),New Vec2D( 65.0,380.0, 45.0,380.0),New Vec2D( 45.0,380.0, 25.0,380.0),
						 		   New Vec2D( 25.0,380.0, 25.0,380.0))
		finalStop=18
	End
	
	Method ShowStops:Void(show:Int)
		showStops=show
	End
	
	Method Reset:Void()
		jobList.Clear()
		movingList.Clear()
		settledList.Clear()
		index=0
		finalStop=18
	End
	
	Method AddJob:Void(b:Ball)
		jobList.AddFirst(b)
	End
	
	Method RemoveCueBall:Void()
		If Not jobList.Empty
			For Local b:Ball = Eachin jobList
				If(b.num=16)
					jobList.RemoveEach(b)
					Return
				End
			End
		End
		If Not movingList.Empty
			For Local b2:RailBall = Eachin movingList
				If(b2.ball.num=16)
					movingList.RemoveEach(b2)
					Return
				End
			End
		End
		If Not settledList.Empty
			For Local b3:RailBall = Eachin settledList
				If(b3.ball.num=16)
					settledList.RemoveEach(b3)
					finalStop=b3.index
				End
			End
		End
		If Not settledList.Empty
			Local c:Int=0
			For Local b4:RailBall = Eachin settledList.Backwards()
				If(b4.index<finalStop)
					settledList.RemoveEach(b4)
					movingList.AddLast(b4)
				End
			End
		End
	End
	
	Method Update:Void(spd:Float)
		If movingList.Empty And jobList.Empty
			Return
		End
		If movingList.Empty
			Local b:Ball=jobList.RemoveLast()
			If(b<>Null)
				Local rb:RailBall=New RailBall(b,stopPVector2Ds[0].x,stopPVector2Ds[0].y)
				movingList.AddLast(rb)
			End
		Else
			If  Not jobList.Empty
				Local rb2:RailBall=movingList.Last
				If((rb2)<>Null)
					Local vx1:Float=rb2.ball.P.x-stopPVector2Ds[0].x
					Local vy1:Float=rb2.ball.P.y-stopPVector2Ds[0].y
					Local dp:Float=vx1*stopPVector2Ds[0].dx+vy1*stopPVector2Ds[0].dy
					If(Abs(dp)>rb2.ball.radius+20.0)
						Local b2:Ball=jobList.RemoveLast()
						movingList.AddLast(New RailBall(b2,stopPVector2Ds[0].x,stopPVector2Ds[0].y))
					End
				End
			End
		End
		Local vx:Float=.0
		Local vy:Float=.0
		For Local rb3:RailBall = Eachin movingList
			vx=stopPVector2Ds[rb3.index].dx*spd
			vy=stopPVector2Ds[rb3.index].dy*spd
			rb3.ball.P.x+=vx
			rb3.ball.P.y+=vy
		End
		For Local rb4:RailBall = Eachin movingList
			If(rb4.index<finalStop)
				Local vx12:Float=rb4.ball.P.x-stopPVector2Ds[rb4.index].x
				Local vy12:Float=rb4.ball.P.y-stopPVector2Ds[rb4.index].y
				Local dp1:Float=vx12*stopPVector2Ds[rb4.index].dx+vy12*stopPVector2Ds[rb4.index].dy
				If(Abs(dp1)>=stopPVector2Ds[rb4.index].len)
					Local len:Float=Abs(dp1)-stopPVector2Ds[rb4.index].len
					vx12=stopPVector2Ds[rb4.index].dx*stopPVector2Ds[rb4.index].len
					vy12=stopPVector2Ds[rb4.index].dy*stopPVector2Ds[rb4.index].len
					rb4.ball.P.x=stopPVector2Ds[rb4.index].x+vx12
					rb4.ball.P.y=stopPVector2Ds[rb4.index].y+vy12
					rb4.animation.Rotate(vx*1.2,vy*1.2)
					rb4.index+=1
					If(rb4.index=finalStop)
						movingList.RemoveEach(rb4)
						settledList.AddLast(rb4)
						rb4.animation.Rotate(vx*1.2,vy*1.2)
						If(finalStop<18)
							media.PlayBallCol(2)
						End
						finalStop-=1
					Else
						vx12=stopPVector2Ds[rb4.index].dx*len
						vy12=stopPVector2Ds[rb4.index].dy*len
						rb4.ball.P.x+=stopPVector2Ds[rb4.index].dx*len
						rb4.ball.P.y+=stopPVector2Ds[rb4.index].dy*len
					End
				Else
					rb4.animation.Rotate(vx,vy)
				End
			Else
				If(rb4.index=finalStop)
					movingList.RemoveEach(rb4)
					rb4.index=finalStop
					rb4.ball.P.x=stopPVector2Ds[finalStop].x
					rb4.ball.P.y=stopPVector2Ds[finalStop].y
					settledList.AddLast(rb4)
				End
			End
		End
	End
	
	Method Render:Void(canvas:Canvas)
		If showStops=1
			canvas.Color = New Color(.95,.95,.4) '(240.0,240.0,100.0)
			Local i:Int=0
			While(i < stopPVector2Ds.Length)
				Local stop:Vec2D=stopPVector2Ds[i]
				canvas.DrawCircle(stop.x,stop.y,3.0)
				canvas.DrawLine(stop.x,stop.y,stop.x+stop.dx*stop.len,stop.y+stop.dy*stop.len)
				i=i+1
			End
		End
		For Local railBall:RailBall = Eachin settledList
			railBall.Render(canvas)
		End
		For Local moving:RailBall = Eachin movingList
			moving.Render(canvas)
		End
	End
End

Class RailBall
	Field ball:Ball
	Field index:Int=0
	Field animation:ABall3D
	Method New(b:Ball,x:Float,y:Float)
		b.P.x=x
		b.P.y=y
		ball=b
		animation=Cast<ABall3D>(b.animation)
		index=0
	End

	Method Render:Void(canvas:Canvas)
		ball.Render(canvas)
	End
End
