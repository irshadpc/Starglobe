/*
 *  star3map
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

#include "star3map.h"
#include "satellite.h"
#include "button.h"

#include "r3/command.h"
#include "r3/common.h"
#include "r3/draw.h"
#include "r3/filesystem.h"
#include "r3/http.h"
#include "r3/model.h"
#include "r3/modelobj.h"
#include "r3/output.h"
#include "r3/thread.h"
#include "r3/time.h"

#include "r3/var.h"

#include <map>

using namespace std;
using namespace star3map;
using namespace r3;

extern VarFloat r_fov;
extern VarInteger r_windowWidth;
extern VarInteger r_windowHeight;

extern VarFloat app_latitude;
extern VarFloat app_longitude;
extern VarFloat app_phaseEarthRotation;
extern VarBool app_cull;

float RampDownTime = 7.5f;

bool lowResolution = false;

VarBool app_pauseAging( "app_pauseAging", "stop aging for dynamic objects - usually for screenshots", 0, false );
VarInteger app_debugLabels( "app_debugLabels", "draw debugging info for labels", 0, 0 );
VarBool app_useCompass( "app_useCompass", "use the compass for pointing the phone around the sky", 1, false );
VarBool app_changeLocation( "app_changeLocation", "change current location when moving in globeView", 0, false );
VarBool app_useCoreLocation( "app_useCoreLocation", "use the location services to get global position", 1, false );
VarBool app_showSatellites( "app_showSatellites", "use TLE satellite data to show satellites", 0, false );
VarString app_satelliteFile( "app_satelliteFile", "file to use for satellite data", 0, "visual.txt" );
VarInteger app_maxSatellites( "app_maxSatellites", "maximum number of satellites to display", 0, 100 );
VarString app_stationsFile( "app_StationsFile", "file to use for stations data", 0, "stations.txt" );
VarString app_constellationsFile( "app_ConstellationsFile", "file to use for constellations data", 0, "constellations_overlays.txt" );
VarString app_telescopeFile( "app_TelescopeFile", "file to use for telescopes data", 0, "telescope.txt" );
VarInteger app_maxStations( "app_maxStations", "maximum number of stations to display", 0, 7 );

VarFloat app_inputDrag( "app_inputDrag", "drag factor on input for inertia effect", 0, .9 );

VarFloat app_debugPhase( "app_debugPhase", "phase adjustment", 0, 0.0f );

extern VarFloat app_scale;
extern VarFloat app_starScale;

bool GotCompassUpdate = false;
bool GotLocationUpdate = false;

extern void UpdateLatLon();
extern Matrix4f platformOrientation;
Matrix4f orientation;
Matrix4f manualOrientation;

VarFloat app_manualPhi( "app_manualPhi", "phi for manual orientation", 0, 0 );
VarFloat app_manualTheta( "app_manualTheta", "theta for manual orientation", 0, 0 );

vector< Sprite > stars;
vector< Sprite > solarsystem;
vector< Lines > constellations;
vector< Button *> buttons;

namespace star3map {
	Matrix4f RotateTo( const Vec3f & direction );
}

#if IPHONE
extern void OpenURL( const char *url );
extern float GetScaleFactor();
#else
void OpenURL( const char *url) {
}
#endif

namespace {

	Model *hemiModel;
	Model *sphereModel;
	Model *starsModel;
	Texture2D *hemiTex;
    Texture2D *up;
    Texture2D *down;
	Texture2D *nTex;
	Texture2D *sTex;
	Texture2D *eTex;
	Texture2D *wTex;
	Texture2D *earthTex;
    Texture2D *earthLightTex;
	Texture2D *satTex;
    Texture2D *telTex;
	ToggleButton *toggleCompass;
	PushButton *viewGlobe;
	PushButton *viewStars;
	ToggleButton *toggleChangeLocation;
	ToggleButton *toggleCoreLocation;
	ToggleButton *toggleSatellites;

	bool GotSatelliteData = false;
    bool GotTelescopeData = false;
	vector<Satellite> satellite;
    vector<Telescope> telescope;
    vector<ConstallationsOverlay> constallationsOverlay;
	
	AppModeEnum appMode = AppMode_ViewStars;
	
	void UpdateManualOrientation();
	
	struct StarVert {
		Vec3f pos;
		uchar c[4];
		Vec2f tc;
	};
	
	float magToDiam[] = { 2.0f, 1.5f, 1.25f, 1.0f, .85f, .75f, .5f };
	
	float GetSpriteDiameter( float magnitude ) {
		int mag = max( 0, min( 6, (int)magnitude ) );
		return magToDiam[ mag ];
	}
	
	float magToColor[] = { 1.0f, .9f, .7f, .5f, .3f, .2f, .1f };
	
	float GetSpriteColorScale( float magnitude ) {
		int mag = max( 0, min( 6, (int)magnitude ) );
		return magToColor[ mag ];
	}
	
	struct ReadUrlThread : public r3::Thread {
		ReadUrlThread( const string & inUrl ) : url( inUrl ) { }
		string url;
		vector<uchar> urldata;
		virtual void Run() {
			UrlReadToMemory( url, urldata );
		}
	};
	
	
	
	bool initialized = false;
	ReadUrlThread *twoLineElements;
	void Initialize() {
		if ( initialized ) {
			return;
		}
		// start async reads
		twoLineElements = new ReadUrlThread("http://celestrak.com/NORAD/elements/" + app_satelliteFile.GetVal() );
		twoLineElements->Start();

        r3::ExecuteCommand("app_useCompass 1");
		// construct hemi model
		{			
			hemiModel = new Model( "hemi" );
            vector<float> data;
            int wedges = 36;
            int slices = 18;
            for ( int j = 0; j <= slices; j++ ) {
                float t = float( j ) / slices;
                float phi = R3_PI * ( t - 0.5 );
                for( int i = 0; i <= wedges; i++ ) {
                    float s = float( i ) / wedges;
                    Vec3f p = SphericalToCartesian( 1.0f, phi, 2.0 * R3_PI * s );
                    data.push_back( p.x );
                    data.push_back( p.y );
                    data.push_back( p.z );
                    data.push_back( s + 0.5f ); // gmt is at s = 0.5 for the earth map texture
                    data.push_back( t );
                }
            }
            vector<ushort> index;
            int pitch = wedges + 1;
            for ( int j = 0; j < slices; j++ ) {
                for( int i = 0; i < wedges; i++ ) {
                    // lower right tri
                    index.push_back( ( j + 0 ) * pitch + ( i + 0 ) );
                    index.push_back( ( j + 0 ) * pitch + ( i + 1 ) );
                    index.push_back( ( j + 1 ) * pitch + ( i + 1 ) );
                    // upper left tri
                    index.push_back( ( j + 0 ) * pitch + ( i + 0 ) );
                    index.push_back( ( j + 1 ) * pitch + ( i + 1 ) );
                    index.push_back( ( j + 1 ) * pitch + ( i + 0 ) );
                }
            }
            VertexBuffer & vb = hemiModel->GetVertexBuffer();
            vb.SetVarying( Varying_PositionBit | Varying_TexCoord0Bit );
            vb.SetData( (int)data.size() * sizeof( float ), & data[0] );
            IndexBuffer & ib = hemiModel->GetIndexBuffer();
            ib.SetData( (int)index.size() * sizeof( ushort ), & index[0] );
            hemiModel->SetPrimitive( Primitive_Triangles );
		} 
		{
			sphereModel = new Model( "sphere" );
			vector<float> data;
			int wedges = 36;
			int slices = 18;
			for ( int j = 0; j <= slices; j++ ) {
				float t = float( j ) / slices;
				float phi = R3_PI * ( t - 0.5 );
				for( int i = 0; i <= wedges; i++ ) {
					float s = float( i ) / wedges;
					Vec3f p = SphericalToCartesian( 1.0f, phi, 2.0 * R3_PI * s );
					data.push_back( p.x );
					data.push_back( p.y );
					data.push_back( p.z );
					data.push_back( s + 0.5f ); // gmt is at s = 0.5 for the earth map texture
					data.push_back( t );
				}
			}
			vector<ushort> index;
			int pitch = wedges + 1;
			for ( int j = 0; j < slices; j++ ) {
				for( int i = 0; i < wedges; i++ ) {
					// lower right tri
					index.push_back( ( j + 0 ) * pitch + ( i + 0 ) );
					index.push_back( ( j + 0 ) * pitch + ( i + 1 ) );
					index.push_back( ( j + 1 ) * pitch + ( i + 1 ) );
					// upper left tri
					index.push_back( ( j + 0 ) * pitch + ( i + 0 ) );
					index.push_back( ( j + 1 ) * pitch + ( i + 1 ) );					
					index.push_back( ( j + 1 ) * pitch + ( i + 0 ) );
				}
			}
			VertexBuffer & vb = sphereModel->GetVertexBuffer();
			vb.SetVarying( Varying_PositionBit | Varying_TexCoord0Bit );
			vb.SetData( (int)data.size() * sizeof( float ), & data[0] );
			IndexBuffer & ib = sphereModel->GetIndexBuffer();
			ib.SetData( (int)index.size() * sizeof( ushort ), & index[0] );
			sphereModel->SetPrimitive( Primitive_Triangles );
		}
		{
			starsModel = new Model( "stars" );
			vector< StarVert > data;
			for ( int i = 0; i < (int)stars.size(); i++ ) {
				Sprite & s = stars[i];
				if ( s.magnitude > 4 ) {
					continue;
				}
				Vec4f c = s.color * GetSpriteColorScale( s.magnitude ) * 255.f;
				Matrix4f mRot = RotateTo( s.direction );
				Matrix4f mScale;
				float sc = s.scale * GetSpriteDiameter( s.magnitude ) * app_starScale.GetVal() * app_scale.GetVal();
				mScale.SetScale( Vec3f( sc, sc, 1 ) );
				Matrix4f mTrans;
				mTrans.SetTranslate( Vec3f( 0, 0, -1 ) );
				Matrix4f m = mRot * mScale * mTrans;
				StarVert v;
				v.c[0] = c.x; v.c[1] = c.y; v.c[2] = c.z; v.c[3] = c.w;
				v.pos = m * Vec3f( -10, -10, 0 );
				v.tc = Vec2f( 0, 0 );
				data.push_back( v );
				v.pos = m * Vec3f(  10, -10, 0 );
				v.tc = Vec2f( 1, 0 );
				data.push_back( v );
				v.pos = m * Vec3f(  10,  10, 0 );
				v.tc = Vec2f( 1, 1 );
				data.push_back( v );
				v.pos = m * Vec3f( -10,  10, 0 );
				v.tc = Vec2f( 0, 1 );
				data.push_back( v );				
			}
			VertexBuffer & vb = starsModel->GetVertexBuffer();
			vb.SetVarying( Varying_PositionBit | Varying_ColorBit | Varying_TexCoord0Bit );
			vb.SetData( (int)data.size() * sizeof( StarVert ), & data[0] );
			starsModel->SetPrimitive( Primitive_Quads );
			
		}
		
		
		hemiTex = CreateTexture2DFromFile("hemi.jpg", TextureFormat_RGB );
		nTex = CreateTexture2DFromFile( lowResolution ? "n_low.png" : "n.png", TextureFormat_RGBA );
		sTex = CreateTexture2DFromFile( lowResolution ? "s_low.png" : "s.png", TextureFormat_RGBA );
        eTex = CreateTexture2DFromFile( lowResolution ? "e_low.png" : "e.png", TextureFormat_RGBA );
		wTex = CreateTexture2DFromFile( lowResolution ? "w_low.png" : "w.png", TextureFormat_RGBA );
        up = CreateTexture2DFromFile( lowResolution ? "compass_up.png" : "compass_up.png", TextureFormat_RGBA );
        down = CreateTexture2DFromFile( lowResolution ? "compass_down.png" : "compass_down.png", TextureFormat_RGBA );
		earthTex = CreateTexture2DFromFile( lowResolution ? "earth-map-day.jpg" : "earth-map-day.jpg", TextureFormat_RGB );
        earthLightTex = CreateTexture2DFromFile( lowResolution ? "earth_clouds_low.jpg" : "earth_clouds.jpg", TextureFormat_RGB );
		satTex = CreateTexture2DFromFile( "satellites_images/default.png", TextureFormat_RGBA );
        telTex = CreateTexture2DFromFile( "satellites_images/hst.png", TextureFormat_RGBA );
		
		toggleCompass = new ToggleButton( lowResolution ? "193-location-arrow.png" : "193-location-arrowhi.png", "app_useCompass" );
		viewGlobe = new PushButton( lowResolution ? "243-globe.png" : "243-globehi.png", "setAppMode viewGlobe" );
		viewStars = new PushButton( lowResolution ? "27-planet.png" : "27-planethi.png", "setAppMode viewStars" );
		toggleChangeLocation = new ToggleButton( lowResolution ? "arrows_low.png" : "arrows.png", "app_changeLocation" );
		toggleCoreLocation = new ToggleButton( lowResolution ? "193-location-arrow.png" : "193-location-arrowhi.png", "app_useCoreLocation" );
		toggleSatellites = new ToggleButton( lowResolution ? "spacestation_low.png" : "spacestation.png", "app_showSatellites" );
        
		UpdateManualOrientation();
		
		ReadSatelliteData( "satellite/" + app_satelliteFile.GetVal() );		
		ComputeSatellitePositions( satellite );
        
        ReadTelescopeData( "satellite/" + app_telescopeFile.GetVal() );
        ComputeTelescopePositions( telescope );
        
        initialized = true;
	}
    
    
	void PlaceButtons() {
		buttons.clear();
		int border = 8;
#ifdef IPHONE
        int buttonWidth = 32 * GetScaleFactor();
#else
		int buttonWidth = 32;		
#endif
		int y = r_windowHeight.GetVal() - buttonWidth - border;
		int x = border;
		if ( appMode == AppMode_ViewStars ) {
#if APP_star3free
			star3mapAppStore->bounds = Bounds2f( x, y, x + buttonWidth, y + buttonWidth );
			buttons.push_back( star3mapAppStore );
			x += buttonWidth + border;
#endif
			//viewGlobe->bounds = Bounds2f( x, y, x + buttonWidth, y + buttonWidth );
			//buttons.push_back( viewGlobe );
			//x += buttonWidth + border;
			if ( GotCompassUpdate ) {
				//toggleCompass->bounds = Bounds2f( x, y, x + buttonWidth, y + buttonWidth );
				//buttons.push_back( toggleCompass );
				//x += buttonWidth + border;
			}
		} else if ( appMode == AppMode_ViewGlobe ) {
			//viewStars->bounds = Bounds2f( x, y, x + buttonWidth, y + buttonWidth );
			//buttons.push_back( viewStars );
			//x += buttonWidth + border;
			//toggleChangeLocation->bounds = Bounds2f( x, y, x + buttonWidth, y + buttonWidth );
			//buttons.push_back( toggleChangeLocation );
			//x += buttonWidth + border;
			//toggleCoreLocation->bounds = Bounds2f( x, y, x + buttonWidth, y + buttonWidth );
			//buttons.push_back( toggleCoreLocation );
			//x += buttonWidth + border;
		}
		if ( satellite.size() > 0 ) {
			//toggleSatellites->bounds = Bounds2f( x, y, x + buttonWidth, y + buttonWidth );
			//buttons.push_back( toggleSatellites );
			x += buttonWidth + border;
		}
	}
	
	struct DrawNonOverlappingStrings {
		vector< OrientedBounds2f > reserved;
		vector< OrientedBounds2f > obs;
		
		bool CanDrawString( const string & str, const Vec3f & direction, const Vec3f & lookDir, float limit ) {
			if ( lookDir.Dot( direction ) < limit ) {
				return false;
			}
			OrientedBounds2f ob = StringBounds( str, direction );
			for ( int i = 0; i < (int)obs.size(); i++ ) {
				if ( Intersect( ob, obs[ i ] ) ) {
					return false; // intersected, so don't draw this one
				}
			}
			return true;
		}
		
		void ReserveString( const string & str, const Vec3f & direction, const Vec3f & lookDir, float limit ) {
			if ( lookDir.Dot( direction ) < limit ) {
				return;
			}
			OrientedBounds2f ob = StringBounds( str, direction );
			reserved.push_back( ob );
		}

		void DrawString( const string & str, const Vec3f & direction, const Vec3f & lookDir, float limit ) {
			if ( lookDir.Dot( direction ) < limit ) {
				return;
			}
			
			OrientedBounds2f ob = StringBounds( str, direction );
			if ( ob.empty ) {
				return;
			}
				
			for ( int i = 0; i < (int)obs.size(); i++ ) {
				if ( Intersect( ob, obs[ i ] ) ) {
					return; // intersected, so don't draw this one
				}
			}
			for ( int i = 0; i < (int)reserved.size(); i++ ) {
				if ( Intersect( ob, reserved[ i ] ) ) {
					return; // intersected, so don't draw this one
				}
			}
			obs.push_back( ob );
			::DrawString( str, direction );
			if ( app_debugLabels.GetVal() ) {
				if ( app_debugLabels.GetVal() > 1 ) {
					float len = 0;
					for ( int i = 0; i < 4; i++ ) {
						len = max( len, ( ob.vert[ i ] - ob.vert[ (i+1)%4 ] ).Length() );
					}
					if ( len > 10 ) {
						Output( "bounds %d %s: ( %f, %f ), ( %f, %f ), ( %f, %f ), ( %f, %f )",
							   (int)obs.size(), str.c_str(),
							   ob.vert[0].x, ob.vert[0].y,
							   ob.vert[1].x, ob.vert[1].y,
							   ob.vert[2].x, ob.vert[2].y,
							   ob.vert[3].x, ob.vert[3].y );					
					}
				}
				PushTransform();
				ClearTransform();
				SetColor( Vec4f( 1, 1, 0, 1 ) );
				ImVarying( 0 );
				ImBegin( Primitive_LineStrip );
				ImVertex( ob.vert[0] );
				ImVertex( ob.vert[1] );
				ImVertex( ob.vert[2] );
				ImVertex( ob.vert[3] );
				ImVertex( ob.vert[0] );
				ImEnd();
				PopTransform();
			}
		}
	};

	const float RampUpTime = .5f;
	
	struct DynamicRenderable {
		enum DState {
			DState_Invalid,
			DState_RampUp,
			DState_Hold,
			DState_RampDown,
			DState_Terminate,
			DState_MAX
		};
		DynamicRenderable() {}
		DynamicRenderable( const Vec3f & lDir, const Vec3f & lLookDir, float lLimit, const Vec4f & lColor, float lDuration ) 
		: direction( lDir ), lookDir( lLookDir ), limit( lLimit ), color( lColor ), duration( lDuration ), state( DState_RampUp ) {
			timeStamp = GetSeconds();
			currAlpha = 0.0f;
		} 
		Vec3f direction;
		Vec3f lookDir;
		float limit;
		Vec4f color;
		float currAlpha;
		float duration;
		DState state;
		float timeStamp;
		float lastSeen;
		void age() {
			float currTime = GetSeconds();
			float delta = currTime - timeStamp;
			switch ( state ) {
				case DState_RampUp:
					if ( delta > RampUpTime ) {
						timeStamp += RampUpTime;
						state = DState_Hold;
						delta = RampUpTime;
					}
					currAlpha = ( delta / RampUpTime ) * color.w;
					break;
				case DState_Hold:
					if ( delta > duration ) {
						timeStamp += duration;
						state = DState_RampDown;
					}
					break;
				case DState_RampDown:
					if ( delta > RampDownTime ) {
						timeStamp += RampUpTime;
						state = DState_Terminate;
						delta = RampDownTime;
					}
					currAlpha = ( 1.0f - delta / RampDownTime ) * color.w;
					break;
				case DState_Terminate:
					break;
				default:
					Output( "Something has gone wrong." );
					break;
			}
		}
		void seen() {
			lastSeen = GetSeconds();
		}
	};
	
	struct DynamicLabel : public DynamicRenderable {
		DynamicLabel() {}
		DynamicLabel( const string & lName, const Vec3f & lDir, const Vec3f & lLookDir, float lLimit, const Vec4f & lColor, float lDuration ) 
		: DynamicRenderable( lDir, lLookDir, lLimit, lColor, lDuration ), name( lName ) {
			timeStamp = GetSeconds();
			currAlpha = 0.0f;
		} 
		string name;
		void render( DrawNonOverlappingStrings & nos ) {
			if ( state != DState_Terminate ) {
				SetColor( Vec4f( color.x, color.y, color.z, currAlpha ) );
				nos.DrawString( name, direction, lookDir, limit );
			}
		}
	};
	
	map< string, DynamicLabel > dynamicLabels;
	
	void AgeDynamicLabels() {
		if ( app_pauseAging.GetVal() ) {
			return;
		}
		map< string, DynamicLabel > oldLabels = dynamicLabels;
		dynamicLabels.clear();
		map< string, DynamicLabel >::iterator it;
		int count = 0;
		float currTime = GetSeconds();
		for ( it = oldLabels.begin(); it != oldLabels.end(); ++it ) {
			DynamicLabel & dl = it->second;
			dl.age();
			if ( dl.state != DynamicLabel::DState_Terminate || ( currTime - dl.lastSeen ) < 1.0f ) {
				dynamicLabels[ dl.name ] = dl;
			}
			count++;
		}
	}
	
	void DrawDynamicLabels( DrawNonOverlappingStrings & nos ) {
		map< string, DynamicLabel >::iterator it;
		for ( it = dynamicLabels.begin(); it != dynamicLabels.end(); ++it ) {
			DynamicLabel & dl = it->second;
			dl.render( nos );
		}
	}
	
	
	struct DynamicLines : public DynamicRenderable {
		DynamicLines() {}
		DynamicLines( Lines *lLines, const Vec3f & lDir, const Vec3f & lLookDir, float lLimit, const Vec4f lColor, float lDuration ) 
		: DynamicRenderable( lDir, lLookDir, lLimit, lColor, lDuration ), lines( lLines ) {
			timeStamp = GetSeconds();
			currAlpha = 0.0f;
		} 
		Lines *lines;
		void render() {
			if ( state != DState_Terminate ) {
				SetColor( Vec4f( color.x, color.y, color.z, currAlpha ) );
				ImVarying( 0 );
				ImBegin( Primitive_Lines );
				for( int j = 0; j < (int)lines->vert.size(); j++ ) {
					Vec3f & v = lines->vert[ j ];
					ImVertex( v.x, v.y, v.z );
				}
				ImEnd();
			}
		}
	};
	
	map< Lines *, DynamicLines > dynamicLines;
	
	void AgeDynamicLines() {
		if ( app_pauseAging.GetVal() ) {
			return;
		}		
		map< Lines *, DynamicLines > oldLines = dynamicLines;
		dynamicLines.clear();
		map< Lines *, DynamicLines >::iterator it;
		int count = 0;
		float currTime = GetSeconds();
		for ( it = oldLines.begin(); it != oldLines.end(); ++it ) {
			DynamicLines & dl = it->second;
			dl.age();
			if ( dl.state != DynamicLabel::DState_Terminate || ( currTime - dl.lastSeen ) < 1.0f ) {
				dynamicLines[ dl.lines ] = dl;
			}
			count++;
		}
	}
	
	void DrawDynamicLines() {
		map< Lines *, DynamicLines >::iterator it;
		for ( it = dynamicLines.begin(); it != dynamicLines.end(); ++it ) {
			DynamicLines & dl = it->second;
			dl.render();
		}
	}
	
	// Draw something to illustrate the horizon
	void DrawUpHemisphere() {
		//Output("DrawUpHemisphere");
		hemiTex->Bind( 0 );
		hemiTex->Enable();
		SetColor( Vec4f( 1, 1, 1, 1 ) );
		hemiModel->Draw();
		hemiTex->Disable();
	}
	
	void DrawEarth() {
        time_t t = time(0);   // get time now
        struct tm * now = localtime( & t );
        //if (now->tm_hour > 15 && now->tm_hour < 6) {
        earthTex->Bind( 0 );
        earthTex->Enable();
        SetColor( Vec4f( 1, 1, 1, 1 ) );
        sphereModel->Draw();
        earthTex->Disable();
        
        earthLightTex->Bind( 0 );
        earthLightTex->Enable();
        SetColor( Vec4f( 1, 1, 1, 1 ) );
        sphereModel->Draw();
        earthLightTex->Disable();
        /*} else {
            earthTex->Bind( 0 );
            earthTex->Enable();
            SetColor( Vec4f( 1, 1, 1, 1 ) );
            sphereModel->Draw();
            earthTex->Disable();
        }*/
        
		
	}
	
	
	bool hasViewedGlobe = false;
	float globeViewLat;
	float globeViewLon;
	void SetAppMode( const vector< Token > & tokens ) {
		if ( tokens.size() == 2 ) {
			if ( tokens[1].valString == "viewStars" ) {
				appMode = AppMode_ViewStars;
			} else if ( tokens[1].valString == "viewGlobe" ) {
				appMode = AppMode_ViewGlobe;
				if ( hasViewedGlobe == false ) {
					hasViewedGlobe = true;
					globeViewLat = app_latitude.GetVal();
					globeViewLon = app_longitude.GetVal();
				}
			}
		}
	}
	CommandFunc SetAppModeCmd( "setAppMode", "set app mode :-)", SetAppMode );
	
	void UpdateManualOrientation() {
        Matrix4f phiMat = Rotationf( Vec3f( 1, 0, 0 ), -ToRadians( app_manualPhi.GetVal() + 90 ) ).GetMatrix4();
		Matrix4f thetaMat = Rotationf( Vec3f( 0, 0, 1 ), -ToRadians( app_manualTheta.GetVal() ) ).GetMatrix4();
        Output( "Updating manualOrientation from phi=%f theta=%f", app_manualPhi.GetVal(), app_manualTheta.GetVal() );
		manualOrientation = phiMat * thetaMat;
	}
	
}




