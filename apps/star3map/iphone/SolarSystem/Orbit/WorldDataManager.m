//
//  WorldDataManager.m
//  Galileo's Sandbox
//
//  Created by Conner Douglass on 6/26/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "WorldDataManager.h"

@implementation WorldDataManager

#pragma mark Non-async Methods

+ (BOOL)packageIsAvailable:(NSString *)package
{
    NSMutableArray *availablePackages = [NSMutableArray arrayWithObject:PACKAGE_BASE];
    if(PURCHASE_ACTIVATED(@"com.connerdouglass.Galileo.moons")) {
        [availablePackages addObject:PACKAGE_MOONS];
    }
    if(PURCHASE_ACTIVATED(@"com.connerdouglass.Galileo.dwarf_planets")) {
        [availablePackages addObject:PACKAGE_DWARF_PLANETS];
    }
    if(PURCHASE_ACTIVATED(@"com.connerdouglass.Galileo.custom_worlds")) {
        [availablePackages addObject:PACKAGE_USERWORLDS];
    }
    
    return [availablePackages containsObject:package];
}

+ (NSArray *)allBodyDataObjects
{
    NSMutableArray *datas = [NSMutableArray array];
    NSArray *jsons = [self allBodyJson];
    for(NSDictionary *json in jsons) {
        [datas addObject:[[GSWorldData alloc] initWithJson:json]];
    }
    return datas;
}

+ (NSArray *)allBodyJson
{
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:BODY_JSON ofType:@""]];
    
    NSError *error;
    NSArray *bodiesRaw = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(error) {
        NSLog(@"%@", error);
        return nil;
    }
    
    NSMutableArray *bodies = [NSMutableArray arrayWithArray:bodiesRaw];
    
    NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *userWorldsPath = [docs stringByAppendingPathComponent:USERWORLDS_JSON];
    
    BOOL userWorldsExists = [[NSFileManager defaultManager] fileExistsAtPath:userWorldsPath];
    
    if(!userWorldsExists) {
        return bodies;
    }
    
    NSData *dataUser = [NSData dataWithContentsOfFile:userWorldsPath];
    
    if(!dataUser) {
        return bodies;
    }
    NSArray *jsonUser = [NSJSONSerialization JSONObjectWithData:dataUser options:kNilOptions error:&error];
    if(error) {
        NSLog(@"%@", error);
        return bodies;
    }
    [bodies addObjectsFromArray:jsonUser];
    return bodies;
}

+ (NSDictionary *)jsonForBodyWithIdentifier:(NSString *)identifier
{
    NSArray *bodies = [WorldDataManager allBodyJson];
    
    // Loop through the body dictionaries in the JSON
    for(NSDictionary *body in bodies) {
        
        // Parse the data
        GSWorldData *data = [[GSWorldData alloc] initWithJson:body];
        
        // If this is not the correct body, try the next one
        if(![data.identifier isEqualToString:identifier]) {
            continue;
        }
        
        // If this body is not enabled, try the next one
        if(!data.enabled) {
            continue;
        }
        
        return body;
    }
    
    return nil;
}

+ (NSArray *)jsonForPeersOfIdentifier:(NSString *)identifier
{
    NSArray *siblingJsons = [WorldDataManager jsonForSiblingsOfIdentifier:identifier];
    NSArray *childrenJsons = [WorldDataManager jsonForChildrenOfIdentifier:identifier];
    
    NSMutableArray *otherBodiesCombined = [NSMutableArray array];
    [otherBodiesCombined addObjectsFromArray:siblingJsons];
    [otherBodiesCombined addObjectsFromArray:childrenJsons];
    
    return otherBodiesCombined;
}

+ (NSArray *)jsonForChildrenOfIdentifier:(NSString *)parentIdentifier
{
    NSMutableArray *jsons = [NSMutableArray array];
    
    for(NSDictionary *bodyJson in [WorldDataManager availableBodyJSON]) {
        
        // Parse the data
        GSWorldData *data = [[GSWorldData alloc] initWithJson:bodyJson];
        
        if(data.parentIdentifier && [data.parentIdentifier isEqualToString:parentIdentifier]) {
            
            [jsons addObject:bodyJson];
            
        }
        
    }
    
    return jsons;
}

