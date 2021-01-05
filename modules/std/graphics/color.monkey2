
Namespace std.graphics

using std.geom

'new jl added function
#rem monkeydoc Allows a colors to be defined using integer values 0..255 instead of 0..1
#end
Function ColorI:Color( red:Float, green:Float, blue:Float, alpha:float = 255 )
	Return New Color( red / 255, green / 255, blue / 255, alpha / 255)
End


#rem monkeydoc The Color type provides support for manipulating red, green blue, alpha colors.
#end
Struct Color

'jl added
#-		
	Const C64Black:=New Color( .1,.1,.1 )
	Const C64White:=New Color( .98,.98,.98 )
	Const C64Liver:=New Color( .41,.20,.18 )
	Const C64Cyan:=New Color( .43,.23,.52 )
	Const C64Purple:=New Color( .43,.23,.52 )
	Const C64Green:=New Color( .33,.56,.25 )
	Const C64Blue:=New Color( .19,.16,.48 )
	Const C64Yellow:=New Color( .73,.76,.43 )
	Const C64Brown:=New Color( .42,.31,.15 )
	Const C64DarkBrown:=New Color( .27,.21,.0 )
	Const C64Pink:=New Color( .58,.40,.35 )
	Const C64Charcoal:=New Color( .26,.26,.26 )
	Const C64Grey:=New Color( .41,.42,.43 )
	Const C64Lime:=New Color( .59,.82,.52 )
	Const C64Morello:=New Color( .42,.36,.71 )
	Const C64Silver:=New Color( .58,.58,.58 )

	Const LabWhite := New Color( .94,.94,.94 )
	Const LabNeutral8 := New Color( .78,.78,.78 )
	Const LabNeutral65 := New Color( .62,.62,.62 )
	Const LabNeutral5 := New Color( .47,.47,.47 )
	Const LabNeutral36 := New Color( .33,.33,.33 )
	Const LabBlack := New Color( .2,.2,.2 )
	Const LabBlue := New Color( .21,.23,.58 )
	Const LabGreen := New Color( .27,.58,.28 )
	Const LabRed := New Color( .68,.21,.23 )
	Const LabYellow := New Color( .90,.78,.12 )
	Const LabMagenta := New Color( .73,.33,.76 )
	Const LabCyan := New Color( .03,.52,.63 )
	Const LabOrange := New Color( .83,.49,.17 )
	Const LabPurpleRed := New Color( .31,.35,.65 )
	Const LabModerateRed := New Color( .75,.35,.38 )
	Const LabPurple := New Color( .36,.23,.42 )
	Const LabYellowGreen := New Color( .61,.73,.25 )
	Const LabOrangeYellow := New Color( .87,.63,.18 )
	Const LabDarkSkin := New Color( .45,.32,.26 )
	Const LabLightSkin := New Color( .76,.58,.50 )
	Const LabBlueSky := New Color( .38,.47,.61 )
	Const LabFoliage := New Color( .34,.42,.26 )
	Const LabBlueFlower := New Color( .52,.50,.69 )
	Const LabBluishGreen := New Color( .40,.72,.66 )
		

	#rem monkeydoc Transparent black.
	#end
	Const None:=New Color( 0,0,0,0 )
	
	#rem monkeydoc Black.
	#end
	Const Black:=New Color( 0,0,0 )
	
	#rem monkeydoc Grey.
	#end
	Const Grey:=New Color( .5,.5,.5 )
	
	#rem monkeydoc Light Grey.
	#end
	Const LightGrey:=New Color( .75,.75,.75 )
	
	#rem monkeydoc Dark Grey.
	#end
	Const DarkGrey:=New Color( .25,.25,.25 )
	
	#rem monkeydoc White.
	#end
	Const White:=New Color( 1,1,1 )
	
	#rem monkeydoc Red.
	#end
	Const Red:=New Color( 1,0,0 )
	
	#rem monkeydoc Red.
	#end
	Const Blood := New Color( 0.4,0,0 )

	#rem monkeydoc Green.
	#end
	Const Green:=New Color( 0,1,0 )
	
	#rem monkeydoc Blue.
	#end
	Const Blue:=New Color( 0,0,1 )
	
	#rem monkeydoc Brown.
	#end
	Const Brown:=New Color( .7,.4,.1 )
	
	#rem monkeydoc Orange.
	#end
	Const Orange:=New Color( 1,.5,0 )
	
	#rem monkeydoc Yellow.
	#end
	Const Yellow:=New Color( 1,1,0 )
	
	#rem monkeydoc Lime.
	#end
	Const Lime:=New Color( .7,1,0 )
	
	#rem monkeydoc Pine.
	#end
	Const Pine:=New Color( 0,.5,0 )
	
	#rem monkeydoc Aqua.
	#end
	Const Aqua:=New Color( 0,.9,.4 )
	
	#rem monkeydoc Cyan.
	#end
	Const Cyan:=New Color( 0,1,1 )
	
	#rem monkeydoc Sky.
	#end
	Const Sky:=New Color( 0,.5,1 )
	
	#rem monkeydoc Steel.
	#end
	Const Steel:=New Color( .2,.2,.7 )
	
	#rem monkeydoc Violet.
	#end
	Const Violet:=New Color( .7,0,1 )
	
	#rem monkeydoc Magenta.
	#end
	Const Magenta:=New Color( 1,0,1 )
	
	#rem monkeydoc Puce.
	#end
	Const Puce:=New Color( 1,0,.4 )
	
	#rem monkeydoc Skin.
	#end
	Const Skin:=New Color( .8,.5,.6 )
	
	#rem monkeydoc Pink.
	#end
	Const Pink:=New Color( 1,.75,.8 )
	
	#rem monkeydoc HotPink.
	#end
	Const HotPink:=New Color( 1,.41,.71 )
	
	#rem monkeydoc Silver.
	#end
	Const Silver:=New Color( .971519,.959915,.915324,1 )
	
	#rem monkeydoc Aluminum.
	#end
	Const Aluminum:=New Color( .913183,.921494,.924524,1 )
	Const Aluminium:=New Color( .913183,.921494,.924524,1 )

	Const Brass:Color = ColorI( 250, 230, 150 )
	Const Iron:Color = ColorI( 196, 200, 200 )

	Const Coal:Color = ColorI( 50, 50, 50 )
	Const Rubber:Color = ColorI( 53, 53, 53 )
	Const Mud:Color = ColorI( 85, 61, 49 )
	Const Grass:Color = ColorI( 123, 130, 78 )
	Const Brick:Color = ColorI( 148, 125, 117 )
	Const Wood:Color = ColorI( 170, 153, 132 )
	Const Concrete:Color = ColorI( 192, 192, 187 )
	Const Asphalt:Color = ColorI( 91, 91, 91 )
	Const ClayTile:Color = ColorI( 200, 124, 101 )
	Const DrySand:Color = ColorI( 177, 167, 132 )
	Const Cement:Color = ColorI( 192, 191, 187 )
	Const Paint:Color = ColorI( 227, 227, 227 )
	Const Snow:Color = ColorI( 243, 243, 243 )
	
	#rem monkeydoc Gold.
	#end
	Const Gold:=New Color( 1,.765557,.336057,1 )
	
	#rem monkeydoc Copper.
	#end
	Const Copper:=New Color( .955008,.637427,.538163,1 )
	
	#rem monkeydoc Chromium.
	#end
	Const Chromium:=New Color( .549585,.556114,.554256,1 )
	
	#rem monkeydoc Nickel.
	#end
	Const Nickel:=New Color( .659777,.608679,.525649,1 )
	
	#rem monkeydoc Titanium.
	#end
	Const Titanium:=New Color( .541931,.496791,.449419,1 )
	
	#rem monkeydoc Cobalt.
	#end
	Const Cobalt:=New Color( .662124,.654864,.633732,1 )
	
	#rem monkeydoc Platinum.
	#end
	Const Platinum:=New Color( .672411,.637331,.585456,1 )
	
	
	#rem monkeydoc SeaGreen.
	#end
	Const SeaGreen:=New Color( .031372,.301960,.247058,1 )



	#rem monkeydoc UIDarkGrey.
	#end
	Const UIDarkGrey := New Color( .15,.15,.15 )

	#rem monkeydoc UICharcoal.
	#end
	Const UICharcoal := New Color( .24,.23,.23 )

	#rem monkeydoc UISilver.
	#end
	Const UISilver := New Color( .74,.73,.73 )

	#rem monkeydoc UIBlue.
	#end
	Const UIBlue := New Color( .0,.4,.9 )

	#rem monkeydoc UIPaleBlue.
	#end
	Const UIPaleBlue := New Color( .56,.78,.85 )

	#rem monkeydoc UIDarkBlue.
	#end
	Const UIDarkBlue := New Color( .24,.35,.58 )

	#rem monkeydoc UIOrange.
	#end
	Const UIOrange := New Color( .86,.61,.13 )

	#rem monkeydoc UIBurntOrange.
	#end
	Const UIBurntOrange := New Color( .79,.31,0 )

	#rem monkeydoc UIDarkOrange.
	#end
	Const UIDarkOrange := New Color( .52,.26,.09 )

	#rem monkeydoc UIPurple.
	#end
	Const UIPurple := New Color( .61,.36,.72 )

	#rem monkeydoc UICyan.
	#end
	Const UICyan := New Color( .25,.60,.82 )

	#rem monkeydoc UILightGreen.
	#end
	Const UILightGreen := New Color( .32,.80,.31 )

	#rem monkeydoc UILavender.
	#end
	Const UILavender := New Color( .51,.58,.93 )

	#rem monkeydoc UIVibrantGreen.
	#end
	Const UIVibrantGreen := New Color( .09,.87,.07 )

	#rem monkeydoc UIFontBlue.
	#end
	Const UIFontBlue := New Color( .11,.57,.96 )

	#rem monkeydoc UIBrown.
	#end
	Const UIBrown := New Color( .62,.31,.01 )

	#rem monkeydoc UIGreen.
	#end
	Const UIGreen := New Color( .2,.6,.19 )

	#rem monkeydoc UILeaf.
	#end
	Const UILeaf := New Color( .21,.43,.17 )

	#rem monkeydoc UILime.
	#end
	Const UILime := New Color( .54,.74,.14 )

	#rem monkeydoc UIMagenta.
	#end
	Const UIMagenta := New Color( .99,.01,.59 )

	#rem monkeydoc UIMango.
	#end
	Const UIMango := New Color( .94,.58,.03 )

	#rem monkeydoc UIPink.
	#end
	Const UIPink := New Color( .90,.44,.72 )

	#rem monkeydoc UIRed.
	#end
	Const UIRed := New Color( .89,.07,.01 )

	#rem monkeydoc UIYellow.
	#end
	Const UIYellow := New Color( .89,.87,.01 )

	#rem monkeydoc UITeal.
	#end
	Const UITeal := New Color( .18,.65,.52 )


	#rem monkeydoc PicoBlack.
	#end
	Const PicoBlack := New Color( .1,.1,.1 )

	#rem monkeydoc PicoBrown.
	#end
	Const PicoBrown := New Color( .67,.32,.21 )

	#rem monkeydoc PicoRed.
	#end
	Const PicoRed := New Color( .92,.1,.31 )

	#rem monkeydoc PicoCyan.
	#end
	Const PicoCyan := New Color( .31,.65,.86 )

	#rem monkeydoc PicoBlue.
	#end
	Const PicoBlue := New Color( .1,.16,.32 )

	#rem monkeydoc PicoDirt.
	#end
	Const PicoDirt := New Color( .37,.34,.3 )

	#rem monkeydoc PicoOrange.
	#end
	Const PicoOrange := New Color( .98,.63,.1 )

	#rem monkeydoc PicoPurple.
	#end
	Const PicoPurple := New Color( .51,.46,.61 )

	#rem monkeydoc PicoMaroon.
	#end
	Const PicoMaroon := New Color( .49,.14,.32 )

	#rem monkeydoc PicoSilver.
	#end
	Const PicoSilver := New Color( .76,.76,.77 )

	#rem monkeydoc PicoYellow.
	#end
	Const PicoYellow := New Color( .96,.92,.18 )

	#rem monkeydoc PicoPink.
	#end
	Const PicoPink := New Color( .94,.46,.65 )

	#rem monkeydoc PicoGreen.
	#end
	Const PicoGreen := New Color( 0,.52,.31 )

	#rem monkeydoc PicoWhite.
	#end
	Const PicoWhite := New Color( .99,.94,.91 )

	#rem monkeydoc PicoLime.
	#end
	Const PicoLime := New Color( .36,.73,.3 )

	#rem monkeydoc PicoSkin.
	#end
	Const PicoSkin := New Color( .98,.8,.87 )


	#rem monkeydoc XamCoral.
	#end
	Const XamCoral := New Color( .95,.26,.21 )

	#rem monkeydoc XamPink.
	#end
	Const XamPink := New Color( .91,.11,.38 )

	#rem monkeydoc XamPurple.
	#end
	Const XamPurple := New Color( .61,.15,.69 )

	#rem monkeydoc XamViolet.
	#end
	Const XamViolet := New Color( .4,.22,.71 )

	#rem monkeydoc XamBlue.
	#end
	Const XamBlue := New Color( .24,.17,.7 )

	#rem monkeydoc XamSky.
	#end
	Const XamSky := New Color( .12,.58,.95 )

	#rem monkeydoc XamWater.
	#end
	Const XamWater := New Color( .01,.66,.95 )

	#rem monkeydoc XamAqua.
	#end
	Const XamAqua := New Color( 0,.73,.83 )

	#rem monkeydoc XamPine.
	#end
	Const XamPine := New Color( 0,.58,.53 )

	#rem monkeydoc XamMint.
	#end
	Const XamMint := New Color( .54,.76,.29 )

	#rem monkeydoc XamGreen.
	#end
	Const XamGreen := New Color( .29,.68,.31 )

	#rem monkeydoc XamLime.
	#end
	Const XamLime := New Color( .8,.86,.22 )

	#rem monkeydoc XamYellow.
	#end
	Const XamYellow := New Color( 1,.92,.23 )

	#rem monkeydoc XamPeach.
	#end
	Const XamPeach := New Color( 1,.75,.03 )

	#rem monkeydoc XamOrange.
	#end
	Const XamOrange := New Color( 1,.59,.01 )

	#rem monkeydoc XamEmber.
	#end
	Const XamEmber := New Color( 1,.38,.13 )

	#rem monkeydoc XamBrown.
	#end
	Const XamBrown := New Color( .47,.33,.28 )

	#rem monkeydoc XamSilver.
	#end
	Const XamSilver := New Color( .61,.61,.61 )

	#rem monkeydoc XamSteel.
	#end
	Const XamSteel := New Color( .37,.49,.54 )


	#rem monkeydoc VicBlack.
	#end
	Const VicBlack := New Color( .1,.1,.1 )

	#rem monkeydoc VicGrey.
	#end
	Const VicGrey := New Color( .61,.61,.61 )

	#rem monkeydoc VicWhite.
	#end
	Const VicWhite := New Color( .96,.96,.96 )

	#rem monkeydoc VicRed.
	#end
	Const VicRed := New Color( .74,.14,.2 )

	#rem monkeydoc VicLiver.
	#end
	Const VicLiver := New Color( .45,.16,.18 )

	#rem monkeydoc VicBlush.
	#end
	Const VicBlush := New Color( .87,.43,.54 )

	#rem monkeydoc VicPink.
	#end
	Const VicPink := New Color( .79,.26,.65 )

	#rem monkeydoc VicDirt.
	#end
	Const VicDirt := New Color( .28,.23,.16 )

	#rem monkeydoc VicBrown.
	#end
	Const VicBrown := New Color( .64,.39,.13 )

	#rem monkeydoc VicKhaki.
	#end
	Const VicKhaki := New Color( .67,.61,.2 )

	#rem monkeydoc VicOrange.
	#end
	Const VicOrange := New Color( .92,.53,.19 )

	#rem monkeydoc VicFire.
	#end
	Const VicFire := New Color( .92,.27,0 )

	#rem monkeydoc VicLemon.
	#end
	Const VicLemon := New Color( .96,.88,.41 )

	#rem monkeydoc VicPeach.
	#end
	Const VicPeach := New Color( .98,.70,.4 )

	#rem monkeydoc VicPine.
	#end
	Const VicPine := New Color( .06,.36,.2 )

	#rem monkeydoc VicGreen.
	#end
	Const VicGreen := New Color( .26,.36,.1 )

	#rem monkeydoc VicLime.
	#end
	Const VicLime := New Color( .63,.80,.15 )

	#rem monkeydoc VicOil.
	#end
	Const VicOil := New Color( .18,.28,.3 )

	#rem monkeydoc VicSea.
	#end
	Const VicSea := New Color( .07,.5,.49 )

	#rem monkeydoc VicAqua.
	#end
	Const VicAqua := New Color( .08,.76,.64 )

	#rem monkeydoc VicRoyal.
	#end
	Const VicRoyal := New Color( .13,.35,.96 )

	#rem monkeydoc VicBlue.
	#end
	Const VicBlue := New Color( .15,.49,.66 )

	#rem monkeydoc VicBlue.
	#end
	Const VicBue := New Color( 0,.34,.52 )

	#rem monkeydoc VicSky.
	#end
	Const VicSky := New Color( .19,.63,.94 )

	#rem monkeydoc VicSteel.
	#end
	Const VicSteel := New Color( .69,.86,.92 )

	#rem monkeydoc VicPurple.
	#end
	Const VicPurple := New Color( .2,.16,.59 )

	#rem monkeydoc VicViolet.
	#end
	Const VicViolet := New Color( .6,.39,.97 )

	#rem monkeydoc VicCandy.
	#end
	Const VicCandy := New Color( .96,.55,.97 )

	#rem monkeydoc VicSkin.
	#end
	Const VicSkin := New Color( .95,.72,.56 )


	#rem monkeydoc ExLightGrey.
	#end
	Const ExLightGrey := New Color( .75,.75,.75 )

	#rem monkeydoc ExDarkGrey.
	#end
	Const ExDarkGrey := New Color( .25,.25,.25 )

	#rem monkeydoc ExBrown.
	#end
	Const ExBrown := New Color( .62,.31,0 )

	#rem monkeydoc ExTreeTrunk.
	#end
	Const ExTreeTrunk := New Color( .31,.23,.17 )

	#rem monkeydoc ExLime.
	#end
	Const ExLime := New Color( .54,.74,.14 )

	#rem monkeydoc ExMango.
	#end
	Const ExMango := New Color( .94,.58,.03 )

	#rem monkeydoc ExOrange.
	#end
	Const ExOrange := New Color( .79,.32,0 )

	#rem monkeydoc ExPink.
	#end
	Const ExPink := New Color( .79,.44,.72 )

	#rem monkeydoc ExPurple.
	#end
	Const ExPurple := New Color( .41,.13,.48 )

	#rem monkeydoc ExLeaf.
	#end
	Const ExLeaf := New Color( .2,.6,.2 )

	#rem monkeydoc ExYolk.
	#end
	Const ExYolk := New Color( 1,.65,0 )

	#rem monkeydoc ExPeach.
	#end
	Const ExPeach := New Color( 1,.8,.01 )

	#rem monkeydoc ExSand.
	#end
	Const ExSand := New Color( .94,.87,.7 )

	#rem monkeydoc ExWetSand.
	#end
	Const ExWetSand := New Color( .73,.66,.48 )

	#rem monkeydoc ExNavy.
	#end
	Const ExNavy := New Color( .09,.15,.44 )

	#rem monkeydoc ExMorello.
	#end
	Const ExMorello := New Color( .6,.34,.71 )

	#rem monkeydoc ExTeal.
	#end
	Const ExTeal := New Color( .22,.43,.5 )

	#rem monkeydoc ExSky.
	#end
	Const ExSky := New Color( .2,.59,.85 )

	#rem monkeydoc ExSlime.
	#end
	Const ExSlime := New Color( .18,.8,.44 )

	#rem monkeydoc ExMint.
	#end
	Const ExMint := New Color( .08,.62,.52 )

	#rem monkeydoc ExSilver.
	#end
	Const ExSilver := New Color( .74,.76,.76 )

	#rem monkeydoc ExGold.
	#end
	Const ExGold := New Color( .83,.66,.29 )

	#rem monkeydoc ExForest.
	#end
	Const ExForest := New Color( .17,.31,.21 )

	#rem monkeydoc ExPlum.
	#end
	Const ExPlum := New Color( .36,.2,.36 )

	#rem monkeydoc ExWatermellon.
	#end
	Const ExWatermellon := New Color( .85,.32,.32 )

	#rem monkeydoc ExAvocado.
	#end
	Const ExAvocado := New Color( .55,.69,.12 )

	#rem monkeydoc ExBubblegum.
	#end
	Const ExBubblegum := New Color( .83,.36,.61 )

	#rem monkeydoc ExMaroon.
	#end
	Const ExMaroon := New Color( .47,.18,.16 )

	#rem monkeydoc ExCoffee.
	#end
	Const ExCoffee := New Color( .55,.44,.36 )

	#rem monkeydoc ExLavender.
	#end
	Const ExLavender := New Color( .6,.67,.83 )

	#rem monkeydoc ExPowder.
	#end
	Const ExPowder := New Color( .72,.78,.94 )

	#rem monkeydoc ExPigeon.
	#end
	Const ExPigeon := New Color( .22,.29,.5 )

	#rem monkeydoc ExUmber.
	#end
	Const ExUmber := New Color( .7,.53,0 )

  #rem monkeydoc ExBuff.
	#end
	Const ExBuff := New Color( .84,.77,.64 )

	#rem monkeydoc ExCobble.
	#end
	Const ExCobble := New Color( .47,.38,.33 )

	#rem monkeydoc ExAqua.
	#end
	Const ExAqua := New Color( .59,.67,.68 )

	#rem monkeydoc ExSewer.
	#end
	Const ExSewer := New Color( .78,.78,.59 )

	#rem monkeydoc ExDragon.
	#end
	Const ExDragon := New Color( .8,.38,.5 )

	#rem monkeydoc ExEmber.
	#end
	Const ExEmber := New Color( .74,.47,.34 )

	#rem monkeydoc ExOlive.
	#end
	Const ExOlive := New Color( .52,.6,.1 )

	#rem monkeydoc ExCorn.
	#end
	Const ExCorn := New Color( .91,.8,.32 )

	#rem monkeydoc ExHoney.
	#end
	Const ExHoney := New Color( .95,.48,.59 )

	#rem monkeydoc ExPhlox.
	#end
	Const ExPhlox := New Color( .52,.25,.51 )

	#rem monkeydoc ExKhaki.
	#end
	Const ExKhaki := New Color( .59,.56,.39 )

	#rem monkeydoc ExNougat.
	#end
	Const ExNougat := New Color( .83,.73,.62 )
