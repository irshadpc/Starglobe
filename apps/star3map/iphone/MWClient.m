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

#import "MWClient.h"
#import "MWAPIRequest.h"
#import "JSONKit.h"


#pragma mark - Private methods

@interface MWClient (Private)

// ASIHTTPRequestDelegate methods
- (void)requestStarted:(ASIHTTPRequest *)request;
- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes;
- (void)incrementDownloadSizeBy:(long long)length;
- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes;
- (void)incrementUploadSizeBy:(long long)length;
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;


// Generic upload request (in order to not repeat myself)
+ (MWAPIRequest *)uploadRequestWithTargetFilename:(NSString *)targetFilename
									  uploadToken:(NSString *)uploadToken
										 pageText:(NSString *)pageText
									uploadComment:(NSString *)uploadComment
										watchPage:(BOOL)watchPage
								   ignoreWarnings:(BOOL)ignoreWarnings;

@end

@implementation MWClient (Private)

- (void)requestStarted:(ASIHTTPRequest *)request {
	
	//MWLOG(@"requestStarted: %@", request);
	
	if (delegate && [delegate respondsToSelector:@selector(mwClient:didStartCallingAPIWithRequest:)]) {
		
		[delegate mwClient:self
didStartCallingAPIWithRequest:currentAPIRequest];
		
	}
}

- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes {
	
	//MWLOG(@"request: %@ didReceiveBytes: %d", request, bytes);
	
	if (delegate && [delegate respondsToSelector:@selector(mwClient:receivedBytes:outOfBytes:withRequest:)]) {
		
		[delegate mwClient:self
			 receivedBytes:bytes
				outOfBytes:(httpDownloadSize < 0 ? 0 : httpDownloadSize)
			   withRequest:currentAPIRequest];
	}
}

- (void)incrementDownloadSizeBy:(long long)length {
	httpDownloadSize += length;
}

- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes {
	
	//MWLOG(@"request: %@ didSendBytes: %d", request, bytes);

	if (delegate && [delegate respondsToSelector:@selector(mwClient:sentBytes:outOfBytes:withRequest:)]) {
		
		[delegate mwClient:self
				 sentBytes:bytes
				outOfBytes:(httpUploadSize < 0 ? 0 : httpUploadSize)
			   withRequest:currentAPIRequest];
	}
}

- (void)incrementUploadSizeBy:(long long)length {
	httpUploadSize += length;
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	
	MWLOG(@"requestFinished: %@", request);
	
	@synchronized(self) {
		networkOperationIsInProgress = NO;
	}
	
	NSString *responseString = [request responseString];
	if (! responseString) {
		MWWARN(@"Response is empty");
		[self requestFailed:request];
		return;
	}
	
	id responseJSON = [responseString objectFromJSONString];
	if (! responseJSON) {
		MWWARN(@"Unable to parse response JSON: %@", responseString);
		[self requestFailed:request];
		return;
	}
	
	if (! [responseJSON isKindOfClass:[NSDictionary class]]) {
		MWWARN(@"Response JSON is not a NSDictionary: %@", responseJSON);
		[self requestFailed:request];
		return;
	}
		
	if (delegate && [delegate respondsToSelector:@selector(mwClient:didSucceedCallingAPIWithRequest:results:)]) {
		
		[delegate mwClient:self
didSucceedCallingAPIWithRequest:currentAPIRequest
				   results:(NSDictionary *)responseJSON];
	}
	
	//MW_RELEASE_SAFELY(currentAPIRequest);
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	
	MWLOG(@"requestFailed: %@", request);
	
	@synchronized(self) {
		networkOperationIsInProgress = NO;
	}
	
	MWAPIRequest *apiRequest = [currentAPIRequest retain];
	//MW_RELEASE_SAFELY(currentAPIRequest);
	
	if (delegate && [delegate respondsToSelector:@selector(mwClient:didFailCallingAPIWithRequest:error:)]) {
		
		[delegate mwClient:self
didFailCallingAPIWithRequest:apiRequest
					 error:[request error]];
	}
}

