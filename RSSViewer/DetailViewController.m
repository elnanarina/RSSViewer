//
//  DetailViewController.m
//  RSSViewer
//
//  Created by Air on 18/12/14.
//  Copyright (c) 2014 Air. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController () {
    NSMutableDictionary *item;
}

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        item = self.detailItem;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];

    self.detailDescriptionLabel.numberOfLines = 0;
    
    self.titleLabel.text = [item objectForKey:@"title"];
    self.detailDescriptionLabel.text = [self stringByConvertingHTMLToPlainText];//[item objectForKey:@"description"]; //
    NSLog(@"detailLink - %@", [item objectForKey:@"link"]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)stringByConvertingHTMLToPlainText {
    @autoreleasepool {
        
        // Character sets
        NSCharacterSet *stopCharacters = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"< \t\n\r%C%C%C%C", (unichar)0x0085, (unichar)0x000C, (unichar)0x2028, (unichar)0x2029]];
        NSCharacterSet *newLineAndWhitespaceCharacters = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@" \t\n\r%C%C%C%C", (unichar)0x0085, (unichar)0x000C, (unichar)0x2028, (unichar)0x2029]];
        NSCharacterSet *tagNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
        
        // Scan and find all tags
        NSMutableString *result = [[NSMutableString alloc] init];
        NSScanner *scanner = [[NSScanner alloc] initWithString:[item objectForKey:@"description"]];
        [scanner setCharactersToBeSkipped:nil];
        [scanner setCaseSensitive:YES];
        NSString *str = nil, *tagName = nil;
        BOOL dontReplaceTagWithSpace = NO;
        do {
            
            // Scan up to the start of a tag or whitespace
            if ([scanner scanUpToCharactersFromSet:stopCharacters intoString:&str]) {
                [result appendString:str];
                str = nil; // reset
            }
            
            // Check if we've stopped at a tag/comment or whitespace
            if ([scanner scanString:@"<" intoString:NULL]) {
                
                // Stopped at a comment, script tag, or other tag
                if ([scanner scanString:@"!--" intoString:NULL]) {
                    
                    // Comment
                    [scanner scanUpToString:@"-->" intoString:NULL];
                    [scanner scanString:@"-->" intoString:NULL];
                    
                } else if ([scanner scanString:@"script" intoString:NULL]) {
                    
                    // Script tag where things don't need escaping!
                    [scanner scanUpToString:@"</script>" intoString:NULL];
                    [scanner scanString:@"</script>" intoString:NULL];
                    
                } else {
                    
                    // Tag - remove and replace with space unless it's
                    // a closing inline tag then dont replace with a space
                    if ([scanner scanString:@"/" intoString:NULL]) {
                        
                        // Closing tag - replace with space unless it's inline
                        tagName = nil; dontReplaceTagWithSpace = NO;
                        if ([scanner scanCharactersFromSet:tagNameCharacters intoString:&tagName]) {
                            tagName = [tagName lowercaseString];
                            dontReplaceTagWithSpace = ([tagName isEqualToString:@"a"] ||
                                                       [tagName isEqualToString:@"b"] ||
                                                       [tagName isEqualToString:@"i"] ||
                                                       [tagName isEqualToString:@"q"] ||
                                                       [tagName isEqualToString:@"span"] ||
                                                       [tagName isEqualToString:@"em"] ||
                                                       [tagName isEqualToString:@"strong"] ||
                                                       [tagName isEqualToString:@"cite"] ||
                                                       [tagName isEqualToString:@"abbr"] ||
                                                       [tagName isEqualToString:@"acronym"] ||
                                                       [tagName isEqualToString:@"label"]);
                        }
                        
                        // Replace tag with string unless it was an inline
                        if (!dontReplaceTagWithSpace && result.length > 0 && ![scanner isAtEnd]) [result appendString:@" "];
                        
                    }
                    
                    // Scan past tag
                    [scanner scanUpToString:@">" intoString:NULL];
                    [scanner scanString:@">" intoString:NULL];
                    
                }
                
            } else {
                
                // Stopped at whitespace - replace all whitespace and newlines with a space
                if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
                    if (result.length > 0 && ![scanner isAtEnd]) [result appendString:@" "]; // Dont append space to beginning or end of result
                }
                
            }
            
        } while (![scanner isAtEnd]);
        
        return result;
    }
}

@end
