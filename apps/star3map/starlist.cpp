/*
 *  starlist.cpp
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

#include "starlist.h"
#include "r3/filesystem.h"
#include "r3/output.h"
#include "r3/parse.h"
#include <math.h>

using namespace std;
using namespace r3;

namespace star3map {

	void ReadStarList( const string & filename, vector<Star> & list ) {
		list.clear();
		File * file = FileOpenForRead( filename );
		while ( file->AtEnd() == false ) {
			string line = file->ReadLine();
			vector< Token > tokens = TokenizeString( line.c_str() );
			if ( ( tokens.size() == 6 ) &&
				tokens[0].type == TokenType_Number &&  // HIP number
				tokens[1].type == TokenType_String &&  // common name
				tokens[2].type == TokenType_Number &&  // magnitude
				tokens[3].type == TokenType_Number &&  // right ascension
				tokens[4].type == TokenType_Number &&  // declination
				tokens[5].type == TokenType_Number     // color index
				) {
				Star s;
				s.hipnum = (int)tokens[0].valNumber;
				s.name = tokens[1].valString;
				s.mag = tokens[2].valNumber;
				s.ra = tokens[3].valNumber / 12.0f;
				if ( s.ra > 1.0 ) {
					s.ra -= 2.0f;
				}
				s.ra *= 180.0f;
				s.dec = tokens[4].valNumber;
				s.colorIndex = tokens[5].valNumber;
				list.push_back( s );
			}
		}
		Output( "Read %d stars from %s.", (int)list.size(), filename.c_str() );
		delete file;
	}
    
    void ReadGalaxyList( const string & filename, vector<Star> & list ) {
        list.clear();
        File * file = FileOpenForRead( filename );
        while ( file->AtEnd() == false ) {
            string line = file->ReadLine();
            vector< Token > tokens = TokenizeString( line.c_str() );
            if ( ( tokens.size() == 6 ) &&
                tokens[0].type == TokenType_Number &&  // HIP number
                tokens[1].type == TokenType_String &&  // common name
                tokens[2].type == TokenType_Number &&  // magnitude
                tokens[3].type == TokenType_Number &&  // right ascension
                tokens[4].type == TokenType_Number &&  // declination
                tokens[5].type == TokenType_Number     // color index
                ) {
                Star s;
                s.hipnum = (int)tokens[0].valNumber;
                s.name = tokens[1].valString;
                s.mag = tokens[2].valNumber;
                s.ra = tokens[3].valNumber / 12.0f;
                if ( s.ra > 1.0 ) {
                    s.ra -= 2.0f;
                }
                s.ra *= 180.0f;
                s.dec = tokens[4].valNumber;
                s.colorIndex = tokens[5].valNumber;
                list.push_back( s );
            }
        }
        Output( "Read %d galaxies from %s.", (int)list.size(), filename.c_str() );
        delete file;
    } 


}
