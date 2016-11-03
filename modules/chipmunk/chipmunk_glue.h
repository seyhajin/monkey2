
#ifndef BB_CHIPMUNK_GLUE_H
#define BB_CHIPMUNK_GLUE_H

#include <chipmunk/chipmunk.h>

#include <bbmonkey.h>

// ***** cpCollisionHandler *****

typedef bbFunction<cpBool(cpArbiter*,cpSpace*,cpDataPointer)> bb_cpCollisionBeginFunc;
typedef bbFunction<cpBool(cpArbiter*,cpSpace*,cpDataPointer)> bb_cpCollisionPreSolveFunc;
typedef bbFunction<void(cpArbiter*,cpSpace*,cpDataPointer)> bb_cpCollisionPostSolveFunc;
typedef bbFunction<void(cpArbiter*,cpSpace*,cpDataPointer)> bb_cpCollisionSeparateFunc;

struct bb_cpCollisionHandler : public bbObject{

	cpCollisionType typeA;
	cpCollisionType typeB;
	bb_cpCollisionBeginFunc beginFunc;
	bb_cpCollisionPreSolveFunc preSolveFunc;
	bb_cpCollisionPostSolveFunc postSolveFunc;
	bb_cpCollisionSeparateFunc separateFunc;
	cpDataPointer userData;
	
	void gcMark();
};

bb_cpCollisionHandler *bb_cpSpaceAddDefaultCollisionHandler( cpSpace* );
bb_cpCollisionHandler *bb_cpSpaceAddCollisionHandler( cpSpace*,cpCollisionType,cpCollisionType );
bb_cpCollisionHandler *bb_cpSpaceAddWildcardHandler( cpSpace*,cpCollisionType );

// ***** cpSpaceDebugDraw *****

typedef bbFunction<void(cpVect,cpFloat,cpFloat,cpSpaceDebugColor,cpSpaceDebugColor,cpDataPointer)> bb_cpSpaceDebugDrawCircleImpl;
typedef bbFunction<void(cpVect,cpVect,cpSpaceDebugColor,cpDataPointer)> bb_cpSpaceDebugDrawSegmentImpl;
typedef bbFunction<void(cpVect,cpVect,cpFloat,cpSpaceDebugColor,cpSpaceDebugColor,cpDataPointer)> bb_cpSpaceDebugDrawFatSegmentImpl;
typedef bbFunction<void(int,cpVect*,cpFloat,cpSpaceDebugColor,cpSpaceDebugColor,cpDataPointer)> bb_cpSpaceDebugDrawPolygonImpl;
typedef bbFunction<void(cpFloat,cpVect,cpSpaceDebugColor,cpDataPointer)> bb_cpSpaceDebugDrawDotImpl;
typedef bbFunction<cpSpaceDebugColor(cpShape*,cpDataPointer)> bb_cpSpaceDebugDrawColorForShapeImpl;

struct bb_cpSpaceDebugDrawOptions : public bbObject{

	bb_cpSpaceDebugDrawCircleImpl drawCircle;
	bb_cpSpaceDebugDrawSegmentImpl drawSegment;
	bb_cpSpaceDebugDrawFatSegmentImpl drawFatSegment;
	bb_cpSpaceDebugDrawPolygonImpl drawPolygon;
	bb_cpSpaceDebugDrawDotImpl drawDot;
	cpSpaceDebugDrawFlags flags;
	cpSpaceDebugColor shapeOutlineColor;
	bb_cpSpaceDebugDrawColorForShapeImpl colorForShape;
	cpSpaceDebugColor constraintColor;
	cpSpaceDebugColor collisionPointColor;
	cpDataPointer userData;
	
	void gcMark();
};

void bb_cpSpaceDebugDraw( cpSpace *space,bb_cpSpaceDebugDrawOptions *options );

#endif
