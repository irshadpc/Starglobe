//
//  main.m
//  star3map
//
//  Created by Cass Everitt on 1/30/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "r3/command.h"
#include "r3/filesystem.h"
#include <stdio.h>
#include <string>
#import "star3mapAppDelegate.h"

using namespace std;

int main(int argc, char *argv[]) {
    
    @autoreleasepool {
	
		{	
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *d = [paths objectAtIndex:0];
			string s( [d UTF8String] );
			string cmd = "set f_cachePath \"" + s + "/cache/\"";
			printf( "doc dir = %s\n", s.c_str() );
			r3::ExecuteCommand( cmd.c_str() );
		}
		{
			NSString *d = [ [NSBundle mainBundle] resourcePath ];
			string s( [d UTF8String] );
			string cmd =  "set f_basePath \"" + s + "/base/\"";
			r3::ExecuteCommand( cmd.c_str() );
		}	
		
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([star3mapAppDelegate class]));
			
    return retVal;
    }
}


void OpenURL( const char *url) {
	NSString *nss = [NSString stringWithCString: url encoding: NSASCIIStringEncoding];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: nss]];
}
