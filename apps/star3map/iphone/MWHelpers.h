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

@interface MWHelpers : NSObject {
	
}

// Checks if after trying to log in we got 'NeedToken' or 'Success'.
// Returns the token that has to be sent, or nil if we're logged in without token already.
+ (NSString *)logInTokenThatWasRequestedOrNil:(NSDictionary *)data;

// Takes a result of
//   http://en.wikipedia.org/w/api.php?action=query&titles=Lietuvos_rytas&prop=images|revisions&redirects&imlimit=max&rvprop=content
// as a parameter.
// Returns an array (NSString) of article titles that do not have their own images or nil in case of an error
+ (NSArray *)articleTitlesOfArticlesThatDoNotHaveImages:(NSDictionary *)apiResult;

@end
