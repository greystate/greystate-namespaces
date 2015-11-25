<%

var nextAvailID = 0;
//	Error constants:
var XMLOBJERROR_INVALID_ARGUMENT	= nextAvailID++;
var XMLOBJERROR_INTERNAL_ERROR		= nextAvailID++;
var XMLOBJERROR_VERSION_UNSUPPORTED	= nextAvailID++;
var XMLOBJERROR_CANNOT_CHANGE_VERSION = nextAvailID++;
var XMLOBJERROR_NOT_IMPLEMENTED		= nextAvailID++;
var XMLOBJERROR_PROCESSOR_NOT_READY	= nextAvailID++;
var XMLOBJERROR_NO_DOCUMENT			= nextAvailID++;
var XMLOBJERROR_NO_STYLESHEET		= nextAvailID++;
var XMLOBJERROR_NO_PROCESSOR		= nextAvailID++;
var XMLOBJERROR_MISSING_DOCS		= nextAvailID++;
var XMLOBJERROR_OBJECT_NOT_READY	= nextAvailID++;
var XMLOBJERROR_NODE_NOT_FOUND		= nextAvailID++;

/*var XMLOBJERROR_	= nextAvailID++;
var XMLOBJERROR_	= nextAvailID++;*/

// General resource strings
var RESID_NO_DESCRIPTION			= nextAvailID++;

//	Misc. enumerations
var ERR_CHECK_STYLESHEET	= nextAvailID++;
var ERR_CHECK_DOCUMENT		= nextAvailID++;
var ERR_CHECK_BOTH			= nextAvailID++;
var ERR_CHECK_PROCESSOR		= nextAvailID++;
var ERR_CHECK_ALL			= nextAvailID++;

//	Object states
var XMLOBJSTATE_EMPTY	= nextAvailID++;
var XMLOBJSTATE_LOADING	= nextAvailID++;
var XMLOBJSTATE_READY	= nextAvailID++;
var XMLOBJSTATE_ERROR	= nextAvailID++;

//	Constructor-call constants - these are bitflags, so you can combine them in one parameter
var XMLOBJ_USE_XSLTEMPLATE		= 0x01;		//	0000 0001
var XMLOBJ_NO_TRANSFORM			= 0x02;		//	0000 0010
var XMLOBJ_NO_ERRORS			= 0x04;		//	0000 0100

var XMLOBJ_TRANSFER_OPERATOR	= "->";


// 	Assign default ProgIDs for internal XML object
var DEF_XMLDOMDOCUMENT	=	"MSXML2.DOMDocument";
var DEF_XMLFREETHREADED =	"MSXML2.FreeThreadedDOMDocument";
var DEF_XSLTEMPLATE 	=	"MSXML2.XSLTemplate";

//	Version Dependent ProgIDs - use XMLObject.setVersion("3.0") before loading document, to use these
var PROGID_DOMDOCUMENT_30	=	"MSXML2.DOMDocument.3.0";
var PROGID_FREETHREADED_30	=	"MSXML2.FreeThreadedDOMDocument.3.0";
var PROGID_XSLTEMPLATE_30	=	"MSXML2.XSLTemplate.3.0";

//	Version Dependent ProgIDs - use XMLObject.setVersion("4.0") before loading document, to use these
var PROGID_DOMDOCUMENT_40	=	"MSXML2.DOMDocument.4.0";
var PROGID_FREETHREADED_40	=	"MSXML2.FreeThreadedDOMDocument.4.0";
var PROGID_XSLTEMPLATE_40	=	"MSXML2.XSLTemplate.4.0";

//	Indexes in parameter array
var XMLOBJ_PROC_QRYNAME		= 0
var XMLOBJ_PROC_XSLNAME		= 1

//	"Test-phase switch" - override in ASP document while testing
var XMLOBJ_ALWAYS_RELOAD_PROCESSORS = false;

// The DOM NodeTypes
var NODE_ELEMENT				=  1;
var NODE_ATTRIBUTE				=  2;
var NODE_TEXT					=  3;
var NODE_CDATA_SECTION			=  4;
var NODE_ENTITY_REFERENCE		=  5;
var NODE_ENTITY					=  6;
var NODE_PROCESSING_INSTRUCTION	=  7;
var NODE_COMMENT				=  8;
var NODE_DOCUMENT				=  9;
var NODE_DOCUMENT_TYPE			= 10;
var NODE_DOCUMENT_FRAGMENT		= 11;
var NODE_NOTATION				= 12;

%>	