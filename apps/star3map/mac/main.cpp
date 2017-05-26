/*
 *  planet_finder app main
 *
 * Copyright (c) 2010 Cass Everitt
 * All rights reserved.
 *
 */

/*  This file is a part of PlanetFinder. PlanetFinder is a Series 60 application
 for locating the planets in the sky. It is a porting of a Java Applet by 
 Benjamin Crowell to the Series 60 Developer Platform. See 
 http://www.lightandmatter.com/area2planet.shtml for the original version.
 Java Applet: Copyright (C) 2000, Benjamin Crowell
 Series 60 Version: Copyright (C) 2004, Kostas Giannakakis
 
 PlanetFinder is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 PlanetFinder is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with PlanetFinder; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include "r3/input.h"
#include "r3/command.h"
#include "r3/common.h"
#include "r3/var.h"
#include "r3/init.h"
#include "r3/texture.h"
#include "r3/draw.h"
#include "r3/console.h"
#include "r3/output.h"
#include "r3/thread.h"


#include "starlist.h"
#include "constellations.h"
#include "render.h"
#include "star3map.h"

#include <map>
#include <iostream>
#include <algorithm>

#include <GLUT/glut.h>

using namespace std;
using namespace r3;
using namespace star3map;

VarInteger r_windowWidth( "r_windowWidth", "window width", Var_ReadOnly, 0 );
VarInteger r_windowHeight( "r_windowHeight", "window height", Var_ReadOnly, 0 );

VarFloat r_fov( "r_fov", "perspective field of view", 0, 90.0f );

VarFloat app_latitude( "app_latitude", "viewer current latitude", Var_Archive, 35.0f );
VarFloat app_longitude( "app_longitude", "viewer current longitude", Var_Archive, -77.0f );
VarFloat app_phaseEarthRotation( "app_phaseEarthRotation", "time based earth rotation", Var_ReadOnly, 0.0f );

VarBool app_cull( "app_cull", "cull stars that are outside the current view", 0, 1 );

VarInteger app_updateMsec( "app_updateMsec", "the frame interval in msec", Var_Archive, 10 );

extern vector< Sprite > stars;
extern vector< Sprite > solarsystem;
extern vector< Lines > constellations;

r3::Texture2D *startex;


#include "engine/PlanetFinderEngine.h"
CPlanetFinderEngine planetFinder;
TPlanetFinderSettings settings;

VarRotationf app_orientation( "app_orientation", "camera orientation", Var_Archive, Rotationf() );
r3::Matrix4f platformOrientation;

void UpdateLatLon() {
	//Output( "lat = %.2f, lon = %.2f", latlon.x, latlon.y );
	settings.iLatitude = app_latitude.GetVal();
	settings.iLongitude = app_longitude.GetVal();
	planetFinder.Init( settings );
	
}

void display() {
	platformOrientation = app_orientation.GetVal().GetMatrix4();
	app_phaseEarthRotation.SetVal( GetPhaseEarthRotation() );
	planetFinder.buildSolarSystemList( solarsystem );
	
	star3map::Display();
	
	glPushMatrix();
	glLoadIdentity();
	glOrtho(0, r_windowWidth.GetVal(), 0, r_windowHeight.GetVal(), -1, 1 );
	r3::console.Draw();
	glPopMatrix();
	
	GLuint err = glGetError();
	if ( err != GL_NO_ERROR ) {
		Output( "gl error: 0x%x", err );
	}
	
	glutSwapBuffers();
}

void reshape( int width, int height ) {
	r_windowWidth.SetVal( width );
	r_windowHeight.SetVal( height );
	glViewport( 0, 0, width, height );
	planetFinder.SetSize( r_windowWidth.GetVal(), r_windowHeight.GetVal() );
	glMatrixMode( GL_MODELVIEW );
}

void key( unsigned char k, int x, int y ) {
	int r3key = r3::AsciiToKey( k );
	r3::ProcessKeyEvent( r3key, r3::KeyState_Down );
	r3::ProcessKeyEvent( r3key, r3::KeyState_Up );
}


void special( int key, int x, int y ) {
	int r3key = 0;
	if ( key >= GLUT_KEY_F1  && key <= GLUT_KEY_F12 ) {
		r3key = XK_F1 + ( key - GLUT_KEY_F1 );
	} else {
		switch ( key ) {
			case GLUT_KEY_LEFT:
				r3key = XK_Left;
				break;
			case GLUT_KEY_UP:
				r3key = XK_Up;
				break;
			case GLUT_KEY_RIGHT:
				r3key = XK_Right;
				break;
			case GLUT_KEY_DOWN:
				r3key = XK_Down;
				break;
			case GLUT_KEY_PAGE_UP:
				r3key = XK_Page_Up;
				break;
			case GLUT_KEY_PAGE_DOWN:
				r3key = XK_Page_Down;
				break;
			case GLUT_KEY_HOME:
				r3key = XK_Home;
				break;
			case GLUT_KEY_END:
				r3key = XK_End;
				break;
			case GLUT_KEY_INSERT:
				r3key = XK_Insert;
				break;
			default:
				break;
		}
	}
	if ( r3key == 0 ) {
		return;
	}
	r3::ProcessKeyEvent( r3key, r3::KeyState_Down );
	r3::ProcessKeyEvent( r3key, r3::KeyState_Up );
}

bool down;
Vec2f p0;

void mouse( int button, int state, int x, int y ) {
	y = r_windowHeight.GetVal() - 1 - y;
	if ( state == GLUT_DOWN ) {
		down = true;
		p0 = Vec2f( x, y );
	} else {
		down = false;
	}
	ProcessInput( down, x, y );
}

void motion( int x, int y ) {
	y = r_windowHeight.GetVal() - 1 - y;
	Vec2f p1( x, y );
	if ( down ) {
		/*
		Trackball t( r_windowWidth.GetVal(), r_windowHeight.GetVal() );
		Rotationf r = t.GetRotation( p0, p1 );
		app_orientation.SetVal( r * app_orientation.GetVal() );
		p0 = p1;
		 */
		ProcessInput( true, x, y );
	}
}

