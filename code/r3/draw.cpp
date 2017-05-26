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

#include "r3/draw.h"

#include "r3/buffer.h"
#include "r3/common.h"
#include "r3/gl.h"
#include "r3/output.h"


#include <assert.h>

#define IM_QUADS 999
#define PRIM_INVALID 1000
#include <string.h>

using namespace std;
using namespace r3;

namespace {
	GLenum ToPrim[] = {
		PRIM_INVALID,
		GL_TRIANGLES,      // Primitive_Triangles,
		IM_QUADS,          // Primitive_Quads,
		GL_TRIANGLE_STRIP, // Primitive_TriangleStrip,
		GL_TRIANGLE_FAN,   // Primitive_TriangleFan,
		GL_LINES,          // Primitive_Lines,
		GL_LINE_STRIP,     // Primitive_LineStrip,
		GL_POINTS,		   // Primitive_Points,
	};
	
	GLenum ToBlendFunc[] = {
		GL_ZERO,                   // BlendFunc_Zero,
		GL_ONE,                    // BlendFunc_One,
		GL_SRC_COLOR,              // BlendFunc_SrcColor,
		GL_SRC_ALPHA,              // BlendFunc_SrcAlpha,
		GL_DST_COLOR,              // BlendFunc_DstColor,
		GL_DST_ALPHA,              // BlendFunc_DstAlpha,
		GL_ONE_MINUS_SRC_COLOR,    // BlendFunc_OneMinusSrcColor,
		GL_ONE_MINUS_SRC_ALPHA,    // BlendFunc_OneMinusSrcAlpha,
		GL_ONE_MINUS_DST_COLOR,    // BlendFunc_OneMinusDstColor,
		GL_ONE_MINUS_DST_ALPHA,    // BlendFunc_OneMinusDstAlpha
	};
	
	int currentVarying = 0;
	GLenum currentPrim = 0;
	PrimitiveEnum imPrim = Primitive_Triangles;
	
#define MAX_VERTS 32768
	int currentIndex = 0;
	r3::byte vab[64];
	r3::byte verts[ MAX_VERTS * sizeof( vab ) ];
	// uniform color - we don't have any other attribs that can be uniform...
	float ucolor[4];
	
	bool quadIndexesInitialized = false;
	GLushort quadIndexes[ MAX_VERTS * 3 / 2 ];

	int stride;
	int offsets[ R3_NUM_VARYINGS ];

#define POSITION_OFFSET 0
#define COLOR_OFFSET 1
#define NORMAL_OFFSET 2
#define TEXCOORD0_OFFSET 3
#define TEXCOORD1_OFFSET 4
		
	int attrib_sizes[] = { 12, 4, 12, 8, 8 };
	
	VertexBuffer *imvb;
}

namespace r3 {
	
	void InitDraw() {
		ucolor[0] = ucolor[1] = ucolor[2] = ucolor[3] = 1.0f;
		imvb = new VertexBuffer( "IMVB" );
	}

	// Vertex size in bytes based on its varying elements
	int GetVertexSize( int varying ) {
		int size = 0;
		for ( int i = 0; i < ARRAY_ELEMENTS( attrib_sizes ); i++ ) {
			size += ( varying & ( 1 << i ) ) ? attrib_sizes[ i ] : 0;
		}
		return size;
	}
	
	void ComputeOffsets( int varying, int & stride, int * offsets ) {
		int off = 0;
		for ( int i = 0; i < ARRAY_ELEMENTS( attrib_sizes ); i++ ) {
			offsets[i] = off;
			off += ( varying & ( 1 << i ) ) ? attrib_sizes[ i ] : 0; 
		}
		stride = off;
	}
	
	// Immediate mode wrapper
	void ImVarying( int varying ) {
		currentVarying = varying | Varying_PositionBit; // position is compulsory in immediate mode
		int off = 0;
		for ( int i = 0; i < ARRAY_ELEMENTS( attrib_sizes ); i++ ) {
			offsets[i] = off;
			off += ( currentVarying & ( 1 << i ) ) ? attrib_sizes[ i ] : 0; 
		}
		stride = off;
	}
	
