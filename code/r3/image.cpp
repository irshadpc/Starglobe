/*
 *  image
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

#include "r3/image.h"
#include "r3/filesystem.h"


#include <vector>

using namespace std;
using namespace r3;

#define STBI_HEADER_FILE_ONLY
#include "stb_image.c"

namespace {
	
	class StbImage : public Image<unsigned char> {
		unsigned char *data;
	public:
		StbImage() : data( NULL ) {
		}
		StbImage( const string & filename, int desiredComponents ) : data( NULL ) {
			Load( filename, desiredComponents );
		}
		virtual ~StbImage() {
			Free();
		}
		virtual void *Data() {
			return data;
		}
		void Free() {
			delete [] data;
			data = NULL;
		}
		void Load( const string & filename, int desiredComponents ) {
			vector< unsigned char > v;
			FileReadToMemory( filename, v );
			int c = 0;
			if ( v.size() > 0 ) {
				unsigned char *d = stbi_load_from_memory(& v[0], v.size(), &width, &height, &components, desiredComponents);
				c = max( desiredComponents, components );
				data = new unsigned char[ width * height * c ];
				int pitch = width * c;
				for ( int j = 0; j < height; j++ ) {
					memcpy( data + ( height - 1 - j ) * pitch, d + j * pitch, pitch );
				}
				stbi_image_free( d );
			}
			// compute alpha as "is rgb effectively non-zero" if it doesn't exist in the input image
			if ( desiredComponents == 4 && components == 3 ) {
				unsigned char *uc = data;
				int sum = 0;
				for ( int i = 0; i < width * height * 4; i++ ) {
					if ( ( i & 0x3 ) == 0x3 ) {
						*uc++ = sum > 0x10 ? 255 : 0;
						sum = 0;
					} else {
						sum += *uc++;
					}
				}
			}
			// assume LA in this case, but I'm not sure this is a good assumption...
			if ( desiredComponents == 4 && components == 2 ) {
				unsigned char *uc = data;
				for ( int i = 0; i < width * height; i++ ) {
					uc[3] = uc[1];
					uc[0] = uc[1] = uc[2] = uc[0];
					uc += 4;
				}
			}
			
			// make an alpha texture, but with RGB == white
			if ( desiredComponents == 4 && components == 1 ) {
				unsigned char *uc = data;
				for ( int i = 0; i < width * height; i++ ) {
					uc[3] = uc[0];
					uc[0] = uc[1] = uc[2] = 255;
					uc += 4;
				}
			}
			
			components = desiredComponents;
		}
	};
	
}


namespace r3 {

	Image<unsigned char> * LoadStbImage( const std::string & filename, int desiredComponents ) {
		return new StbImage( filename, desiredComponents );
	}
}
