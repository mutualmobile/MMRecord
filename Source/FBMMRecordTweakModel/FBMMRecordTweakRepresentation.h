//
// FBMMRecordTweakRepresentation.h
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

#import "MMRecordRepresentation.h"

/**
 The FBMMRecordTweakRepresentation can be used in development to provide a way to change MMRecord
 parsing and population behavior on the fly without having to recompile the app. This class is what
 makes MMRecord use the tweaked values supplied through the Tweaks UI, and configured by the
 FBMMRecordTweakModel class, when record population methods get called.
 
 The way this works is that this class overrides the keyPathsForAttribute/Relationship methods and
 queries the tweak store to determine if any of the key path values have been changed. If they have,
 then this class can use the tweaked values instead of the defaults when attempting to populate an
 instance of a record.
 */
@interface FBMMRecordTweakRepresentation : MMRecordRepresentation

/**
 Optional method that sets whether or not the settings obtained in a tweak override all other key
 paths for a given property, or if the tweak gets added to the front of the list of possible key
 paths. If the tweak gets added to the front of the list, then if the tweaked value does not result
 in successfully populating an attribute or relationship then other key paths in the list will be 
 used to attempt to populate the object, if those other key paths exist.
 @param overrideKeyPaths BOOL value for whether or not the tweak should override other key paths.
 @discussion The default for this method is YES.
 */
+ (void)setTweakOverrideAllPropertyKeyPathsForRepresentation:(BOOL)overrideKeyPaths;

@end
