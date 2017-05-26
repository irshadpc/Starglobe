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

#include "r3/common.h"
#include "r3/draw.h"
#include "r3/output.h"
#include "r3/btexture.h"
#include "r3/time.h"
#include "r3/var.h"

#include "PlanetFinderEngine.h"
#include <string.h>

#if _WIN32
# include <Windows.h>
#endif

// temporary while this code still does rendering
#include "../render.h"
using namespace star3map;
// end temporary

extern bool lowResolution;

using namespace r3;

namespace {
	bool initialized = false;
	r3::Texture2D *star0;
	int year2000Time;
	
	void initialize() {
		if ( initialized ) {
			return;
		}
		star0 = r3::CreateTexture2DFromFile(lowResolution ? "startex_low.jpg" : "startex.jpg", TextureFormat_RGBA );
		
		struct tm epoch_tm, curr_tm;
		time_t gmt = time_t( GetTime() );
		curr_tm = *Gmtime( &gmt );
		epoch_tm = curr_tm;
		epoch_tm.tm_sec = 0;
		epoch_tm.tm_min = 0;
		epoch_tm.tm_hour = 12;
		epoch_tm.tm_mday = 1;
		epoch_tm.tm_mon = 0;
		epoch_tm.tm_year = 2000 - 1900;
		epoch_tm.tm_isdst = -1; // timegm() will try to figure it out if negative

#if __APPLE__
		// we operate on gmtime only...
		setenv( "TZ", "", 1 );
		tzset();
		
		time_t epoch = timegm( & epoch_tm );
#else if _WIN32
		_putenv_s( "TZ", "GST" );
		_tzset();
		time_t epoch = mktime( & epoch_tm );
#endif
		//Output( "Epoch = %s", ctime( & epoch ) );
		
		year2000Time = epoch;
		
		// elements of orbits, taken from planetary fact sheets, NASA web site
		//Planet name = new Planet("name",mass,siderealperiod,a,e,incl,longascnode,longperi,meanlong);
		/*
		 Mercury:   -0.36 + 5*log10(r*R) + 0.027 * FV + 2.2E-13 * FV**6
		 Venus:     -4.34 + 5*log10(r*R) + 0.013 * FV + 4.2E-7  * FV**3
		 Mars:      -1.51 + 5*log10(r*R) + 0.016 * FV
		 Jupiter:   -9.25 + 5*log10(r*R) + 0.014 * FV
		 Saturn:    -9.0  + 5*log10(r*R) + 0.044 * FV + ring_magn
		 Uranus:    -7.15 + 5*log10(r*R) + 0.001 * FV
		 Neptune:   -6.90 + 5*log10(r*R) + 0.001 * FV
		 */
		
	}
	
}

int GetSecondsSince2000();
int moon_phase(int y, int m, int d);
float GetPhaseEarthRotation() {
	float daysSince2000 = GetSecondsSince2000() / float( 24 * 60 * 60 );
	float phaseEarthRot = ( daysSince2000 / CPlanetFinderEngine::earthRotationPeriod ) * 2.0 * M_PI - CPlanetFinderEngine::earthRotationPhase;
	return phaseEarthRot;
}

// Astronomy Constants
const float CPlanetFinderEngine::earthRotationTilt = 0.4092797;	// radians
const float CPlanetFinderEngine::earthRotationPeriod = 0.9972708;	// days
const float CPlanetFinderEngine::earthRotationPhase = -1.747;

const float CPlanetFinderEngine::sunMass = 3.33e+05; // in units of the earth's mass


void CPlanetFinderEngine::Construct()
{
	initialize();
	initPlanets();
}


// Initialisation

void CPlanetFinderEngine::Init(TPlanetFinderSettings& aSettings)
{
	init( aSettings.iLongitude, aSettings.iLatitude );
		
}

void CPlanetFinderEngine::init( float longitude, float latitude ) 
{
	this->longitude = ToRadians( longitude );
	this->latitude = ToRadians( latitude );

	secondsSince2000 = GetSecondsSince2000();// + 24*3600*2 + 3600*4;

	daysSince2000 = ((double) secondsSince2000)/(24*3600);
	//Output( "Days since J2000 = %f", (float)daysSince2000 );
}

void CPlanetFinderEngine::SetSize( int Width, int Height )
{
}

