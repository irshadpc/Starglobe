//
// Copyright 2011 Linas Valiukas
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "MWDefines.h"

@class MWClient;
@class MWAPIRequest;


#pragma mark - MWClient delegate

@protocol MWClientDelegate

@optional

// API call
- (void)mwClient:(MWClient *)client
didStartCallingAPIWithRequest:(MWAPIRequest *)request;

// Big POST requests might want to use an uplink progress report
- (void)mwClient:(MWClient *)client
	   sentBytes:(NSUInteger)bytesSent
	  outOfBytes:(NSUInteger)bytesAvailable
	 withRequest:(MWAPIRequest *)request;

// Big POST requests might want to use an uplink progress report
- (void)mwClient:(MWClient *)client
   receivedBytes:(NSUInteger)bytesSent
	  outOfBytes:(NSUInteger)bytesAvailable
	 withRequest:(MWAPIRequest *)request;

- (void)mwClient:(MWClient *)client
didSucceedCallingAPIWithRequest:(MWAPIRequest *)request
		 results:(NSDictionary *)results;

- (void)mwClient:(MWClient *)client
didFailCallingAPIWithRequest:(MWAPIRequest *)request
		   error:(NSError *)error;

@end
