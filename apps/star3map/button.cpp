/*
 *  button
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

#include "button.h"
#include "render.h"

#include "r3/command.h"
#include "r3/common.h"

using namespace r3;
using namespace std;

float GUIAlpha = 1.0f;
bool ButtonWasPressed = false;

namespace star3map {
	
	Button::Button( const std::string & bTextureFilename ) 
	: tex( NULL ), inputOver( false ), color( 1, 1, 1, 1 )  {
		tex = CreateTexture2DFromFile( bTextureFilename, TextureFormat_RGBA );
		bounds.Min() = Vec2f( 0, 0 );
		bounds.Max() = Vec2f( (float)tex->Width(), (float)tex->Height() );
	}
	
	Button::~Button() {
		delete tex;
	}

	void Button::Draw() {
		Vec4f c = color;
        c.w *= GUIAlpha;
		if ( inputOver ) {
			SetColor( c );
		} else {
			c *= .85f;
			SetColor( c );			
		}
		star3map::DrawSprite( tex, bounds );
	}
	
	bool Button::ProcessInput( bool active, int x, int y ) {
		if ( bounds.IsInside( Vec2f( (float)x, (float)y ) ) ) {
			inputOver = active;
			if ( active == false ) {
				Pressed();
			}
			return true;
		} else {
			inputOver = false;
			return false;
		}
		
	}
	
	PushButton::PushButton( const string & pbTextureFilename, const string & pbCommand ) 
	: Button( pbTextureFilename ), command( pbCommand ) {
	}
	
	void PushButton::Pressed() {
        if(GUIAlpha >= 0.9f)
        {
            ExecuteCommand( command.c_str() );
            ButtonWasPressed = true;
        }
	}
	
	ToggleButton::ToggleButton( const string & tbTextureFilename, const string & tbVarName ) 
	: Button( tbTextureFilename ), onColor( .4f, 1.f, .4f, .9f ), offColor( .65f, .65f, .65f, .75f ) {
		var = FindVar( tbVarName.c_str() );
		float f;
		if ( StringToFloat( var->Get(), f ) ) {
			color = ( f != 0 ) ? onColor : offColor;
		}
	}
	
	void ToggleButton::Draw() {
		float f;
		if ( StringToFloat( var->Get(), f ) ) {
			color = ( f != 0 ) ? onColor : offColor;
		}
		Button::Draw();
	}
	
	void ToggleButton::Pressed() {
		if ( var == NULL ) {
			return;
		}
		char cmd[128];
		r3Sprintf( cmd, "toggle %s", var->Name().Str().c_str() );
        
        if(GUIAlpha >= 0.9f)
        {
            ExecuteCommand( cmd );
            ButtonWasPressed = true;
        }
		
		float f;
		if ( StringToFloat( var->Get(), f ) ) {
			color = ( f != 0 ) ? onColor : offColor;
		}
		
	}
	
}

