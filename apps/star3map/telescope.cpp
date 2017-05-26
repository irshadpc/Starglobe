/*
 *  satellite
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


#include "telescope.h"

#include "sgp4/sgp4io.h"
#include "sgp4/sgp4unit.h"
#include "sgp4/sgp4ext.h"

#include "r3/filesystem.h"
#include "r3/linear.h"
#include "r3/output.h"
#include "r3/time.h"

using namespace std;
using namespace star3map;
using namespace r3;

namespace {
	
	bool initialized = false;
	vector<elsetrec> satrec;
	vector<string> satname;
	double epochMinutes;
	void Initialize() {
		if ( initialized ) {
			return;
		}
		
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
		
		epochMinutes = double( epoch ) / 60.0;
		initialized = true;
	}
	

}

namespace star3map {

	double GetMinutesFromEpoch() {
		return  ( double( GetTime() ) / 60.0 ) - epochMinutes;
	}
	
	double GetJulianDate() {
		double JD = ( GetMinutesFromEpoch() / MinutesPerDay ) + JulianDateAtEpoch;
		return JD;
	}

	double Frac( double d ) {
		return d - floor( d );
	}

	double GetThetaG() { 
		double JD = GetJulianDate();
		double UT = Frac( JD + 0.5 );
		JD -= UT;
		double Tu = ( JD - JulianDateAtEpoch ) / 36525.0;
		double gmst = 24110.54841 + 8640184.812866 * Tu + 0.093104 * Tu * Tu - 6.2e-6 * Tu * Tu * Tu;
		gmst /= SecondsPerDay;
		gmst += EarthRotationsPerSiderealDay * UT;
		gmst = Frac( gmst );
		return gmst * 2.0 * R3_PI;
	}
	
	void ReadTelescopeData( const std::string & filename ) {
		Initialize();
		File *f = FileOpenForRead( filename );
		if ( f ) {
			satname.clear();
			satrec.clear();
			vector<string> twoLineElements;
			while( f->AtEnd() == false ) {
				twoLineElements.push_back( f->ReadLine() );
			}
			delete f;
			Output( "ReadTelescopeData: Read %d lines from %s", (int)twoLineElements.size(), filename.c_str() );
			double startmfe, stopmfe, deltamin; // dummies
			for ( int i = 2; i < (int)twoLineElements.size(); i+=3 ) {
				string s0 = twoLineElements[ i-2 ];
				int last = s0.size() - 1;
				char lc = s0[ last ];
				while( last >= 0 && ( lc == ' ' || lc == '\t' || lc == 0 || lc == 13 ) ) {
					last--;
					lc = s0[last];
				}
				last++;
				s0 = s0.substr( 0, last );

				char s1[130], s2[130];
				strncpy( s1, twoLineElements[i-1].c_str(), 130 );
				strncpy( s2, twoLineElements[i-0].c_str(), 130 );

				satname.push_back( s0 );
				elsetrec srec;
				twoline2rv( s1, s2, 'm', 'm', 'i', wgs72, startmfe, stopmfe, deltamin, srec );
				double ro[3];
				double vo[3];
				sgp4( wgs72, srec, 0.0, ro, vo );
				satrec.push_back( srec );
			}
			
			
		}
	}
	
	void ComputeTelescopePositions( std::vector<Telescope> & telescopes ) {
		Initialize();
		telescopes.clear();
		double mfe = GetMinutesFromEpoch();
		
		for ( int i = 0; i < (int)satname.size(); i++ ) {
			Telescope sat;
			sat.name = satname[i];
			double ro[3];
			double vo[3];
			elsetrec & srec = satrec[i];
			double minutesFromSatEpoch = mfe - ( ( srec.jdsatepoch - JulianDateAtEpoch ) * 1440.0 );
			sgp4( wgs72, srec, minutesFromSatEpoch, ro, vo );
			if ( srec.error > 0 ) {
				Output( "Sat %s error %d at %lf mins from sat epoch.", sat.name.c_str(), srec.error, minutesFromSatEpoch );
			}
			sat.pos = Vec3f( ro[0], ro[1], ro[2] );
			telescopes.push_back( sat );
		}
	}
	
	// Get the rotation of the earth relative to ECI
	float GetCurrentEarthPhase() {
		return GetThetaG();
	}

}


