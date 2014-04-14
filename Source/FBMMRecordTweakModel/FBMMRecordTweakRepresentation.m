//
// FBMMRecordTweakRepresentation.m
//
// Copyright (c) 2014 Mutual Mobile (http://www.mutualmobile.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "FBMMRecordTweakRepresentation.h"

#import "FBMMRecordTweakModel.h"
#import "FBTweak.h"
#import "FBTweakCategory.h"
#import "FBTweakCollection.h"
#import "FBTweakStore.h"

static BOOL FBMMRecordTweakRepresentation_tweakOverrideAllPropertyKeyPathsForRepresentation;

@implementation FBMMRecordTweakRepresentation

+ (void)load {
    FBMMRecordTweakRepresentation_tweakOverrideAllPropertyKeyPathsForRepresentation = YES;
}

+ (void)setTweakOverrideAllPropertyKeyPathsForRepresentation:(BOOL)overrideKeyPaths {
    FBMMRecordTweakRepresentation_tweakOverrideAllPropertyKeyPathsForRepresentation = overrideKeyPaths;
}

- (NSArray *)keyPathsForMappingAttributeDescription:(NSAttributeDescription *)attributeDescription {
    NSArray *keyPaths = [super keyPathsForMappingAttributeDescription:attributeDescription];

    FBTweak *tweak = [FBMMRecordTweakModel tweakForProperty:attributeDescription entity:self.entity];
    NSArray *newKeyPaths = [self keyPathsForTweak:tweak currentKeyPaths:keyPaths];
    
    return newKeyPaths;
}

- (NSArray *)keyPathsForMappingRelationshipDescription:(NSRelationshipDescription *)relationshipDescription {
    NSArray *keyPaths = [super keyPathsForMappingRelationshipDescription:relationshipDescription];
    
    FBTweak *tweak = [FBMMRecordTweakModel tweakForProperty:relationshipDescription entity:self.entity];
    NSArray *newKeyPaths = [self keyPathsForTweak:tweak currentKeyPaths:keyPaths];
    
    return newKeyPaths;
}

- (NSArray *)keyPathsForTweak:(FBTweak *)tweak currentKeyPaths:(NSArray *)keyPaths {
    FBTweakValue tweakValue = [tweak currentValue];
    
    if (tweakValue == nil) {
        return keyPaths;
    }
    
    NSMutableArray *mutableKeyPaths = [NSMutableArray array];
    [mutableKeyPaths addObject:tweakValue];
    
    if (FBMMRecordTweakRepresentation_tweakOverrideAllPropertyKeyPathsForRepresentation == NO) {
        [mutableKeyPaths addObjectsFromArray:keyPaths];
    }
    
    return mutableKeyPaths;
}

@end
