
#Import "<std>"
#Import "<assimp>"

#Import "assets/"

Using std..
Using assimp..

Function Main()
	
'	Local flags:UInt=aiProcess_CalcTangentSpace | aiProcess_Triangulate | aiProcess_JoinIdenticalVertices | aiProcess_SortByPType
	Local flags:UInt=aiProcess_CalcTangentSpace | aiProcess_Triangulate | aiProcess_JoinIdenticalVertices | aiProcess_SortByPType
	
	Local scene:=aiImportFile( AssetsDir()+"WusonBlitz.b3d",flags )

	If scene
		Print "Success!"
		Print "NumMeshes="+scene.mNumMeshes
		For Local i:=0 Until scene.mNumMeshes
			Local mesh:=scene.mMeshes[i]
			Print "Mesh "+i+":mNumVertices="+mesh.mNumVertices
		Next
	Else
		Print "Error!"
	Endif
		
	aiReleaseImport( scene )
	
	Print "Bye!"
	
End
