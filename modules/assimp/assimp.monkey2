
Namespace assimp

#Import "<libc>"

#Import "makefile"

#Import "assimp/include/*.h"

#Import "<assimp/cimport.h>"
#Import "<assimp/scene.h>"
#Import "<assimp/postprocess.h>"

Const AI_MATKEY_COLOR_DIFFUSE:="$clr.diffuse"
Const AI_MATKEY_COLOR_AMBIENT:="$clr.ambient"
Const AI_MATKEY_COLOR_SPECULAR:="$clr.specular"
Const AI_MATKEY_COLOR_EMISSIVE:="$clr.emissive"
Const AI_MATKEY_COLOR_TRANSPARENT:="$clr.transparent"
Const AI_MATKEY_COLOR_REFLECTIVE:="$clr.reflective"

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

Const aiTextureType_NONE:UInt
Const aiTextureType_DIFFUSE:UInt
Const aiTextureType_SPECULAR:UInt
Const aiTextureType_AMBIENT:UInt
Const aiTextureType_EMISSIVE:UInt
Const aiTextureType_HEIGHT:UInt
Const aiTextureType_NORMALS:UInt
Const aiTextureType_SHININESS:UInt
Const aiTextureType_OPACITY:UInt
Const aiTextureType_DISPLACEMENT:UInt
Const aiTextureType_LIGHTMAP:UInt
Const aiTextureType_REFLECTION:UInt
Const aiTextureType_UNKNOWN:UInt

Struct aiVector3D
	Field x:Float
	Field y:Float
	Field z:Float
End

Struct aiString
	Field data:CString
End

Struct aiColor4D
	Field r:Float
	Field g:Float
	Field b:Float
	Field a:Float
End

Struct aiFace
	Field mIndices:UInt Ptr
	Field mNumIndices:UInt
End

Class aiMaterial Extends Void
End

Class aiMesh Extends Void
	
	Field mVertices:aiVector3D Ptr 
	Field mNormals:aiVector3D Ptr
	Field mTangents:aiVector3D Ptr
	Field mBitangents:aiVector3D Ptr
	Field mTextureCoords:aiVector3D Ptr Ptr
	Field mFaces:aiFace Ptr
	
	Field mName:aiString
	Field mMaterialIndex:UInt
	Field mNumVertices:UInt
	Field mPrimitiveTypes:UInt
	Field mNumUVComponents:UInt Ptr
	Field mNumFaces:UInt

End

Class aiScene Extends Void="const aiScene"
	
	Field mMeshes:aiMesh Ptr
	Field mMaterials:aiMaterial Ptr
	
	Field mNumMeshes:UInt
	Field mNumMaterials:UInt
	
End

Function aiImportFile:aiScene( pFile:CString,pFlags:UInt )

Function aiImportFileFromMemory:aiScene( pBuffer:libc.char_t Ptr,pLength:UInt,pFlags:UInt,pHint:CString )

Function aiReleaseImport( scene:aiScene )
	
Function aiGetMaterialTextureCount:UInt( pMat:aiMaterial,type:UInt )
	
Function aiGetMaterialTexture( mat:aiMaterial,type:UInt,index:UInt,path:aiString Ptr )

Function aiGetMaterialColor( pMat:aiMaterial,pKey:CString,type:UInt,index:UInt,pOut:aiColor4D Ptr )
