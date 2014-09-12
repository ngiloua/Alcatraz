//
// ATZStyleKit.m
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

#import "ATZStyleKit.h"


@implementation ATZStyleKit

#pragma mark Initialization

+ (void)initialize
{
}

#pragma mark Drawing Methods

+ (void)drawFillableButtonWithFrame: (NSRect)frame buttonText: (NSString*)buttonText fillRatio: (CGFloat)fillRatio buttonWidth: (CGFloat)rawButtonWidth buttonType: (NSString*)buttonType;
{
    CGFloat buttonWidth = rawButtonWidth - 4;
    //// General Declarations
    CGContextRef context = (CGContextRef)NSGraphicsContext.currentContext.graphicsPort;

    //// Color Declarations
    NSColor* buttonColor = [NSColor colorWithCalibratedRed: 0.063 green: 0.856 blue: 0.483 alpha: 1];
    NSColor* clear = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 0];
    NSColor* white = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 1];
    NSColor* gray = [NSColor colorWithCalibratedRed: 0.378 green: 0.378 blue: 0.378 alpha: 1];

    //// Variable Declarations
    CGFloat computedFillWidth = fillRatio * buttonWidth * 0.01;
    CGFloat fillWidth = computedFillWidth < 0 ? 0 : (computedFillWidth > buttonWidth ? buttonWidth : computedFillWidth);
    NSColor* buttonTextColor = fillRatio >= 100 ? white : ([buttonType isEqualToString: @"install"] ? buttonColor : gray);
    NSColor* buttonStrokeColor = [buttonType isEqualToString: @"install"] ? buttonColor : gray;
    NSColor* buttonFillColor = fillWidth <= 8 ? clear : buttonStrokeColor;

    //// Rectangle Drawing
    NSBezierPath* rectanglePath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(1, 1, buttonWidth, 24.5) xRadius: 4 yRadius: 4];
    [buttonStrokeColor setStroke];
    [rectanglePath setLineWidth: 1];
    [rectanglePath stroke];


    //// Rectangle 2 Drawing
    [NSGraphicsContext saveGraphicsState];
    CGContextTranslateCTM(context, NSMinX(frame) + 1, NSMaxY(frame) - 24);

    NSBezierPath* rectangle2Path = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(0, -1.5, fillWidth, 25) xRadius: 4 yRadius: 4];
    [buttonFillColor setFill];
    [rectangle2Path fill];

    [NSGraphicsContext restoreGraphicsState];


    //// Text Drawing
    NSRect textRect = NSMakeRect(1, 3, buttonWidth, 20);
    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSCenterTextAlignment;

    NSDictionary* textFontAttributes = @{NSFontAttributeName: [NSFont fontWithName: @"HelveticaNeue" size: 14], NSForegroundColorAttributeName: buttonTextColor, NSParagraphStyleAttributeName: textStyle};

    [buttonText drawInRect: NSOffsetRect(textRect, 0, -2) withAttributes: textFontAttributes];
}

@end
