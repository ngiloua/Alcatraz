// PluginWindowController.m
// 
// Copyright (c) 2014 Marin Usalj | supermar.in
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

#import <Cocoa/Cocoa.h>

#import "ATZPluginWindowController.h"
#import "ATZDownloader.h"
#import "ATZPackageFactory.h"

#import "ATZVersionLabel.h"

#import "ATZPlugin.h"
#import "ATZColorScheme.h"
#import "ATZTemplate.h"

#import "ATZShell.h"

#import "ATZFillableButton.h"
#import "ATZPackageTableViewDelegate.h"

static NSString *const ALL_ITEMS_ID = @"AllItemsToolbarItem";
static NSString *const CLASS_PREDICATE_FORMAT = @"(self isKindOfClass: %@)";
static NSString *const SEARCH_PREDICATE_FORMAT = @"(name contains[cd] %@ OR description contains[cd] %@)";
static NSString *const INSTALLED_PREDICATE_FORMAT = @"(installed == YES)";

typedef NS_ENUM(NSInteger, ATZFilterSegment) {
    ATZFilterSegmentPlugins = 0,
    ATZFilterSegmentColorSchemes = 1,
    ATZFilterSegmentTemplates = 2,
};

@interface ATZPluginWindowController ()
@property (nonatomic, assign) NSView *hoverButtonsContainer;
@property (nonatomic, strong) ATZPackageTableViewDelegate* tableViewDelegate;
@end

@implementation ATZPluginWindowController

- (id)init {
    @throw [NSException exceptionWithName:@"There's a better initializer" reason:@"Use -initWithNibName:inBundle:" userInfo:nil];
}

- (id)initWithBundle:(NSBundle *)bundle {
    if (self = [super initWithWindowNibName:NSStringFromClass([ATZPluginWindowController class])]) {
        [[self.window toolbar] setSelectedItemIdentifier:ALL_ITEMS_ID];
        
        [self addVersionToWindow];

        @try {
            if ([NSUserNotificationCenter class])
                [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
        }
        @catch(NSException *exception) { NSLog(@"I've heard you like exceptions... %@", exception); }
    }
    return self;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    [self.window makeKeyAndOrderFront:self];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

#pragma mark - Bindings

- (IBAction)installPressed:(ATZFillableButton *)button {
    ATZPackage *package = [self.tableViewDelegate tableView:self.tableView objectValueForTableColumn:0 row:[self.tableView rowForView:button]];
    
    if (package.isInstalled)
        [self removePackage:package andUpdateControl:button];
    else
        [self installPackage:package andUpdateControl:button];
}

- (NSDictionary *)segmentClassMapping {
    static NSDictionary *segmentClassMapping;
    if (!segmentClassMapping) {
       segmentClassMapping = @{@(ATZFilterSegmentColorSchemes): [ATZColorScheme class],
            @(ATZFilterSegmentPlugins): [ATZPlugin class],
            @(ATZFilterSegmentTemplates): [ATZTemplate class]};
    }
    return segmentClassMapping;
}

- (IBAction)segmentedControlPressed:(NSSegmentedControl*)sender {
    [self updatePredicate];
}

- (IBAction)displayScreenshotPressed:(NSButton *)sender {
    ATZPackage *package = [self.tableViewDelegate tableView:self.tableView objectValueForTableColumn:0 row:[self.tableView rowForView:sender]];
    
    [self displayScreenshot:package.screenshotPath withTitle:package.name];
}

- (IBAction)openPackageWebsitePressed:(NSButton *)sender {
    ATZPackage *package = [self.tableViewDelegate tableView:self.tableView objectValueForTableColumn:0 row:[self.tableView rowForView:sender]];

    [self openWebsite:package.website];
}

- (void)controlTextDidChange:(NSNotification *)note {
    [self updatePredicate];
}

- (void)keyDown:(NSEvent *)event {
    if (hasPressedCommandF(event))
        [self.window makeFirstResponder:self.searchField];
    else
        [super keyDown:event];
}

- (IBAction)reloadPackages {
    ATZDownloader *downloader = [ATZDownloader new];
    [downloader downloadPackageListWithCompletion:^(NSDictionary *packageList, NSError *error) {

        if (error) {
            NSLog(@"Error while downloading packages! %@", error);
        } else {
            self.packages = [ATZPackageFactory createPackagesFromDicts:packageList];
            [self reloadTableView];
            [self updatePackages];
        }
    }];
}

- (void)reloadTableView {
    self.tableViewDelegate = [[ATZPackageTableViewDelegate alloc] initWithPackages:self.packages
                                                                    tableViewOwner:self];
    self.tableView.delegate = self.tableViewDelegate;
    self.tableView.dataSource = self.tableViewDelegate;
    [self.tableViewDelegate configureTableView:self.tableView];
    [self updatePredicate];
    [self.tableView reloadData];
}

#pragma mark - Private

- (void)enqueuePackageUpdate:(ATZPackage *)package {
    if (!package.isInstalled) return;

    NSOperation *updateOperation = [NSBlockOperation blockOperationWithBlock:^{
        [package updateWithProgress:^(NSString *proggressMessage, CGFloat progress){}
                                completion:^(NSError *failure){}];
    }];
    [updateOperation addDependency:[[NSOperationQueue mainQueue] operations].lastObject];
    [[NSOperationQueue mainQueue] addOperation:updateOperation];
}

- (void)removePackage:(ATZPackage *)package andUpdateControl:(ATZFillableButton *)button {
    button.fillRatio = 0;
    button.title = @"INSTALL";
    [package removeWithCompletion:NULL];
}

- (void)installPackage:(ATZPackage *)package andUpdateControl:(ATZFillableButton *)control {
    [package installWithProgress:^(NSString *progressMessage, CGFloat progress) {
        control.title = @"INSTALLING";
        control.fillRatio = progress * 100;
    } completion:^(NSError *failure) {
        control.title = package.isInstalled ? @"REMOVE" : @"INSTALL";
        control.fillRatio = (package.isInstalled ? 100 : 0);
        if (package.requiresRestart) [self postNotificationForInstalledPackage:package];
    }];
}

- (void)postNotificationForInstalledPackage:(ATZPackage *)package {
    if (![NSUserNotificationCenter class] || !package.isInstalled) return;
    
    NSUserNotification *notification = [NSUserNotification new];
    notification.title = [NSString stringWithFormat:@"%@ installed", package.type];
    NSString *restartText = package.requiresRestart ? @" Please restart Xcode to use it." : @"";
    notification.informativeText = [NSString stringWithFormat:@"%@ was installed successfully! %@", package.name, restartText];

    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

BOOL hasPressedCommandF(NSEvent *event) {
    return ([event modifierFlags] & NSCommandKeyMask) && [[event characters] characterAtIndex:0] == 'f';
}

- (void)updatePredicate {
    NSString *searchText = self.searchField.stringValue;
    NSMutableArray* predicates = [[NSMutableArray alloc] initWithCapacity:3];
    Class selectedPackageClass = [self segmentClassMapping][@([self.packageTypeSegmentedControl selectedSegment])];
    if (selectedPackageClass)
        [predicates addObject:[NSPredicate predicateWithFormat:CLASS_PREDICATE_FORMAT, selectedPackageClass]];

    if (searchText.length > 0)
        [predicates addObject:[NSPredicate predicateWithFormat:SEARCH_PREDICATE_FORMAT, searchText, searchText]];

    if ([self.installationStateSegmentedControl selectedSegment] != 0)
        [predicates addObject:[NSPredicate predicateWithFormat:INSTALLED_PREDICATE_FORMAT]];

    [self.tableViewDelegate filterUsingPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]];
    [self.tableView reloadData];
}

- (void)updatePackages {
    for (ATZPackage *package in self.packages) {
        [self enqueuePackageUpdate:package];
    }
}

- (void)openWebsite:(NSString *)address {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:address]];
}

