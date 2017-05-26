/*
 *  draw
 *
 */

/* 
 Copyright (c) 2010 Cass Everitt
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or
 without modification, are permitted provided that the following
 conditions are met:
 
 * Redistributions of source code must retain the above
 copyright notice, this list of conditions and the following
 disclaimer.
 
 * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following
 disclaimer in the documentation and/or other materials
 provided with the distribution.
 
 * The names of contributors to this software may not be used
 to endorse or promote products derived from this software
 without specific prior written permission. 
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
 
 
 Cass Everitt
 */

#ifndef __R3_DRAW_H__
#define __R3_DRAW_H__

#include "r3/buffer.h"
#include "r3/linear.h"

#include <vector>

namespace r3 {
	
	void InitDraw();
	
#define R3_NUM_VARYINGS 5
	
	enum VaryingEnum {
		Varying_Nothing      = 0x00,
		Varying_PositionBit  = 0x01,
		Varying_ColorBit     = 0x02,
		Varying_NormalBit    = 0x04,
		Varying_TexCoord0Bit = 0x08,
		Varying_TexCoord1Bit = 0x10
	};
	
	enum PrimitiveEnum {
		Primitive_Invalid,
		Primitive_Triangles,
		Primitive_Quads,
		Primitive_TriangleStrip,
		Primitive_TriangleFan,
		Primitive_Lines,
		Primitive_LineStrip,
		Primitive_Points,
		Primitive_MAX
	};
	
	int GetVertexSize( int varying );
	
	// ImVarying() is called before ImBegin() to identify which
	// attributes will be in an array.
	void ImVarying( int varying );
	
	void ImBegin( PrimitiveEnum prim );
	void ImEnd();
	
	void ImVertex( float x, float y, float z = 0.0f );
	inline void ImVertex( const Vec2f & v ) {	ImVertex( v.x, v.y ); }
	inline void ImVertex( const Vec3f & v ) {	ImVertex( v.x, v.y, v.z ); }
	void ImNormal( float x, float y, float z );
	void ImColor( unsigned char r, unsigned char g, unsigned char b, unsigned char a = 255 );
	void ImColorf( float r, float g, float b, float a = 1.0f );
	void ImTexCoord( int attr, float s, float t );
	
	inline void ImColor4ubv( unsigned char * c) {
		ImColor( c[0], c[1], c[2], c[3] );
	}
	
	
	enum BlendFuncEnum {
		BlendFunc_Zero,
		BlendFunc_One,
		BlendFunc_SrcColor,
		BlendFunc_SrcAlpha,
		BlendFunc_DstColor,
		BlendFunc_DstAlpha,
		BlendFunc_OneMinusSrcColor,
		BlendFunc_OneMinusSrcAlpha,
		BlendFunc_OneMinusDstColor,
		BlendFunc_OneMinusDstAlpha
	};
	
	void BlendFunc( BlendFuncEnum srcFactor, BlendFuncEnum dstFactor );
	void BlendEnable();
	void BlendDisable();

	enum CompareEnum  {
		Compare_Never,
		Compare_Less,
		Compare_Equal,
		Compare_LessOrEqual,
		Compare_Greater,
		Compare_NotEqual,
		Compare_GreaterOrEqual,
		Compare_Always
	};

	void DepthFunc( CompareEnum compare );
	void DepthTestEnable();
	void DepthTestDisable();

	void AlphaFunc( CompareEnum cmp, float ref );
	void AlphaTestEnable();
	void AlphaTestDisable();



	void LineWidth( float width );
	void PointSize( float size );
	void PointSmoothEnable();
	void PointSmoothDisable();
		
	void Draw( PrimitiveEnum prim, const std::vector< VertexBuffer * > & vertexBuffers, const IndexBuffer * indexBuffer = NULL );

	void DrawQuad( float x0, float y0, float x1, float y1 );
	void DrawTexturedQuad( float x0, float y0, float x1, float y1, float s0, float t0, float s1, float t1 );
	void DrawSprite( float x0, float y0, float x1, float y1 );
	
}

#endif // __R3_DRAW_H__