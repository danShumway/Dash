module components.assetanimation;

import core.properties;
import components.component;

import derelict.assimp3.assimp;

import math.matrix, math.vector;

class AssetAnimation
{
public:
	mixin Property!( "AnimationSet", "animationSet", "public" );

	this( string name, const(aiAnimation*) animation, const(aiNode*) boneHierarchy )
	{
		animationSet.duration = cast(float)animation.mDuration;
		animationSet.fps = cast(float)animation.mTicksPerSecond;

		animationSet.boneAnimData = makeBoneFromNode( animation, boneHierarchy );
	}

	Bone makeBoneFromNode( const(aiAnimation*) animation, const(aiNode*) bones )
	{
		
		Bone temp = new Bone( cast(string)bones.mName.data );
		
		if( !(bones.mParent !is null) )
			temp.parent = makeBoneFromNode( animation, bones.mParent );

		for(int i = 0; i < bones.mNumChildren; i++)
		{
			temp.children ~= makeBoneFromNode( animation, bones.mChildren[i]);
		}

		assignCorrectAnimationData( animation, temp );

		return temp;
	}
	void assignCorrectAnimationData( const(aiAnimation*) animation, Bone boneToAssign )
	{
		// For each bone animation data
		for( int i = 0; i < animation.mNumMeshChannels; i++)
		{
			// If the names match
			if( cast(string)animation.mChannels[ i ].mNodeName.data == boneToAssign.name )
			{
				// Assign the bone animation data to the bone
				boneToAssign.positionKeys = convertVectorArray( animation.mChannels[ i ].mPositionKeys,
																animation.mChannels[ i ].mNumPositionKeys );
			}
		}
	}
	// Go through array of keys and convert/store in vector[]
	Vector!3[] convertVectorArray(const(aiVectorKey*) vectors, int numKeys)
	{
		Vector!3[] temp;
		for(int i = 0; i < numKeys; i++)
		{
			aiVector3D vector = vectors[i].mValue;
			temp ~= new Vector!3(vector.x, vector.y, vector.z);
		}

		return temp;
	}
	
	// Find bone with name in our structure
	/*Bone findBoneWithName(string name, Bone bone)
	{
		if(name == bone.name)
		{
			return bone;
		}

		for(int i = 0; i < bone.children.length; i++)
		{
			Bone temp = findBoneWithName(name, bone.children[i]);
			if(temp !is null)
			{
				return temp;
			}
		}

		return null;
	}*/

	struct AnimationSet
	{
		float duration;
		float fps;
		Bone boneAnimData;
	}
	class Bone
	{
		this( string boneName )
		{
			name = boneName;
			//positionKeys = positions;
		}

		string name;
		Bone parent;
		Bone[] children;
		Vector!3[] positionKeys;
		//Quaternion[] rotationKeys;
		//Vector!3[] scaleKeys;
	}
}