+ (MWAPIRequest *)uploadRequestWithTargetFilename:(NSString *)targetFilename
									  uploadToken:(NSString *)uploadToken
										 pageText:(NSString *)pageText
									uploadComment:(NSString *)uploadComment
										watchPage:(BOOL)watchPage
								   ignoreWarnings:(BOOL)ignoreWarnings {
	
	if ((! targetFilename) || [targetFilename length] == 0) {
		MWWARN(@"Target filename is nil or empty");
		return nil;
	}
	if ((! uploadToken) || [uploadToken length] == 0) {
		MWWARN(@"Upload token is nil or empty");
		return nil;
	}
	
	MWAPIRequest *request = [MWAPIRequest requestWithAction:@"upload"];
	[request setParameter:targetFilename forKey:@"filename"];
	[request setParameter:uploadToken forKey:@"token"];
	if (pageText) {
		[request setParameter:pageText forKey:@"text"];
	}
	if (uploadComment) {
		[request setParameter:uploadComment forKey:@"comment"];
	}
	[request setParameter:[NSNumber numberWithBool:watchPage] forKey:@"watch"];
	[request setParameter:[NSNumber numberWithBool:ignoreWarnings] forKey:@"ignorewarnings"];
	
	return request;
}

@end


#pragma mark - Public methods

@implementation MWClient

@synthesize apiURL;
@synthesize delegate;
@synthesize timeoutInterval;


#pragma mark Initialization

- (id)init {
	
	if ((self = [super init])) {
		apiURL = nil;
		delegate = nil;
		networkOperationIsInProgress = NO;
		timeoutInterval = 30.0;
		httpRequest = nil;
		httpUploadSize = 0;
		httpDownloadSize = 0;
		currentAPIRequest = nil;
		
#if TARGET_OS_IPHONE
		[ASIHTTPRequest setShouldThrottleBandwidthForWWAN:YES];
#endif
		
	}
	
	return self;
}

- (id)initWithApiURL:(NSString *)_apiURL {
	
	return [self initWithApiURL:_apiURL
					   delegate:NULL];
}

- (id)initWithApiURL:(NSString *)_apiURL
			delegate:(id<MWClientDelegate>)_delegate {
	
	if ((self = [self init])) {
		[self setApiURL:_apiURL];
		[self setDelegate:_delegate];
	}
	
	return self;
}

- (void)dealloc {
	
	if (httpRequest) {
		[httpRequest clearDelegatesAndCancel];
		//MW_RELEASE_SAFELY(httpRequest);
	}
	
	// Remove cookies
	[ASIHTTPRequest setSessionCookies:nil];
	
	if (currentAPIRequest) {
		//MW_RELEASE_SAFELY(currentAPIRequest);
	}
		
	[super dealloc];
}


#pragma mark Setters / getters

- (void)setApiURL:(NSString *)_apiURL {
	
	if (! [apiURL isEqualToString:_apiURL]) {
		if (apiURL) {
			[self cancelOngoingAPIRequest];
			[self logout];
			[apiURL release];
			
			// Remove cookies
			[ASIHTTPRequest setSessionCookies:nil];
		}
		apiURL = [_apiURL retain];
	}
}


#pragma mark Call API

- (void)callAPIWithRequest:(MWAPIRequest *)request {
	
	//MWLOG(@"I'm about to call API with request: %@", request);
	
	if (! apiURL) {
		MWWARN(@"API URL is nil");
		return;
	}
	
	if (! request) {
		MWWARN(@"Request is nil");
		return;
	}
	
	// Thread safety (sort of)
	@synchronized(self) {
		if (networkOperationIsInProgress) {
			MWWARN(@"Network operation is in progress: %@", currentAPIRequest);
			return;
		}
		
		networkOperationIsInProgress = YES;
	}
	
	// Retain request for later
	currentAPIRequest = [request retain];
	
	// HTTP request
	httpRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:apiURL]];
	[httpRequest setDelegate:self];
	[httpRequest setRequestMethod:@"POST"];
	[httpRequest setDownloadProgressDelegate:self];
	[httpRequest setUploadProgressDelegate:self];
	[httpRequest setShowAccurateProgress:YES];
	
	[httpRequest setPostValue:[request action] forKey:@"action"];
	[httpRequest setPostValue:@"json" forKey:@"format"];
	