namespace star3map {
	
    AppModeEnum GetDisplayMode()
    {
        return appMode;
    }
    
	bool touchActive = false;
	Vec2f inputInertia;
	void ApplyInputInertia() {
		
		inputInertia *= app_inputDrag.GetVal();
		float len = inputInertia.Length();
		
		if ( touchActive == false && len > 1 ) {
			float dx = inputInertia.x;
			float dy = inputInertia.y;
			if ( appMode == AppMode_ViewGlobe && ( dx != 0 || dy != 0 ) ) {
				globeViewLat = max( -90.f, min( 90.f, globeViewLat - dy ) );
				globeViewLon = ModuloRange( globeViewLon - dx, -180, 180 );
				if ( app_changeLocation.GetVal() ) {
					app_useCoreLocation.SetVal( false );
					app_latitude.SetVal( globeViewLat );
					app_longitude.SetVal( globeViewLon );
				}
			} else if ( appMode == AppMode_ViewStars && app_useCompass.GetVal() == true ) {
				float phi = max( -90.f, min( 90.f, app_manualPhi.GetVal() - dy ) );
				float theta = ModuloRange( app_manualTheta.GetVal() + dx, -180, 180 );
                Output("phi:%f   theta:%f", phi, theta);
				app_manualPhi.SetVal( phi );
				app_manualTheta.SetVal( theta );
				UpdateManualOrientation();
			}
		}
		
	}

	
	bool ProcessInput( bool active, int x, int y ) {
		
		bool handled = false;
		for ( int i = 0; i < (int)buttons.size(); i++ ) {
			handled = handled || buttons[i]->ProcessInput( active, x, y );
		}
		
		if ( app_useCoreLocation.GetVal() == true && GotLocationUpdate == false ) {
			Output( "setting useCoreLocation back to false because we have not gotten a location update" );
			app_useCoreLocation.SetVal( false );
		}
		if ( app_useCompass.GetVal() == true && GotCompassUpdate == false ) {
			Output( "setting useCompass back to false because we have not gotten a compass update" );
			app_useCompass.SetVal( false );
		}
		if ( app_showSatellites.GetVal() == true && satellite.size() == 0 ) {
			Output( "setting showSatellites to false because we have not gotten TLE data" );
			app_showSatellites.SetVal( false );
		}
		
		static int prevx;
		static int prevy;
		float dx;
		float dy;
		// If the UI didn't handle the input, then try to use it as "global" input
		if ( active && handled == false ) {
            if ( appMode == AppMode_ViewStars && app_useCompass.GetVal() == true ) {
                app_useCompass.SetVal(  false );
            }
            
            
			if ( prevx != 0 && prevy != 0 ) {
				float factor = 0.25 * r_fov.GetVal() / 90.0f;
				dx = factor * ( x - prevx ) ;
				dy = factor * ( y - prevy );
				if ( appMode == AppMode_ViewGlobe && ( dx != 0 || dy != 0 ) ) {
					globeViewLat = max( -90.f, min( 90.f, globeViewLat - dy ) );
					globeViewLon = ModuloRange( globeViewLon - dx, -180, 180 );
					if ( app_changeLocation.GetVal() ) {
						app_useCoreLocation.SetVal( false );
						app_latitude.SetVal( globeViewLat );
						app_longitude.SetVal( globeViewLon );
					}
				} else if ( appMode == AppMode_ViewStars && app_useCompass.GetVal() == false ) {
					float phi = max( -90.f, min( 90.f, app_manualPhi.GetVal() - dy ) );
					float theta = ModuloRange( app_manualTheta.GetVal() + dx, -180, 180 );
					app_manualPhi.SetVal( phi );
					app_manualTheta.SetVal( theta );
					UpdateManualOrientation();
				}
			}
			prevx = x;
			prevy = y;
			if ( fabs( float( dx ) ) > fabs( inputInertia.x ) ) {
				inputInertia.x = dx;
			}
			if ( fabs( float( dy ) ) > fabs( inputInertia.y ) ) {
				inputInertia.y = dy;
			}
		}

		if ( active == false ) {
			prevx = prevy = 0;
		}
		
		touchActive = active;
		
		return true;
	}
	
	
	void DisplayViewStars() {
		DrawNonOverlappingStrings nos;
		
		Clear();
		
		PushTransform(); // 0
		ClearTransform();
		r3::Matrix4f proj = r3::Perspective( r_fov.GetVal(), float(r_windowWidth.GetVal()) / r_windowHeight.GetVal(), 0.1f, 100.0f );
		ApplyTransform( proj );
		
		float latitude = ToRadians( app_latitude.GetVal() );
		float longitude = ToRadians( app_longitude.GetVal() );
		Matrix4f xout = Rotationf( Vec3f( 0, 1, 0 ), -R3_PI / 2.0f ).GetMatrix4(); // current Lat/Lon now at { 0, 0, 1 }, with z up
		Matrix4f zup = Rotationf( Vec3f( 1, 0, 0 ), -R3_PI / 2.0f ).GetMatrix4();  // current Lat/Lon now at { 1, 0, 0 }, with z up
		Matrix4f lat = Rotationf( Vec3f( 0, 1, 0 ), latitude ).GetMatrix4();       // current Lat/Lon now at { 1, 0, 0 }, with y up
		Matrix4f lon = Rotationf( Vec3f( 0, 0, 1 ), -longitude ).GetMatrix4();
		float phaseEarthRot = GetCurrentEarthPhase();
		Matrix4f phase = Rotationf( Vec3f( 0, 0, 1 ), -phaseEarthRot ).GetMatrix4();
			
		Matrix4f comp = ( xout * zup * lat * lon * phase );

		
		BlendFunc( BlendFunc_SrcAlpha, BlendFunc_OneMinusSrcAlpha );
		BlendEnable();
		
		SetColor( Vec4f( 1, 1, 1 ) );
		
		// compute culling info
		Matrix4f mvp = proj * orientation * comp;
		Matrix4f imvp = mvp.Inverse();
		Vec3f lookDir = imvp * Vec3f( 0, 0, -1 );
		lookDir.Normalize();
		Vec3f corner = imvp * Vec3f( 1, 1, 1 );
		corner.Normalize();
		float limit = lookDir.Dot( corner );

		float labelLimit = ( limit + 8 ) / 9.0f;
		
		
		PushTransform(); // 1
		ApplyTransform( orientation );			

		// draw horizon hemisphere indicator
		DrawUpHemisphere();	
		
		ApplyTransform( comp );
		
		Matrix3f local = ToMatrix3( comp );
		UpVector = local.GetRow(2); // to orient text correctly

		
		// draw constellations
		for ( int i = 0; i < (int)constellations.size(); i++ ) {
			Lines &l = constellations[ i ];
			Vec4f c( .5, .5, .7, .5 );
			Vec4f cl( .5, .5, .7, .8 );
            
            if (l.name == "Andromeda") {
                DrawSprite(CreateTexture2DFromFile( "constellations/andromeda_low.png", TextureFormat_RGBA ), 50, l.center, lookDir);
            } else if (l.name == "Antila") {
                DrawSprite(CreateTexture2DFromFile( "constellations/antila_low.png", TextureFormat_RGBA ), 35, l.center, lookDir);
            } else if (l.name == "Apus") {
                DrawSprite(CreateTexture2DFromFile( "constellations/apus_low.png", TextureFormat_RGBA ), 20, l.center, lookDir);
            } else if (l.name == "Aquarius") {
                DrawSprite(CreateTexture2DFromFile( "constellations/aquarius_low.png", TextureFormat_RGBA ), 70, l.center, lookDir);
            } else if (l.name == "Aquila") {
                DrawSprite(CreateTexture2DFromFile( "constellations/aquila_low.png", TextureFormat_RGBA ), 65, l.center, lookDir);
            } else if (l.name == "Ara") {
                DrawSprite(CreateTexture2DFromFile( "constellations/ara_low.png", TextureFormat_RGBA ), 30, l.center, lookDir);
            } else if (l.name == "Aries") {
                DrawSprite(CreateTexture2DFromFile( "constellations/aries_low.png", TextureFormat_RGBA ), 50, l.center, lookDir);
            } else if (l.name == "Auriga") {
                DrawSprite(CreateTexture2DFromFile( "constellations/auriga_low.png", TextureFormat_RGBA ), 90, l.center, lookDir);
            } else if (l.name == "Bootes") {
                DrawSprite(CreateTexture2DFromFile( "constellations/bootes_low.png", TextureFormat_RGBA ), 80, l.center, lookDir);
            } else if (l.name == "Caelum") {
                DrawSprite(CreateTexture2DFromFile( "constellations/caelum_low.png", TextureFormat_RGBA ), 15, l.center, lookDir);
            } else if (l.name == "Camelopardalis") {
                DrawSprite(CreateTexture2DFromFile( "constellations/camelopardalis_low.png", TextureFormat_RGBA ), 50, l.center, lookDir);
            } else if (l.name == "Cancer") {
                DrawSprite(CreateTexture2DFromFile( "constellations/cancer_low.png", TextureFormat_RGBA ), 60, l.center, lookDir);
            } else if (l.name == "Canes Venatici") {
                DrawSprite(CreateTexture2DFromFile( "constellations/canes_venatici_low.png", TextureFormat_RGBA ), 15, l.center, lookDir);
            } else if (l.name == "Canis Major") {
                DrawSprite(CreateTexture2DFromFile( "constellations/canis_major_low.png", TextureFormat_RGBA ), 40, l.center, lookDir);
            } else if (l.name == "Canis Minor") {
                DrawSprite(CreateTexture2DFromFile( "constellations/canis_minor_low.png", TextureFormat_RGBA ), 25, l.center, lookDir);
            } else if (l.name == "Capricornus") {
                DrawSprite(CreateTexture2DFromFile( "constellations/capricornus_low.png", TextureFormat_RGBA ), 55, l.center, lookDir);
            } else if (l.name == "Carina") {
                DrawSprite(CreateTexture2DFromFile( "constellations/carina_low.png", TextureFormat_RGBA ), 50, l.center, lookDir);
            } else if (l.name == "Cassiopeia") {
                DrawSprite(CreateTexture2DFromFile( "constellations/cassiopeia_low.png", TextureFormat_RGBA ), 50, l.center, lookDir);
            } else if (l.name == "Centaurus") {
                DrawSprite(CreateTexture2DFromFile( "constellations/centaurus_low.png", TextureFormat_RGBA ), 80, l.center, lookDir);
            } else if (l.name == "Cepheus") {
                DrawSprite(CreateTexture2DFromFile( "constellations/cepheus_low.png", TextureFormat_RGBA ), 60, l.center, lookDir);
            } else if (l.name == "Cetus") {
                DrawSprite(CreateTexture2DFromFile( "constellations/cetus_low.png", TextureFormat_RGBA ), 100, l.center, lookDir);
            } else if (l.name == "Chamaeleon") {
                DrawSprite(CreateTexture2DFromFile( "constellations/chamaeleon_low.png", TextureFormat_RGBA ), 40, l.center, lookDir);
            } else if (l.name == "Circinus") {
                DrawSprite(CreateTexture2DFromFile( "constellations/circinus_low.png", TextureFormat_RGBA ), 20, l.center, lookDir);
            } else if (l.name == "Columba") {
                DrawSprite(CreateTexture2DFromFile( "constellations/columba_low.png", TextureFormat_RGBA ), 25, l.center, lookDir);
            } else if (l.name == "Coma Berenices") {
                DrawSprite(CreateTexture2DFromFile( "constellations/coma_berenices_low.png", TextureFormat_RGBA ), 40, l.center, lookDir);
            } else if (l.name == "Corona Australis") {
                DrawSprite(CreateTexture2DFromFile( "constellations/corona_australis_low.png", TextureFormat_RGBA ), 15, l.center, lookDir);
            } else if (l.name == "Corona Borealis") {
                DrawSprite(CreateTexture2DFromFile( "constellations/corona_borealis_low.png", TextureFormat_RGBA ), 15, l.center, lookDir);
            } else if (l.name == "Corvus") {
                DrawSprite(CreateTexture2DFromFile( "constellations/corvus_low.png", TextureFormat_RGBA ), 30, l.center, lookDir);
            } else if (l.name == "Crater") {
                DrawSprite(CreateTexture2DFromFile( "constellations/crater_low.png", TextureFormat_RGBA ), 30, l.center, lookDir);
            } else if (l.name == "Crux") {
                DrawSprite(CreateTexture2DFromFile( "constellations/crux_low.png", TextureFormat_RGBA ), 15, l.center, lookDir);
            } else if (l.name == "Cygnus") {
                DrawSprite(CreateTexture2DFromFile( "constellations/cygnus_low.png", TextureFormat_RGBA ), 50, l.center, lookDir);
            } else if (l.name == "Delphinus") {
                DrawSprite(CreateTexture2DFromFile( "constellations/delphinus_low.png", TextureFormat_RGBA ), 30, l.center, lookDir);
            } else if (l.name == "Dorado") {
                DrawSprite(CreateTexture2DFromFile( "constellations/dorado_low.png", TextureFormat_RGBA ), 40, l.center, lookDir);
            } else if (l.name == "Draco") {
                DrawSprite(CreateTexture2DFromFile( "constellations/draco_low.png", TextureFormat_RGBA ), 80, l.center, lookDir);
            } else if (l.name == "Equuleus") {
                DrawSprite(CreateTexture2DFromFile( "constellations/equuleus_low.png", TextureFormat_RGBA ), 20, l.center, lookDir);
            } else if (l.name == "Eridanus") {
                DrawSprite(CreateTexture2DFromFile( "constellations/eridanus_low.png", TextureFormat_RGBA ), 120, l.center, lookDir);
            } else if (l.name == "Fornax") {
                DrawSprite(CreateTexture2DFromFile( "constellations/fornax_low.png", TextureFormat_RGBA ), 15, l.center, lookDir);
            } else if (l.name == "Gemini") {
                DrawSprite(CreateTexture2DFromFile( "constellations/gemini_low.png", TextureFormat_RGBA ), 70, l.center, lookDir);
            } else if (l.name == "Grus") {
                DrawSprite(CreateTexture2DFromFile( "constellations/grus_low.png", TextureFormat_RGBA ), 40, l.center, lookDir);
            } else if (l.name == "Hercules") {
                DrawSprite(CreateTexture2DFromFile( "constellations/hercules_low.png", TextureFormat_RGBA ), 80, l.center, lookDir);
            } else if (l.name == "Horologium") {
                DrawSprite(CreateTexture2DFromFile( "constellations/horologium_low.png", TextureFormat_RGBA ), 40, l.center, lookDir);
            } else if (l.name == "Hydra") {
                DrawSprite(CreateTexture2DFromFile( "constellations/hydra_low.png", TextureFormat_RGBA ), 100, l.center, lookDir);
            } else if (l.name == "Hydrus") {
                DrawSprite(CreateTexture2DFromFile( "constellations/hydrus_low.png", TextureFormat_RGBA ), 40, l.center, lookDir);
            } else if (l.name == "Indus") {
                DrawSprite(CreateTexture2DFromFile( "constellations/indus_low.png", TextureFormat_RGBA ), 20, l.center, lookDir);
            } else if (l.name == "Lacerta") {
                DrawSprite(CreateTexture2DFromFile( "constellations/lacerta_low.png", TextureFormat_RGBA ), 30, l.center, lookDir);
            } else if (l.name == "Leo") {
                DrawSprite(CreateTexture2DFromFile( "constellations/leo_low.png", TextureFormat_RGBA ), 80, l.center, lookDir);
            } else if (l.name == "Leo Minor") {
                DrawSprite(CreateTexture2DFromFile( "constellations/leo_minor_low.png", TextureFormat_RGBA ), 60, l.center, lookDir);
            } else if (l.name == "Lepus") {
                DrawSprite(CreateTexture2DFromFile( "constellations/lepus_low.png", TextureFormat_RGBA ), 35, l.center, lookDir);
            } else if (l.name == "Libra") {
                DrawSprite(CreateTexture2DFromFile( "constellations/libra_low.png", TextureFormat_RGBA ), 35, l.center, lookDir);
            } else if (l.name == "Lupus") {
                DrawSprite(CreateTexture2DFromFile( "constellations/lupus_low.png", TextureFormat_RGBA ), 50, l.center, lookDir);
            } else if (l.name == "Lynx") {
                DrawSprite(CreateTexture2DFromFile( "constellations/lynx_low.png", TextureFormat_RGBA ), 90, l.center, lookDir);
            } else if (l.name == "Lyra") {
                DrawSprite(CreateTexture2DFromFile( "constellations/lyra_low.png", TextureFormat_RGBA ), 20, l.center, lookDir);
            } else if (l.name == "Mensa") {
                DrawSprite(CreateTexture2DFromFile( "constellations/mensa_low.png", TextureFormat_RGBA ), 35, l.center, lookDir);
            } else if (l.name == "Monoceros") {
                DrawSprite(CreateTexture2DFromFile( "constellations/monoceros_low.png", TextureFormat_RGBA ), 80, l.center, lookDir);
            } else if (l.name == "Musca") {
                DrawSprite(CreateTexture2DFromFile( "constellations/musca_low.png", TextureFormat_RGBA ), 20, l.center, lookDir);
            } else if (l.name == "Norma") {
                DrawSprite(CreateTexture2DFromFile( "constellations/norma_low.png", TextureFormat_RGBA ), 20, l.center, lookDir);
            } else if (l.name == "Octans") {
                DrawSprite(CreateTexture2DFromFile( "constellations/octans_low.png", TextureFormat_RGBA ), 30, l.center, lookDir);
            } else if (l.name == "Orion") {
                DrawSprite(CreateTexture2DFromFile( "constellations/orion_low.png", TextureFormat_RGBA ), 65, l.center, lookDir);
            } else if (l.name == "Pavo") {
                DrawSprite(CreateTexture2DFromFile( "constellations/pavo_low.png", TextureFormat_RGBA ), 50, l.center, lookDir);
            } else if (l.name == "Pegasus") {
                DrawSprite(CreateTexture2DFromFile( "constellations/pegasus_low.png", TextureFormat_RGBA ), 110, l.center, lookDir);
            } else if (l.name == "Perseus") {
                DrawSprite(CreateTexture2DFromFile( "constellations/perseus_low.png", TextureFormat_RGBA ), 80, l.center, lookDir);
            } else if (l.name == "Phoenix") {
                DrawSprite(CreateTexture2DFromFile( "constellations/phoenix_low.png", TextureFormat_RGBA ), 40, l.center, lookDir);
            } else if (l.name == "Pictor") {
                DrawSprite(CreateTexture2DFromFile( "constellations/pictor_low.png", TextureFormat_RGBA ), 30, l.center, lookDir);
            } else if (l.name == "Pisces") {
                DrawSprite(CreateTexture2DFromFile( "constellations/pisces_low.png", TextureFormat_RGBA ), 100, l.center, lookDir);
            } else if (l.name == "Piscis Austrinus") {
                DrawSprite(CreateTexture2DFromFile( "constellations/piscis_austrinus_low.png", TextureFormat_RGBA ), 35, l.center, lookDir);
            } else if (l.name == "Pyxis") {
                DrawSprite(CreateTexture2DFromFile( "constellations/pyxis_low.png", TextureFormat_RGBA ), 25, l.center, lookDir);
            } else if (l.name == "Reticulum") {
                DrawSprite(CreateTexture2DFromFile( "constellations/reticulum_low.png", TextureFormat_RGBA ), 15, l.center, lookDir);
            } else if (l.name == "Sagitta") {
                DrawSprite(CreateTexture2DFromFile( "constellations/sagitta_low.png", TextureFormat_RGBA ), 15, l.center, lookDir);
            } else if (l.name == "Sagittarius") {
                DrawSprite(CreateTexture2DFromFile( "constellations/sagittarius_low.png", TextureFormat_RGBA ), 80, l.center, lookDir);
            } else if (l.name == "Scorpius") {
                DrawSprite(CreateTexture2DFromFile( "constellations/scorpius_low.png", TextureFormat_RGBA ), 70, l.center, lookDir);
            } else if (l.name == "Sculptor") {
                DrawSprite(CreateTexture2DFromFile( "constellations/sculptor_low.png", TextureFormat_RGBA ), 40, l.center, lookDir);
            } else if (l.name == "Scutum") {
                DrawSprite(CreateTexture2DFromFile( "constellations/scutum_low.png", TextureFormat_RGBA ), 25, l.center, lookDir);
            } else if (l.name == "Sextans") {
                DrawSprite(CreateTexture2DFromFile( "constellations/sextans_low.png", TextureFormat_RGBA ), 12, l.center, lookDir);
            } else if (l.name == "Taurus") {
                DrawSprite(CreateTexture2DFromFile( "constellations/taurus_low.png", TextureFormat_RGBA ), 75, l.center, lookDir);
            } else if (l.name == "Telescopium") {
                DrawSprite(CreateTexture2DFromFile( "constellations/telescopium_low.png", TextureFormat_RGBA ), 15, l.center, lookDir);
            } else if (l.name == "Triangulum") {
                DrawSprite(CreateTexture2DFromFile( "constellations/triangulum_low.png", TextureFormat_RGBA ), 15, l.center, lookDir);
            } else if (l.name == "Tucana") {
                DrawSprite(CreateTexture2DFromFile( "constellations/tucana_low.png", TextureFormat_RGBA ), 40, l.center, lookDir);
            } else if (l.name == "Ursa Major") {
                DrawSprite(CreateTexture2DFromFile( "constellations/ursa_major_low.png", TextureFormat_RGBA ), 100, l.center, lookDir);
            } else if (l.name == "Ursa Minor") {
                DrawSprite(CreateTexture2DFromFile( "constellations/ursa_minor_low.png", TextureFormat_RGBA ), 50, l.center, lookDir);
            } else if (l.name == "Virgo") {
                DrawSprite(CreateTexture2DFromFile( "constellations/virgo_low.png", TextureFormat_RGBA ), 90, l.center, lookDir);
            } else if (l.name == "Volans") {
                DrawSprite(CreateTexture2DFromFile( "constellations/volans_low.png", TextureFormat_RGBA ), 25, l.center, lookDir);
            } else if (l.name == "Vulpecula") {
                DrawSprite(CreateTexture2DFromFile( "constellations/vulpecula_low.png", TextureFormat_RGBA ), 30, l.center, lookDir);
            }
            
            
			if ( lookDir.Dot( l.center ) > l.limit ) {
				if ( dynamicLines.count( &l ) == 0 ) {
					DynamicLines dl( &l, l.center, lookDir, 0, c, 4.0f );
					dynamicLines[ &l ] = dl;
				} else {
					dynamicLines[ &l ].seen();
				}
                //Output("constellation %s", l.name.c_str());
                
				if ( dynamicLabels.count( l.localizedName ) == 0 ) {
					DynamicLabel dl( l.localizedName, l.center, lookDir, 0, cl, 2.5f );
					dynamicLabels[ dl.name ] = dl;					
				} else {
					dynamicLabels[ l.name ].seen();
				}
			}
		}
		AgeDynamicLines();
		DrawDynamicLines();

		SetColor( Vec4f( 1, 1, 1, 1 ) );
		
		
		// Reserve space for planet labels.
		Matrix4f axis = Rotationf( Vec3f( 1, 0, 0 ), ToRadians( 23.0 ) ).GetMatrix4();
		Matrix4f iaxis = Rotationf( Vec3f( 1, 0, 0 ), ToRadians( -23.0 ) ).GetMatrix4();
		PushTransform(); // 2
		ApplyTransform( axis );
		{
			UpVector = iaxis * local.GetRow(2);
			// compute culling info
			Matrix4f mvp = proj * orientation * comp * axis;
			Matrix4f imvp = mvp.Inverse();
			Vec3f lookDir = imvp * Vec3f( 0, 0, -1 );
			lookDir.Normalize();
			
			for ( int i = 0; i < (int)solarsystem.size(); i++ ) {
				Sprite & s = solarsystem[i];
				nos.ReserveString( s.name, s.direction, lookDir, limit );
			}
			
		}
		PopTransform();  // 2
		
		UpVector = local.GetRow(2); // to orient text correctly

		//nos.DrawString( "Up", local.GetRow(2), lookDir, 0.3f );
		//nos.DrawString( "Down", -local.GetRow(2), lookDir, 0.3f );
		SetColor( Vec4f( 1, 1, 1, 1 ) );
		DrawSprite( nTex, 10, local.GetRow(1) );
		DrawSprite( sTex, 10, -local.GetRow(1) );
		DrawSprite( eTex, 10, local.GetRow(0) );
		DrawSprite( wTex, 10, -local.GetRow(0) );
        
        DrawSprite( up, 20, local.GetRow(2) );
        DrawSprite( down, 20, -local.GetRow(2) );

		float dynamicLabelDot = 0.0f;
		string dynamicLabel;
		Vec4f dynamicLabelColor;
		Vec3f dynamicLabelDirection;
		
		static int prev_culled;
		int culled = 0;
		int drew = 0;
		for ( int i = 0; i < (int)stars.size(); i++ ) {
			Sprite & s = stars[i];
			if ( s.magnitude > 4 ) {
				continue;
			}
			float dot = lookDir.Dot( s.direction );
			if ( app_cull.GetVal() && dot < limit ) {
				culled++;
				continue;
			}
			drew++;
			if ( s.name.size() > 0 && dot > labelLimit && dot > dynamicLabelDot && s.magnitude < 2.5 ) {
				float c = ( dot - labelLimit ) / ( 1.0 - labelLimit );
				c = pow( c, 4 );
				dynamicLabelDot = dot;
				dynamicLabel = s.name;
				dynamicLabelColor = Vec4f( 1, 1, 1, c );
				dynamicLabelDirection = s.direction;
			}
		}

		// draw stars
		{
			stars[0].tex->Bind( 0 );
			stars[0].tex->Enable();
			starsModel->Draw();
			stars[0].tex->Disable();
		}
		
		// draw satellites
		if ( app_showSatellites.GetVal() ) {

			double t = GetTime() / 1.0;
			t = t - floor( t );
            
            float r = t + 0;
			float g = t + 1.0 / 3.0;
			float b = t + 2.0 / 3.0;
			r = ( cos( r * R3_PI * 2.0 ) * .5 + .5 ) * .5 + .5;
			g = ( cos( g * R3_PI * 2.0 ) * .5 + .5 ) * .5 + .5;
			b = ( cos( b * R3_PI * 2.0 ) * .5 + .5 ) * .5 + .5;
			//SetColor( Vec4f( r, g, b, 1 ) );
			Matrix4f invPhase = Rotationf( Vec3f( 0, 0, 1 ), phaseEarthRot ).GetMatrix4();
			Vec3f viewer = invPhase * SphericalToCartesian( 6371, latitude, longitude );
			
			for ( int i = 0; i < (int)satellite.size(); i++ ) {
				Vec3f dir = satellite[ i ].pos - viewer;
				dir.Normalize();

				float dot = lookDir.Dot( dir );
				if ( app_cull.GetVal() && dot < limit ) {
					continue;
				}
                
                if (satellite[ i ].name == "ISIS 1") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/isis_1.png", TextureFormat_RGBA ), 5, dir );
                } else if (satellite[ i ].name == "ISS (ZARYA)") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/iss_(zarya).png", TextureFormat_RGBA ), 8, dir );
                } else if (satellite[ i ].name == "METEOR PRIRODA") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/meteor_priroda.png", TextureFormat_RGBA ), 5, dir );
                } else if (satellite[ i ].name == "AJISAI (EGS)") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/ajisai_(egs).png", TextureFormat_RGBA ), 3, dir );
                } else if (satellite[ i ].name == "AKARI (ASTRO-F)") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/akari_(astro-f).png", TextureFormat_RGBA ), 5, dir );
                } else if (satellite[ i ].name == "ALOS (DAICHI)") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/alos_(daichi).png", TextureFormat_RGBA ), 5, dir );
                } else if (satellite[ i ].name == "AQUA") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/aqua.png", TextureFormat_RGBA ), 5, dir );
                } else if (satellite[ i ].name == "ASTEX 1") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/astex_1.png", TextureFormat_RGBA ), 5, dir );
                } else if (satellite[ i ].name == "COSMO-SKYMED 1") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/cosmo-skymed_1.png", TextureFormat_RGBA ), 5, dir );
                } else if (satellite[ i ].name == "COSMOS 2428") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/cosmos_2428.png", TextureFormat_RGBA ), 5, dir );
                } else if (satellite[ i ].name == "ENVISAT") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/envisat.png", TextureFormat_RGBA ), 5, dir );
                } else if (satellite[ i ].name == "ERBS") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/erbs.png", TextureFormat_RGBA ), 5, dir );
                } else if (satellite[ i ].name == "ERS-1") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/ers-1.png", TextureFormat_RGBA ), 5, dir );
                } else if (satellite[ i ].name == "GENESIS 1") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/genesis_1.png", TextureFormat_RGBA ), 5, dir );
                } else if (satellite[ i ].name == "GENESIS 2") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/genesis_2.png", TextureFormat_RGBA ), 5, dir );
                } else if (satellite[ i ].name == "INTERCOSMOS 24") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/intercosmos_24.png", TextureFormat_RGBA ), 5, dir );
                } else if (satellite[ i ].name == "KORONAS-FOTON") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/koronas-foton.png", TextureFormat_RGBA ), 5, dir );
                } else if (satellite[ i ].name == "MIDORI II (ADEOS II)") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/midori_ii_(adeos-ii).png", TextureFormat_RGBA ), 5, dir );
                } else if (satellite[ i ].name == "OAO 2") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/oao_2.png", TextureFormat_RGBA ), 5, dir );
                } else if (satellite[ i ].name == "RESURS-DK 1") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/resurs-dk_1.png", TextureFormat_RGBA ), 5, dir );
                } else if (satellite[ i ].name == "SEASAT 1") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/seasat_1.png", TextureFormat_RGBA ), 5, dir );
                } else if (satellite[ i ].name == "TIANGONG 1") {
                    DrawSprite( CreateTexture2DFromFile( "satellites_images/tiangong_1.png", TextureFormat_RGBA ), 5, dir );
                } else {
                    DrawSprite( satTex, 5, dir );
                }
				
				if ( dot > labelLimit && dot > dynamicLabelDot ) {
					float c = ( dot - labelLimit ) / ( 1.0 - labelLimit );
					c = pow( c, 4 );
					dynamicLabelDot = dot;
                    if (satellite[ i ].name == "ISS (ZARYA)") {
                        dynamicLabel = "International Space Station";
                    } else {
                       dynamicLabel = satellite[ i ].name;
                    }
					dynamicLabelColor = Vec4f( 1, 1, 1, c );
					dynamicLabelDirection = dir;
				}
	
			}
            
            
            for ( int i = 0; i < (int)telescope.size(); i++ ) {
                Vec3f dir = telescope[ i ].pos - viewer;
                dir.Normalize();
                
                float dot = lookDir.Dot( dir );
                if ( app_cull.GetVal() && dot < limit ) {
                    continue;
                }
                
                DrawSprite( telTex, 7, dir );
                
                if ( dot > labelLimit && dot > dynamicLabelDot ) {
                    float c = ( dot - labelLimit ) / ( 1.0 - labelLimit );
                    c = pow( c, 4 );
                    dynamicLabelDot = dot;
                    dynamicLabel = "Hubble Space Telescope";
                    dynamicLabelColor = Vec4f( 1, 1, 1, c );
                    dynamicLabelDirection = dir;
                }
                
            }
		}
		
		
		AgeDynamicLabels();
		DrawDynamicLabels( nos );
		
		if ( dynamicLabelDot > 0.0f ) {
			if ( dynamicLabels.count( dynamicLabel )  == 0) {
				if ( nos.CanDrawString( dynamicLabel, dynamicLabelDirection, lookDir, limit ) ) {
					DynamicLabel dl( dynamicLabel, dynamicLabelDirection, lookDir, limit, Vec4f( 1, 1, 1, 1), 1.0f );
					dynamicLabels[ dl.name ] = dl;
				}
			} else {
				dynamicLabels[ dynamicLabel ].seen();
			}
		}
		

		if ( culled != prev_culled ) {
			//Output( "Culled %d and drew %d", culled, drew );
			prev_culled = culled;
		}
		
		nos.reserved.clear();
		PushTransform(); // 2
		ApplyTransform( axis );
		{
			UpVector = iaxis * local.GetRow(2);
			// compute culling info
			Matrix4f mvp = proj * orientation * comp * axis;
			Matrix4f imvp = mvp.Inverse();
			Vec3f lookDir = imvp * Vec3f( 0, 0, -1 );
			lookDir.Normalize();
			
			for ( int i = 0; i < (int)solarsystem.size(); i++ ) {
				Sprite & s = solarsystem[i];
				SetColor( s.color );
				DrawSprite( s.tex, s.scale, s.direction );			
				nos.DrawString( s.name, s.direction, lookDir, limit );
			}

		}
		PopTransform(); // 2
		
		BlendDisable();
		PopTransform(); // 1
		
		PopTransform(); // 0
	}
	
	struct IndexedSatDirCompare {
		const vector< Satellite > & sats;
		const Vec3f & dir;
		IndexedSatDirCompare( const vector< Satellite > & satList, const Vec3f & sortDir ) : sats( satList ), dir( sortDir ) {
		}
		bool operator() ( int a, int b ) {
			return dir.Dot( sats[a].pos ) > dir.Dot( sats[b].pos );
		}
	};
	
	
	void DisplayViewGlobe() {
		DrawNonOverlappingStrings nos;

		DepthFunc( Compare_Less );
		DepthTestEnable();
	
		Clear();
		
		PushTransform(); // 0
		ClearTransform();
		r3::Matrix4f proj = r3::Perspective( r_fov.GetVal(),
											float(r_windowWidth.GetVal()) / r_windowHeight.GetVal(), 0.5f, 100.0f );
		ApplyTransform( proj );		
		r3::Matrix4f trans;
		trans.SetTranslate( Vec3f( 0, 0, -2 ) );
		ApplyTransform( trans );

		float latitude = ToRadians( globeViewLat );
		float longitude = ToRadians( globeViewLon );
		Matrix4f xout = Rotationf( Vec3f( 0, 1, 0 ), -R3_PI / 2.0f ).GetMatrix4(); // current Lat/Lon now at { 0, 0, 1 }, with z up
		Matrix4f zup = Rotationf( Vec3f( 1, 0, 0 ), -R3_PI / 2.0f ).GetMatrix4();  // current Lat/Lon now at { 1, 0, 0 }, with z up
		Matrix4f lat = Rotationf( Vec3f( 0, 1, 0 ), latitude ).GetMatrix4();       // current Lat/Lon now at { 1, 0, 0 }, with y up
		Matrix4f lon = Rotationf( Vec3f( 0, 0, 1 ), -longitude ).GetMatrix4();
		float phaseEarthRot = GetCurrentEarthPhase();
		Matrix4f phase = Rotationf( Vec3f( 0, 0, 1 ), -phaseEarthRot ).GetMatrix4();

		Matrix4f comp = ( xout * zup * lat * lon );

		SetColor( Vec4f( 1, 1, 1 ) );

		PushTransform();
		ApplyTransform( comp );
        
		DrawEarth();

		PointSmoothEnable();
		BlendEnable();
		AlphaFunc( Compare_GreaterOrEqual, 0.1 );
		AlphaTestEnable();

		// current view position
		{
			Vec3f currPos = SphericalToCartesian( 1.005, ToRadians( app_latitude.GetVal() ), ToRadians( app_longitude.GetVal() ) );
			ImVarying( Varying_PositionBit );
			SetColor( Vec4f( 1, 1, 1, 1 ) );
			PointSize( 3 );
			ImBegin( Primitive_Points );
			ImVertex( currPos.x, currPos.y, currPos.z );
			ImEnd();
		}
		
		if ( app_showSatellites.GetVal() ) {
			PointSize( 3 );
			ApplyTransform( phase );
			
			vector<int> indexes( satellite.size() );
			for ( int i = 0; i < (int)indexes.size(); i++ ) {
				indexes[i] = i;
			}
			Matrix4f invPhase = Rotationf( Vec3f( 0, 0, 1 ), phaseEarthRot ).GetMatrix4();
			Vec3f dir = invPhase * SphericalToCartesian( 1.0, latitude, longitude );

			IndexedSatDirCompare isdc( satellite, dir );
			sort( indexes.begin(), indexes.end(), isdc );
			
			ImVarying( Varying_PositionBit );
			ImBegin( Primitive_Points );
			
			int num = min( app_maxSatellites.GetVal(), (int)satellite.size() );
            for ( int i = 0; i < num; i++ ) {
				Vec3f p = satellite[ indexes[ i ] ].pos;
				p /= 6371.0f;
				ImVertex( p.x, p.y, p.z );
			}
            ImEnd();
            
            
			PushTransform();
			Matrix4f billboard = ToMatrix4( ToMatrix3( GetTransform() ).Inverse() );
			for ( int i = 0; i < num; i++ ) {
				Satellite sat = satellite[ indexes[ i ] ];
                sat.pos /= 6371.0f;
                if (sat.name == "ISS (ZARYA)") {
                    SetColor( Vec4f( 1, 1, 1, 1 ) );
                    DrawStringAtLocation( "International Space Station", sat.pos, billboard );
                } else {
                    SetColor( Vec4f( 1, 1, 0, 1 ) );
                    DrawStringAtLocation( sat.name, sat.pos, billboard );

                }
            }
            PopTransform();
		}

		AlphaTestDisable();
		BlendDisable();
		PointSmoothDisable();

		PopTransform();

		PopTransform();

		DepthTestDisable();
	}
	
	void Display() {
		Initialize();  // do this once instead?
				
		ApplyInputInertia();
		
		if ( GotSatelliteData == false &&
			twoLineElements &&
			twoLineElements->running == false &&
			twoLineElements->urldata.size() > 0 ) {
			// we have satellite data
			GotSatelliteData = true;
			File *f = FileOpenForWrite( "satellite/" + app_satelliteFile.GetVal() );
			if ( f ) {
				f->Write( &twoLineElements->urldata[0], 1, (int)twoLineElements->urldata.size() );
				delete f;
			}
			delete twoLineElements;
			twoLineElements = NULL;
			ReadSatelliteData( "satellite/" + app_satelliteFile.GetVal() );
			app_showSatellites.SetVal( true );
		}
		
		if ( app_showSatellites.GetVal() ) {
			ComputeSatellitePositions( satellite );
		}
		
		orientation = app_useCompass.GetVal() ? platformOrientation : manualOrientation;
				
		UpdateLatLon();
		
		switch ( appMode ) {
			case AppMode_ViewStars:
				DisplayViewStars();
				break;
			case AppMode_ViewGlobe:
				DisplayViewGlobe();
				break;
			default:
				break;
		}

		// UI
		PlaceButtons();
		
		BlendFunc( BlendFunc_SrcAlpha, BlendFunc_OneMinusSrcAlpha );
		BlendEnable();
		PushTransform(); // 0
		ClearTransform();
		Matrix4f o = Ortho<float>( 0, r_windowWidth.GetVal(), 0, r_windowHeight.GetVal(), -1, 1 );
		ApplyTransform( o );
		for ( int i = 0; i < (int)buttons.size(); i++ ) {
			buttons[i]->Draw();
		}
		PopTransform(); // 0
		BlendDisable();
		
	}		
		
	
	

}