	void ImBegin( PrimitiveEnum prim ) {
		imPrim = prim;
		if ( ( currentVarying & Varying_ColorBit ) == 0 ) {
			glColor4f( ucolor[0], ucolor[1], ucolor[2], ucolor[3] );
		}
		currentPrim = ToPrim[ int( prim ) ] ;
		currentIndex = 0;
	}
	
	void ImEnd() {
		if ( imPrim == Primitive_Invalid || currentIndex == 0 ) {
			return;
		}
		
		if ( quadIndexesInitialized == false ) {
			for ( int i = 0; i < MAX_VERTS / 4; i++ )  {
				quadIndexes[ i * 6 + 0 ] = i * 4 + 0;  // first triangle
				quadIndexes[ i * 6 + 1 ] = i * 4 + 1;
				quadIndexes[ i * 6 + 2 ] = i * 4 + 2;			
				quadIndexes[ i * 6 + 3 ] = i * 4 + 0;  // second triangle
				quadIndexes[ i * 6 + 4 ] = i * 4 + 2;
				quadIndexes[ i * 6 + 5 ] = i * 4 + 3;
			}
			quadIndexesInitialized = true;
		}
		imvb->SetData( currentIndex * stride, verts );
		imvb->SetVarying( currentVarying );
		static vector< VertexBuffer *> vvb;
		if ( vvb.size() != 1 ) {
			vvb.push_back( NULL );
		}
		vvb[0] = imvb;
		Draw( imPrim, vvb );
		imPrim = Primitive_Invalid;
		currentPrim = 0;
		currentIndex = 0;

		imvb->Disable();		
	}
	
	void ImVertex( float x, float y, float z ) {
		if ( currentIndex >= MAX_VERTS || ( currentVarying & Varying_PositionBit ) == 0 ) {
			return;
		}
		float *v = (float *)( vab + offsets[ POSITION_OFFSET ] );
		v[0] = x;
		v[1] = y;
		v[2] = z;
		memcpy( verts + stride * currentIndex, vab, stride );
		currentIndex++;
	}
	
	void ImNormal( float x, float y, float z ) {
		if ( ( currentVarying & Varying_NormalBit ) == 0 ) {
			return;
		}
		float *n = (float *)( vab + offsets[ NORMAL_OFFSET ] );
		n[0] = x;
		n[1] = y;
		n[2] = z;
	}
	
	void ImColor( unsigned char r, unsigned char g, unsigned char b, unsigned char a ) {
		if ( currentPrim == 0 ) {
			ucolor[0] = r / 255.0f; ucolor[1] = g / 255.0f; ucolor[2] = b / 255.0f; ucolor[3] = a / 255.0f;
		}
		if ( currentPrim != 0 && ( currentVarying & Varying_ColorBit ) == 0 ) {
			return;
		}
		byte *c = (byte *)( vab + offsets[ COLOR_OFFSET ] );
		c[0] = r;
		c[1] = g;
		c[2] = b;
		c[3] = a;
	}

	void ImColorf( float r, float g, float b, float a ) {
		if ( currentPrim == 0 ) {
			ucolor[0] = r; ucolor[1] = g; ucolor[2] = b; ucolor[3] = a;
		}
		if ( currentPrim != 0 && ( currentVarying & Varying_ColorBit ) == 0 ) {
			return;
		}
		byte *c = (byte *)( vab + offsets[ COLOR_OFFSET ] );
		c[0] = byte(r * 255);
		c[1] = byte(g * 255);
		c[2] = byte(b * 255);
		c[3] = byte(a * 255);
	}
	
	void ImTexCoord( int attr, float s, float t ) {
		assert( attr < 2 && attr >= 0 );
		if ( ( currentVarying & ( Varying_TexCoord0Bit << attr ) ) == 0 ) {
			return;
		}
		float *tc = (float *)( vab + offsets[ TEXCOORD0_OFFSET ] + 8 * attr );
		tc[0] = s;
		tc[1] = t;
	}
	
	
	void BlendFunc( BlendFuncEnum srcFactor, BlendFuncEnum dstFactor ) {
		glBlendFunc( ToBlendFunc[ srcFactor ], ToBlendFunc[ dstFactor ] );
	}
	
