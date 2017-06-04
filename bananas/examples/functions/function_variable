Namespace myapp
#Import "<std>"
Using std..

class C
   field t:=10
   method test:void()
      print "haha "+t
   end
End

Function ftest:Void(i:int)
 Print "hoho "+i
End

function Main:void()
   local c:=New C
   Local f:void()=c.test ' a function varable that has a class method as function
   f() 'calling that method
   Local f2:Void(i:int)=ftest ' a function variable that has a function as function
   f2(15) 'calling that function
end
