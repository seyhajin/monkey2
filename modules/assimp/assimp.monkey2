
Namespace assimp

#Import "makefile"

#Import "assimp/include/*.h"

#Import "<assimp/cimport.h>"
#Import "<assimp/scene.h>"
#Import "<assimp/postprocess.h>"

Extern

Const aiProcess_CalcTangentSpace:Uint
Const aiProcess_JoinIdenticalVertices:UInt
Const aiProcess_MakeLeftHanded:UInt
Const aiProcess_Triangulate:UInt
Const aiProcess_RemoveComponent:UInt
Const aiProcess_GenNormals:UInt
Const aiProcess_GenSmoothNormals:UInt
Const aiProcess_SplitLargeMeshes:UInt
Const aiProcess_PreTransformVertices:UInt
Const aiProcess_LimitBoneWeights:UInt
Const aiProcess_ValidateDataStructure:UInt
Const aiProcess_ImproveCacheLocality:UInt
Const aiProcess_RemoveRedundantMaterials:UInt
Const aiProcess_FixInfacingNormals:UInt
Const aiProcess_SortByPType:UInt
Const aiProcess_FindDegenerates:UInt
Const aiProcess_FindInvalidData:UInt
Const aiProcess_GenUVCoords:UInt
Const aiProcess_TransformUVCoords:UInt
Const aiProcess_FindInstances:UInt
Const aiProcess_OptimizeMeshes:UInt
Const aiProcess_OptimizeGraph:UInt
Const aiProcess_FlipUVs:UInt
Const aiProcess_FlipWindingOrder:UInt
Const aiProcess_SplitByBoneCount:UInt
Const aiProcess_Debone:UInt

Struct aiVector3D'="Assimp::aiVector3D"
	
	Field x:Float
	Field y:Float
	Field z:Float
	
End

Class aiMesh Extends Void
	
	Field mVertices:aiVector3D Ptr 
	Field mNormals:aiVector3D Ptr
	Field mTextureCoords:aiVector3D Ptr Ptr
	
	Field mNumVertices:UInt

End

Class aiScene Extends Void="const aiScene"
	
	Field mMeshes:aiMesh Ptr
	
	Field mNumMeshes:UInt
	
End

Function aiImportFile:aiScene( pFile:CString,pFlags:UInt )

Function aiImportFileFromMemory:aiScene( pBuffer:Void Ptr,pLength:UInt,pFlags:UInt,pHint:CString )

Function aiReleaseImport( scene:aiScene )

