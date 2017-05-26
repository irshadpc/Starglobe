/*
 *  constellations.cpp
 *  planet_finder
 *
 *  Created by Cass Everitt on 2/11/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "constellations.h"
#include "r3/filesystem.h"
#include "r3/output.h"
#include "r3/parse.h"
#include <math.h>

using namespace std;
using namespace r3;

namespace star3map {
	
	void ReadConstellations( const string & filename, vector<Constellation> & list ) {
		list.clear();
		File * file = FileOpenForRead( filename );
		while ( file->AtEnd() == false ) {
			string line = file->ReadLine();
			vector< Token > tokens = TokenizeString( line.c_str() );
			if ( ( tokens.size() & 0x1 ) == 0 &&
				tokens.size() > 2 &&
				tokens[0].type == TokenType_String &&  // name
				tokens[1].type == TokenType_Number &&  // segments
				tokens[2].type == TokenType_Number &&  // first pair...
				tokens[3].type == TokenType_Number
				) {
				Constellation c;
				c.name = tokens[0].valString;
				for ( int i = 2; i < (int)tokens.size(); i++ ) {
					c.indexes.push_back( (int)tokens[i].valNumber );
				}
				list.push_back( c );
			}
		}
		Output( "Read %d constellations from %s.", (int)list.size(), filename.c_str() );
		delete file;
	}
	
}
