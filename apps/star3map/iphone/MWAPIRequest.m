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

#import "MWAPIRequest.h"

#pragma mark - Private methods

@interface MWAPIRequest (Private)

+ (NSString *)URLEncodedStringForString:(NSString *)string;

- (NSString *)description;

@end

@implementation MWAPIRequest (Private)

+ (NSString *)URLEncodedStringForString:(NSString *)string {
	
	return [(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
																(CFStringRef)string,
																NULL,
																(CFStringRef)@"!*'();:@&=+$,/?%#[] -",
																kCFStringEncodingUTF8) autorelease];
}

- (NSString *)description {

	NSMutableArray *resultParams = [NSMutableArray array];
	NSString *result = nil;
	NSString *key = nil;
	NSObject *value = nil;

	// Parameters
	for (key in parameters) {
		value = [parameters objectForKey:key];
		
		// Encode key
		key = [MWAPIRequest URLEncodedStringForString:key];
		
		if ([value isKindOfClass:[NSArray class]]) {
			value = [(NSArray *)value componentsJoinedByString:@"|"];
			
		} else if ([value isKindOfClass:[NSDate class]]) {
			value = [NSString stringWithFormat:@"%f", [(NSDate *)value timeIntervalSince1970]];
			
		} else if ([value isKindOfClass:[NSNumber class]]) {
			// Assume boolean
			value = [(NSNumber *)value boolValue] ? @"true" : @"false";
			
		}
		
		// Encode value
		value = [MWAPIRequest URLEncodedStringForString:(NSString *)value];
		
		[resultParams addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
	}

	// Attachments
	for (key in attachments) {
		value = [attachments objectForKey:key];
		
		// Encode key
		key = [MWAPIRequest URLEncodedStringForString:key];
				
		// Encode value
		value = [MWAPIRequest URLEncodedStringForString:(NSString *)value];
		
		[resultParams addObject:[NSString stringWithFormat:@"%@=[%@]", key, value]];
	}

	// Single stringWithFormat: would have been nicer, but this might just be a little bit quicker
	result = [@"action=" stringByAppendingString:[MWAPIRequest URLEncodedStringForString:action]];
	if ([resultParams count]) {
		result = [result stringByAppendingString:@"&"];
		result = [result stringByAppendingString:[resultParams componentsJoinedByString:@"&"]];
	}
	return result;
}

@end


#pragma mark - Public methods


@implementation MWAPIRequest

@synthesize action;
@synthesize tag;

- (id)init {
	
	if ((self = [super init])) {
		action = nil;
		parameters = [[NSMutableDictionary alloc] init];
		attachments = [[NSMutableDictionary alloc] init];
		temporaryFiles = [[NSMutableArray alloc] init];
		tag = 0;
	}
	
	return self;
}

- (void)dealloc {
	MW_RELEASE_SAFELY(parameters);
	MW_RELEASE_SAFELY(attachments);
	MW_RELEASE_SAFELY(temporaryFiles);
	
	// Don't remove temporary files as they might be on the way to the webserver at the time of request's release
	
	[super dealloc];
}

+ (MWAPIRequest *)requestWithAction:(NSString *)action {
	
	MWAPIRequest *request = [[[MWAPIRequest alloc] init] autorelease];
	[request setAction:action];
	return request;
}


#pragma mark Parameters

- (NSUInteger)parameterCount {
	return [parameters count];
}

- (id)parameterForKey:(NSString *)key {
	
	if (! key) {
		MWWARN(@"Key is nil");
		return nil;
	}

	return [parameters objectForKey:key];
}

- (NSEnumerator *)parameterKeyEnumerator {
	return [parameters keyEnumerator];
}

- (void)setParameter:(id)parameter forKey:(NSString *)key {
	
	if (! parameter) {
		MWWARN(@"Parameter for key %@ is nil", key);
		return;
	}
	
	if (! key) {
		MWWARN(@"Key for parameter %@ is nil", parameter);
		return;
	}
	
	if ([key isEqualToString:@"format"]) {
		MWWARN(@"Please don't set the return format, I only read JSON");
		return;
	}
	
	[parameters setObject:parameter
				   forKey:key];
}

- (void)removeParameterForKey:(NSString *)key {

	if (! key) {
		MWWARN(@"Key is nil");
		return;
	}

	[parameters removeObjectForKey:key];
}


#pragma mark File attachments

- (NSUInteger)attachmentCount {
	return [attachments count];
}

- (NSString *)attachmentPathForKey:(NSString *)key {
	
	if (! key) {
		MWWARN(@"Key is nil");
		return nil;
	}
	
	return [attachments objectForKey:key];
}

- (NSEnumerator *)attachmentKeyEnumerator {
	return [attachments keyEnumerator];
}

- (void)setAttachmentPath:(NSString *)attachmentPath forKey:(NSString *)key {
	
	if (! attachmentPath) {
		MWWARN(@"Attachment path is nil");
		return;
	}
	
	if (! key) {
		MWWARN(@"Key is nil");
		return;
	}
	
	NSFileManager *fm = [NSFileManager defaultManager];
	if (! ([fm fileExistsAtPath:attachmentPath] && [fm isReadableFileAtPath:attachmentPath])) {
		MWWARN(@"Attachment at path '%@' does not exist or is not readable", attachmentPath);
		return;
	}
	
	[attachments setObject:attachmentPath forKey:key];
}

- (void)setAttachmentData:(NSData *)attachmentData withBasename:(NSString *)basename forKey:(NSString *)key {
	
	if ((! attachmentData) || [attachmentData length] == 0) {
		MWWARN(@"Attachment data is nil or empty");
		return;
	}
	
	if (! key) {
		MWWARN(@"Key is nil");
		return;
	}
	
	if ((! basename) || [basename length] == 0) {
		MWWARN(@"Basename is nil or empty");
		return;
	}
	
	// Store data to temp. directory
	NSString *tempFilename = [MWAPIRequest temporaryFilenameForImageWithBasename:basename];
	if (! [attachmentData writeToFile:tempFilename
						   atomically:YES]) {
		
		MWWARN(@"Unable to store file data to temp. file '%@'", tempFilename);
		return;
	}
	
	[self setAttachmentPath:tempFilename forKey:key];
}

- (void)removeAttachmentForKey:(NSString *)key {
	
	if (! key) {
		MWWARN(@"Key is nil");
		return;
	}
	
	[attachments removeObjectForKey:key];
}

+ (NSString *)temporaryFilenameForImageWithBasename:(NSString *)basename {
	
	// Create a temp. directory
	NSString *tempDirectoryTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:@"WikiShoot.XXXXXX"];
	const char *tempDirectoryTemplateCString = [tempDirectoryTemplate fileSystemRepresentation];
	char *tempDirectoryNameCString = (char *)malloc(strlen(tempDirectoryTemplateCString) + 1);
	strcpy(tempDirectoryNameCString, tempDirectoryTemplateCString);
	
	char *result = mkdtemp(tempDirectoryNameCString);
	if (! result) {
		MWWARN(@"Unable to create temporary directory to store the file (#1)");
		free(tempDirectoryNameCString);
		return nil;
	}
	
	NSString *tempDirectoryPath = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:tempDirectoryNameCString
																							  length:strlen(result)];
	if (! tempDirectoryPath) {
		MWWARN(@"Unable to create temporary directory to store the file (#2)");
		free(tempDirectoryNameCString);
		return nil;
	}
	free(tempDirectoryNameCString);
	
	NSString *tempFilename = [tempDirectoryPath stringByAppendingPathComponent:basename];
	MWLOG(@"Will store file to: %@", tempFilename);

	return tempFilename;
}

@end
