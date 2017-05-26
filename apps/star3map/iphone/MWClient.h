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
#import "MWClientDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

// FIXME ar _ yra private, ar laikinieji variables?

@class MWClient;
@class MWAPIRequest;


@interface MWClient : NSObject <ASIHTTPRequestDelegate> {
	
	@public
	
	NSString *apiURL;
	id<MWClientDelegate> delegate;
	NSTimeInterval timeoutInterval;
	
	@private
	
	// Network operation in progress
	// FIXME thread-safety
	BOOL networkOperationIsInProgress;
	
	// Current request that is being handled
	MWAPIRequest *currentAPIRequest;
	
	// Uses ASIHTTPRequest for the uploads
	ASIFormDataRequest *httpRequest;
	
	// HTTP request / response lengths
	long long httpUploadSize;
	long long httpDownloadSize;
	
}

@property (nonatomic, retain) NSString *apiURL;
@property (nonatomic, assign) id<MWClientDelegate> delegate;
@property (nonatomic) NSTimeInterval timeoutInterval;

// Initialize with API URL
- (id)initWithApiURL:(NSString *)_apiURL;
- (id)initWithApiURL:(NSString *)_apiURL
			delegate:(id<MWClientDelegate>)_delegate;

// Call API
- (void)callAPIWithRequest:(MWAPIRequest *)request;

// Cancel any ongoing request
- (void)cancelOngoingAPIRequest;

// (Helper) Log in
- (void)loginWithUsername:(NSString *)username
				 password:(NSString *)password;

- (void)loginWithUsername:(NSString *)username
				 password:(NSString *)password
				   domain:(NSString *)domain
					token:(NSString *)token;

// (Helper) Log out
- (void)logout;

// (Helper) Retrieve upload token
- (void)retrieveUploadToken;

// (Helper) Upload file from memory
- (void)uploadFileFromData:(NSData *)fileData
				  basename:(NSString *)basename
			targetFilename:(NSString *)targetFilename
			   uploadToken:(NSString *)uploadToken
				  pageText:(NSString *)pageText
			 uploadComment:(NSString *)uploadComment
				 watchPage:(BOOL)watchPage
			ignoreWarnings:(BOOL)ignoreWarnings;

- (void)uploadFileFromData:(NSData *)fileData
				  basename:(NSString *)basename
			targetFilename:(NSString *)targetFilename
			   uploadToken:(NSString *)uploadToken
				  pageText:(NSString *)pageText;

// (Helper) Upload file from filesystem
- (void)uploadFileFromFilesystem:(NSString *)filePath
				  targetFilename:(NSString *)targetFilename
					 uploadToken:(NSString *)uploadToken
						pageText:(NSString *)pageText
				   uploadComment:(NSString *)uploadComment
					   watchPage:(BOOL)watchPage
				  ignoreWarnings:(BOOL)ignoreWarnings;

- (void)uploadFileFromFilesystem:(NSString *)filePath
				  targetFilename:(NSString *)targetFilename
					 uploadToken:(NSString *)uploadToken
						pageText:(NSString *)pageText;

// (Helper) Upload file from URL
- (void)uploadFileFromURL:(NSString *)fileURL
		   targetFilename:(NSString *)targetFilename
			  uploadToken:(NSString *)uploadToken
				 pageText:(NSString *)pageText
			uploadComment:(NSString *)uploadComment
				watchPage:(BOOL)watchPage
		   ignoreWarnings:(BOOL)ignoreWarnings;

- (void)uploadFileFromURL:(NSString *)fileURL
		   targetFilename:(NSString *)targetFilename
			  uploadToken:(NSString *)uploadToken
				 pageText:(NSString *)pageText;

@end