void tick( int dummy ) {
	static float lat;
	static float lon;
	
	if ( lat != app_latitude.GetVal() || lon != app_longitude.GetVal() ) {
		settings.iLatitude = lat = app_latitude.GetVal();
		settings.iLongitude = lon = app_longitude.GetVal();
		planetFinder.Init( settings );		
		r3::Output( "Lat = %0.2f, Lon = %0.2f", settings.iLatitude, settings.iLongitude );
	}
	
	
	glutPostRedisplay();
	glutTimerFunc( app_updateMsec.GetVal(), tick, 0 );
}

int main (int argc, char ** argv) {
	
	//glutInitDisplayMode( GLUT_RGBA | GLUT_DEPTH | GLUT_DOUBLE );
	glutInitDisplayString( "rgba>=8 depth double" );
	glutInitWindowSize( 320, 480 );
	glutInit( & argc, argv );
	
	glutCreateWindow("star3map");
	
	r3::Init( argc, argv );
	
	r3::ExecuteCommand( "bind escape quit" );
	//r3::ExecuteCommand( "readbindings default" );

	startex = r3::CreateTexture2DFromFile("startex.jpg", TextureFormat_RGBA );
	
	
	{
		float starColors [] = {
			0.8, 0.8, 1.0, // blue
			1.0, 1.0, 0.8, // light yellow
			1.0, 1.0, 0.6, // yellow
			1.0, 0.8, 0.4, // orange
			1.0, 0.6, 0.3  // red
		};
		vector< star3map::Star > sl;
		ReadStarList( "stars.txt", sl );
		map<int, star3map::Star *> sm;
		for ( int i = 0; i < (int)sl.size(); i++ ) {
			Sprite sp;
			star3map::Star & st = sl[i];
			sm[ st.hipnum ] = & st;
			sp.direction = SphericalToCartesian( 1.0f, ToRadians( st.dec ), ToRadians( st.ra ) );
			sp.magnitude = st.mag;
			sp.scale = 1.0f;
			sp.tex = startex;
			sp.name = st.name;
			float f = 3.99f * max( 0.f, min( 1.0f, float( ( st.colorIndex + 0.29 ) / ( 1.41 + 0.29 ) )  ) );
			int ind = f;
			float phase = f - ind;
			ind *= 3;
			Vec3f c0( starColors + ind );
			Vec3f c1( starColors + ind + 3 );
			Vec3f c = c0 * ( 1 - phase ) + c1 * phase;
			sp.color = Vec4f( c.x, c.y, c.z, 1 );
			stars.push_back( sp );
		}		
		vector< star3map::Constellation > cl;
		ReadConstellations( "constellations.txt", cl );
		for( int i = 0; i < (int)cl.size(); i++ ) {
			star3map::Constellation & c = cl[ i ];
			star3map::Lines lines;
			lines.name = c.name;
			lines.center = Vec3f( 0, 0, 0 );
			for ( int j = 0; j < (int)c.indexes.size(); j+=2 ) {
				if ( sm.count( c.indexes[ j + 0 ] ) && sm.count( c.indexes[j + 1 ] ) ) {
					for ( int k = 0; k < 2; k++ ) {
						star3map::Star *s = sm[ c.indexes[ j + k ] ];
						lines.vert.push_back( SphericalToCartesian( 1.0, ToRadians( s->dec ), ToRadians( s->ra ) ) );
						lines.center += lines.vert.back();
					}
				} else {
					Output( "One of the following constellation indexes was not found: %d, %d.", c.indexes[j], c.indexes[j+1] );
				}
			}
			lines.center.Normalize();
			lines.limit = 1.0f;
			for ( int j = 0; j < (int)lines.vert.size(); j++ ) {
				lines.limit = min( lines.limit, lines.center.Dot( lines.vert[ j ] ) );
			}
			constellations.push_back( lines );
		}
		
	}
	
	
	settings.iLatitude = 0;
	settings.iLongitude = 0;
	
	planetFinder.Construct();
	planetFinder.Init( settings );
	
	glClearColor(0, 0, 0, 0);
	glutDisplayFunc( display );
	glutReshapeFunc( reshape );
	glutKeyboardFunc( key );
	glutSpecialFunc( special );
	glutMouseFunc( mouse );
	glutMotionFunc( motion );
	glutTimerFunc( app_updateMsec.GetVal(), tick, 0 );
	glutMainLoop();
	
	return 0;
}


// appquit command
void AppQuit( const vector< Token > & tokens ) {
	exit( 0 );
}
CommandFunc AppQuitCmd( "appquit", "destroys app specific stuff", AppQuit );

