<%

/*
________________________________________________________
--------------------------------------------------------
				Simple XMLObject Wrapper				
              Code by Chriztian Steinmeier				
		chriztian@steinmeier.dk - www.steinmeier.dk		
		===========================================		
			http://www.greystate.dk/xmlobject/			
--------------------------------------------------------
	<tracking exactversion="2002-03-22T00:21+01:00" />	
														
	Version History :									
[version 2.8.2]											
	22-03-2002 00:21									
		Bugfix: Using setVersion() worked, but would	
		throw an error anyway.							
														
[version 2.8.1]		(Never published!)					
	23-02-2002 02:25									
		Bugfix: Using replaceNode() in conjunction		
		with the caching mechanisms threw an error		
		about mixed threading models.					
[version 2.8]											
	14-01-2002 00:20									
		Fixed some bugs with Version-Dependent ProgIDs,	
		and loading via URLs.							
		Added support for the MSXML4 Parser.			
		Added the constants to the Reference section.	
--------------------------------------------------------
[version 2.7]		(Never published!)					
	22-11-2001 01:31									
		New function: quickTransformXML(),				
		and a new constant: XMLOBJ_NO_ERRORS			
		was added to the interface.						
--------------------------------------------------------
						...								
	History abbreviated - full history available at:	
		http://www.greystate.dk/xmlobject/				
						...								
[Version 0.1]											
	26-08-2001 20:44									
		Project started. Interface layout. Coding.		
														
________________________________________________________
													  */

// **************** Includes ***********************
%><!--#include file="xmlobj_constants.asp"--><%		
%><!--#include file="xmlobj_resources.asp"--><%		
// ************** End Includes *********************

/* Object: XMLObject														
----------------------------------------------------------------------------
______________________________[ INTERFACE ]_________________________________
							   ::: ::: :::									
		Please use the website (URL above) for object reference,			
		as it contains detailed info on all the properties, methods			
		and constructors available in the XMLObject.						
							   ::: ::: :::									
													  					  */
