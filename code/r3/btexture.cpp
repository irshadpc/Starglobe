/*
 *  texture
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

#include "r3/btexture.h"

#include "r3/command.h"
#include "r3/image.h"
#include "r3/output.h"

#include "r3/gl.h"

#include <map>

#include <assert.h>


using namespace std;
using namespace r3;

namespace {
	
	const GLenum GlTarget[] = {
		GL_TEXTURE_1D,       // TextureTarget_1D,
		GL_TEXTURE_2D,       // TextureTarget_2D,
		GL_TEXTURE_3D,       // TextureTarget_3D,
		GL_TEXTURE_CUBE_MAP, // TextureTarget_Cube		
	};

#if ! TARGET_OS_IPHONE
	const GLenum GlInternalFormat[] = {
		0,                          // TextureFormat_INVALID,
		GL_LUMINANCE,               // TextureFormat_L,
		GL_LUMINANCE_ALPHA,         // TextureFormat_LA,
		GL_RGB8,                    // TextureFormat_RGB,
		GL_RGBA8,                   // TextureFormat_RGBA,
		GL_DEPTH_COMPONENT16,		// TextureFormat_DepthComponent,
		0                           // TextureFormat_MAX
	};
#endif
	
	const GLenum GlFormat[] = {
		0,                          // TextureFormat_INVALID,
		GL_LUMINANCE,               // TextureFormat_L,
		GL_LUMINANCE_ALPHA,         // TextureFormat_LA,
		GL_RGB,                     // TextureFormat_RGB,
		GL_RGBA,                    // TextureFormat_RGBA,
		GL_DEPTH_COMPONENT,			// TextureFormat_DepthComponent,
		0                           // TextureFormat_MAX
	};
	
	const char *FormatString[] = {
		"INVALID",                  // TextureFormat_INVALID,
		"L",                        // TextureFormat_L,
		"LA",                       // TextureFormat_LA,
		"RGB",                      // TextureFormat_RGB,
		"RGBA",                     // TextureFormat_RGBA,
		"WTF?"                      // TextureFormat_MAX
	};
	
	
	const GLenum GlMagFilt[3] = {
		GL_NEAREST, // TextureFilter_None		
		GL_NEAREST, // TextureFilter_Nearest
		GL_LINEAR   // TextureFilter_linear		
	};
	
	const GLenum GlMipMinFilt[3][3] = { // indexed by [MipFilt][MinFilt]
		{ // MipFilt = None
			GL_NEAREST,  // None
			GL_NEAREST,  // Nearest
			GL_LINEAR    // Linear
		},
		{ // MipFilt = Nearest
			GL_NEAREST_MIPMAP_NEAREST,  // None
			GL_NEAREST_MIPMAP_NEAREST,  // Nearest
			GL_NEAREST_MIPMAP_LINEAR    // Linear
		},
		{ // MipFilt = Linear
			GL_LINEAR_MIPMAP_NEAREST,  // None
			GL_LINEAR_MIPMAP_NEAREST,  // Nearest
			GL_LINEAR_MIPMAP_LINEAR    // Linear
		}
	};

	
	struct TexInfo {
		TexInfo() {}
		TexInfo( GLuint tiObj, Texture *tiTex ) : obj( tiObj ), tex( tiTex ) {}
		GLuint obj;
		Texture *tex;
	};

	struct TextureDatabase {
		map< string, TexInfo > textures;
		Texture * GetTexture( const string & name ) {
			if ( textures.count( name ) ) {
				return textures[ name ].tex;
			}
			return NULL;
		}
		GLuint GetTextureObject( const string & name ) {
			if ( textures.count( name )  ) {
				return textures[name].obj;
			}
			return 0;
		}
		void AddTexture( const string & name, Texture * tex ) {
			assert( textures.count( name ) == 0 );
			GLuint obj;
			glGenTextures( 1, & obj );
			textures[ name ] = TexInfo( obj, tex );
		}
		void DeleteTexture( const string & name ) {
			assert( textures.count( name ) == 0 );
			glDeleteTextures( 1, & textures[name].obj );
			textures.erase( name );
		}
	};
	TextureDatabase *textureDatabase;
	
	int modBindUnit = 0; // what texture unit is used for "bind for modification"?
	
	bool initialized = false;
	
	// listTextures command
	void ListTextures( const vector< Token > & tokens ) {
		if ( textureDatabase == NULL ) {
			return;
		}
		map< string, TexInfo > &textures = textureDatabase->textures;;
		for( map< string, TexInfo >::iterator it = textures.begin(); it != textures.end(); ++it ) {
			const string & n = it->first;
			TexInfo &ti = it->second;
			const char *fmt = FormatString[ (int)ti.tex->Format() ];
			switch ( ti.tex->Target() ) {
			case TextureTarget_2D:
				{
					Texture2D *t = (Texture2D *)ti.tex;
					Output( "2D - w=%d h=%d fmt=%s - %s", t->Width(), t->Height(), fmt, n.c_str() );					
				}
				break;
			default:
				break;
			}
		}
	}
	CommandFunc ListTexturesCmd( "listtextures", "lists defined textures", ListTextures );
	
	
	
}


namespace r3 {
	
	void InitTexture() {
		if ( initialized ) {
			return;
		}
		textureDatabase = new TextureDatabase;
		initialized = true;
	}
	
	Texture::Texture( const std::string & texName, TextureFormatEnum texFormat, TextureTargetEnum texTarget )
	: name( texName ), format( texFormat ), target( texTarget ) {
		textureDatabase->AddTexture( name, this );
		SetSampler( sampler );
	}

	Texture::~Texture() {
		textureDatabase->DeleteTexture( name );
	}
	
	
	Texture *textureBindShadow[16];
	
	void Texture::Bind( int imageUnit ) {
		if ( textureBindShadow[ imageUnit ] == this ) {
			return;
		}
		glActiveTexture( GL_TEXTURE0 + imageUnit );
        //glEnable(GL_TEXTURE_2D);
		glBindTexture( GlTarget[ target ], textureDatabase->GetTextureObject( name ) );
        
		//textureBindShadow[ imageUnit ] = this;
	}
	
	void Texture::Enable() {
		glEnable( GlTarget[ target ] );
	}

	void Texture::Disable() {
		glDisable( GlTarget[ target ] );
	}
	
	void Texture::SetSampler( const SamplerParams & s ) {
		Bind(modBindUnit);
		sampler = s;
		GLenum t = GlTarget[ target ];
		glTexParameteri( t, GL_TEXTURE_MAG_FILTER, GlMagFilt[ s.magFilter ] );
		glTexParameteri( t, GL_TEXTURE_MIN_FILTER, GlMipMinFilt[ s.mipFilter ][ s.minFilter ] );
		glTexParameterf( t, GL_TEXTURE_LOD_BIAS, s.levelBias );
		glTexParameterf( t, GL_TEXTURE_MIN_LOD, s.levelMin );
		glTexParameterf( t, GL_TEXTURE_MAX_LOD, s.levelMax );
		glTexParameterf( t, GL_TEXTURE_MAX_ANISOTROPY_EXT, s.anisoMax );
	} 
	
	
	Texture2D::Texture2D( const std::string & texName, TextureFormatEnum texFormat, int texWidth, int texHeight )
	: Texture( texName, texFormat, TextureTarget_2D ), width( texWidth ), height( texHeight ) {
	}
	
	Texture2D * Texture2D::Create( const std::string & texName, TextureFormatEnum texFormat, int texWidth, int texHeight ) {
		if ( textureDatabase->GetTexture( texName ) ) {
			//Output( "texName \"%s\" already in use.  Returning NULL.", texName.c_str() );
			return NULL;
		}
		return new Texture2D( texName, texFormat, texWidth, texHeight );
	}

		
	void Texture2D::SetImage( int level, void *data ) {
		glTexImage2D( GlTarget[ Target() ], level, GlInternalFormat[ Format() ], width, height, 0, GlFormat[ Format() ], GL_UNSIGNED_BYTE, data );
		glGenerateMipmapEXT( GlTarget[ Target() ] );
	}
	
	Texture2D * CreateTexture2DFromFile( const std::string & filename, TextureFormatEnum f ) {
		Texture2D * tex;
		if ( tex = (Texture2D *)textureDatabase->GetTexture( filename ) ) {
			//Output( "Returned already loaded texture %s", filename.c_str() );
			return tex;
		}
		Image<unsigned char> * img = LoadStbImage( filename, f );
		
		tex = Texture2D::Create( filename, (TextureFormatEnum)img->Components(), img->Width(), img->Height() );
		tex->SetImage( 0, img->Data() );
		//Output( "Loaded image %s (w=%d, h=%d)", filename.c_str(), img->Width(), img->Height() );
		delete img;
		return tex;
	}
	
	
}