#if TARGET_OS_IPHONE
	[httpRequest setShouldContinueWhenAppEntersBackground:YES];
#endif
	
	NSEnumerator *enumerator = nil;
	NSString *key = nil, *stringValue = nil;
	id value = nil;
	
	// Parameters
	enumerator = [request parameterKeyEnumerator];
	while (key = [enumerator nextObject]) {
		value = [request parameterForKey:key];
		
		if ([value isKindOfClass:[NSString class]]) {
			stringValue = value;
			
		} else if ([value isKindOfClass:[NSArray class]]) {
			stringValue = [(NSArray *)value componentsJoinedByString:@"|"];
			
		} else if ([value isKindOfClass:[NSDate class]]) {
			stringValue = [NSString stringWithFormat:@"%f", [(NSDate *)value timeIntervalSince1970]];
			
		} else if ([value isKindOfClass:[NSNumber class]]) {
			// Assume boolean
			stringValue = [(NSNumber *)value boolValue] ? @"true" : @"false";
			
		}
		
		[httpRequest setPostValue:stringValue forKey:key];
	}
	
	// File attachments
	enumerator = [request attachmentKeyEnumerator];
	while (key = [enumerator nextObject]) {
		stringValue = [request attachmentPathForKey:key];
		
		[httpRequest setFile:stringValue forKey:key];
	}
	
	httpUploadSize = httpDownloadSize = 0;
		
	// Start request
	[httpRequest startAsynchronous];
}

- (void)cancelOngoingAPIRequest {

	@synchronized(self) {
		if (networkOperationIsInProgress || httpRequest) {
			[httpRequest cancel];
			networkOperationIsInProgress = NO;
		}
		if (currentAPIRequest) {
			//MW_RELEASE_SAFELY(currentAPIRequest)
		}
	}
	
}


#pragma mark Log in / log out

- (void)loginWithUsername:(NSString *)username
				 password:(NSString *)password {
	
	[self loginWithUsername:username
				   password:password
					 domain:nil
					  token:nil];
}

- (void)loginWithUsername:(NSString *)username
				 password:(NSString *)password
				   domain:(NSString *)domain
					token:(NSString *)token {
	
	if (! username) {
		MWWARN(@"Username is nil");
		return;
	}
	
	if (! password) {
		MWWARN(@"Password is nil");
		return;
	}
	
	MWAPIRequest *request = [MWAPIRequest requestWithAction:@"login"];
	[request setParameter:username forKey:@"lgname"];
	[request setParameter:password forKey:@"lgpassword"];
	if (domain) {
		[request setParameter:domain forKey:@"lgdomain"];
	}
	if (token) {
		[request setParameter:token forKey:@"lgtoken"];
	}
	
	[self callAPIWithRequest:request];
}

- (void)logout {
	
	MWAPIRequest *request = [MWAPIRequest requestWithAction:@"logout"];
	
	[self callAPIWithRequest:request];
}


#pragma mark Upload file

- (void)retrieveUploadToken {
	
	MWAPIRequest *request = [MWAPIRequest requestWithAction:@"query"];
	[request setParameter:@"info" forKey:@"prop"];
	[request setParameter:@"edit" forKey:@"intoken"];
	[request setParameter:@"titles" forKey:@"Foo"];	// FIXME "magic" string
	
	[self callAPIWithRequest:request];
}

