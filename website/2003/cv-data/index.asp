<% @language = "jscript" %>
<% Response.Expires = "0";

/* -----------------------------------------------------
	File:		index.asp								
	Author:		Chriztian Steinmeier					
	Created:	2002-11-19								
	RCS-Id												
		$Id: index.asp,v 1.0 2003-06-27 00:15:40+02 chriz Exp chriz $	
	Description											
		Simple Server.Transfer() to /process.asp		
														
----------------------------------------------------- */

Server.Transfer("/process.asp");

%>
