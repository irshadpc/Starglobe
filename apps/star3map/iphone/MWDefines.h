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

#import <Foundation/Foundation.h>

// Safele release shorthand
#define MW_RELEASE_SAFELY(__POINTER)	{ [__POINTER release]; __POINTER = nil; }

// Logging
#ifdef DEBUG
//#define MWLOG(xx, ...)	NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define MWLOG(...)	NSLog(__VA_ARGS__)
#else
#define MWLOG(xx, ...)	((void)0)
#endif

// Warnings
#define MWWARN(...)		NSLog(__VA_ARGS__)

// Errors
#define MWERR(...)		NSLog(__VA_ARGS__)

// Dummy implementation exception
#define MW_DUMMY_IMPL_EXC()	[NSException raise:NSInternalInconsistencyException format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
