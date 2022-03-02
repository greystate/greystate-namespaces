<% @language = "jscript" %>
<% Response.Expires = "0"
/* -----------------------------------------------------
	File:		index.asp								
	Author:		Chriztian Steinmeier					
	Created:	2002-04-24								
	Description											
		Index file for folders in the "namespaces" 		
		section of greystate.dk - ie:					
														
		http://xmlns.greystate.dk/2002/insectbase		
														
			will actually point to:						
														
		http://www.greystate.dk/xmlns/2002/insectbase	
														
		This file will catch the requested folder, and	
		output information about this namespace.		
														
	Changes/edits										
	Date		DevID	Description						
	----------------------------------------------		
	2002-00-00	CS										
														
----------------------------------------------------- */
%><!-- #include virtual="/include/xmlobject.asp" --><%

XMLOBJ_ALWAYS_RELOAD_PROCESSORS = true;

var oSrv = Request.ServerVariables;
var URL = String(oSrv("URL"));
var strNamespace = "http://xmlns.greystate.dk" + URL.replace(/\/index.asp/, "");

var oXML = new XMLObject("/namespaces.xml", "/namespace-transform.xsl", XMLOBJ_USE_XSLTEMPLATE | XMLOBJ_NO_TRANSFORM);

oXML.addParameter("namespace", strNamespace);
oXML.transform();

var strHTML = oXML.error ? oXML.errorDesc : oXML.output;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<title>Greystate XML Namespace</title>
	<meta http-equiv="author" content="Chriztian Steinmeier">
	<meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
	<link rel="stylesheet" type="text/css" href="/standard.css">
</head>
<body>

<%= strHTML %>

</body>
</html>
