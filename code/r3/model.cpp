/*
 *  model
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

#include "model.h"

#include "r3/command.h"
#include "r3/output.h"

#include <map>

using namespace std;
using namespace r3;

namespace {

	bool initialized = false;

	struct ModelDatabase {
		map< string, Model *> models;
	};
	ModelDatabase *modelDatabase;
	
	
	// listmodels command
	void ListModels( const vector< Token > & tokens ) {
		if ( modelDatabase == NULL ) {
			return;
		}
		map< string, Model * > &models = modelDatabase->models;
		for( map< string, Model * >::iterator it = models.begin(); it != models.end(); ++it ) {
			const string & n = it->first;
			//Model * m = it->second;
			Output( "%s", n.c_str() );					
		}
	}
	CommandFunc ListModelsCmd( "listmodels", "lists defined models", ListModels );
	
}

namespace r3 {
	
	void InitModel() {
		if ( initialized ) {
			return;
		}
		modelDatabase = new ModelDatabase;
		
		initialized = true;
	}
	
	Model::Model( const string & mName ) 
	: name( mName )
	, vertexBuffer( NULL )
	, indexBuffer( NULL ) {
		assert( modelDatabase->models.count( name ) == 0 );
		modelDatabase->models[ name ];
	}

	Model::~Model() {
		modelDatabase->models.erase( name );
		delete vertexBuffer;
		delete indexBuffer;
	}
	
	VertexBuffer & Model::GetVertexBuffer() {
		if ( vertexBuffer == NULL ) {
			vertexBuffer = new VertexBuffer( name + "_vb" );
		}
		return *vertexBuffer;
	}
	IndexBuffer & Model::GetIndexBuffer() {
		if ( indexBuffer == NULL ) {
			indexBuffer = new IndexBuffer( name + "_ib" );
		}
		return *indexBuffer;
	}
	
	void Model::Draw() {
		vector< VertexBuffer * > vvb;
		vvb.push_back( vertexBuffer );
		
		r3::Draw( prim, vvb, indexBuffer );
	}
	
	
}


