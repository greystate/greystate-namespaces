<% @language = "jscript" %>
<% Response.Expires = "0"
/* -----------------------------------------------------
	File:		process.asp
	Author:		Chriztian Steinmeier
	Created:	2002-11-19
	RCS-Id
		$Id: process.asp,v 1.2 2004-03-03 01:53:04+01 chriz Exp chriz $
	Description
		Processing file for the namespaces section of
		greystate.dk - ie:

		http://xmlns.greystate.dk/2002/insectbase/

		- will actually Server.Transfer() to this file,
		which will catch the requested folder, and
		output information about that namespace.

----------------------------------------------------- */
%><!-- #include virtual="/include/xmlobject.asp" --><%

XMLOBJ_ALWAYS_RELOAD_PROCESSORS = true;

var XMLNS_SERVER_DEVELOPMENT = "aptiva";
var XMLNS_SERVER_PRODUCTION = "xmlns.greystate.dk";

var oSrv = Request.ServerVariables;
var strServername = XMLNS_SERVER_PRODUCTION; //String(oSrv("SERVER_NAME"));
var strResource = String(oSrv("SCRIPT_NAME")).replace(/\/index.asp/, "");

var strNamespace = "http://" + strServername + strResource;
var strYear = new Date().getFullYear();

var oXML = new XMLObject("/namespaces.xml", "/namespace-transform.xsl", XMLOBJ_USE_XSLTEMPLATE | XMLOBJ_NO_TRANSFORM);

oXML.addParameter("namespace", strNamespace);
oXML.addParameter("currentYear", strYear);
oXML.transform();

var strHTML = oXML.error ? oXML.errorDesc : oXML.output;

%><!DOCTYPE html>
<html>
<head>
	<title>Greystate XML Namespace <%= strResource %></title>
	<meta http-equiv="author" content="Chriztian Steinmeier">
	<meta charset="utf-8">
	<link rel="stylesheet" type="text/css" href="/standard.css">
	<link rel="stylesheet" type="text/css" href="/xmlschema.css">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>

<%= strHTML %>

</body>
</html>
<!--
	Namespace: <%= strNamespace %>
	Resource:  <%= strResource %>
-->