function XMLObject()
{
	// Initialize public variables:
    this.input 		= null;
	this.stylesheet = null;
	this.processor	= null;
	
	this.output 	= null;
	
	this.xml		= "";
	this.xsl		= "";
	
	this.async			 = false;
	this.validateOnParse = true;
	this.version 		 = "";
	
	this.error			= false;
	this.errorDesc		= "";
	this.hideErrors 	= false;
	
	this.status		= XMLOBJSTATE_EMPTY;
	
	this.ID			= m_generate_ID("_");
	this.cachedXML	= false;
	this.cachedXSL	= false;
	
	// Initialize public functions:
	this.loadXMLdoc	= m_loadXMLDocument;
	this.loadXSLdoc	= m_loadStylesheet;
	
	this.loadProcessorDocs	= m_loadProcessorDocs;
	this.transferParameters	= m_transferParameters;
	
	this.addParameter	= m_procAddParam;
	this.addObject		= m_procAddObj;
	
	this.transform	= m_transform;
	this.validate	= m_validate;
	
	this.setVersion	= m_setVersion;
	this.versionChanged = m_versionChanged;
	
	this.getCacheInfo = m_getCacheInfo;
	
	// Manipulator functions:
	this.saveXML		= m_saveXMLdoc;
	this.replaceNode	= m_replaceNode;
	this.appendToRoot	= m_appendToRoot;
	this.removeNode		= m_removeNode;
	
	this.getNodeText	= m_getNodeText;
	
	// Set default version	(MUST do - sets up ProgIDs)
	this.setVersion("default");
	
	// The following line MUST be below call to "setVersion()"
	this.progID			= PROGID_DOMDOCUMENT;
	
	// Prepare for loading document(s)
	var a_Args = XMLObject.arguments;	// Grab arguments - can be none, 1, 2 or 3
	var numArgs = a_Args.length;
	
	var bUseCaching = false;
	var transferParams = ( (numArgs == 3 && String(a_Args[2]).indexOf(XMLOBJ_TRANSFER_OPERATOR) > 0) ? a_Args[2] : "" );
	// We will use caching if
	//		A: User has specified transfer parameters,
	//	 or B: User has set the bit XMLOBJ_USE_XSLTEMPLATE
	if ( (numArgs == 3) && ((transferParams > "") || (a_Args[2] & XMLOBJ_USE_XSLTEMPLATE)) )
		bUseCaching = true;
	
	if (bUseCaching) {
		this.progID = PROGID_FREETHREADED;
		this.loadProcessorDocs(a_Args);
	} else {
		if (numArgs >= 2)					// Load a stylesheet
		{
			this.status = XMLOBJSTATE_LOADING;		// Signal loading in progress...
			this.stylesheet = loadDocument(a_Args[1], this.async, this.validateOnParse);
			this.errorDesc += errorCheck(this.stylesheet.parseError, ERR_CHECK_STYLESHEET);
		}
		if (numArgs >= 1)					// Load main document
		{
			this.status = XMLOBJSTATE_LOADING;		// Signal loading in progress...
			this.input =  loadDocument(a_Args[0], this.async, this.validateOnParse, this.progID);
			this.errorDesc += errorCheck(this.input.parseError, ERR_CHECK_DOCUMENT);
		}
	}
	
	// Set the error flag if there was any...
	this.error = (this.errorDesc != "") ? true : false;
	
	if (!this.error && numArgs >= 1)
	{
		// Transfer xml to objects properties
		this.xml = this.input.xml;
		if (numArgs >= 2)
			this.xsl = this.stylesheet.xml;
		
		// Default behavior is to call .transform() if there is a stylesheet, but the optional 3rd argument
		// can be flagged to say that we don't want to call the transform() method.
		if (numArgs > 1)
		{
			if ( numArgs == 2 || ( (numArgs == 3) && (transferParams > "") || !(a_Args[2] & XMLOBJ_NO_TRANSFORM) ) )
				this.transform();
		}
	}
	
	// Final courtesy to potential debug/progress checks:
	this.status = this.error ? XMLOBJSTATE_ERROR : (this.status == XMLOBJSTATE_EMPTY)? XMLOBJSTATE_EMPTY : XMLOBJSTATE_READY;
	// Hey - that's it?!

// ***********************************************************************************
// ******************************* INTERFACE FUNCTIONS *******************************
// ***********************************************************************************

	//	Changes version of (MS)XML to use. If called it must be before any XML Documents are loaded.
	function m_setVersion(sVersionString)
	{
		if (this.status != XMLOBJSTATE_EMPTY)
			throwError(XMLOBJERROR_CANNOT_CHANGE_VERSION, "You can not change the version after a document is loaded.");
		else if (!isSupported(sVersionString))
			throwError(XMLOBJERROR_VERSION_UNSUPPORTED);
		else
		{
			this.version = sVersionString;
			this.versionChanged();
		}
	}
	
	//	Handles a version change - called from setVersion(),
	//	so it's safe to assume that version is correct.
	function m_versionChanged()
	{
		switch (this.version)
		{
			case "default":
				PROGID_DOMDOCUMENT	= DEF_XMLDOMDOCUMENT;
				PROGID_FREETHREADED	= DEF_XMLFREETHREADED;
				PROGID_XSLTEMPLATE	= DEF_XSLTEMPLATE;
			break;
			case "3.0":
				PROGID_DOMDOCUMENT	= PROGID_DOMDOCUMENT_30;
				PROGID_FREETHREADED	= PROGID_FREETHREADED_30;
				PROGID_XSLTEMPLATE	= PROGID_XSLTEMPLATE_30;
			break;
			case "4.0":
				PROGID_DOMDOCUMENT	= PROGID_DOMDOCUMENT_40;
				PROGID_FREETHREADED	= PROGID_FREETHREADED_40;
				PROGID_XSLTEMPLATE	= PROGID_XSLTEMPLATE_40;
			break;
			// Add new versions here...
		}
	}
	
	//	Load the cached files
	function m_loadProcessorDocs(a_Names)
    {
		//	This is necessary when using XSLTemplate and you have made changes to the files
		var bForceReload = ( Request.QueryString("reloadprocessors") == "yes" || XMLOBJ_ALWAYS_RELOAD_PROCESSORS );
		
		//	Define IDs
		var IDcachedXML 	= "XMLCache_" + a_Names[0];
		var IDcachedXSL 	= "XSLCache_" + a_Names[1];
		var IDcachedProc	= IDcachedXSL + "processor";
		
		//	Handle XML document
        if ( typeof(Application(IDcachedXML)) == "undefined" || bForceReload )	//	Not cached yet...
		{
			this.status = XMLOBJSTATE_LOADING;		// Signal loading in progress...
			this.input = loadDocument(a_Names[0], this.async, this.validateOnParse, this.progID);
			this.errorDesc += errorCheck(this.input.parseError, ERR_CHECK_DOCUMENT);
			Application.Lock();
			Application(IDcachedXML) = this.input;
			Application.Unlock();
		}
		else
		{
			this.input = Application(IDcachedXML);	// Since it's cached, it has been errorchecked
			this.cachedXML = true;
		}
		//	Handle Stylesheet document - make XSLProcessor
        if (typeof(Application(IDcachedXSL)) == "undefined" || bForceReload)	//	Not cached yet...
		{
			this.status = XMLOBJSTATE_LOADING;		// Signal loading in progress...
			this.stylesheet = loadDocument(a_Names[1], this.async, this.validateOnParse, PROGID_FREETHREADED);
			this.errorDesc += errorCheck(this.stylesheet.parseError, ERR_CHECK_STYLESHEET);
			Application.Lock();
			Application(IDcachedXSL) = this.stylesheet;
			Application.Unlock();
		}
		else
		{
			this.stylesheet = Application(IDcachedXSL);	// Since it's cached, it has been errorchecked
			this.cachedXSL = true;
		}
		
		//	Handle the processor
		if ( typeof(Session(IDcachedProc)) == "undefined" || bForceReload )
		{
			var oTemp = Server.CreateObject(PROGID_XSLTEMPLATE);
			oTemp.stylesheet = this.stylesheet;
			
			this.processor = oTemp.createProcessor();
			Session(IDcachedProc) = this.processor;
		}
		else
			this.processor = Session(IDcachedProc);
		
		//	Set the Processors input to the already loaded XML document.
		this.processor.input = this.input;
		
		//	Lastly, add parameters to processor, if any.
		//	XMLOBJ_TRANSFER_OPERATOR equals the "transfer" operator - if a_Names[2] contains this there are parameters
		if ( a_Names[2].toString().indexOf(XMLOBJ_TRANSFER_OPERATOR) > 0 )
			this.transferParameters(a_Names[2]);
    }
	
	//	Loads and returns an XML document
	function loadDocument(xXMLspec, bAsyncLoad, bValid8OnParse, sCustomProgID)
	{
		var oTemp = (typeof(sCustomProgID) != "undefined") ? Server.CreateObject(sCustomProgID) : Server.CreateObject(PROGID_DOMDOCUMENT);
		oTemp.async = bAsyncLoad;
		oTemp.validateOnParse = bValid8OnParse;
		
		xXMLspec = String(xXMLspec);
		
		if (xXMLspec.indexOf("http://") == 0 || xXMLspec.indexOf("file://") == 0)	// URL
			oTemp.load(xXMLspec);
		
		else if (xXMLspec.indexOf(".xml") >= 1 || xXMLspec.indexOf(".xsl") >= 1)	// path
		{
			if (xXMLspec.match(/[A-Za-z]:[\\|/]{1,2}[\S]*/))								// local
				oTemp.load(xXMLspec);
			else																	// virtual
				oTemp.load(Server.MapPath(xXMLspec));
		}
		else if (xXMLspec.indexOf("<") >= 0)	// XML string
			oTemp.loadXML(xXMLspec);
		
		else	// Must be an error
			throwError(XMLOBJERROR_INVALID_ARGUMENT, "Allowed: (none), [URL], [path], [XMLstring]");
		
		return oTemp;
	}
	
	//	Load a new XML document into .input - returns boolean "success"
	function m_loadXMLDocument(sXMLfile)
	{
		this.errorDesc = "";
		
		if (typeof(sXMLfile) != "string")
			throwError(XMLOBJERROR_INVALID_ARGUMENT, ".loadXMLdoc() expects: [URL], [path] or [XMLstring]");
		else
		{
			this.status = XMLOBJSTATE_LOADING;		// Signal loading in progress...
			this.input = loadDocument(sXMLfile, this.async, this.validateOnParse, this.progID);
			this.errorDesc += errorCheck(this.input.parseError, ERR_CHECK_DOCUMENT);
			
			this.error = (this.errorDesc != "") ? true : false;
		}
		
		if (this.error)
		{
			this.status = XMLOBJSTATE_ERROR;
			return false;
		}
		else
		{
			this.status = XMLOBJSTATE_READY;
			this.xml = this.input.xml;
			return true;
		}
	}
	
	//	Load a new XSL (XML) document into .stylesheet - returns boolean "success"
	function m_loadStylesheet(sXSLfile)
	{
		this.errorDesc = "";
		
		if (typeof(sXSLfile) != "string")
			throwError(XMLOBJERROR_INVALID_ARGUMENT, ".loadXSLdoc() expects: [URL], [path] or [XMLstring]");
		else
		{
			this.status = XMLOBJSTATE_LOADING;		// Signal loading in progress...
			this.stylesheet = loadDocument(sXSLfile, this.async, this.validateOnParse, this.progID);
			this.errorDesc += errorCheck(this.stylesheet.parseError, ERR_CHECK_STYLESHEET);
			
			this.error = (this.errorDesc != "") ? true : false;
		}
		
		if (this.error)
		{
			this.status = XMLOBJSTATE_ERROR;
			return false;
		}
		else
		{
			this.status = XMLOBJSTATE_READY;
			this.xsl = this.stylesheet.xml;
			return true;
		}
	}
	
	//	Transfer specific parameters from QueryString to the compiled XSLProcessor object
	function m_transferParameters(sParams)
    {
		var oQry = Request.QueryString;
		var p, i, param, val;
        var aParam1, aParams = sParams.split(";");
		
		if (oQry.Count > 0)
		{
			for (i=0; i<aParams.length; ++i)
			{
				// Get the current parameter and ...
				aParam1 = aParams[i].split(XMLOBJ_TRANSFER_OPERATOR);
				// ...transfer QueryString parameter to processor, if there is a QRY parameter
				if ( String(oQry(aParam1[XMLOBJ_PROC_QRYNAME])) != "undefined" )
					this.processor.addParameter(aParam1[XMLOBJ_PROC_XSLNAME], String(oQry(aParam1[XMLOBJ_PROC_QRYNAME])));
			}
		}
    }
	
	function m_procAddParam(baseName, parameter)
    {
        if (this.processor && this.processor.readyState > 1)
			this.processor.addParameter(baseName, parameter);
		else
			throwError(XMLOBJERROR_PROCESSOR_NOT_READY, ".addParameter() needs an XSLProcessor in the .processor property. ["+this.processor.readyState+"]");
    }
	
	//	Add an object to into the stylesheet processor
	function m_procAddObj(oObj, sNameSpace)
    {
        if (this.processor && this.processor.readyState > 1)
			this.processor.addObject(oObj, sNameSpace);
		else
			throwError(XMLOBJERROR_PROCESSOR_NOT_READY, ".addObject() needs an XSLProcessor in the .processor property.");
    }
	
	function m_transform()
	{
		// :TODO: There should be some errorhandling here, in case the documents have been changed since load
	    if (this.processor)
		{
//			this.processor.input = this.input;
			this.processor.transform();
			this.output = this.processor.output;
		}
		else
			this.output = this.input.transformNode(this.stylesheet);
		this.output += this.getCacheInfo();
	}
	
	function m_validate(iValidateWhat)
	{
		var result = 0;
		switch (iValidateWhat)
		{
			case ERR_CHECK_DOCUMENT:
				if (this.input)
					result = this.input.validate();
				else
					throwError(XMLOBJERROR_NO_DOCUMENT);
			break;
			case ERR_CHECK_STYLESHEET:
				if (this.stylesheet)
					result = this.stylesheet.validate();
				else
					throwError(XMLOBJERROR_NO_STYLESHEET);
			break;
			case ERR_CHECK_BOTH:
				if (this.input && this.stylesheet)
				{
					result = this.input.validate();
					if (result == 0)
						result = this.stylesheet.validate();
				}
				else
					throwError(XMLOBJERROR_MISSING_DOCS);
			break;
			default:
				throwError(XMLOBJERROR_INVALID_ARGUMENT, "You must specify which document(s) you wish to validate.");
		}
		if (result != 0)
		{
			this.errorDesc += result.reason;
			this.error = true;
			this.status = XMLOBJSTATE_ERROR;
		}
	}
	
	//	Generates an ID for the XMLObject file instance used for caching
	function m_generate_ID(sFilename)
	{
		var oSrv = Request.ServerVariables;
		return oSrv("SERVER_NAME") + oSrv("SCRIPT_NAME") + sFilename;
	}
	
	function m_getCacheInfo()
    {
		ret = "\n<!-- XML: " + (this.cachedXML ? "Cached" : "Reloaded") + " |||| XSL: " + (this.cachedXSL ? "Cached" : "Reloaded") + " -->";
		return ret;
    }
	
	// Save the XML Document (.input) to "sPath".
	function m_saveXMLdoc(sPath)
	{
		if (typeof(sPath) != "string")
			throwError(XMLOBJERROR_INVALID_ARGUMENT, "You MUST specify a path to save the document.");
		else if (this.status == XMLOBJSTATE_READY)
		{
			if (this.input)
				this.input.save(sPath);
			else
				throwError(XMLOBJERROR_NO_DOCUMENT);
		}
		else
			throwError(XMLOBJERROR_OBJECT_NOT_READY);
	}
	
	// Replace a node with another. The node to replace is specified with an XPath expression.
	function m_replaceNode(xXMLnode, sXPath)
	{
		if (xXMLnode && sXPath)
		{
			var oOldNode = this.input.selectSingleNode(sXPath);
			if (oOldNode)
			{
				var oNewNode = loadDocument(xXMLnode, false, false, this.progID);
				oOldNode.parentNode.replaceChild(oNewNode.documentElement, oOldNode);
				this.xml = this.input.xml;								// Update .xml property.
			}
			else
				throwError(XMLOBJERROR_NODE_NOT_FOUND, "The XPath expression did not return an XML node.");
		}
		else
			throwError(XMLOBJERROR_INVALID_ARGUMENT);
	}
	
	// Append a new node to the root of the XML document.
	function m_appendToRoot(xXMLnode)
	{
		if (xXMLnode)
		{
			var oNewNode = loadDocument(xXMLnode, false, false, this.progID);
			this.input.documentElement.appendChild(oNewNode.documentElement);
			this.xml = this.input.xml;								// Update .xml property.
		}
		else
			throwError(XMLOBJERROR_INVALID_ARGUMENT);
	}
	
	function m_removeNode(sXPath)
    {
		if (sXPath)
		{
        	var oDeleteNode = this.input.selectSingleNode(sXPath);
			if (oDeleteNode)
			{
				oDeleteNode.parentNode.removeChild(oDeleteNode);
				this.xml = this.input.xml;							// Update .xml property.
			}
			else
				throwError(XMLOBJERROR_NODE_NOT_FOUND, "The XPath expression did not return an XML node.");
		}
		else
			throwError(XMLOBJERROR_INVALID_ARGUMENT);
    }
	
	function m_getNodeText(sXPath)
    {
        if (sXPath)
		{
			var oNode = this.input.selectSingleNode(sXPath);
			if (oNode)
			{
				return oNode.text;
			}
			else
				throwError(XMLOBJERROR_NODE_NOT_FOUND, "The XPath expression did not return an XML node.");
		}
		else
			throwError(XMLOBJERROR_INVALID_ARGUMENT);
    }
}

