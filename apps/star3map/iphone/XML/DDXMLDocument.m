#import "DDXMLDocument.h"
#import "NSStringAdditions.h"
#import "DDXMLPrivate.h"
#include <libxml/xmlschemas.h>

// errors callback for validation with schema
XMLCALL void xmlSchemaValidityErrorCallback(void * ctx, const char * msg, ...)
{
	NSLog(@"XML validation error: %s", msg);
}

XMLCALL void xmlSchemaValidityWarningCallback(void * ctx, const char * msg, ...)
{
	NSLog(@"XML validation warning: %s", msg);
}

XMLCALL void xmlStructuredErrorCallback(void * userData, xmlErrorPtr error)
{
	NSLog(@"XML validation error: %s", error->message);
}

@implementation DDXMLDocument

void MyErrorHandler(void * userData, xmlErrorPtr error)
{
	// Here we could extract the information from xmlError struct
}

+ (void)initialize
{
	static BOOL initialized = NO;
	if(!initialized)
	{
		// Redirect error output to our own function (don't clog up the console)
		initGenericErrorDefaultFunc(NULL);
		xmlSetStructuredErrorFunc(NULL, MyErrorHandler);
		
		initialized = YES;
	}
}

+ (id)nodeWithPrimitive:(xmlKindPtr)nodePtr
{
	return [[[DDXMLDocument alloc] initWithPrimitive:nodePtr] autorelease];
}

- (id)initWithPrimitive:(xmlKindPtr)nodePtr
{
	if(nodePtr == NULL || nodePtr->type != XML_DOCUMENT_NODE)
	{
		[super dealloc];
		return nil;
	}
	
	self = [super initWithPrimitive:nodePtr];
	return self;
}

+(id) documentWithFile: (NSString*)file andSchema: (NSString*)schema
{
	return [[[self alloc] initWithFile: file schema: schema options: 0 error: nil] autorelease];
}

/**
 * Initializes and returns a DDXMLDocument object created from an NSData object.
 * 
 * Returns an initialized DDXMLDocument object, or nil if initialization fails
 * because of parsing errors or other reasons.
**/
- (id)initWithXMLString:(NSString *)string options:(NSUInteger)mask error:(NSError **)error
{
	return [self initWithData:[string dataUsingEncoding:NSUTF8StringEncoding] schemaData: nil options:mask error:error];
}

- (id)initWithFile: (NSString*)file schema: (NSString*)schema options: (NSUInteger)mask error: (NSError **)error
{
	// read XML data from file
	NSData * data = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: file ofType: nil]];
	
	// read validation schema data from file
	NSData * schemaData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: schema ofType: nil]];
	
	return [self initWithData: data schemaData: schemaData options: mask error: error];
}

/**
 * Initializes and returns a DDXMLDocument object created from an NSData object.
 * 
 * Returns an initialized DDXMLDocument object, or nil if initialization fails
 * because of parsing errors or other reasons.
**/
- (id)initWithData: (NSData *)data schemaData: (NSData *)schemaData options: (NSUInteger)mask error: (NSError **)error
{
	if(data == nil || [data length] == 0)
	{
		NSLog(@"Unable to parse XML document from memory. Invalid data.");
		
		if(error) 
			*error = [NSError errorWithDomain: @"DDXMLErrorDomain" code: 0 userInfo: nil];
		
		[super dealloc];
		return nil;
	}
	
	xmlDocPtr doc = xmlParseMemory([data bytes], [data length]);
	if(doc == NULL)
	{
		NSLog(@"Unable to parse XML document from memory.");
		
		if(error) 
			*error = [NSError errorWithDomain: @"DDXMLErrorDomain" code: 1 userInfo: nil];
		
		[super dealloc];
		return nil;
	}
	
	// validate XML with specified schema
	if(schemaData)
	{
		// parse schema document in memory
		xmlDocPtr schemaDocument = xmlParseMemory([schemaData bytes], [schemaData length]);
		if(schemaDocument == NULL)
		{
			NSLog(@"Unable to parse schema document from memory.");
			
			if(error) 
				*error = [NSError errorWithDomain: @"DDXMLErrorDomain" code: 2 userInfo: nil];
			
			xmlFreeDoc(doc);
			[super dealloc];
			return nil;
		}
		
		// create new parser for schema
		xmlSchemaParserCtxtPtr parserContext = xmlSchemaNewDocParserCtxt(schemaDocument);
		if(parserContext == NULL)
		{
			NSLog(@"Unable to create schema document parser.");
			
			if(error) 
				*error = [NSError errorWithDomain: @"DDXMLErrorDomain" code: 3 userInfo: nil];
			
			xmlFreeDoc(doc);
			xmlFreeDoc(schemaDocument);
			return nil;
		}
		
		// set errors callbacks for parser
		xmlSchemaSetParserErrors(parserContext, xmlSchemaValidityErrorCallback, xmlSchemaValidityWarningCallback, NULL);
		
		// parse schema
		xmlSchemaPtr schema = xmlSchemaParse(parserContext);
		if(schema == NULL)
		{
			NSLog(@"Unable to parse schema document from memory.");
			
			if(error) 
				*error = [NSError errorWithDomain: @"DDXMLErrorDomain" code: 4 userInfo: nil];
			
			xmlFreeDoc(doc);
			xmlSchemaFreeParserCtxt(parserContext);
			xmlFreeDoc(schemaDocument);
			return nil;
		}
		
		// create new validation context for schema
		xmlSchemaValidCtxtPtr validationContext = xmlSchemaNewValidCtxt(schema);
		if(validationContext == NULL)
		{
			NSLog(@"Unable to create validation context.");
			
			if(error) 
				*error = [NSError errorWithDomain: @"DDXMLErrorDomain" code: 5 userInfo: nil];
			
			xmlFreeDoc(doc);
			xmlSchemaFree(schema);
			xmlSchemaFreeParserCtxt(parserContext);
			xmlFreeDoc(schemaDocument);
			return nil; 
		}
		
		// set errors callbacks for validator
		xmlSchemaSetValidStructuredErrors(NULL, xmlStructuredErrorCallback, NULL);
		
		// validate parsed document with schema
		int isValid = xmlSchemaValidateDoc(validationContext, doc);
		
		// cleanup
		xmlSchemaFreeValidCtxt(validationContext);
		xmlSchemaFree(schema);
		xmlSchemaFreeParserCtxt(parserContext);
		xmlFreeDoc(schemaDocument);
		
		// check validation result
		if(isValid != 0)
		{
			NSLog(@"ERROR: XML document doesn't passed validation with specified schema. Error #%i", isValid);
			
			if(isValid == -1)
				NSLog(@"ERROR: Internal libXML error occured.");
			
			if(error) 
				*error = [NSError errorWithDomain: @"DDXMLErrorDomain" code: 6 userInfo: nil];
			
			xmlFreeDoc(doc);
			return nil; 
		}
	}
	
	return [self initWithPrimitive:(xmlKindPtr)doc];
}

/**
 * Returns the root element of the receiver.
**/
- (DDXMLElement *)rootElement
{
	xmlDocPtr docPtr = (xmlDocPtr)genericPtr;
	
	if(docPtr->children == NULL)
		return nil;
	else
		return [DDXMLElement nodeWithPrimitive:(xmlKindPtr)(docPtr->children)];
}

@end
