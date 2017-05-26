/*
 *  render
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

#include "render.h"

#include "r3/draw.h"
#include "r3/font.h"
#include "r3/gl.h"
#include "r3/output.h"
#include "r3/var.h"

using namespace r3;
using namespace std;

VarString app_font( "app_font", "main app font", Var_Archive, "Cantarell-Regular.ttf" );
VarInteger app_fontSize( "app_fontSize", "main app font rasterization size", Var_Archive, 16 );
VarFloat app_fontScale( "app_fontScale", "main app font rendering scale", Var_Archive, 0.5 );

VarFloat app_starScale( "app_starScale", "scale of star sprite rendering", Var_Archive, 2 );
VarFloat app_scale( "app_scale", "scale of stuff in angle space", Var_Archive, 0.00009f );

VarFloat app_nightFactor("app_nightFactor", "scale of stuff in angle space", Var_Archive, 0.0f);

using namespace star3map;

extern VarFloat r_fov;

namespace {
	
	Font *font;
	float fov;
	float fovFontScale;

	int transformVersion = 0;
	vector< Matrix4f > transformStack;

}



namespace star3map {

	// Our object space is z-up (which is the zenith)  
	Matrix4f RotateTo( const Vec3f & direction ) {
		Matrix4f m;
		m.MakeIdentity();
		Vec3f dx = UpVector.Cross( direction );
		dx.Normalize();
		Vec3f dup = direction.Cross( dx );
		Quaternionf q( Vec3f( 0, 0, -1 ), Vec3f( 0, 1, 0), direction, dup );
		q.GetValue(m);
		return m;
	}
	
	
	
	Vec3f UpVector;
	
	void Clear() {
		glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	}
	
	void SetColor( const Vec4f & c ) {
		//Output( "SetColor( %.2f, %.2f, %.2f, %.2f )", c.x, c.y, c.z, c.w );
		ImColorf(c.x * (1.0f - app_nightFactor.GetVal()) + app_nightFactor.GetVal(), 
                 c.y * (1.0f - app_nightFactor.GetVal()),
                 c.z * (1.0f - app_nightFactor.GetVal()),
                 c.w);
	}
	
	void PushTransform() {
		if ( transformStack.size() > 0 ) {
			transformStack.push_back( transformStack.back() );			
		} else {
			transformStack.push_back( Matrix4f() );
			transformStack.back().MakeIdentity();
		}
		glPushMatrix();
	}
	
	void ClearTransform() {
		transformVersion++;
		assert( transformStack.size() > 0 );
		transformStack.back().MakeIdentity();
		glLoadIdentity();
	}
	
	void PopTransform() {
		transformVersion++;
		assert( transformStack.size() > 0 );
		transformStack.pop_back();
		glPopMatrix();
	}
	
	void ApplyTransform( const r3::Matrix4f &m ) {
		transformVersion++;
		assert( transformStack.size() > 0 );
		transformStack.back() = transformStack.back() * m;
		glMultMatrixf( m.Ptr() );	
	}
	
	Matrix4f GetTransform() {
		assert( transformStack.size() > 0 );
		return transformStack.back();
	}
	
	void DrawQuad( float radius, const Vec3f & direction ) {
		Matrix4f m = RotateTo( direction );
		glPushMatrix();
		glMultMatrixf( m.Ptr() );
		glScalef( radius * app_scale.GetVal(), radius * app_scale.GetVal(), 1.f );
		glTranslatef( 0, 0, -1 );
		r3::DrawQuad( -10, -10, 10, 10 );
		glPopMatrix();
	}

	void DrawSprite( Texture2D *tex, r3::Bounds2f bounds ) {
		tex->Bind( 0 );
		tex->Enable();
		r3::DrawSprite( bounds.Min().x, bounds.Min().y, bounds.Max().x, bounds.Max().y );
		tex->Disable();
	}
	
    void DrawSprite( Texture2D *tex, float radius, const Vec3f & direction, const Vec3f & lookDir ) {
        // beef up the width and height since the texture will make it
        // effectively smaller
        radius *= app_starScale.GetVal();
        Matrix4f m = RotateTo( direction );
        glPushMatrix();
        glTranslatef( direction.x, direction.y, direction.z );
        glMultMatrixf( m.Ptr() );
        glRotatef(-150, 0, 0, 1);
        //glRotatef(m.Ptr(), 0, 0, 1);
        glScalef( radius * app_scale.GetVal(), radius * app_scale.GetVal(), 1.f );
        glTranslatef( 0, 0, -1 );
        tex->Bind( 0 );
        tex->Enable();
        r3::DrawSprite( -10, -10, 10, 10 );
        tex->Disable();
        glPopMatrix();
    }
    
	void DrawSprite( Texture2D *tex, float radius, const Vec3f & direction ) {
		// beef up the width and height since the texture will make it
		// effectively smaller
		radius *= app_starScale.GetVal();
		Matrix4f m = RotateTo( direction );
		glPushMatrix();
		glMultMatrixf( m.Ptr() );
		glScalef( radius * app_scale.GetVal(), radius * app_scale.GetVal(), 1.f );
		glTranslatef( 0, 0, -1 );
		tex->Bind( 0 );
		tex->Enable();
		r3::DrawSprite( -10, -10, 10, 10 );
		tex->Disable();
		glPopMatrix();
	}
	
	void InitAndUpdate() {
		if ( font == NULL ) {
			font = r3::CreateStbFont( app_font.GetVal(), (float)app_fontSize.GetVal() ); 			
		}
		if ( fov != r_fov.GetVal() ) {
			fov = r_fov.GetVal();
			fovFontScale = app_fontScale.GetVal() * sin( ToRadians( fov ) );
		}		
		static int localTransformVersion = 0;
		if ( transformVersion != localTransformVersion ) {
			
		}
	}
	
	OrientedBounds2f StringBounds( const std::string & s, const Vec3f & direction ) {
		InitAndUpdate();
		Bounds2f b = font->GetStringDimensions( s, fovFontScale );
		
		Matrix4f m = RotateTo( direction );
		Matrix4f mt;
		mt.SetScale( app_scale.GetVal() );
		mt.SetTranslate( Vec3f( 0, 0, -1 ) );
		Matrix4f xf = GetTransform() * m * mt;
		
		Vec4f pts[4];
		Vec2f bias( -b.Width() / 2.f, -1.5f * b.Height() );
		pts[0] = xf * Vec4f( b.Min().x + bias.x, b.Min().y + bias.y );
		pts[1] = xf * Vec4f( b.Max().x + bias.x, b.Min().y + bias.y );
		pts[2] = xf * Vec4f( b.Max().x + bias.x, b.Max().y + bias.y );
		pts[3] = xf * Vec4f( b.Min().x + bias.x, b.Max().y + bias.y );
		OrientedBounds2f ob;
		for ( int i = 0; i < 4; i++ ) {
			float w = pts[i].w;
			if ( w > 0 ) {
				ob.vert[ i ] = Vec2f( pts[ i ].x / w, pts[ i ].y / w );
			} else {
				return OrientedBounds2f(); // just send an empty bounds if we have negative w
			}
		}
		ob.empty = false;
		return ob;
	}

	void DrawString( const std::string & s, const Vec3f & direction ) {
		InitAndUpdate();
		Bounds2f b = font->GetStringDimensions( s, fovFontScale );
		
		Matrix4f m = RotateTo( direction );
		glPushMatrix();
		glMultMatrixf( m.Ptr() );
		glScalef( app_scale.GetVal(), app_scale.GetVal(), 1.f );
		glTranslatef( 0, 0, -1 );
		font->Print( s, -b.Width() / 2.f, -1.5f * b.Height(), (float)fovFontScale );
		glPopMatrix();
	}
	
	void DrawStringAtLocation( const std::string & s, const Vec3f & position, const Matrix4f & rotation ) {
		InitAndUpdate();
		Bounds2f b = font->GetStringDimensions( s, 20.0f );
		
		
		glPushMatrix();
		glTranslatef( position.x, position.y, position.z );
		glMultMatrixf( rotation.Ptr() );
		float sc = app_scale.GetVal();
		glScalef( sc, sc, 1.f );
		font->Print( s, -b.Width() / 2.f, -1.5f * b.Height(), 20.0f );
		glPopMatrix();
	}
	
	void DrawDebugGrid() {
		
		for ( int i = 0; i < 360; i+= 15 ) {
			ImVarying( Varying_ColorBit );
			ImBegin( Primitive_LineStrip );
			for ( int j = -90; j <= 90; j+= 15 ) {
				Vec3f v = SphericalToCartesian( 1.0f, ToRadians(float(j)), ToRadians(float(i)) );
				Vec3f c = v * 0.5f + Vec3f(0.5f, 0.5f, 0.5f);
				ImColorf( c.x, c.y, c.z );
				ImVertex( v.x, v.y, v.z );
			}
			ImEnd();
		}
		for ( int j = -90; j < 90; j+= 15 ) {
			ImVarying( Varying_ColorBit );
			ImBegin( Primitive_LineStrip );
			for ( int i = 0; i <= 360; i+= 15 ) {
				Vec3f v = SphericalToCartesian( 1.0f, ToRadians(float(j)), ToRadians(float(i)) );
				Vec3f c = v * 0.5f + Vec3f(0.5f, 0.5f, 0.5f);
				ImColorf( c.x, c.y, c.z );
				ImVertex( v.x, v.y, v.z );
			}
			ImEnd();
		}
		
	}

	Vec3f SphericalToCartesian( float rho, float phi, float theta ) {
		Vec3f p( cos( phi ) * cos( theta ), cos( phi ) * sin( theta ), sin( phi ) );
		p *= rho;
		return p;	
	}
	
	Vec3f CartesianToSpherical( const Vec3f & c ) {
		Vec3f s;
		// rho
		s.x = c.Length();
		// phi
		s.y = atan2( c.z, sqrt( c.x * c.x + c.y * c.y ) );
		// theta
		s.z = atan2( c.y, c.x );
		return s;
	}
	
}

