/*
 *  output
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

#include "r3/output.h"
#include "r3/common.h"
#include "r3/console.h"
#include "r3/thread.h"
#include "r3/var.h"

#include <stdio.h>
#include <stdarg.h>

#if _WIN32
# include <Windows.h>
#endif
r3::VarBool win_OutputDebugString( "win_OutputDebugString", "Dump output to debugger in Windows.", r3::Var_Archive, false );

using namespace r3;
using namespace std;

namespace {
	Mutex outputMutex;
}

namespace r3 {
	
	void InitOutput() {
	}
	
	void Output( const char *fmt, ... ) {
		ScopedMutex m( outputMutex );
		char str[16384];
		va_list args;
		va_start( args, fmt );
		r3Vsprintf( str, fmt, args );
		va_end( args );
		extern Console console;
		console.AppendOutput( str );
#if _WIN32
		if ( win_OutputDebugString.GetVal() ) {
			OutputDebugStringA( str );
			OutputDebugStringA( "\n" );
		}
#endif
		fprintf( stderr, "%s\n", str );
	}
	void OutputDebug( const char *fmt, ... ) {
		char str[1024];
		va_list args;
		va_start( args, fmt );
		r3Vsprintf( str, fmt, args );
		va_end( args );
		fprintf( stderr, "%s\n", str );
	}
	
}
