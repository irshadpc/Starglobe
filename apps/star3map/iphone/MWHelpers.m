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

#import "MWHelpers.h"

@implementation MWHelpers

+ (NSString *)logInTokenThatWasRequestedOrNil:(NSDictionary *)data {
	
	// Logging in?
	if ([data objectForKey:@"login"]) {
		
		// Token requested?
		if ([[[data objectForKey:@"login"] objectForKey:@"result"] isEqualToString:@"NeedToken"]) {
			
			return [[data objectForKey:@"login"] objectForKey:@"token"];
			
		}
	}

	return nil;
}

+ (NSArray *)articleTitlesOfArticlesThatDoNotHaveImages:(NSDictionary *)apiResult {
	
	if (! [apiResult respondsToSelector:@selector(objectForKey:)]) {
		MWERR(@"'results' is not a NSDictionary");
		return nil;
	}
	
	NSDictionary *resQuery = [apiResult objectForKey:@"query"];
	if (! resQuery) {
		MWERR(@"no 'query' key in 'results'");
		return nil;
	}
	
	if (! [resQuery respondsToSelector:@selector(objectForKey:)]) {
		MWERR(@"'resQuery' is not a NSDictionary");
		return nil;
	}
	
	NSDictionary *resPages = [resQuery objectForKey:@"pages"];
	if (! resPages) {
		MWERR(@"no 'pages' key in 'resQuery'");
		return nil;
	}
	
	if (! [resPages respondsToSelector:@selector(keyEnumerator)]) {
		MWERR(@"'resPages' does not respond to 'keyEnumerator'");
		return nil;
	}
	
	
	//
	// Normally, we could fetch lists of articles' images using the following API query:
	//
	//  http://en.wikipedia.org/w/api.php?action=query&titles=A|B|C&prop=images&redirects&imlimit=max
	//
	// ...and then sort out the articles that *don't* have images based on the list of articles
	// that do.
	// 
	// The problem is that some (most?) articles contain images that do not represent the actual
	// article's subject but are there for some sort of technical purpose, e.g.: stub articles,
	// belonging to projects, links to WikiQuote, etc.
	// 
	// For example, the article http://en.wikipedia.org/wiki/Lietuvos_rytas does not have a
	// photo (as of Nov 4, 2011), but the API:
	// 
	//   http://en.wikipedia.org/w/api.php?action=query&titles=Lietuvos_rytas&prop=images&redirects&imlimit=max
	//
	// ... reports that the article contains two images, "File:Flag of Lithuania.svg" and
	// "File:Newspaper.svg". Both of them are used in a stub template that is included in the
	// article.
	//
	// So, we cheat and do this:
	//
	// 1) Do an API request for image list and the content of latest revision:
	//   
	//   http://en.wikipedia.org/w/api.php?action=query&titles=Lietuvos_rytas&prop=images|revisions&redirects&imlimit=max&rvprop=content
	//
	// 2) Search for the filename of the image in the wikitext and see if it's there. If it is,
	//    assume that the image belongs to an article and that the article actually is illustrated
	//    (thus, nothing to do here). If the image's filename is not in the wikitext, this means
	//    that the image came here from some sort of a template and should not be taken as an
	//    article's image
	//
	
	NSMutableArray *articlesThatDoNotHaveImages = [NSMutableArray array];
	
	// Image filename prefix for the specific wiki, e.g. "File:" (found out later)
	NSString *imageFilenamePrefix = nil;
	
	for (NSString *pageID in resPages) {
		
		NSDictionary *page = [resPages objectForKey:pageID];
		
		//
		// Page title
		//
		
		NSString *pageTitle = [page objectForKey:@"title"];
		if (! pageTitle) {
			MWWARN(@"no 'title' key in 'page'");
			// Don't err, just skip
			continue;
		}
		
		//
		// Page images
		//
		
		// Article doesn't have images at all -- write this down, don't check anything else
		NSArray *pageImages = [page objectForKey:@"images"];
		if ((! pageImages) || [pageImages count] == 0) {
			[articlesThatDoNotHaveImages addObject:pageTitle];
			continue;
		}
		
		//
		// Page content
		//
		
		NSArray *pageRevisions = [page objectForKey:@"revisions"];
		if (! pageRevisions) {
			MWWARN(@"no 'revisions' key in 'page'");
			// Don't err, just skip
			continue;
		}
		
		if ([pageRevisions count] != 1) {
			MWERR(@"A single (current) revision expected");
			return nil;
		}
		
		NSDictionary *pageRevision = [pageRevisions objectAtIndex:0];
		if (! [pageRevision respondsToSelector:@selector(objectForKey:)]) {
			MWERR(@"'pageRevision' is not a NSDictionary'");
			return nil;
		}
		
		NSString *pageContent = [pageRevision objectForKey:@"*"];
		if (! pageContent) {
			MWERR(@"Unable to fetch page content");
			// Don't err, just skip
			continue;
		}
		
		//
		// Check page content for every image
		//
		
		BOOL articleHasImages = NO;
		for (NSDictionary *pageImage in pageImages) {
			
			NSString *pageImageName = [pageImage objectForKey:@"title"];
			if (! pageImageName) {
				MWWARN(@"no 'title' key in 'pageImage'");
				// Don't err, just skip
				continue;
			}
			
			// Figure out file name prefix
			if (! imageFilenamePrefix) {
				
				NSRange rangeOfColon = [pageImageName rangeOfString:@":"];
				if (rangeOfColon.location == NSNotFound || rangeOfColon.location == 0) {
					MWWARN(@"Unable to figure out the filename prefix");
					return nil;
				}
				
				// e.g. "File:"
				imageFilenamePrefix = [pageImageName substringToIndex:(rangeOfColon.location+1)];
			}
			
			// Remove "File:" or some other prefix
			if (! [pageImageName hasPrefix:imageFilenamePrefix]) {
				MWWARN(@"Image name '%@' does not have expected prefix '%@'", pageImageName, imageFilenamePrefix);
				return nil;
			}
			pageImageName = [pageImageName substringFromIndex:[imageFilenamePrefix length]];
			
			// Check against content (whether "[[File:Blah.jpg..." exists)
			if ([pageContent rangeOfString:pageImageName].location != NSNotFound) {
				// At least one image found -- article has images, skip
				articleHasImages = YES;
				break;
			}
		}
		
		if (! articleHasImages) {
			[articlesThatDoNotHaveImages addObject:pageTitle];
		}
	}
	
	return articlesThatDoNotHaveImages;
}

@end
