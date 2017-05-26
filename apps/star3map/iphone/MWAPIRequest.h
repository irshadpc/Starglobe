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


@interface MWAPIRequest : NSObject {
	
	@public
	NSString *action;
	NSInteger tag;
	
	@private
	
	// NSString -> (NSArray|NSString) dictionary (key -> parameter(s))
	NSMutableDictionary *parameters;
	
	// NSString -> NSString dictionary (key -> file path)
	NSMutableDictionary *attachments;
	
	// Temporary files
	NSMutableArray *temporaryFiles;
}

@property (nonatomic, retain) NSString *action;
@property (nonatomic) NSInteger tag;

+ (MWAPIRequest *)requestWithAction:(NSString *)action;

// NSDictionary-like methods for setting/getting parameters
- (NSUInteger)parameterCount;
- (id)parameterForKey:(NSString *)aKey;
- (NSEnumerator *)parameterKeyEnumerator;
- (void)setParameter:(id)parameter forKey:(NSString *)key;
- (void)removeParameterForKey:(NSString *)aKey;

// NSDictionary-like methods for setting/getting file attachments
- (NSUInteger)attachmentCount;
- (NSString *)attachmentPathForKey:(NSString *)key;
- (NSEnumerator *)attachmentKeyEnumerator;
- (void)setAttachmentPath:(NSString *)attachmentPath forKey:(NSString *)key;
- (void)setAttachmentData:(NSData *)attachmentData withBasename:(NSString *)basename forKey:(NSString *)key;
- (void)removeAttachmentForKey:(NSString *)key;

// Returns temporary filename to store an image
+ (NSString *)temporaryFilenameForImageWithBasename:(NSString *)basename;

@end