// (Helper) Upload file from memory
- (void)uploadFileFromData:(NSData *)fileData
				  basename:(NSString *)basename
			targetFilename:(NSString *)targetFilename
			   uploadToken:(NSString *)uploadToken
				  pageText:(NSString *)pageText
			 uploadComment:(NSString *)uploadComment
				 watchPage:(BOOL)watchPage
			ignoreWarnings:(BOOL)ignoreWarnings {
	
	MWAPIRequest *request = [MWClient uploadRequestWithTargetFilename:targetFilename
														  uploadToken:uploadToken
															 pageText:pageText
														uploadComment:uploadComment
															watchPage:watchPage
													   ignoreWarnings:ignoreWarnings];
	if (! request) {
		MWWARN(@"Unable to create generic request");
		return;
	}
	
	[request setAttachmentData:fileData withBasename:basename forKey:@"file"];
	
	[self callAPIWithRequest:request];
}

// (Helper) Upload file from filesystem
- (void)uploadFileFromFilesystem:(NSString *)filePath
				  targetFilename:(NSString *)targetFilename
					 uploadToken:(NSString *)uploadToken
						pageText:(NSString *)pageText
				   uploadComment:(NSString *)uploadComment
					   watchPage:(BOOL)watchPage
				  ignoreWarnings:(BOOL)ignoreWarnings {
	
	MWAPIRequest *request = [MWClient uploadRequestWithTargetFilename:targetFilename
														  uploadToken:uploadToken
															 pageText:pageText
														uploadComment:uploadComment
															watchPage:watchPage
													   ignoreWarnings:ignoreWarnings];
	if (! request) {
		MWWARN(@"Unable to create generic request");
		return;
	}

	[request setAttachmentPath:filePath forKey:@"file"];
	
	[self callAPIWithRequest:request];
}

// (Helper) Upload file from URL
- (void)uploadFileFromURL:(NSString *)fileURL
		   targetFilename:(NSString *)targetFilename
			  uploadToken:(NSString *)uploadToken
				 pageText:(NSString *)pageText
			uploadComment:(NSString *)uploadComment
				watchPage:(BOOL)watchPage
		   ignoreWarnings:(BOOL)ignoreWarnings {
	
	MWAPIRequest *request = [MWClient uploadRequestWithTargetFilename:targetFilename
														  uploadToken:uploadToken
															 pageText:pageText
														uploadComment:uploadComment
															watchPage:watchPage
													   ignoreWarnings:ignoreWarnings];
	if (! request) {
		MWWARN(@"Unable to create generic request");
		return;
	}

	[request setParameter:fileURL forKey:@"url"];
	
	[self callAPIWithRequest:request];
}

- (void)uploadFileFromData:(NSData *)fileData
				  basename:(NSString *)basename
			targetFilename:(NSString *)targetFilename
			   uploadToken:(NSString *)uploadToken
				  pageText:(NSString *)pageText {
	
	[self uploadFileFromData:fileData
					basename:basename
			  targetFilename:targetFilename
				 uploadToken:uploadToken
					pageText:pageText
			   uploadComment:nil
				   watchPage:YES
			  ignoreWarnings:YES];
}

- (void)uploadFileFromFilesystem:(NSString *)filePath
				  targetFilename:(NSString *)targetFilename
					 uploadToken:(NSString *)uploadToken
						pageText:(NSString *)pageText {
	
	[self uploadFileFromFilesystem:filePath
					targetFilename:targetFilename
					   uploadToken:uploadToken
						  pageText:pageText
					 uploadComment:nil
						 watchPage:YES
					ignoreWarnings:YES];
}

- (void)uploadFileFromURL:(NSString *)fileURL
		   targetFilename:(NSString *)targetFilename
			  uploadToken:(NSString *)uploadToken
				 pageText:(NSString *)pageText {

	[self uploadFileFromURL:fileURL
			 targetFilename:targetFilename
				uploadToken:uploadToken
				   pageText:pageText
			  uploadComment:nil
				  watchPage:YES
			 ignoreWarnings:YES];
}

@end
