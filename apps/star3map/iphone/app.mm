/*
 *  app.cpp
 *  star3map
 *
 *  Created by Cass Everitt on 1/31/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "app.h"
#include "r3/command.h"
#include "r3/common.h"
#include "r3/console.h"
#include "r3/draw.h"
#include "r3/init.h"
#include "r3/output.h"

#ifdef __APPLE__
# include <TargetConditionals.h>
# if TARGET_OS_IPHONE
#  include <OpenGLES/ES1/gl.h>
#  define glOrtho glOrthof
# else
#  include <OpenGL/gl.h>
# endif
#else
#include <GL/gl.h>
#endif


#include "r3/var.h"
#include "r3/linear.h"

#include "starlist.h"
#include "constellations.h"
#include "render.h"
#include "star3map.h"

#include <map>
#include <deque>

using namespace r3;
using namespace std;
using namespace star3map;

VarInteger r_windowWidth( "r_windowWidth", "window width", r3::Var_ReadOnly, 320 );
VarInteger r_windowHeight( "r_windowHeight", "window height", r3::Var_ReadOnly, 480 );

VarFloat r_fov( "r_fov", "perspective field of view", 0, 75.0f );

VarFloat app_latitude( "app_latitude", "viewer current latitude", Var_Archive, 35.0f );
VarFloat app_longitude( "app_longitude", "viewer current longitude", Var_Archive, -77.0f );
VarFloat app_phaseEarthRotation( "app_phaseEarthRotation", "time based earth rotation", Var_ReadOnly, 0.0f );

VarBool app_cull( "app_cull", "cull stars that are outside the current view", 0, true );

VarFloat app_latBias( "app_latBias", "latitude bias - for debugging", 0, 0.0f );
VarFloat app_lonBias( "app_lonBias", "longitude bias - for debugging", 0, 0.0f );

VarFloat app_orientationHysteresis( "app_orientationHysteresis", "Ignore orientation noise below this threshold (degrees).", 0, 4 );

extern VarBool app_useCoreLocation;
extern vector< Sprite > stars;
extern vector< Sprite > galaxies;
extern vector< Sprite > solarsystem;
extern vector< Lines > constellations;
extern vector< Sprite > constellationsOverlays;

extern bool lowResolution;

r3::Texture2D *startex;


#include "engine/PlanetFinderEngine.h"

CPlanetFinderEngine planetFinder;
TPlanetFinderSettings settings;

Vec3f heading;
float trueHeadingDiff;
Vec3f accel;
extern bool GotCompassUpdate;
extern bool GotLocationUpdate;
bool orientationDirty = false;

Vec3f headingSmooth( 0, 1, 0 );
Vec3f accelSmooth( 0, -1, 0 );

Matrix4f platformOrientation;
float platformLat;
float platformLon;

extern double yRotation;

void UpdateLatLon() {
	//Output( "lat = %.2f, lon = %.2f", latlon.x, latlon.y );
	if ( app_useCoreLocation.GetVal() ) {
		app_latitude.SetVal( platformLat );
		app_longitude.SetVal( platformLon );
	}		
	settings.iLatitude = app_latitude.GetVal();
	settings.iLongitude = app_longitude.GetVal();
    //Output( "lat = %.2f, lon = %.2f", platformLat, platformLon );
	planetFinder.Init( settings );
}

bool useGyro = false;

void updateRotationMatrix(float m11, float m12, float m13, 
                          float m21, float m22, float m23, 
                          float m31, float m32, float m33)
{
    Matrix4f o;
	o.SetRow( 0, Vec4f( m11, m12, m13, 0.0f ) );
	o.SetRow( 1, Vec4f( m21, m22, m23, 0.0f ) );
	o.SetRow( 2, Vec4f( m31, m32, m33, 0.0f ) );
	o.SetRow( 3, Vec4f( 0.0, 0.0, 0.0, 1.0f ) );
    
    Matrix4f calibration = Rotationf(Vec3f(0.0f, 0.0f, 1.0f), -yRotation).GetMatrix4();
	
	platformOrientation = o * calibration;//.Transpose();
    
    useGyro = true;
    
    if ( GotCompassUpdate == false ) {
		GotCompassUpdate = true;
		extern VarBool app_useCompass;
		if ( app_useCompass.GetVal() == false ) {
			app_useCompass.SetVal( true );
		}
	}
}

void updateOrientation() {
	if ( orientationDirty == false ) {
		return;
	}
	orientationDirty = false;
	
    if(useGyro)
        return;
    
	float decay = 0.9f;
	
	float hyst = cos( ToRadians( app_orientationHysteresis.GetVal() ) );

    if ( GotCompassUpdate ) {
        if ( headingSmooth.Dot( heading ) < hyst ) {
            headingSmooth *= decay;
            headingSmooth += (1.0f - decay) * heading;
        }
        headingSmooth.Normalize();
    } 		

	if ( accelSmooth.Dot( accel ) < hyst ) {
		accelSmooth *= decay;
		accelSmooth += (1.0f - decay) * accel;		
	}
	accelSmooth.Normalize();		
	
	Vec3f up = -accelSmooth;
	up.Normalize();
	Vec3f north;
    north = headingSmooth;
    north -= up * up.Dot( north );
    north.Normalize();

    Matrix3f toTrueNorth = Rotationf( up, ToRadians( trueHeadingDiff ) ).GetMatrix3();
    north = toTrueNorth * north;

	Vec3f east = north.Cross( up );

	Matrix4f o;
	o.SetRow( 0, Vec4f(  east.x,  east.y,  east.z, 0.0f ) );
	o.SetRow( 1, Vec4f( north.x, north.y, north.z, 0.0f ) );
	o.SetRow( 2, Vec4f(    up.x,    up.y,    up.z, 0.0f ) );
	o.SetRow( 3, Vec4f(     0.0,     0.0,     0.0, 1.0f ) );
	
	platformOrientation = o.Transpose();
}

void display() {
	updateOrientation();
	app_phaseEarthRotation.SetVal( GetPhaseEarthRotation() );
	planetFinder.buildSolarSystemList( solarsystem );
	star3map::Display();

	glPushMatrix();
	glLoadIdentity();
	glOrtho(0, r_windowWidth.GetVal(), 0, r_windowHeight.GetVal(), -1, 1 );
	r3::console.Draw();
	glPopMatrix();
		
	SwapBuffers();
}

void reshape( int width, int height ) {
	r_windowWidth.SetVal( width );
	r_windowHeight.SetVal( height );
	glViewport( 0, 0, width, height );
	planetFinder.SetSize( r_windowWidth.GetVal(), r_windowHeight.GetVal() );
	glMatrixMode( GL_MODELVIEW );
}

float savedLat = 0.0f;
float savedLon = 0.0f;

void resetLocation()
{
    setLocation(savedLat, savedLon);
}

void setLocation( float latitude, float longitude ) {
	if ( GotLocationUpdate == false ) {
		GotLocationUpdate = true;
		if ( app_useCoreLocation.GetVal() == false ) {
			app_useCoreLocation.SetVal( true );
		}
	}
    
    savedLat = latitude;
    savedLon = longitude;
    
	platformLat = latitude + app_latBias.GetVal();
	platformLon = longitude + app_lonBias.GetVal();
	orientationDirty = true;
}

Vec3f headings[2];
int headingCount = 0;

void setHeading( float x, float y, float z, float trueDiff ) {
	if ( GotCompassUpdate == false ) {
		GotCompassUpdate = true;
		extern VarBool app_useCompass;
		if ( app_useCompass.GetVal() == false ) {
			app_useCompass.SetVal( true );
		}
	}
	
	headings[ headingCount ] = Vec3f( x, y, z );
	headingCount++;
	headingCount &= ( ARRAY_ELEMENTS( heading ) - 1 );

	for ( int i = 0; i < ARRAY_ELEMENTS( headings ); i++ ) {
		heading += headings[ i ];
	}
	heading.Normalize();
	trueHeadingDiff = trueDiff;
	//Output( "heading: (%.2f, %.2f, %.2f)", x, y, z );
	orientationDirty = true;
}

Vec3f accels[2];
int accelCount = 0;

void setAccel( float x, float y, float z ) {
	
	accels[ accelCount ] = Vec3f( x, y, z );
	accelCount++;
	accelCount &= ( ARRAY_ELEMENTS( accels ) - 1 );
	
	for( int i = 0; i < ARRAY_ELEMENTS( accels ); i++ ) {
		accel += accels[ i ];
	}
	accel.Normalize();
	//Output( "accel: (%.2f, %.2f, %.2f)", x, y, z );
	orientationDirty = true;
}

vector< Vec2f > t[2];

void touches( int count, int *points ) {
	static int cycle;
	static int maxTouches;
	vector< Vec2f > &p = t[ cycle ];
	cycle = ( cycle + 1 ) & 1;
	vector< Vec2f > &c = t[ cycle ];
	c.clear();

	maxTouches = max( maxTouches, count );
	if ( count == 0 ) {
		maxTouches = 0;
	}
	
	int h = r_windowHeight.GetVal() - 1;

	for ( int i = 0; i < count * 2; i+=2 ) {
		c.push_back( Vec2f( points[ i ], points[ i + 1 ] ) );
	}
	//Output( "%d %d touches", (int)p.size(), (int)c.size() );
	
	if ( maxTouches < 2 ) {
		if ( c.size() == 1 && p.size() < 2 ) {
			ProcessInput( true, c[0].x, h - c[0].y );
		} else if ( c.size() == 0 && p.size() == 1 ) {
			ProcessInput( false, p[0].x, h - p[0].y );
		} else if ( c.size() == 2 && p.size() == 1 ) {
			ProcessInput( false, p[0].x, h - p[0].y );
		}	
	} else if ( c.size() == 2 && p.size() == 2 ) {
		
		float pl = ( p[1] - p[0] ).Length();
		float cl = ( c[1] - c[0] ).Length();
		float s = pl / cl;
		float fov = r_fov.GetVal() * s;
		fov = min( 90.f, max( 20.f, fov ) );
		r_fov.SetVal( fov );
		//Output( "scale = %0.2f, new fov = %.2f", s, fov );
	}
}

// testing
#include "r3/http.h"

void platformMain () {
		
	r3::Init( 0, NULL );
	
	{		
		// testing
		vector<uchar> urldata;
		//UrlReadToMemory( "http://www.xyzw.us/", urldata );
	}
	
	r3::ExecuteCommand( "bind escape quit" );
	
	settings.iLatitude = 0;
	settings.iLongitude = 0;
	
	planetFinder.Construct();
	planetFinder.Init( settings );
	
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
            
            NSString *str = [NSString stringWithUTF8String: sp.name.c_str()];
            std::string s([NSLocalizedString(str, nil) UTF8String]);
            sp.name = s;
            
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

            NSString *str = [NSString stringWithUTF8String: c.name.c_str()];
            std::string s([NSLocalizedString(str, nil) UTF8String]);
            
            lines.localizedName = s;
            
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
	
	
	
	glClearColor(0, 0, 0, 0);
}

void platformQuit() {
	r3::ExecuteCommand( "quit" );
}

// appquit command
void AppQuit( const vector< Token > & tokens ) {
}
CommandFunc AppQuitCmd( "appquit", "destroys app specific stuff", AppQuit );


