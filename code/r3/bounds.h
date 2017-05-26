/*
 bounds

 Copyright (c) 2010 Cass Everitt

 from glh library - 
 
 Copyright (c) 2000-2009 Cass Everitt
 Copyright (c) 2000 NVIDIA Corporation
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

// Author:  Cass W. Everitt

#ifndef __R3_BOUNDS_H__
#define __R3_BOUNDS_H__

#include <algorithm>
#include "r3/linear.h"

namespace r3 {

	struct Bounds2f {
		Bounds2f() { Clear(); }
		Bounds2f( const Vec2f &pmin, const Vec2f &pmax ) : bMin( pmin ), bMax( pmax ) {}
		Bounds2f( float x0, float y0, float x1, float y1 ) : bMin( x0, y0 ), bMax( x1, y1 ) {}
			
		void Set( float x0, float y0, float x1, float y1 ) {
			bMin.SetValue( x0, y0 );
			bMax.SetValue( x1, y1 );
		}
		
		void Scale( float s ) {
			bMin *= s;
			bMax *= s;
		}
		
		// negative inset grows bounds
		void Inset( float f ) {
			Vec2f v( f, f );
			bMin = bMin + v;
			bMax = bMax - v;
		}
		void Clear() { bMin = Vec2f( 1e20f, 1e20f );  bMax = Vec2f( -1e20f, -1e20f ); }
		bool IsClear() { return bMin[0] > bMax[0]; }

		bool IsInside( const Vec2f & p ) {
			return bMin.x <= p.x && bMin.y <= p.y && bMax.x >= p.x && bMax.y >= p.y;
		}

		void Add( const Vec2f v ) {
			if ( IsClear() ) {
				bMin = bMax = v;
				return;
			}
			bMin[0] = v[0] < bMin[0] ? v[0] : bMin[0];
			bMin[1] = v[1] < bMin[1] ? v[1] : bMin[1]; 
			bMax[0] = v[0] > bMax[0] ? v[0] : bMax[0];
			bMax[1] = v[1] > bMax[1] ? v[1] : bMax[1];
		}
		
		Vec2f & Min() { return bMin; }
		Vec2f & Max() { return bMax; }
		
		float Width() const { return bMax[0] - bMin[0]; }
		float Height() const { return bMax[1] - bMin[1]; }
		Vec2f Mid() const { return ( bMax + bMin ) * 0.5f; }
		const Vec2f & Min() const { return bMin; }
		const Vec2f & Max() const { return bMax; }
		Vec2f bMin;
		Vec2f bMax;
	};

	inline Bounds2f Intersection( const Bounds2f & a, const Bounds2f & b ) {
		Bounds2f r;
		r.Min() = Max( a.Min(), b.Min() );
		r.Max() = Min( a.Max(), b.Max() );
		return r;
	}
	
	struct OrientedBounds2f {
		OrientedBounds2f() : empty( true ) {}
		bool empty;
		Vec2f vert[4];
	};
	
	inline bool Intersect( const OrientedBounds2f & a, const OrientedBounds2f & b ) {
		int ind[] = { 0, 1, 2, 3, 0 };

		// do any segments intersect ?
		for ( int i = 0; i < 4; i++ ) {
			LineSegment2f sa( a.vert[ ind[ i ] ], a.vert[ ind[ i + 1 ] ] );
			for ( int j = 0; j < 4; j++ ) {
				LineSegment2f sb( b.vert[ ind[ j ] ], b.vert[ ind[ j + 1 ] ] );
				if ( Intersect( sa, sb ) ) {
					return true;
				}
			}
		}

		// is a completely inside b ?
		bool inside = true;
		for ( int i = 0; i < 4 && inside ; i++ ) {
			LineSegment2f sb( b.vert[ ind[ i ] ], b.vert[ ind[ i + 1 ] ] );
			Vec3f pl = sb.GetPlane();
			for ( int j = 0; j < 4 && inside ; j++ ) {
				inside = pl.Dot( Vec3f( a.vert[ j ].x, a.vert[ j ].y, 1 ) ) > 0.0f;
			}
		}
		if ( inside ) {
			return true;
		}
		
		// is b completely inside a ?
		inside = true;
		for ( int i = 0; i < 4 && inside ; i++ ) {
			LineSegment2f sa( a.vert[ ind[ i ] ], a.vert[ ind[ i + 1 ] ] );
			Vec3f pl = sa.GetPlane();
			for ( int j = 0; j < 4 && inside ; j++ ) {
				inside = pl.Dot( Vec3f( b.vert[ j ].x, b.vert[ j ].y, 1 ) ) > 0.0f;
			}
		}
		if ( inside ) {
			return true;
		}
		
		
		return false;
	}
	
	
}

#endif // __R3_BOUNDS_H__

