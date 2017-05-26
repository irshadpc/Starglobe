/*
 *  filesystem
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

#include "r3/filesystem.h"
#include "r3/var.h"
#include "r3/output.h"
#include "r3/parse.h"

#if __APPLE__
# include <TargetConditionals.h>
# include <unistd.h>
# include <dirent.h>
# include <sys/stat.h>
#endif

#if _WIN32
# include <Windows.h>
#endif

#include <stdio.h>
#include <assert.h>

using namespace std;
using namespace r3;

VarInteger f_numOpenFiles( "f_numOpenFiles", "Number of open files.", 0, 0 );

namespace {
	
	string NormalizePathSeparator( const string inPath ) {
		string path = inPath;
		for ( int i = 0; i < (int)path.size(); i++ ) {
			if ( path[i] == '\\' )  {
				path[i] = '/';
			}
		}
		return path;
	}
	
#if _WIN32
	FILE *Fopen( const char *filename, const char *mode ) {
		FILE *fp;		
		fopen_s( &fp, filename, mode );
		if ( fp ) {
			f_numOpenFiles.SetVal( f_numOpenFiles.GetVal() + 1 );
		}
		return fp;
	}
#else
	FILE *Fopen( const char *filename, const char *mode ) {
		FILE *fp;		
		fp = fopen( filename, mode );
		f_numOpenFiles.SetVal( f_numOpenFiles.GetVal() + 1 );
		return fp;
	}
#endif


	class StdCFile : public r3::File {
	public:
		FILE *fp;
		StdCFile() : fp( 0 ) {
		}
		virtual ~StdCFile() {
			if ( fp ) {
				f_numOpenFiles.SetVal( f_numOpenFiles.GetVal() - 1 );
				fclose( fp );
			}
		}
		virtual int Read( void *data, int size, int nitems ) {
			return fread( data, size, nitems, fp );
		}
		
		virtual int Write( const void *data, int size, int nitems ) {
			return fwrite( data, size, nitems, fp );
		}
		
		virtual void Seek( SeekEnum whence, int offset ) {
			fseek( fp, offset, (int)whence );
		}
		
		virtual int Tell() {
			return ftell( fp );
		}
		
		virtual int Size() {
			int curPos = Tell();
			Seek( Seek_End, 0 );
			int size = Tell();
			Seek( Seek_Begin, curPos );
			return size;
		}
		
		virtual bool AtEnd() {
			return feof( fp ) != 0;
		}
	};

	bool FindDirectory( VarString & path, const char * dirName ) {
		string dirname = dirName;
#if ! _WIN32
		// figure out current working directory
		if ( path.GetVal().size() > 0 ) {
			DIR *dir = opendir( path.GetVal().c_str() );			
			if ( ! dir ) {
				return false;
			}
		} else {
			//Output( "Searching for base directory." );
			char ccwd[256];
			getcwd( ccwd, sizeof( ccwd ));
			string cwd = ccwd;
			for( int i = 0; i < 10; i++ ) {
				//Output( "cwd = %s", cwd );
				DIR *dir = opendir( ( cwd + string("/") + dirname ).c_str() );
				if ( dir ) {
					cwd += "/" + dirname + "/";
					path.SetVal( cwd );
					//Output( "Found base: %s", base.c_str() );
					closedir( dir );
					break;
				} else {
					cwd += "/..";
				}
			}
		}
#else
		WIN32_FIND_DATAA findData;
		// figure out current working directory
		if ( path.GetVal().size() > 0 ) {
			HANDLE hDir = FindFirstFileA( path.GetVal().c_str(), &findData );			
			if ( hDir == INVALID_HANDLE_VALUE ) {
				return false;
			}
		} else {
			//Output( "Searching for base directory." );
			char ccwd[256];
			GetCurrentDirectoryA( sizeof( ccwd ), ccwd );
			string cwd = ccwd;
			for( int i = 0; i < 10; i++ ) {
				//Output( "cwd = %s", cwd );
				HANDLE hDir = FindFirstFileA( ( cwd + "/" + dirname ).c_str(), &findData );			
				if ( hDir != INVALID_HANDLE_VALUE ) {
					cwd += "/" + dirname + "/";
					cwd = NormalizePathSeparator( cwd );
					path.SetVal( cwd );
					//Output( "Found base: %s", base.c_str() );
					FindClose( hDir );
					break;
				} else {
					cwd += "/..";
				}
			}			
		}
#endif
		return true;
	}
	
	bool MakeDirectory( const char * dirName ) {
		assert( dirName );
		vector<Token> tokens = TokenizeString( dirName, "/" );
		string dirname = dirName[0] == '/' ? "/" : "";
		for ( int i = 0; i < (int)tokens.size(); i++ ) {
			dirname += tokens[i].valString;
#if ! _WIN32
			DIR *dir = opendir( dirname.c_str() );			
			if ( ! dir ) {
				Output( "Attempting to create dir %s", dirname.c_str() );
				int ret = mkdir( dirname.c_str(), 0777 );
				if ( ret != 0 ) {
					Output( "Failed to create dir %s", dirname.c_str() );
					return false;
				}
			}
#else
			WIN32_FIND_DATAA findData;
			// figure out current working directory
			HANDLE hDir = FindFirstFileA( dirname.c_str(), &findData );			
			if ( hDir == INVALID_HANDLE_VALUE ) {
				Output( "Attempting to create dir %s", dirname.c_str() );
				CreateDirectoryA( dirname.c_str(), NULL );
				HANDLE hDir = FindFirstFileA( dirname.c_str(), &findData );			
				if ( hDir == INVALID_HANDLE_VALUE ) {
					Output( "Failed to create dir %s", dirname.c_str() );
					return false;
				}
			}
#endif
			dirname += "/";			
		}
		return true;
	}
	
}


namespace r3 {

	
	VarString f_basePath( "f_basePath", "path to the base directory", Var_ReadOnly, "");
	VarString f_cachePath( "f_cachePath", "path to writable cache directory", Var_ReadOnly, "" );
	
	void InitFilesystem() {
		if ( FindDirectory( f_basePath, "base" ) == false ) {
			Output( "exiting due to invalid %s: %s", f_basePath.Name().Str().c_str(), f_basePath.GetVal().c_str() ); 
			exit( 1 );
		}
		if ( f_cachePath.GetVal().size() > 0 ) {
			MakeDirectory( f_cachePath.GetVal().c_str() );			
		}
	}
	
	File * FileOpenForWrite( const string & inFileName ) {
		string filename = NormalizePathSeparator( inFileName );
		vector<string> paths;
		paths.push_back( f_cachePath.GetVal() );
		paths.push_back( f_basePath.GetVal() );
		vector<Token> tokens = TokenizeString( filename.c_str(), "/" );
		for ( int i = 0; i < (int)paths.size(); i++ ) {
			string & path = paths[i];
			if ( path.size() > 0 ) {
				string dir = path;
				for ( int j = 0; j < (int)tokens.size() - 1; j++ ) {
					dir += tokens[j].valString;
					dir += "/";
				}
				if ( MakeDirectory( dir.c_str() ) == false ) {
					continue;
				}
				string fn = path + filename;
				FILE * fp = Fopen( fn.c_str(), "wb" );
				Output( "Opening file %s for write %s", fn.c_str(), fp ? "succeeded" : "failed" );
				if ( fp ) {
					StdCFile * F = new StdCFile;
					F->fp = fp;
					return F;
				}
			}				
		}
		return NULL;
	}
	
	File * FileOpenForRead( const string & inFileName ) {
		string filename = NormalizePathSeparator( inFileName );
		// first look for it in cache
		if ( f_cachePath.GetVal().size() > 0 ) {
			string fn = f_cachePath.GetVal() + filename;
			FILE * fp = Fopen( fn.c_str(), "rb" );
			Output( "Opening file %s for read %s", fn.c_str(), fp ? "succeeded" : "failed" );
			if ( fp ) {
				StdCFile * F = new StdCFile;
				F->fp = fp;
				return F;
			}			
		}
		// then check in base
		{
			string fn = f_basePath.GetVal() + filename;
			FILE * fp = Fopen( fn.c_str(), "rb" );
			Output( "Opening file %s for read %s", fn.c_str(), fp ? "succeeded" : "failed" );
			if ( fp ) {
				StdCFile * F = new StdCFile;
				F->fp = fp;
				return F;
			}			
		}
		// then give up
		return NULL;
	}
	
	bool FileReadToMemory( const string & inFileName, vector< unsigned char > & data ) {
		string filename = NormalizePathSeparator( inFileName );
		File *f = FileOpenForRead( filename );
		if ( f == NULL ) {
			data.clear();
			return false;
		}
		int sz = f->Size();
		data.resize( sz );
		int bytesRead = f->Read( &data[0], 1, sz );
		assert( sz == bytesRead && sz == data.size() );
		delete f;
		return true;
	}
	
	
	string File::ReadLine() {
		string ret;
		char s[256];
		int l;
		do {
			l = Read( s, 1, sizeof( s ) );
			for ( int i = 0; i < l; i++ ) {
				if ( s[i] == '\n' ) {
					// We take care not seek with a zero offset,
					// because it clears the eof flag.
					int o = i + 1 - l;
					if ( o != 0 ) {
						Seek( Seek_Curr, o );						
					}
					l = 0;
					break;
				}
				ret.push_back( s[i] );
			}
		} while( l );
		return ret;
	}
	
	void File::WriteLine( const string & str ) {
		string s = str + "\n";
		Write( s.c_str(), 1, s.size() );
	}
	
}