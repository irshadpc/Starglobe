/*
 *  console
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


#include "r3/console.h"
#include "r3/command.h"
#include "r3/common.h"
#include "r3/input.h"
#include "r3/output.h"
#include "r3/var.h"
#include "r3/font.h"
#include "r3/draw.h"

using namespace std;
using namespace r3;

r3::VarString con_font( "con_font", "console font", Var_Archive, "Roboto-Regular.ttf" );
r3::VarInteger con_fontSize( "con_fontSize", "console font rasterization size", Var_Archive, 12 );
r3::VarFloat con_fontScale( "con_fontScale", "console font rendering scale", Var_Archive, 0.5 );
r3::VarInteger con_scrollBuffer( "con_scrollBuffer", "console scrollback buffer size", Var_Archive, 1000 );
r3::VarFloat con_opacity( "con_opacity", "opacity of the console display", Var_Archive, 0.5f );

r3::Console r3::console;	

namespace {

	Font *font;	
	
	void InitConsoleBindings() {
		InitInput();
		ExecuteCommand( "bind ` activateconsole" );
	}

	void ConsoleProcessKeyEvent( int key, KeyStateEnum keyState ) {
		console.ProcessKeyEvent( key, keyState );
	}
	
	// ActivateConsole command
	void ActivateConsole( const vector< Token > & tokens ) {
		fprintf(stderr, "Activating console!\n" );
		console.Activate();
	}	
	CommandFunc ActivateConsoleCmd( "activateconsole", "activates the console to acquire keyboard input", ActivateConsole );
	
	// DeactivateConsole command
	void DeactivateConsole( const vector< Token > & tokens ) {
		fprintf(stderr, "Deactivating console!\n" );
		console.Deactivate();
	}	
	CommandFunc DeactivateConsoleCmd( "deactivateconsole", "deactivates the console and restores previous keyboard input handler", DeactivateConsole );
	
	
	void AttemptCompletion( string & commandLine, int & cursorPos ) {
		// pad cmdline for simplicity
		string cmdLine = " " + commandLine + " ";
		int pos = cursorPos + 1;
		// back the pos up by one if it is directly in front of an arg 
		if ( cmdLine[ pos ] == ' ' && cmdLine[ pos - 1 ] != ' ' ) {
			pos--;
		}
		
		int bgn = pos;
		int end = pos;
		
		while( cmdLine[ bgn - 1 ] != ' ' ) {
			bgn--;
		}
		while( cmdLine[ end ] != ' ' ) {
			end++;
		}
		
		int len = end - bgn;
		if ( len == 0 ) {
			return;
		}
		
		string arg = cmdLine.substr( bgn, len );
		// switch back to the non-padded version
		bgn --;
		end --;
		//Output( "Arg to attempt completion on: %s (%d, %d)\n", arg.c_str(), bgn, len );

		vector< string > matches;
		for ( int i = 0; i < GetAtomTableSize(); i++ ) {
			string candidate = GetAtom( i ).Str();
			if ( candidate.compare( 0, len, arg ) == 0 ) {
				matches.push_back( candidate );
			}
		}

		if ( matches.size() > 0 ) {
			sort( matches.begin(), matches.end() );
			if ( matches.size() > 1 ) {
				Output( "Found %d matches:", (int)matches.size() );
			}
			int minLen = 100000;
			for ( int i = 0; i < matches.size(); i++ ) {
				minLen = min( minLen, (int)matches[ i ].size() );
				if ( matches.size() > 1 ) {
					Output( "  %s", matches[ i ].c_str() );
				}
			}
			for( int i = arg.size(); i < minLen; i++ ) {
				bool mismatch = false;
				for ( int j = 1; j < matches.size(); j++ ) {
					if ( matches[0][i] != matches[j][i] ) {
						mismatch = true;
						break;
					}					
				}
				if ( mismatch ) {
					break;
				}
				arg.push_back( matches[0][i] );
			}
			//Output( "replace old arg with \"%s\"\n", arg.c_str() );
			commandLine.replace( bgn, len, arg);
			cursorPos = bgn + arg.size();
			
		} else {
			Output( "No matches found." );
		}

		
	}
	
	
}

extern VarInteger r_windowWidth;
extern VarInteger r_windowHeight;


namespace r3 {
	
	
	Console::Console() : cursorPos( 0 ), historyPos( 0 ) {
		//fprintf(stderr,"Constructing console singleton\n");
		InitConsoleBindings();
		history.push_front( string() );
	}
	
	void Console::Activate() {
		if ( ! active ) {
			active = true;
			previousHandler = SetKeyHandler( ConsoleProcessKeyEvent );
		}
	}
	
	void Console::Deactivate() {
		if ( active ) {
			active = false;
			SetKeyHandler( previousHandler );
			previousHandler = NULL;
		}
	}
	
	void Console::AppendOutput( const string & str ) {
		outputBuffer.push_back( str );
		if ( outputBuffer.size() > con_scrollBuffer.GetVal() ) {
			outputBuffer.pop_front();
		}		
	}
	
	void Console::ProcessKeyEvent( int key, KeyStateEnum keyState ) {
		//Output( "Got console key event! key = %d, keyState = %s\n", key, keyState == KeyState_Up ? "up" : "down" );
		if ( keyState == KeyState_Up ) {
			return;
		}
		if ( key == '`' ) {
			ExecuteCommand( "deactivateconsole" );
			return;
		} else if ( key == XK_BackSpace ) {
			if ( cursorPos > 0 ) {
				cursorPos--;
				commandLine.erase( cursorPos, 1 );
			}
		} else if ( key == XK_Delete ) {
			if ( cursorPos > 0 && cursorPos < commandLine.size() ) {
				commandLine.erase( cursorPos, 1 );
			}
		} else if ( key == XK_Return ) {
			AppendOutput( "> " + commandLine );
			ExecuteCommand( commandLine.c_str() );
			history.pop_front();
			history.push_front( commandLine );
			commandLine.clear();
			history.push_front( commandLine );
			cursorPos = 0;
			historyPos = 0;
		} else if ( key == XK_Up || key == XK_Down ) {
			historyPos += key == XK_Up ? 1 : -1;
			historyPos = std::max( 0, std::min( (int)historyPos, (int)history.size() - 1 ) );
			if ( history.size() > 0 ) {
				commandLine = history[ historyPos ];
				cursorPos = commandLine.size();			
			}
		} else if ( key == XK_Left ) {
			cursorPos--;
			cursorPos = std::max( cursorPos, 0 );
		} else if ( key == XK_Right ) {
			cursorPos++;
			cursorPos = std::min( cursorPos, (int)commandLine.size() );
		} else if ( key == XK_Tab ) {
			AttemptCompletion( commandLine, cursorPos );
		} else if ( key >= 0x20 && key <= 0x7f ){ // printable characters
			char c[2] = { key, 0 };
			commandLine.insert( cursorPos, c );
			cursorPos++;
		}
	
		//Output( "> %s_%s\n", commandLine.substr(0, cursorPos ).c_str(), commandLine.substr( cursorPos, string::npos ).c_str() );
		// else actually process the keyboard input
	}
	
	void Console::Draw() {
		if ( font == NULL ) {
			font = r3::CreateStbFont( con_font.GetVal(), con_fontSize.GetVal() ); 			
		}
		if ( ! IsActive() ) {
			return;
		}
		
		int border = 10;
		
		int w = r_windowWidth.GetVal();
		int h = r_windowHeight.GetVal();
		int conW = w - 2 * border;
		int conH = ( h - ( h >> 2 ) ) - border;
		float s = con_fontScale.GetVal();

		static Bounds2f bO;
		static float yAdvance = 0;
		static float sCache = 0;
		if ( s != sCache ) {
			bO = font->GetStringDimensions( "O", s );
			Bounds2f bb = font->GetStringDimensions( "|", s );
			sCache = s;
			yAdvance = std::max( bO.Height(), bb.Height() );
		}
		
		int x0 = border;
		int y = ( h >> 2) + border;
		
		ImColor( 16, 16, 16, con_opacity.GetVal() * 255 );
		BlendFunc( BlendFunc_SrcAlpha, BlendFunc_OneMinusSrcAlpha );
		BlendEnable();

		DrawQuad( x0, y, x0 + conW, y + conH );
		
		string cl = "> " + commandLine;
		int cp = cursorPos + 2;

		Bounds2f b = font->GetStringDimensions( cl, s );
		Bounds2f b2 = font->GetStringDimensions( cl.substr(0, cp ), s );
		
		ImColor( 255, 255, 255, 192 );
		font->Print( cl, x0, y, s );
		
		ImColor( 255, 255, 255, 64 );
		DrawQuad( x0 + b2.Width(), y, x0 + b2.Width() + bO.Width(), y + bO.Height() );
		
		y += yAdvance;

		ImColor( 255, 255, 255, 128 );
		for ( int i = outputBuffer.size() - 1; i >= 0 && y < h; i-- ) {
			string & line = outputBuffer[ i ];
			font->Print( line, x0, y, s );
			y += yAdvance;
		}

		BlendDisable();
	}
	
}
