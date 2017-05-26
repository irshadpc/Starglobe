//
//  Network.m
//  star3map
//
//  Created by Dmitry Fadeev on 13.01.12.
//  Copyright (c) 2012 knightmare@ether-engine.com. All rights reserved.
//

#import "Network.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

@implementation Network

+(BOOL) connectionAvailable
{
	// create address structure
	struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len    = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	
	// creare reachability for zero address
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
	
	// check result
    if(reachability != NULL)
    {
		// getting reachability flags
		SCNetworkReachabilityFlags flags;
		SCNetworkReachabilityGetFlags(reachability, &flags);
		
		// test it
		if((flags & kSCNetworkReachabilityFlagsReachable) == 0)
			return NO;
        
		if((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
			return YES;
		
		
		if((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0) || (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
		{
            if((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
				return YES;
        }
		
		
		if((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
			return YES;
		
		return NO;
    }
	else
	{
		return NO;
	}
}

+(void) showUnavailableMessage: (NSString*)message
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Sky Above"
                                                     message: message
                                                    delegate: nil
                                           cancelButtonTitle: @"Ok"
                                           otherButtonTitles: nil];
    [alert show];
}

@end