	void BlendEnable() {
		glEnable( GL_BLEND );
	}
	
	void BlendDisable() {
		glDisable( GL_BLEND );
	}
	
	void DepthFunc( CompareEnum compare ) {
		glDepthFunc( compare + GL_NEVER );
	}
	
	void DepthTestEnable() {
		glEnable( GL_DEPTH_TEST );
	}
	
	void DepthTestDisable() {
		glDisable( GL_DEPTH_TEST );
	}

	void AlphaFunc( CompareEnum compare, float ref ) {
		glAlphaFunc( compare + GL_NEVER, ref );
	}

	void AlphaTestEnable() {
		glEnable( GL_ALPHA_TEST );
	}

	void AlphaTestDisable() {
		glDisable( GL_ALPHA_TEST );
	}



	void LineWidth( float width ) {
		glLineWidth( width );
	}
	
	void PointSize( float size ) {
		glPointSize( size );
	}

	void PointSmoothEnable() {
		glEnable( GL_POINT_SMOOTH );
	}

	void PointSmoothDisable() {
		glDisable( GL_POINT_SMOOTH );
	}

	
	void Draw( PrimitiveEnum prim, const vector<VertexBuffer *> & vertexBuffers, const IndexBuffer * indexBuffer ) {
		assert( vertexBuffers.size() );
		uint varying = 0;
		for ( int i = 0; i < (int)vertexBuffers.size(); i++ ) {
			VertexBuffer *vb = vertexBuffers[i];
			vb->Bind();
			vb->Enable();
			varying |= vb->GetVarying();
		}
		if ( ( varying & Varying_ColorBit ) == 0 ) {
			glColor4f( ucolor[0], ucolor[1], ucolor[2], ucolor[3] );
		}
		
		if ( indexBuffer ) {
			glPointSize( 9 );
			indexBuffer->Bind();
			glDrawElements( ToPrim[ prim ], indexBuffer->GetSize() / 2, GL_UNSIGNED_SHORT, (void *)0 );
			indexBuffer->Unbind();			
		} else {
			int indexes = vertexBuffers[0]->GetNumVerts();
			if ( prim == Primitive_Quads ) { // support non-indexed quads
				glDrawElements( GL_TRIANGLES, indexes * 3 / 2, GL_UNSIGNED_SHORT, quadIndexes );
			} else {	
				glDrawArrays( ToPrim[ prim ], 0, indexes );
			}
		}
		for ( int i = 0; i < (int)vertexBuffers.size(); i++ ) {
			vertexBuffers[i]->Disable();
			vertexBuffers[i]->Unbind();
		}
	}
	
	void DrawQuad( float x0, float y0, float x1, float y1 ) {
		ImVarying( 0 );
		ImBegin( Primitive_Quads );
		ImVertex( x0, y0 );
		ImVertex( x1, y0 );
		ImVertex( x1, y1 );
		ImVertex( x0, y1 );		
		ImEnd();
	}
	
	void DrawTexturedQuad( float x0, float y0, float x1, float y1, float s0, float t0, float s1, float t1 ) {
		ImVarying( Varying_TexCoord0Bit );
		ImBegin( Primitive_Quads );
		ImTexCoord( 0, s0, t0 );
		ImVertex( x0, y0 );
		ImTexCoord( 0, s1, t0 );
		ImVertex( x1, y0 );
		ImTexCoord( 0, s1, t1 );
		ImVertex( x1, y1 );
		ImTexCoord( 0, s0, t1 );
		ImVertex( x0, y1 );		
		ImEnd();
	}
	
	void DrawSprite( float x0, float y0, float x1, float y1 ) {
		ImVarying( Varying_TexCoord0Bit );
		ImBegin( Primitive_Quads );
		ImTexCoord( 0, 0, 0 );
		ImVertex( x0, y0 );
		ImTexCoord( 0, 1, 0 );
		ImVertex( x1, y0 );
		ImTexCoord( 0, 1, 1 );
		ImVertex( x1, y1 );
		ImTexCoord( 0, 0, 1 );
		ImVertex( x0, y1 );		
		ImEnd();
	}
	
	
}