// ******************** Utility functions ****************************

//	This function works as kind of an "Assert" - you can add functions to the call
function isSupported(sArgument)
{
	var funcName = String(isSupported.caller).replace(/^function ([^ \({]*)[\s\S]*$/, "$1");
    if (funcName == "m_setVersion")
		return (sArgument == "3.0" || sArgument == "4.0" || sArgument == "default")? true : false;
	else
		throwError(XMLOBJERROR_INTERNAL_ERROR, "Function " + funcName + " called isSupported() with the following arguments: " + isSupported.arguments[0]);
}

function throwError(xErrorID, sDescription)
{
    if (!this.hideErrors)
	{
		var sErrorMessage, sMsg;
		if (typeof(xErrorID) == "string")
			sErrorMessage = xErrorID;
		else
			sErrorMessage = loadResourceString(xErrorID);
		
		if (typeof(sDescription) != "string")
			sDescription = "[No description]";
		
		var sMsg	= '<code style="color:#a00;">Error in file <b>xmlobject.asp</b>:'
					+ '<dl><dt>'+ sErrorMessage + '</dt><dd>' + sDescription + '</dd></dl></code>';
		outputToClient(sMsg);
	}
}

//	The ONLY function that actually generates output to the client.
//	This makes customization for other potential clients (Palm, PocketPC, etc.) easier.
function outputToClient(sMessageString)
{
	// Suppress potential stupid error
    if (typeof(sMessageString) == "string")
	{
		// Add conditions if needed (for instance you might want to strip HTML tags when outputting to a text device)
		Response.Write(sMessageString);
	}
}

//	Returns a string from the string array containing Errormessages etc.
function loadResourceString(iResID)
{
    if (iResID < a_ResourceStrings.length)
		return a_ResourceStrings[iResID];
	else
		return "Missing resource, #"+ iResID + " not found.";
}

//	Returns errormessage fom a parseError object
function errorCheck(oError, iWhichObj)
{
    return (oError.errorCode != 0) ? formatError(oError) : "";
}

//	The formatting function for XML parseErrors
function formatError(oErr)
{
	var errHTML = "";
	if (!this.hideErrors)
	{
		errHTML = '<code style="color:#a00; font:12px verdana;">'
				+ 'Error in <b>' + oErr.url + '</b>, line <b>' + oErr.line + '</b>, pos. <b>' + oErr.linepos + '</b>'
				+ '<ul type="square"><li>' + oErr.reason + '</li>'
				+ '<span style="background:#eee;color:#00c;font:10px monospace;">' + oErr.srcText + '</span>'
				+ '</ul></code>';
	}
	return errHTML;
}

//	Use this when all you need is to output the transform
function quickTransformXML(sXMLspec, sXSLspec, fNoErrors)
{
	if (typeof(fNoErrors) == "undefined")
		fNoErrors = 0;
	var xmlobj = new XMLObject(sXMLspec, sXSLspec);
	if (fNoErrors == XMLOBJ_NO_ERRORS)
		return (xmlobj.error ? "" : xmlobj.output);
	else
		return (xmlobj.error ? xmlobj.errorDesc : xmlobj.output);
}


%>