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

#ifndef __STAR3MAP_RENDER_H__
#define __STAR3MAP_RENDER_H__

#include "r3/bounds.h"
#include "r3/linear.h"
#include "r3/btexture.h"
#include <string>
#include <vector>

namespace star3map {

	extern r3::Vec3f UpVector;
	
	
	// we get a static list of these for each star at
	// startup, and generate a new list for the solar system
	// each frame...
	struct Sprite {
		std::string name;
		r3::Vec3f direction;
		float magnitude;
		float scale;
		r3::Vec4f color;
		r3::Texture2D *tex;
	};
	
	// for constellations
	struct Lines {
		std::string name;
        std::string localizedName;
		std::vector< r3::Vec3f > vert;
		r3::Vec3f center;
		float limit;
	};
			
	void Clear();
	void SetColor( const r3::Vec4f & c );
    
	void PushTransform();
	void ClearTransform();
	void PopTransform();
	
	void ApplyTransform( const r3::Matrix4f &m );
	r3::Matrix4f GetTransform();
	
	void DrawQuad(  float radius, const r3::Vec3f & direction  ); 
	
	void DrawSprite( r3::Texture2D *tex, r3::Bounds2f bounds );
	
    void DrawSprite( r3::Texture2D *tex, float radius, const r3::Vec3f & direction, const r3::Vec3f & lookDir );
    
	void DrawSprite( r3::Texture2D *tex, float radius, const r3::Vec3f & direction ); 

	r3::OrientedBounds2f StringBounds( const std::string & str, const r3::Vec3f & direction );

	void DrawString( const std::string & str, const r3::Vec3f & direction);
	void DrawStringAtLocation( const std::string & str, const r3::Vec3f & position, const r3::Matrix4f & rotation );
	
	void DrawDebugGrid();

	r3::Vec3f SphericalToCartesian( float rho, float phi, float theta );
	r3::Vec3f CartesianToSpherical( const r3::Vec3f & c );
}

#endif //__STAR3MAP_RENDER_H__
