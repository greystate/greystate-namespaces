<% @language = "jscript" %>
<% Response.Expires = "0";

/* -----------------------------------------------------
	File:		index.asp
	Author:		Chriztian Steinmeier
	Created:	2002-11-19
	RCS-Id
		$Id: index.asp,v 1.0 2004-03-02 00:43:19+01 chriz Exp chriz $
	Description
		Simple Server.Transfer() to /process.asp

----------------------------------------------------- */

Server.Transfer("/process.asp");

%>
