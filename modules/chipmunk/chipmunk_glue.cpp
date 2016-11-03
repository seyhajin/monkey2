
#include "chipmunk_glue.h"

// ***** cpCollisionHandler *****

namespace{

	cpBool collisionTrueFunc( cpArbiter *arbiter,cpSpace *space,cpDataPointer data ){
		return true;
	}

	void collisionVoidFunc( cpArbiter *arbiter,cpSpace *space,cpDataPointer data ){
	}

	cpBool collisionBeginFunc( cpArbiter *arbiter,cpSpace *space,cpDataPointer data ){
		bb_cpCollisionHandler *handler=(bb_cpCollisionHandler*)data;
		
		return handler->beginFunc( arbiter,space,handler->userData );
	}

	cpBool collisionPreSolveFunc( cpArbiter *arbiter,cpSpace *space,cpDataPointer data ){
		bb_cpCollisionHandler *handler=(bb_cpCollisionHandler*)data;
		
		return handler->preSolveFunc( arbiter,space,handler->userData );
	}

	void collisionPostSolveFunc( cpArbiter *arbiter,cpSpace *space,cpDataPointer data ){
		bb_cpCollisionHandler *handler=(bb_cpCollisionHandler*)data;
		
		handler->postSolveFunc( arbiter,space,handler->userData );
	}

	void collisionSeparateFunc( cpArbiter *arbiter,cpSpace *space,cpDataPointer data ){
		bb_cpCollisionHandler *handler=(bb_cpCollisionHandler*)data;
		
		handler->separateFunc( arbiter,space,handler->userData );
	}
	
	bb_cpCollisionHandler *bbHandler( cpCollisionHandler *handler ){
	
		bb_cpCollisionHandler *bbhandler=(bb_cpCollisionHandler*)handler->userData;
		if( bbhandler ) return bbhandler;
		
		bbhandler=new bb_cpCollisionHandler;	//FIXME: GC leak!
		bbhandler->typeA=handler->typeA;		//assume these are const-ish?
		bbhandler->typeB=handler->typeB;
		bbhandler->beginFunc=bbMakefunc( collisionTrueFunc );
		bbhandler->preSolveFunc=bbMakefunc( collisionTrueFunc );
		bbhandler->postSolveFunc=bbMakefunc( collisionVoidFunc );
		bbhandler->separateFunc=bbMakefunc( collisionVoidFunc );
			
		handler->beginFunc=collisionBeginFunc;
		handler->preSolveFunc=collisionPreSolveFunc;
		handler->postSolveFunc=collisionPostSolveFunc;
		handler->separateFunc=collisionSeparateFunc;
		handler->userData=bbhandler;

		return bbhandler;
	}
}

void bb_cpCollisionHandler::gcMark(){
	bbGCMark( beginFunc );
	bbGCMark( preSolveFunc );
	bbGCMark( postSolveFunc );
	bbGCMark( separateFunc );
}

bb_cpCollisionHandler *bb_cpSpaceAddDefaultCollisionHandler( cpSpace *space ){
	cpCollisionHandler *handler=cpSpaceAddDefaultCollisionHandler( space );
	return bbHandler( handler );
}

bb_cpCollisionHandler *bb_cpSpaceAddCollisionHandler( cpSpace *space,cpCollisionType a,cpCollisionType b ){
	cpCollisionHandler *handler=cpSpaceAddCollisionHandler( space,a,b );
	return bbHandler( handler );	
}

bb_cpCollisionHandler *bb_cpSpaceAddWildcardHandler( cpSpace *space,cpCollisionType t ){
	cpCollisionHandler *handler=cpSpaceAddWildcardHandler( space,t );
	return bbHandler( handler );	
}

// ***** cpSpaceDebugDraw *****

namespace{

	void debugDrawCircle(cpVect pos, cpFloat angle, cpFloat radius, cpSpaceDebugColor outlineColor, cpSpaceDebugColor fillColor, cpDataPointer data ){
		bb_cpSpaceDebugDrawOptions *opts=(bb_cpSpaceDebugDrawOptions*)data;
		
		opts->drawCircle( pos,angle,radius,outlineColor,fillColor,opts->userData );
	}
	
	void debugDrawSegment(cpVect a, cpVect b, cpSpaceDebugColor color, cpDataPointer data){
		bb_cpSpaceDebugDrawOptions *opts=(bb_cpSpaceDebugDrawOptions*)data;
		
		opts->drawSegment( a,b,color,opts->userData );
	}
	
	void debugDrawFatSegment(cpVect a, cpVect b, cpFloat radius, cpSpaceDebugColor outlineColor, cpSpaceDebugColor fillColor, cpDataPointer data){
		bb_cpSpaceDebugDrawOptions *opts=(bb_cpSpaceDebugDrawOptions*)data;
		
		opts->drawFatSegment( a,b,radius,outlineColor,fillColor,opts->userData );
	}
	
	void debugDrawPolygon(int count, const cpVect *verts, cpFloat radius, cpSpaceDebugColor outlineColor, cpSpaceDebugColor fillColor, cpDataPointer data){
		bb_cpSpaceDebugDrawOptions *opts=(bb_cpSpaceDebugDrawOptions*)data;
		
		opts->drawPolygon( count,(cpVect*)verts,radius,outlineColor,fillColor,opts->userData );
	}
	
	void debugDrawDot(cpFloat size, cpVect pos, cpSpaceDebugColor color, cpDataPointer data){
		bb_cpSpaceDebugDrawOptions *opts=(bb_cpSpaceDebugDrawOptions*)data;
		
		opts->drawDot( size,pos,color,opts->userData );
	}
	
	cpSpaceDebugColor debugDrawColorForShape(cpShape *shape, cpDataPointer data){
		bb_cpSpaceDebugDrawOptions *opts=(bb_cpSpaceDebugDrawOptions*)data;
		
		return opts->colorForShape( shape,opts->userData );
	}
}

void bb_cpSpaceDebugDrawOptions::gcMark(){

	bbGCMark( drawCircle );
	bbGCMark( drawSegment );
	bbGCMark( drawFatSegment );
	bbGCMark( drawPolygon );
	bbGCMark( colorForShape );
}

void bb_cpSpaceDebugDraw( cpSpace *space,bb_cpSpaceDebugDrawOptions *options ){

	cpSpaceDebugDrawOptions opts;
	
	opts.drawCircle=debugDrawCircle;
	opts.drawSegment=debugDrawSegment;
	opts.drawFatSegment=debugDrawFatSegment;
	opts.drawPolygon=debugDrawPolygon;
	opts.drawDot=debugDrawDot;
	opts.flags=options->flags;
	opts.shapeOutlineColor=options->shapeOutlineColor;
	opts.colorForShape=debugDrawColorForShape;
	opts.constraintColor=options->constraintColor;
	opts.collisionPointColor=options->collisionPointColor;
	opts.data=options;
	
	cpSpaceDebugDraw( space,&opts );
}
