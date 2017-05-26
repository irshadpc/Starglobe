//
//  WorldDataManager.h
//  Galileo's Sandbox
//
//  Created by Conner Douglass on 6/26/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WorldDataManager : NSObject

// Non-async:
+ (NSDictionary *)jsonForBodyWithIdentifier:(NSString *)identifier;
+ (NSArray *)jsonForPeersOfIdentifier:(NSString *)identifier;
+ (NSArray *)availableBodyJSON;

// Async:
+ (void)fetchJsonForBodyWithIdentifier:(NSString *)identifier completion:(void(^)(NSDictionary *json))completion;
+ (void)fetchAllBodyJson:(void(^)(NSArray *json))completion;
+ (void)fetchJsonForPeersOfIdentifier:(NSString *)identifier completion:(void(^)(NSArray *json))completion;
+ (void)fetchJsonForSiblingsOfIdentifier:(NSString *)identifier completion:(void(^)(NSArray *json))completion;
+ (void)fetchJsonForChildrenOfIdentifier:(NSString *)identifier completion:(void(^)(NSArray *json))completion;
+ (void)fetchBodyIdentifiersForPackage:(NSString *)package completion:(void(^)(NSArray *identifiers))completion;
+ (void)fetchJsonForBodiesInPackage:(NSString *)package completion:(void(^)(NSArray *json))completion;
+ (void)fetchParentIdentifierOfIdentifier:(NSString *)identifier completion:(void(^)(NSString *parentIdentifier))completion;
+ (void)fetchAvailableBodyJson:(void(^)(NSArray *json))completion;
+ (void)fetchAvailableBodyIdentifiers:(void(^)(NSArray *identifiers))completion;
+ (void)fetchAvailableBodyJsonForButtons:(void(^)(NSArray *json))completion;

@end