- (void)displayScreenshot:(NSString *)screenshotPath withTitle:(NSString *)title {
    
    [self.previewPanel.animator setAlphaValue:0.f];
    self.previewPanel.title = title;
    [self retrieveImageViewForScreenshot:screenshotPath
                                progress:^(CGFloat progress) {

    }
                              completion:^(NSImage *image) {
        
        self.previewImageView.image = image;
        [NSAnimationContext beginGrouping];
        
        [self.previewImageView.animator setFrame:(CGRect){ .origin = CGPointMake(0, 0), .size = image.size }];
        CGRect previewPanelFrame = (CGRect){.origin = self.previewPanel.frame.origin, .size = image.size};
        [self.previewPanel setFrame:previewPanelFrame display:NO animate:NO];
        [self.previewPanel.animator center];
        
        [NSAnimationContext endGrouping];
        
        [self.previewPanel makeKeyAndOrderFront:self];
        [self.previewPanel.animator setAlphaValue:1.f];
    }];
}

- (void)retrieveImageViewForScreenshot:(NSString *)screenshotPath progress:(void (^)(CGFloat))downloadProgress completion:(void (^)(NSImage *))completion {
    
    ATZDownloader *downloader = [ATZDownloader new];
    [downloader downloadFileFromPath:screenshotPath
                            progress:^(CGFloat progress) {
                                downloadProgress(progress);
                            }
                          completion:^(NSData *responseData, NSError *error) {
                              
                              NSImage *image = [[NSImage alloc] initWithData:responseData];
                              completion(image);
                          }];
    
}

- (void)addVersionToWindow {
    NSView *windowFrameView = [[self.window contentView] superview];
    NSTextField *label = [[ATZVersionLabel alloc] initWithFrame:(NSRect){
        .origin.x = self.window.frame.size.width - 46,
        .origin.y = windowFrameView.bounds.size.height - 26,
        .size.width = 40,
        .size.height = 20
    }];
    [windowFrameView addSubview:label];
}

@end
