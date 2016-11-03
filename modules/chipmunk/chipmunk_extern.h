
#ifndef BB_CHIPMUNK_EXTERN_H
#define BB_CHIPMUNK_EXTERN_H

#include <chipmunk/chipmunk.h>

struct bb_cpSpaceDebugDrawOptions{
	cpSpaceDebugDrawCircleImpl  drawCircle;
	cpSpaceDebugDrawSegmentImpl drawSegment;
	cpSpaceDebugDrawFatSegmentImpl drawFatSegment;
	cpSpaceDebugDrawPolygonImpl drawPolygon;
	cpSpaceDebugDrawDotImpl drawDot;
	cpSpaceDebugDrawFlags flags;
	cpSpaceDebugColor shapeOutlineColor;
	cpSpaceDebugDrawColorForShapeImpl colorForShape;
	cpSpaceDebugColor constraintColor;
	cpSpaceDebugColor collisionPointColor;
	cpDataPointer data;
};

inline void bb_cpSpaceDebugDraw( cpSpace *space,bb_cpSpaceDebugDrawOptions *options ){
	cpSpaceDebugDrawOptions opts=*(cpSpaceDebugDrawOptions*)options;
	cpSpaceDebugDraw( space,&opts );
};

#endif
