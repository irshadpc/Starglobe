//
//  User.h
//  Starglobe
//
//  Created by Alex on 05.05.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

#import <Realm/Realm.h>

@interface User : RLMObject
@property BOOL proVersion;
@property NSDate *expirationDate;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<User>
RLM_ARRAY_TYPE(User)