+ (NSArray *)jsonForSiblingsOfIdentifier:(NSString *)identifier
{
    NSMutableArray *jsons = [NSMutableArray array];
    
    NSDictionary *json = [WorldDataManager jsonForBodyWithIdentifier:identifier];
    
    // Parse the data
    GSWorldData *data = [[GSWorldData alloc] initWithJson:json];
    
    // Moons are the only things capable of having siblings.
    if(![data.type isEqualToString:@"moon"] || !data.parentIdentifier) {
        return jsons;
    }
    
    for(NSDictionary *bodyJson in [WorldDataManager jsonForChildrenOfIdentifier:data.parentIdentifier]) {
        
        GSWorldData *otherData = [[GSWorldData alloc] initWithJson:bodyJson];
        
        if(![data.identifier isEqualToString:otherData.identifier] && [data.parentIdentifier isEqualToString:otherData.parentIdentifier]) {
            
            [jsons addObject:bodyJson];
            
        }
        
    }
    
    return jsons;
}

+ (NSArray *)bodyIdentifiersForPackage:(NSString *)package
{
    NSArray *bodies = [WorldDataManager allBodyJson];
    
    NSMutableArray *identifiers = [NSMutableArray array];
    
    for(NSDictionary *body in bodies) {
        
        // Parse the data
        GSWorldData *data = [[GSWorldData alloc] initWithJson:body];
        
        if([data.package isEqualToString:package]) {
            if(data.enabled) {
                [identifiers addObject:data.identifier];
            }
        }
        
    }
    
    return [NSArray arrayWithArray:identifiers];
    
}

+ (NSArray *)jsonForBodiesInPackage:(NSString *)package
{
    NSArray *bodies = [WorldDataManager allBodyJson];
    
    NSMutableArray *identifiers = [NSMutableArray array];
    
    for(NSDictionary *body in bodies) {
        
        // Parse the data
        GSWorldData *data = [[GSWorldData alloc] initWithJson:body];
        
        if([data.package isEqualToString:package]) {
            if(data.enabled) {
                [identifiers addObject:body];
            }
        }
        
    }
    
    return [NSArray arrayWithArray:identifiers];
}

+ (NSString *)parentIdentifierOfIdentifier:(NSString *)child
{
    NSDictionary *json = [WorldDataManager jsonForBodyWithIdentifier:child];
    // Parse the data
    GSWorldData *data = [[GSWorldData alloc] initWithJson:json];
    return data.parentIdentifier;
}

+ (NSArray *)availableBodyIdentifiers
{
    NSMutableArray *identifiers = [NSMutableArray array];
    
    NSArray *allJSON = [WorldDataManager availableBodyJSON];
    for(NSDictionary *body in allJSON) {
        // Parse the data
        GSWorldData *data = [[GSWorldData alloc] initWithJson:body];
        [identifiers addObject:data.identifier];
    }
    
    return identifiers;
}

+ (NSArray *)availableBodyJSON
{
    NSMutableArray *json = [NSMutableArray array];
    
    NSArray *allJSON = [WorldDataManager allBodyJson];
    
    for(NSDictionary *body in allJSON) {
        // Parse the data
        GSWorldData *data = [[GSWorldData alloc] initWithJson:body];
        if([WorldDataManager packageIsAvailable:data.package] && data.enabled) {
            [json addObject:body];
        }
    }
    
    return json;
}

#pragma mark Async Methods

+ (void)fetchJsonForBodyWithIdentifier:(NSString *)identifier completion:(void(^)(NSDictionary *json))completion
{
    if(!completion) {
        return;
    }
    dispatch_async(GALILEO_DATA_QUEUE, ^{
        
        NSDictionary *json = [WorldDataManager jsonForBodyWithIdentifier:identifier];
        
        dispatch_async(GALILEO_MAIN_QUEUE, ^{
            completion(json);
        });
        
    });
}

+ (void)fetchAllBodyJson:(void(^)(NSArray *json))completion
{
    if(!completion) {
        return;
    }
    dispatch_async(GALILEO_DATA_QUEUE, ^{
        
        NSArray *json = [WorldDataManager allBodyJson];
        
        dispatch_async(GALILEO_MAIN_QUEUE, ^{
            completion(json);
        });
        
    });
}

