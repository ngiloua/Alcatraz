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

#import "ATZSegmentedControl.h"
#import "NSColor+Alcatraz.h"

@implementation ATZSegmentedControl

- (void)drawRect:(NSRect)dirtyRect {
    NSColor* selectedColor = [NSColor selectedItemColor];

    CGFloat totalWidth = 0;
    for (int i = 0; i < self.segmentCount; i++) {
        NSString* text = [self labelForSegment:i];
        NSMutableDictionary* attributes = [NSMutableDictionary dictionaryWithDictionary:[self defaultAttributes]];
        CGFloat segmentWidth = [self widthForSegment:i withAttributes:attributes];
        NSRect rect = NSMakeRect(totalWidth, 0, segmentWidth, self.bounds.size.height);
        NSSize textSize = [text sizeWithAttributes:attributes];
        if ([self isSelectedForSegment:i]) {
            if ([self shouldUsePillHighlighting]) {
                attributes[NSForegroundColorAttributeName] = [NSColor whiteColor];
                NSRect backgroundRect = rect;
                backgroundRect.origin.x = rect.origin.x + (rect.size.width - textSize.width - 10) / 2.f;
                backgroundRect.origin.y = 3;
                backgroundRect.size.width = segmentWidth;
                backgroundRect.size.height = textSize.height + 2;
                CGFloat cornerRadius = floorf(backgroundRect.size.height/2);
                NSBezierPath *textViewSurround = [NSBezierPath bezierPathWithRoundedRect:backgroundRect xRadius:cornerRadius yRadius:cornerRadius];
                [selectedColor setFill];
                [textViewSurround fill];
            } else {
                attributes[NSForegroundColorAttributeName] = selectedColor;
            }
        }
        rect.origin.y = (rect.size.height - textSize.height) / 2.f - 1.f;
        [text drawInRect:rect withAttributes:attributes];
        totalWidth += segmentWidth;
    }
}

- (NSDictionary*)defaultAttributes {
    NSFont* font = [NSFont fontWithName:@"HelveticaNeue" size:12.f];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];

    [style setAlignment:NSCenterTextAlignment];
    return @{
        NSFontAttributeName: font,
        NSParagraphStyleAttributeName: style,
        NSKernAttributeName: @(0.3)
    };
}

- (CGFloat)widthForSegment:(NSInteger)segment withAttributes:(NSDictionary*)attributes {
    NSString* text = [self labelForSegment:segment];
    NSSize textSize = [text sizeWithAttributes:attributes];
    return textSize.width + 10;
}

- (CGFloat)widthForSegment:(NSInteger)segment {
    return [self widthForSegment:segment withAttributes:[self defaultAttributes]];
}

- (NSSize)intrinsicContentSize {
    NSSize defaultSize = [super intrinsicContentSize];
    defaultSize.height *= 1.2;
    return defaultSize;
}

- (BOOL)shouldUsePillHighlighting {
    NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
    return version.majorVersion < 11 && version.minorVersion < 10;
}

@end
