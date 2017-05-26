/*
 *  buffer
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

#include "r3/buffer.h"

#include "r3/command.h"
#include "r3/draw.h"
#include "r3/output.h"

#include "r3/gl.h"

#include "r3/var.h"

#include <assert.h>
#include <map>

using namespace std;
using namespace r3;

extern VarFloat app_nightFactor;

namespace {
	
	bool initialized = false;
	
	struct BufferDatabase {
		map< string, Buffer *> buffers;
		Buffer * GetBuffer( const string & name ) {
			if ( buffers.count( name ) ) {
				return buffers[ name ];
			}
			return NULL;
		}
		void AddBuffer( const string & name, Buffer * buf ) {
			assert( buffers.count( name ) == 0 );
			buffers[ name ] = buf;
		}
		void DeleteBuffer( const string & name ) {
			assert( buffers.count( name ) == 0 );
			buffers.erase( name );
		}		
	};
	BufferDatabase * bufferDatabase;
	
	int modBindTarget = GL_ARRAY_BUFFER; // what location is used for "bind for modification"?
	
	// listbuffers command
	void ListBuffers( const vector< Token > & tokens ) {
		if ( bufferDatabase == NULL ) {
			return;
		}
		map< string, Buffer * > &buffers = bufferDatabase->buffers;
		for( map< string, Buffer * >::iterator it = buffers.begin(); it != buffers.end(); ++it ) {
			const string & n = it->first;
			Buffer * b = it->second;
			Output( "%s - sz=%d", n.c_str(), b->GetSize() );					
		}
	}
	CommandFunc ListBuffersCmd( "listbuffers", "lists defined buffers", ListBuffers );
	
	
	
}


namespace r3 {
	void ComputeOffsets( int varyings, int & stride, int * offsets );
	
	void InitBuffer() {
		if ( initialized ) {
			return;
		}
		bufferDatabase = new BufferDatabase();
		initialized = true;
	}
	
	Buffer::Buffer( const std::string & bufName, int bufTarget ) : name( bufName ), target( bufTarget ) {
		glGenBuffers( 1, & obj );
		bufferDatabase->AddBuffer( name, this );
	}
	Buffer::~Buffer() {
		glDeleteBuffers( 1, & obj );
		bufferDatabase->DeleteBuffer( name );
	}
	
	void Buffer::Bind() const {
		glBindBuffer( target, obj );
	}
	
	void Buffer::Unbind() const {
		glBindBuffer( target, 0 );		
	}
	
	
	void Buffer::SetData( int sz, const void * data ) {
		size = sz;
		glBindBuffer( modBindTarget, obj );
		glBufferData( modBindTarget, size, data, GL_STATIC_DRAW );
		glBindBuffer( modBindTarget, 0 );
	}
	
	void Buffer::SetSubdata( int offset, int sz, const void * data ) {
		assert( ( offset + sz ) <= size );
		glBindBuffer( modBindTarget, obj );
		glBufferSubData( modBindTarget, offset, sz, data );
		glBindBuffer( modBindTarget, 0 );
	}
	
	void Buffer::GetData( void * data ) {
		assert( 0 ); // unimplemented
	}

	void Buffer::GetSubData( int offset, int size, void * data ) {
		assert( 0 ); // unimplemented
	}
	
	VertexBuffer::VertexBuffer( const std::string & vbName ) : Buffer( vbName, GL_ARRAY_BUFFER ) {}
	void VertexBuffer::SetVarying( int vbVarying ) { varying = vbVarying; }
	int VertexBuffer::GetNumVerts() const {
		int vsz = GetVertexSize( varying );
		int numVerts = size / vsz;
		return numVerts;
	}

	void VertexBuffer::Enable() const {
		int stride;
		int offsets[ R3_NUM_VARYINGS ];
		ComputeOffsets( varying, stride, offsets );
		if ( varying & Varying_PositionBit ) {
			glEnableClientState( GL_VERTEX_ARRAY );
			glVertexPointer( 3, GL_FLOAT, stride, (void *)offsets[0] );
		}
		if ( varying & Varying_ColorBit ) {
			glEnableClientState( GL_COLOR_ARRAY );
			glColorPointer( 4, GL_UNSIGNED_BYTE, stride, (void *)offsets[1] );
            
            glActiveTexture( GL_TEXTURE0 );
            
            GLint texture;
            glGetIntegerv(GL_TEXTURE_BINDING_2D, &texture);
            
            if(texture != 0)
            {
                glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
                glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_RGB, GL_TEXTURE);
                glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_RGB, GL_PREVIOUS);
                glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
                glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
                glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
                glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_ALPHA, GL_PREVIOUS);
                glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_ALPHA, GL_TEXTURE);
                glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
                glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_ALPHA, GL_SRC_ALPHA);
                glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_MODULATE);
                
                glActiveTexture( GL_TEXTURE1 );
                glEnable(GL_TEXTURE_2D);
                glBindTexture( GL_TEXTURE_2D, texture );
                GLfloat color[] = { 1.0f, 1.0f - app_nightFactor.GetVal(), 1.0f - app_nightFactor.GetVal(), 1.0f };
                glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_COLOR, color);
                glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
                glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_RGB, GL_CONSTANT);
                glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_RGB, GL_PREVIOUS);
                glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
                glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
                glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
                glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_ALPHA, GL_PREVIOUS);
                glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_ALPHA, GL_CONSTANT);
                glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
                glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_ALPHA, GL_SRC_ALPHA);
                glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_MODULATE);
            }
		}
		if ( varying & Varying_NormalBit ) {
			glEnableClientState( GL_NORMAL_ARRAY );			
			glNormalPointer( GL_FLOAT, stride, (void *)offsets[2] );
		}
		if ( varying & Varying_TexCoord0Bit ) {
			glClientActiveTexture( GL_TEXTURE0 );
			glEnableClientState( GL_TEXTURE_COORD_ARRAY );
			glTexCoordPointer( 2, GL_FLOAT, stride, (void *)offsets[3] );
		}
		if ( varying & Varying_TexCoord1Bit ) {
			glClientActiveTexture( GL_TEXTURE1 );
			glEnableClientState( GL_TEXTURE_COORD_ARRAY );			
			glTexCoordPointer( 2, GL_FLOAT, stride, (void *)offsets[4] );
		}		
	}
	
	void VertexBuffer::Disable() const {
		if ( varying & Varying_PositionBit ) {
			glDisableClientState( GL_VERTEX_ARRAY );
		}
		if ( varying & Varying_ColorBit ) {
			glDisableClientState( GL_COLOR_ARRAY );		
            
            glActiveTexture( GL_TEXTURE0 );
            
            GLint texture;
            glGetIntegerv(GL_TEXTURE_BINDING_2D, &texture);
            
            if(texture != 0)
            {
                glActiveTexture( GL_TEXTURE1 );
                glDisable(GL_TEXTURE_2D);
            }
		}
		if ( varying & Varying_NormalBit ) {
			glDisableClientState( GL_NORMAL_ARRAY );			
		}
		if ( varying & Varying_TexCoord0Bit ) {
			glClientActiveTexture( GL_TEXTURE0 );
			glDisableClientState( GL_TEXTURE_COORD_ARRAY );
		}
		if ( varying & Varying_TexCoord1Bit ) {
			glClientActiveTexture( GL_TEXTURE1 );
			glDisableClientState( GL_TEXTURE_COORD_ARRAY );			
		}		
	}
	
	IndexBuffer::IndexBuffer( const std::string & ibName ) : Buffer( ibName, GL_ELEMENT_ARRAY_BUFFER ) {}

	
	
	
	
}