#-
	
	#rem monkeydoc Red component of color.
	#end
	Field r:Float

	#rem monkeydoc Green component of color.
	#end
	Field g:Float
	#rem monkeydoc Blue component of color.
	#end
	Field b:Float
	
	#rem monkeydoc Alpha component of color.
	#end
	Field a:Float
	
	#rem monkeydoc Creates a new color.
	#end
	Method New( a:Float=1 )
		Self.a=a
	End
	
	Method New( i:Float,a:Float=1 )
		Self.r=i
		Self.g=i
		Self.b=i
		Self.a=a
	End
	
	Method New( r:Float,g:Float,b:Float,a:Float=1 )
		Self.r=r
		Self.g=g
		Self.b=b
		Self.a=a
	End
	
	Method New( v:geom.Vec4f )
		Self.r=v.x
		Self.g=v.y
		Self.b=v.z
		Self.a=v.w
	End
	
	#rem monkeydoc Converts the color to a printable string.
	#end
	Operator To:String()
		Return "Color("+r+","+g+","+b+","+a+")"
	End
	
	#rem monkeydoc Converts the color to float 4 vector.
	#end
	Operator To:geom.Vec4f()
		Return New Vec4f( r,g,b,a )
	End

	#rem monkeydoc The Red color component.
	#end
	Property R:Float()
		Return r
	Setter( r:Float )
		Self.r=r
	End
	
	#rem monkeydoc The green color component.
	#end
	Property G:Float()
		Return g
	Setter( g:Float )
		Self.g=g
	End
	
	#rem monkeydoc The blue color component.
	#end
	Property B:Float()
		Return b
	Setter( b:Float )
		Self.b=b
	End
	
	#rem monkeydoc The alpha color component.
	#end
	Property A:Float()
		Return a
	Setter( a:Float )
		Self.a=a
	End
	
	#rem monkeydoc Multiplies the color by another color or value and returns the result.
	#end
	Operator*:Color( color:Color )
		Return New Color( r*color.r,g*color.g,b*color.b,a*color.a )
	End

	Operator*:Color( scale:Float )
		Return New Color( r*scale,g*scale,b*scale,a*scale )
	End
	
	#rem monkeydoc Divides the color by another color or value and returns the result.
	#end
	Operator/:Color( color:Color )
		Return New Color( r/color.r,g/color.g,b/color.b,a/color.a )
	End

	Operator/:Color( scale:Float )
		Return New Color( r/scale,g/scale,b/scale,a/scale )
	End

	#rem monkeydoc Adds another color or value to the color and returns the result.
	#end
	Operator+:Color( color:Color )
		Return New Color( r+color.r,g+color.g,b+color.b,a+color.a )
	End

	Operator+:Color( offset:Float )
		Return New Color( r+offset,g+offset,b+offset,a+offset )
	End

	#rem monkeydoc Subtracts another color or value from the color and returns the result.
	#end
	Operator-:Color( color:Color )
		Return New Color( r-color.r,g-color.g,b-color.b,a-color.a )
	End

	Operator-:Color( offset:Float )
		Return New Color( r-offset,g-offset,b-offset,a-offset )
	End
	
	#rem monkeydoc Blends the color with another color and returns the result.
	#end	
	Method Blend:Color( color:Color,delta:Float )
		Local idelta:=1-delta
		Return New Color( r*idelta+color.r*delta,g*idelta+color.g*delta,b*idelta+color.b*delta,a*idelta+color.a*delta )
	End

	#rem monkeydoc Converts the color to 32 bit big endian ARGB format.
	
	Big endian ARGB is the same as little endian BGRA.
	
	#end	
	Method ToARGB:UInt()
		Return UInt(a*255) Shl 24 | UInt(r*255) Shl 16 | UInt(g*255) Shl 8 | UInt(b*255)
	End

	#rem monkeydoc Converts the color to 32 bit big endian BGRA format.

	Big endian BGRA is the same as little endian ARGB.
	
	#end	
	Method ToBGRA:UInt()
		Return UInt(b*255) Shl 24 | UInt(g*255) Shl 16 | UInt(r*255) Shl 8 | UInt(a*255)
	End

	#rem monkeydoc Converts the color to 32 bit big endian RGBA format.
	
	Big endian RGBA is the same as little endian ABGR.
	
	#end	
	Method ToRGBA:UInt()
		Return UInt(r*255) Shl 24 | UInt(g*255) Shl 16 | UInt(b*255) Shl 8 | UInt(a*255)
	End

	#rem monkeydoc Converts the color to 32 bit big endianABGR format.
	
	Big endian ABGR is the same as little endian RGBA.
	
	#end	
	Method ToABGR:UInt()
		Return UInt(a*255) Shl 24 | UInt(b*255) Shl 16 | UInt(g*255) Shl 8 | UInt(r*255)
	End

	#rem monkeydoc Converts the color to printable string.
	#end
	Method ToString:String()
		Return Self
	End
	
	#rem monkeydoc Creates a color from hue, saturation and value.
	#end
	Function FromHSV:Color( h:Float,s:Float,v:Float,a:Float=1 )

		h*=6
		
		Local f:=h-Floor( h )
		
		Local p:=v * ( 1 - s )
		Local q:=v * ( 1 - ( s * f ) )
		Local t:=v * ( 1 - ( s * ( 1-f ) ) )
		
		Local r:Float,g:Float,b:Float
		
		Select Int( h ) Mod 6
		Case 0 r=v ; g=t ; b=p
		Case 1 r=q ; g=v ; b=p
		Case 2 r=p ; g=v ; b=t
		Case 3 r=p ; g=q ; b=v
		Case 4 r=t ; g=p ; b=v
		Case 5 r=v ; g=p ; b=q
		End
		
		Return New Color( r,g,b,a )
	End
	
	#rem monkeydoc Creates a color from a 32 bit big endian ARGB color.

	Big endian ARGB is the same as little endian BGRA.

	#end
	Function FromARGB:Color( argb:UInt )
		Local a:=(argb Shr 24 & $ff)/255.0
		Local r:=(argb Shr 16 & $ff)/255.0
		Local g:=(argb Shr 8 & $ff)/255.0
		Local b:=(argb & $ff)/255.0
		Return New Color( r,g,b,a )
	End
	
	#rem monkeydoc Creates a color from a 32 bit big endian BGRA color.

	Big endian BGRA is the same as little endian ARGB.
	
	#end
	Function FromBGRA:Color( bgra:UInt )
		Local b:=(bgra Shr 24 & $ff)/255.0
		Local g:=(bgra Shr 16 & $ff)/255.0
		Local r:=(bgra Shr 8 & $ff)/255.0
		Local a:=(bgra & $ff)/255.0
		Return New Color( r,g,b,a )
	End
	
	#rem monkeydoc Creates a color from a 32 bit big endian RGBA color.

	Big endian RGBA is the same as little endian ABGR.
	
	#end
	Function FromRGBA:Color( rgba:UInt )
		Local r:=(rgba Shr 24 & $ff)/255.0
		Local g:=(rgba Shr 16 & $ff)/255.0
		Local b:=(rgba Shr 8 & $ff)/255.0
		Local a:=(rgba & $ff)/255.0
		Return New Color( r,g,b,a )
	End
	
	#rem monkeydoc Creates a color from a 32 bit big endian ABGR color.

	Big endian ABGR is the same as little endian RGBA.
	
	#end
	Function FromABGR:Color( abgr:UInt )
		Local a:=(abgr Shr 24 & $ff)/255.0
		Local b:=(abgr Shr 16 & $ff)/255.0
		Local g:=(abgr Shr 8 & $ff)/255.0
		Local r:=(abgr & $ff)/255.0
		Return New Color( r,g,b,a )
	End
	
	#rem monkeydoc Creates a random color.
	#end
	Function Rnd:Color()
		
		Return FromHSV( random.Rnd(6),1,1 )
		
	End

End
