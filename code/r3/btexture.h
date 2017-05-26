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


#ifndef __R3_TEXTURE_H__
#define __R3_TEXTURE_H__

#include <string>

namespace r3 {
	
	void InitTexture();
	
	enum TextureFormatEnum {
		TextureFormat_INVALID,
		TextureFormat_L,
		TextureFormat_LA,
		TextureFormat_RGB,
		TextureFormat_RGBA,
		TextureFormat_DepthComponent,
		TextureFormat_MAX
	};

	enum TextureTargetEnum {
		TextureTarget_1D,
		TextureTarget_2D,
		TextureTarget_3D,
		TextureTarget_Cube
	};
	
	enum TextureFilterEnum {
		TextureFilter_None,
		TextureFilter_Nearest,
		TextureFilter_Linear
	};

	struct SamplerParams {
		SamplerParams() 
		: magFilter( TextureFilter_Linear )
		, minFilter( TextureFilter_Linear )
		, mipFilter( TextureFilter_Linear )
		, levelBias( 0.0f )
		, levelMin( 0.0f )
		, levelMax( 128.0f )
		, anisoMax( 4.0f )
		{}
		
		SamplerParams( TextureFilterEnum tfMagFilter, TextureFilterEnum tfMinFilter, TextureFilterEnum tfMipFilter, float tfLevelBias, float tfLevelMin, float tfLevelMax, float tfAnisoMax )
		: magFilter( tfMagFilter )
		, minFilter( tfMinFilter )
		, mipFilter( tfMipFilter )
		, levelBias( tfLevelBias )
		, levelMin( tfLevelMin )
		, levelMax( tfLevelMax )
		, anisoMax( tfAnisoMax )
		{}
		
		TextureFilterEnum magFilter;
		TextureFilterEnum minFilter;
		TextureFilterEnum mipFilter;
		float levelBias;
		float levelMin;
		float levelMax;
		float anisoMax;
	};
	
	class Texture {
		std::string name; 
		TextureFormatEnum format;
		TextureTargetEnum target;
		SamplerParams sampler;
	protected:
		Texture( const std::string & texName, TextureFormatEnum texFormat, TextureTargetEnum texTarget );
	public:
		~Texture();
		
		void Bind( int imageUnit );
		void Enable();
		void Disable();
		
		const std::string & Name() {
			return name;
		}

		TextureFormatEnum Format() {
			return format;
		}
		TextureTargetEnum Target() {
			return target;
		}
		
		const SamplerParams & Sampler() const {
			return sampler;
		}
		void SetSampler( const SamplerParams & s );
		
	};
	
	class Texture2D : public Texture {
		int width;
		int height;
		Texture2D( const std::string & n, TextureFormatEnum f, int w, int h );
	public:
		static Texture2D *Create( const std::string &n, TextureFormatEnum f, int w, int h );
		int Width() const {
			return width;
		}
		
		int Height() const {
			return height;
		}
		
		void SetImage( int level, void *data );
	};
	
	Texture2D * CreateTexture2DFromFile( const std::string & filename, TextureFormatEnum f = TextureFormat_INVALID );

	
}

#endif // __R3_TEXTURE_H__