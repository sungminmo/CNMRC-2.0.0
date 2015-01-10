//
//  CMParser.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 6. 25..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMParser.h"

@implementation CMParser

+ (NSMutableDictionary *)dictionaryWithXMLNode:(TBXMLElement *)element
{
    NSMutableDictionary *elementDict = [NSMutableDictionary dictionary];
    
    do
    {
        // 자식 엘리먼트가 있다면...
        if (element->firstChild)
        {
            if ([elementDict valueForKey:[TBXML elementName:element]] == nil)
            {
                [elementDict setObject:[self dictionaryWithXMLNode:element->firstChild] forKey:[TBXML elementName:element]];
            }
            else if ([[elementDict valueForKey:[TBXML elementName:element]] isKindOfClass:[NSMutableArray class]])
            {
                [[elementDict valueForKey:[TBXML elementName:element]] addObject:[self dictionaryWithXMLNode:element->firstChild]];
            }
            else
            {
                NSMutableArray *items = [NSMutableArray new];
                [items addObject:[elementDict valueForKey:[TBXML elementName:element]]];
                [items addObject:[self dictionaryWithXMLNode:element->firstChild]];
                [elementDict setObject:items forKey:[TBXML elementName:element]];
            }
        }
        else
        {
            [elementDict setObject:[TBXML textForElement:element] forKey:[TBXML elementName:element]];
        }
    }
    while ((element = element->nextSibling));
    
    return elementDict;
}

+ (NSMutableDictionary *)dictionaryWithXMLData:(NSData *)data
{
    NSError *error = nil;
    //TBXML *tbxml = [TBXML tbxmlWithXMLData:data error:&error];
    TBXML *tbxml = [TBXML newTBXMLWithXMLData:data error:&error];
    
    if (!tbxml.rootXMLElement)
    {
        return nil;
    }
    
    return [self dictionaryWithXMLNode:tbxml.rootXMLElement];
}

@end