void CPlanetFinderEngine::initPlanets() 
{
	mercury.Init("Mercury",0.0558,87.969,0.38709893,0.20563069,7.00487,48.33167,77.45645,252.25084,true,-0.36,0.027,2.2e-13,6.0);
	venus.Init("Venus",0.815,224.701,0.72333199,0.00677323,3.39471,76.68069,131.53298,181.97973,true,-4.34,0.013,4.2e-7,3.0);
	earth.Init("Earth",1.0,365.256,1.00000011,0.01671022,0.00005,-11.26064,102.94719,100.46435,false,0.0,0.0,0.0,0.0);
	mars.Init("Mars",0.1075,686.980,1.52366231,0.09341233,1.85061,49.57854,336.04084,355.45332,true,-1.51,0.016,0.0,1.0);
	jupiter.Init("Jupiter",17.83,4332.589,5.20336301,0.04839266,1.30530,100.55615,14.75385,34.40438,true,-9.25,0.014,0,1);
	saturn.Init("Saturn",95.147,10759.22,9.53707032,0.05415060,2.48446,113.71504,92.43194,49.94432,true,-9.0,0.044,0,1);
	saturn.scale = 2.0f;
	uranus.Init("Uranus",14.54,30685.4,19.19126393,0.04716771,0.76986,74.22988,170.96424,313.23218,true,-7.15,0.001,0,1);
	neptune.Init("Neptune",17.23,60189.0,30.06896348,0.00858587,1.76917,131.72169,44.97135,304.88003,true,-6.90,0.001,0.0,1.0);
	pluto.Init("Pluto",0.0022,90465.0,39.48168677,0.24880766,17.14175,110.30347,224.06676,238.92881,false,0.0,0.0,0.0,0.0);

	planets[0] = &mercury; 
	planets[1] = &venus; 
	planets[2] = &earth; 
	planets[3] = &mars; 
	planets[4] = &jupiter;
	planets[5] = &saturn; 
	planets[6] = &uranus; 
	planets[7] = &neptune; 
	planets[8] = &pluto;

	sunTexture = CreateTexture2DFromFile( lowResolution ? "sun_low.png" : "sun.png", TextureFormat_RGBA );
};

   	

// Drawing

