/*
 *  font
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

#include "r3/bounds.h"
#include "r3/common.h"
#include "r3/draw.h"
#include "r3/filesystem.h"
#include "r3/font.h"
#include "r3/output.h"
#include "r3/btexture.h"

#include <map>
#include <string>

using namespace std;
using namespace r3;

#define STB_TRUETYPE_IMPLEMENTATION  // force following include to generate implementation
#include "stb_truetype.h"

#include <math.h>
#include <assert.h>

namespace {
	
	struct FontDatabase {
		map< string, r3::Font * > fontMap;
		string GetName( const string & name, int imgSize ) {
			char szstr[32];
			r3Sprintf( szstr, "_%d", imgSize );
			return name + szstr;
		}
		r3::Font * GetFont( const string & fullname ) {
			if ( fontMap.count( fullname ) ) {
				return fontMap[ fullname ];
			}
			return NULL;
		}
		void AddFont( const string & fullname, r3::Font * f ) {
			assert( fontMap.count( fullname ) == 0 );
			assert( f != NULL );
			fontMap[ fullname ] = f;
		}		
	};
	FontDatabase *fontDatabase;

	bool initialized = false;
	
	
	void GetBakedScaledQuad(stbtt_bakedchar *chardata, int pw, int ph, int char_index, float *xpos, float ypos, float scale, stbtt_aligned_quad *q )
	{
		stbtt_bakedchar *b = chardata + char_index;
		
		q->x0 = (*xpos + b->xoff * scale );
		q->y0 = ( ypos + b->yoff * scale );
		q->x1 = q->x0 + ( b->x1 - b->x0 ) * scale;
		q->y1 = q->y0 + ( b->y1 - b->y0 ) * scale;
		
		q->s0 = (b->x0 - 0.5f) / pw;
		q->t0 = (b->y0 - 0.5f) / pw;
		q->s1 = (b->x1 + 0.5f) / ph;
		q->t1 = (b->y1 + 0.5f) / ph;
		
		*xpos += b->xadvance * scale;
	}
	
	struct StbFont : public Font {
		StbFont( const string & texName, const string & ttfFilename, int imageSize );
		virtual void Print( const std::string &text, float x, float y, float scale = 1.0f );	
		virtual Bounds2f GetStringDimensions( const std::string &text, float scale = 1.0f );
		stbtt_bakedchar cdata[96]; // ASCII 32..126 is 95 glyphs
		int imgSize;
		Texture2D *ftex;
	};
	
	StbFont::StbFont( const string & texName, const string & ttfFilename, int imageSize ) {
		unsigned char *ttf_buffer = new unsigned char[ 1 << 20 ];
		unsigned char *temp_bitmap = new unsigned char[ 2 * imageSize * imageSize ];
		imgSize = imageSize;
		File *f = FileOpenForRead( ttfFilename );
		f->Read( ttf_buffer, 1, 1<<20 );
		delete f;
		stbtt_BakeFontBitmap( ttf_buffer, 0, 32.0, temp_bitmap, imageSize, imageSize, 32, 96, cdata ); // no guarantee this fits!
		// can free ttf_buffer at this point
		ftex = Texture2D::Create( texName, TextureFormat_LA, imageSize, imageSize );
		
		for ( int i = imgSize * imgSize - 2; i >= 0; i-=2 ) {
			temp_bitmap[ i + 0 ] = 255;                   // Luminance
			temp_bitmap[ i + 1 ] = temp_bitmap[ i >> 1 ]; // Alpha
		}
		
		ftex->SetImage( 0, temp_bitmap );
		// can free temp_bitmap at this point
		//glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR );
		//glGenerateMipmapOES( GL_TEXTURE_2D );
		delete [] ttf_buffer;
		delete [] temp_bitmap;		
	}
	
	
	
	void StbFont::Print( const string &text, float x, float y, float scale ) {
		if ( ftex == 0 ) {
			return;
		}
		// assume orthographic projection with units = screen pixels, origin at top left
		ftex->Bind( 0 );
		ftex->Enable();
		
		ImVarying( Varying_TexCoord0Bit );
		//ImColor( 255, 192, 128, 255 );
		ImBegin( Primitive_Quads );
		for ( int i = 0; i < (int)text.size(); i++ ) {
			char c = text[i];
			if ( c >= 32 ) {
				stbtt_aligned_quad q;
				//stbtt_GetBakedQuad(cdata, 512,512, *text-32, &x,&bakeY,&q,0); //1=opengl,0=old d3d
				GetBakedScaledQuad( cdata, imgSize, imgSize, c-32, &x, 0, scale, &q ); 
				DrawTexturedQuad( q.x0, y - q.y0, q.x1, y - q.y1, q.s0, q.t0, q.s1, q.t1 );
				/*
				ImTexCoord( 0, q.s0, q.t0 );			ImVertex( q.x0, y - q.y0 );
				ImTexCoord( 0, q.s1, q.t0 );			ImVertex( q.x1, y - q.y0 );
				ImTexCoord( 0, q.s1, q.t1 );			ImVertex( q.x1, y - q.y1 );
				ImTexCoord( 0, q.s0, q.t1 );			ImVertex( q.x0, y - q.y1 );
				 */
			}
		}
		ImEnd();
		ftex->Disable();
	}
	
	Bounds2f StbFont::GetStringDimensions( const std::string & text, float scale ) {
		float x = 0;
		float y = 0;
		Bounds2f b;
		for ( int i = 0; i < (int)text.size(); i++ ) {
			char c = text[i];
			if ( c >= 32 ) {
				stbtt_aligned_quad q;
				stbtt_GetBakedQuad(cdata, imgSize, imgSize, c-32, &x,&y,&q,0); //1=opengl,0=old d3d
				b.Add( Vec2f( q.x0, -q.y0 ) );
				b.Add( Vec2f( q.x1, -q.y1 ) );
				//Output(" char=\'%c\', x1=%f, x=%f\n", c, (float)q.x1, x ); 
			}
		}
		b.Add( Vec2f( x, y ) );
		b.Scale( scale );
		return b;
	}
	
}


namespace r3 {
	
	void InitFont() {
		if ( initialized ) {
			return;
		}
		fontDatabase = new FontDatabase();
		initialized = true;
		
	}

	// FIXME: make this honor point size
	Font * CreateStbFont( const std::string &ttfname, float pointSize ) {
		assert( initialized );
		int imgSize = (int)pow( 2.0, ceil( log( 32 * pointSize ) / log( 2.0 ) ) ) + 0.5;
		string fn = fontDatabase->GetName( ttfname, imgSize );
		Font * f = fontDatabase->GetFont( fn );
		if ( f == NULL ) {
			f = new StbFont( fn, ttfname, imgSize );
			fontDatabase->AddFont( fn, f );
			Output( "Returning existing font for \"%s\"", fn.c_str() );
		}
		return f;
	}

	
}