+ (void)fetchJsonForPeersOfIdentifier:(NSString *)identifier completion:(void(^)(NSArray *json))completion
{
    if(!completion) {
        return;
    }
    dispatch_async(GALILEO_DATA_QUEUE, ^{
        
        NSArray *json = [WorldDataManager jsonForPeersOfIdentifier:identifier];
        
        dispatch_async(GALILEO_MAIN_QUEUE, ^{
            completion(json);
        });
        
    });
}

+ (void)fetchJsonForSiblingsOfIdentifier:(NSString *)identifier completion:(void(^)(NSArray *json))completion
{
    if(!completion) {
        return;
    }
    dispatch_async(GALILEO_DATA_QUEUE, ^{
        
        NSArray *json = [WorldDataManager jsonForSiblingsOfIdentifier:identifier];
        
        dispatch_async(GALILEO_MAIN_QUEUE, ^{
            completion(json);
        });
        
    });
}

+ (void)fetchJsonForChildrenOfIdentifier:(NSString *)identifier completion:(void(^)(NSArray *json))completion
{
    if(!completion) {
        return;
    }
    dispatch_async(GALILEO_DATA_QUEUE, ^{
        
        NSArray *json = [WorldDataManager jsonForChildrenOfIdentifier:identifier];
        
        dispatch_async(GALILEO_MAIN_QUEUE, ^{
            completion(json);
        });
        
    });
}

+ (void)fetchBodyIdentifiersForPackage:(NSString *)package completion:(void(^)(NSArray *identifiers))completion
{
    if(!completion) {
        return;
    }
    dispatch_async(GALILEO_DATA_QUEUE, ^{
        
        NSArray *identifiers = [WorldDataManager bodyIdentifiersForPackage:package];
        
        dispatch_async(GALILEO_MAIN_QUEUE, ^{
            completion(identifiers);
        });
        
    });
}

+ (void)fetchJsonForBodiesInPackage:(NSString *)package completion:(void(^)(NSArray *json))completion
{
    if(!completion) {
        return;
    }
    dispatch_async(GALILEO_DATA_QUEUE, ^{
        
        NSArray *json = [WorldDataManager jsonForBodiesInPackage:package];
        
        dispatch_async(GALILEO_MAIN_QUEUE, ^{
            completion(json);
        });
        
    });
}

+ (void)fetchParentIdentifierOfIdentifier:(NSString *)identifier completion:(void(^)(NSString *parentIdentifier))completion
{
    if(!completion) {
        return;
    }
    dispatch_async(GALILEO_DATA_QUEUE, ^{
        
        NSString *parentIdentifier = [WorldDataManager parentIdentifierOfIdentifier:identifier];
        
        dispatch_async(GALILEO_MAIN_QUEUE, ^{
            completion(parentIdentifier);
        });
        
    });
}

+ (void)fetchAvailableBodyJsonForButtons:(void(^)(NSArray *json))completion
{
    NSString *viewableKey = @"viewable";
    
    if(!completion) {
        return;
    }
    [self fetchAvailableBodyJson:^(NSArray *jsons) {
        
        NSMutableArray *jsonsToReturn = [NSMutableArray array];
        
        for(NSDictionary *json in jsons) {
            
            if(![json valueForKey:viewableKey]) {
                [jsonsToReturn addObject:json];
                continue;
            }
            
            if([json valueForKey:viewableKey] && [[json valueForKey:viewableKey] boolValue]) {
                [jsonsToReturn addObject:json];
                continue;
            }
            
        }
        
        completion(jsonsToReturn);
        
    }];
}

+ (void)fetchAvailableBodyJson:(void(^)(NSArray *json))completion
{
    if(!completion) {
        return;
    }
    dispatch_async(GALILEO_DATA_QUEUE, ^{
        
        NSArray *json = [WorldDataManager availableBodyJSON];
        
        dispatch_async(GALILEO_MAIN_QUEUE, ^{
            completion(json);
        });
        
    });
}

+ (void)fetchAvailableBodyIdentifiers:(void(^)(NSArray *identifiers))completion
{
    if(!completion) {
        return;
    }
    dispatch_async(GALILEO_DATA_QUEUE, ^{
        
        NSArray *identifiers = [WorldDataManager availableBodyIdentifiers];
        
        dispatch_async(GALILEO_MAIN_QUEUE, ^{
            completion(identifiers);
        });
        
    });
}

@end