void CPlanetFinderEngine::buildSolarSystemList( std::vector< star3map::Sprite > & solarsystem )
{
	solarsystem.clear();
	
	float moonN0 = 125.1228;
	float moonw0 = 318.0634;
	//float moonM0 = 115.3654;
	float moonN = 	moonN0 - 0.0529538083 * daysSince2000;
	float moonw =  moonw0 + 0.1643573223 * daysSince2000;
	//float MoonM = 	moonM0 + 13.0649929509 * daysSince2000;

	moon.Init("Moon",1.23e-02,27.322,2.569519e-03,0.0549,5.145,
	     		moonN,
	     		moonN+moonw, //-- lon of peri = N + w
	     		/*moonN0+moonw0+moonM0*/ // meanlong2000 = N+w+M
	     		218.32,	//use Dave's data instead
	     		false,0.,0.,0.,0.);

	// This is the correction for parallax due to the earth's rotation.
	Vec3f earthPosition = earth.position( daysSince2000, 0.000001 ); // + (zenith * (float)(4.3e-05));
	Vec3f earthToMoon = moon.position( daysSince2000, 0.000001 );
	//--- Nonkeplerian perturbations for the moon:
	//First convert vector to spherical coords:
	float moonRad = earthToMoon.Length();
	float moonLat = acos( -earthToMoon.z / moonRad ) - M_PI/2.0;
	float moonLon = atan2(earthToMoon.y, earthToMoon.x);

	if ( moonLon < -M_PI/2.0 ) moonLon += M_PI;
	if ( moonLon > M_PI/2.0 ) moonLon -= M_PI;
	if ( earthToMoon.x < 0.0 ) moonLon += M_PI;
	if ( moonLon < 0.0 ) moonLon += 2*M_PI;
	if ( moonLon > 2.0*M_PI ) moonLon -= 2*M_PI;

	moonLon = moonLon + MoonPerturbations::moonLongitudeCorrectionDegrees(daysSince2000)*M_PI/180.0;
	moonLat = moonLat + MoonPerturbations::moonLatitudeCorrectionDegrees(daysSince2000)*M_PI/180.0;
		
	earthToMoon = latLongToUnitVector(moonLat,moonLon);
	earthToMoon *= moonRad;

	Vec3f moonPosition = earthToMoon + earthPosition;

	
	//================================================================================
	//		Show planets, moon & sun
	//================================================================================
	Vec3f planetsCenterOfMass(0, 0 , 0);
	Vec3f currentPosition[9];
	int i;

	for (i= 0; i<PLANETS_NUMBER; i++) 
	{
		currentPosition[i] = planets[i]->position( daysSince2000, 0.000001 );
		planetsCenterOfMass += currentPosition[i] * planets[i]->mass;
	}
	
	Vec3f sunPosition =  planetsCenterOfMass*(float)(-1.0/sunMass);
	for (i= -1; i<PLANETS_NUMBER; i++) 
	{   // Yuck.
		//==moon is when you do earth, sun is i== -1
		Vec3f directionFromEarth;
		SetColor( Vec4f( 1, 1, 1 ) );
		Texture2D *tex = NULL;
		std::string name;
		bool isSun,isMoon;
		isSun=false;
		isMoon=false;
		float scale = 1.0;
			
		if (i!= -1 && planets[i]!=&earth) 
		{
			// a planet other than earth
			directionFromEarth = currentPosition[i] - earthPosition;
			directionFromEarth.Normalize();
			tex = planets[ i ]->texture;
			name = planets[i]->name;
			scale = planets[ i ]->scale;
		}
		else 
		{
			if (i== -1) 
			{
				//-- sun
				directionFromEarth = sunPosition - earthPosition;
				directionFromEarth.Normalize();
                
                time_t currentTime;
                struct tm *localTime;
                
                time( &currentTime );                   // Get the current time
                localTime = localtime( &currentTime );  // Convert the current time to the local time
                int Sec    = localTime->tm_sec;
                
                int random = round(Sec);
                
                //int random = 1 + rand() % (14 - 1);
                //Output("t %d", random);
                if (random == 1 || random == 14 || random == 27 || random == 40 || random == 53) {
                    sunTexture = CreateTexture2DFromFile( lowResolution ? "sun1.png" : "sun1.png", TextureFormat_RGBA );
                } else if (random == 2 || random == 15 || random == 28 || random == 41 || random == 54) {
                    sunTexture = CreateTexture2DFromFile( lowResolution ? "sun2.png" : "sun2.png", TextureFormat_RGBA );
                } else if (random == 3 || random == 16 || random == 29 || random == 42 || random == 55) {
                    sunTexture = CreateTexture2DFromFile( lowResolution ? "sun3.png" : "sun3.png", TextureFormat_RGBA );
                } else if (random == 4 || random == 17 || random == 30 || random == 43 || random == 56) {
                    sunTexture = CreateTexture2DFromFile( lowResolution ? "sun4.png" : "sun4.png", TextureFormat_RGBA );
                } else if (random == 5 || random == 18 || random == 31 || random == 44 || random == 57) {
                    sunTexture = CreateTexture2DFromFile( lowResolution ? "sun5.png" : "sun5.png", TextureFormat_RGBA );
                } else if (random == 6 || random == 19 || random == 32 || random == 45 || random == 58) {
                    sunTexture = CreateTexture2DFromFile( lowResolution ? "sun6.png" : "sun6.png", TextureFormat_RGBA );
                } else if (random == 7 || random == 20 || random == 33 || random == 46 || random == 59) {
                    sunTexture = CreateTexture2DFromFile( lowResolution ? "sun7.png" : "sun7.png", TextureFormat_RGBA );
                } else if (random == 8 || random == 21 || random == 34 || random == 47) {
                    sunTexture = CreateTexture2DFromFile( lowResolution ? "sun8.png" : "sun8.png", TextureFormat_RGBA );
                } else if (random == 9 || random == 22 || random == 35 || random == 48) {
                    sunTexture = CreateTexture2DFromFile( lowResolution ? "sun9.png" : "sun9.png", TextureFormat_RGBA );
                } else if (random == 10 || random == 23 || random == 36 || random == 49) {
                    sunTexture = CreateTexture2DFromFile( lowResolution ? "sun10.png" : "sun10.png", TextureFormat_RGBA );
                } else if (random == 11 || random == 24 || random == 37 || random == 50) {
                    sunTexture = CreateTexture2DFromFile( lowResolution ? "sun11.png" : "sun11.png", TextureFormat_RGBA );
                } else if (random == 12 || random == 25 || random == 38 || random == 51) {
                    sunTexture = CreateTexture2DFromFile( lowResolution ? "sun12.png" : "sun12.png", TextureFormat_RGBA );
                } else if (random == 13 || random == 26 || random == 39 || random == 52) {
                    sunTexture = CreateTexture2DFromFile( lowResolution ? "sun13.png" : "sun13.png", TextureFormat_RGBA );
                } else {
                    sunTexture = CreateTexture2DFromFile( lowResolution ? "sun10.png" : "sun10.png", TextureFormat_RGBA );
                }
                
				tex = sunTexture;
				name = "Sun";
				isSun = true;
			}
			else 
			{
				//-- moon
				directionFromEarth = moonPosition - earthPosition;
				directionFromEarth.Normalize();
                
                time_t currentTime;
                struct tm *localTime;
                
                time( &currentTime );                   // Get the current time
                localTime = localtime( &currentTime );  // Convert the current time to the local time
                int random = moon_phase(localTime->tm_year-100+2000, localTime->tm_mon+1, localTime->tm_mday);
                if (random == 1) {
                    tex = CreateTexture2DFromFile( "moon1.png", TextureFormat_RGBA );
                } else if (random == 2) {
                    tex = CreateTexture2DFromFile( "moon2.png", TextureFormat_RGBA );
                } else if (random == 3) {
                    tex = CreateTexture2DFromFile( "moon3.png", TextureFormat_RGBA );
                } else if (random == 4) {
                    tex = CreateTexture2DFromFile( "moon4.png", TextureFormat_RGBA );
                } else if (random == 5) {
                    tex = CreateTexture2DFromFile( "moon5.png", TextureFormat_RGBA );
                } else if (random == 6) {
                    tex = CreateTexture2DFromFile( "moon6.png", TextureFormat_RGBA );
                } else if (random == 7) {
                    tex = CreateTexture2DFromFile( "moon7.png", TextureFormat_RGBA );
                } else if (random == 8) {
                    tex = CreateTexture2DFromFile( "moon8.png", TextureFormat_RGBA );
                } else if (random == 9) {
                    tex = CreateTexture2DFromFile( "moon9.png", TextureFormat_RGBA );
                } else if (random == 10) {
                    tex = CreateTexture2DFromFile( "moon10.png", TextureFormat_RGBA );
                } else if (random == 11) {
                    tex = CreateTexture2DFromFile( "moon11.png", TextureFormat_RGBA );
                } else {
                    tex = CreateTexture2DFromFile( "moon0.png", TextureFormat_RGBA );
                }
                
				//tex = moon.texture;
				name = "Moon";
				isMoon=true;
			}
		}
		
        int dotRadius = 2;
        if (isSun) {
            dotRadius = 12;
        }
        if (isMoon) {
            dotRadius = 6;
        }
		dotRadius *= scale;
		star3map::Sprite sp;
		sp.direction = directionFromEarth;
		sp.magnitude = 0;
		sp.scale = dotRadius;
		sp.name = name;
		sp.color = Vec4f( 1, 1, 1, 1 );
		sp.tex = tex;
		solarsystem.push_back( sp );
	}
	
}

// Time
VarFloat t_bias( "t_bias", "time bias in hours", 0, 0.0f );

int GetSecondsSince2000()
{
	int t = GetTime();
	int t2k = year2000Time;
	int dt = t - t2k;
	int bias = t_bias.GetVal() * 3600;
	//Output( "t = %d, t2k = %d, dt = %d", t, t2k, dt );
	return dt + bias;
}

int moon_phase(int y, int m, int d)
{
    /*
     calculates the moon phase (0-7), accurate to 1 segment.
     0 = > new moon.
     4 => full moon.
     */
    
    int c,e;
    double jd;
    int b;
    
    if (m < 3) {
        y--;
        m += 12;
    }
    ++m;
    c = 365.25*y;
    e = 30.6*m;
    jd = c+e+d-694039.09;  /* jd is total days elapsed */
    jd /= 29.53;           /* divide by the moon cycle (29.53 days) */
    b = jd;		   /* int(jd) -> b, take integer part of jd */
    jd -= b;		   /* subtract integer part to leave fractional part of original jd */
    b = jd*8 + 0.5;	   /* scale fraction from 0-8 and round by adding 0.5 */
    b = b & 7;		   /* 0 and 8 are the same so turn 8 into 0 */
    return b;
}


