//
//  Constellations.h
//  Starglobe
//
//  Created by Alex on 05.05.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

#import <Realm/Realm.h>

@interface Constellations : RLMObject
@property NSString *objectName;
@property NSString *objectDescription;
@property NSString *imageName;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<Constellations>
RLM_ARRAY_TYPE(Constellations)
