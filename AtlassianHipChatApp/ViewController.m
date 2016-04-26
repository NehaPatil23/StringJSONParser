//
//  ViewController.m
//  AtlassianHipChatApp
//
//  Created by Neha Patil on 22/04/2016.
//  Copyright © 2016 University. All rights reserved.
//

#import "ViewController.h"
#import "OutputJSONViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *chatTextViewField;
@property (weak, nonatomic) IBOutlet UIButton *convertTxtToJSONBtn;
@property (nonatomic,strong)NSDictionary *jsonDict;

/** check for presence of Mentions
 * @param chatString
 * @return array containing mentions
 */

-(NSArray *) checkForPresenceOfMentions:(NSString *)chatString;

/** check for presence of Emoticons
 * @param chatString
 * @return array containing Emoticons
 */


-(NSArray *) checkForPresenceOfEmoticons:(NSString *)chatString;

/** check for presence of Links
 * @param chatString
 * @return array containing Links
 */

-(NSArray *) checkForLinksInChatMessage:(NSString *)chatString;

/** Returns title for given URL
 * @param currentURL URL
 * @return title
 */

-(NSString *) getTitleFromURL:(NSURL *)currentURL;

/** Returns strings array between startPoint and EndPoint
 * @param chatString 
 * @param startPoint Starting Point
 * @param endPoint Ending Point
 * @return strings array between startPoint and EndPoint
 */

-(NSArray *) scanForString:(NSString *)chatString betweenStartPoint:(NSString *)startPoint andEndPoint:(NSString *)endPoint;


/** Performs action on button click
 * @param sender instance of button
 * @return action performed
 */
- (IBAction)convertTextToJSONString:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _jsonDict = [NSDictionary dictionary];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Button IBAction method
- (IBAction)convertTextToJSONString:(id)sender
{
    if (_chatTextViewField.text.length > 0) {
        NSString *chatText = _chatTextViewField.text;
        NSArray *mentions = [self checkForPresenceOfMentions:chatText];
        NSArray *emoticons = [self checkForPresenceOfEmoticons:chatText];
        NSArray *linksArray = [self checkForLinksInChatMessage:chatText];
        
            NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
            if (mentions.count > 0)
            [mutableDict setObject:mentions forKey:@"mentions"];
            if(emoticons.count > 0)
            [mutableDict setObject:emoticons forKey:@"emoticons"];
            if(linksArray.count > 0)
            [mutableDict setObject:linksArray forKey:@"links"];
            if ([NSJSONSerialization isValidJSONObject:mutableDict])
            {
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableDict
                                                                   options:NSJSONWritingPrettyPrinted
                                                                     error:&error];
                
                if (! jsonData) {
                    NSLog(@"Got an error: %@", error);
                } else {
                    NSError* error;
                    // Final JSON Value printed on console
                    NSMutableDictionary *dJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
                    _jsonDict = dJSON;
                    NSLog(@"jsonString = %@",dJSON);
                }
            }
        }
    }

#pragma Helper methods

-(NSArray *) checkForPresenceOfMentions:(NSString *)chatString
{
    NSArray *mentionsArray = [NSArray array];
    
    mentionsArray = [self scanForString:chatString betweenStartPoint:@"@" andEndPoint:@" "];
    
    return mentionsArray;
    
}

-(NSArray *) checkForPresenceOfEmoticons:(NSString *)chatString
{
    NSArray *emoticonsArray = [NSArray array];
    
    emoticonsArray = [self scanForString:chatString betweenStartPoint:@"(" andEndPoint:@")"];

    return emoticonsArray;
    
}

-(NSArray *) checkForLinksInChatMessage:(NSString *)chatString
{
    NSMutableArray *substrings = [NSMutableArray array];
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                               error:&error];
    [detector enumerateMatchesInString:chatString
                               options:0
                                 range:NSMakeRange(0, chatString.length)
                            usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
     {
         if (result.resultType == NSTextCheckingTypeLink)
         {
             NSMutableDictionary *linksDict = [NSMutableDictionary dictionary];
             [linksDict setObject:[result.URL absoluteString] forKey:@"url"];
             NSString *title = [self getTitleFromURL:result.URL];
             [linksDict setObject:title forKey:@"title"];
             [substrings addObject:linksDict];
         }
     }];
    return  substrings;
    
}

-(NSString *) getTitleFromURL:(NSURL *)currentURL
{
    //for any exceptions/errors
    NSError *error;
    //converts the url html to a string
    NSString *htmlCode = [NSString stringWithContentsOfURL:currentURL encoding:NSASCIIStringEncoding error:&error];
    //so let's create two strings that are our starting and ending signs
    NSString *startPoint = @"<title>";
    NSString *endPoint = @"</title>";
    
    NSArray *substrings = [self scanForString:htmlCode betweenStartPoint:startPoint andEndPoint:endPoint];
    
    NSString *docTitle = @"";
    if (substrings.count > 0) {
        docTitle = substrings[0];
    }
    
    return docTitle;
}

#pragma reusable method

-(NSArray *) scanForString:(NSString *)chatString betweenStartPoint:(NSString *)startPoint andEndPoint:(NSString *)endPoint
{
    NSMutableArray *substrings = [NSMutableArray new];
    NSScanner *scanner = [NSScanner scannerWithString:chatString];
    [scanner scanUpToString:startPoint intoString:nil]; // Scan all characters before startPoint
    while(![scanner isAtEnd]) {
        NSString *substring = nil;
        [scanner scanString:startPoint intoString:nil]; // Scan the startPoint character
        if([scanner scanUpToString:endPoint intoString:&substring]) {
            [substrings addObject:substring];
        }
        [scanner scanUpToString:startPoint intoString:nil]; // Scan all characters before next startPoint
    }
    return substrings;
}



#pragma TextViewDelegate methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma navigation methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showOutput"])
    {
        OutputJSONViewController *outputViewController = [segue destinationViewController];
        // Passing data to be displayed to the view controller here
        outputViewController.outputString = _jsonDict;
    }
}

@end
