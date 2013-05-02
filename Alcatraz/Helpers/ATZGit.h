// Git.h
// 
// Copyright (c) 2013 Marin Usalj | mneorr.com
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

#import <Foundation/Foundation.h>

static NSString *const CLONE = @"clone";
static NSString *const FETCH = @"fetch";
static NSString *const ORIGIN = @"origin";
static NSString *const BRANCH = @"branch";
static NSString *const TAG = @"tag";
static NSString *const ORIGIN_MASTER = @"origin/master";
static NSString *const RESET = @"reset";
static NSString *const HARD = @"--hard";

// Options examples:
//  @{ BRANCH: @"deploy" }
//  @{ TAG: @"1.2.1" }

@interface ATZGit : NSObject

+ (void)updateOrCloneRepository:(NSString *)remotePath toLocalPath:(NSString *)localPath options:(NSDictionary *)options
                     completion:(void(^)(NSString *output, NSError *error))completion;

+ (void)updateOrCloneRepository:(NSString *)remotePath toLocalPath:(NSString *)localPath
                     completion:(void(^)(NSString *output, NSError *error))completion;

@end
