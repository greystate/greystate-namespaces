# Greystate Namespaces

This is the source code for the site at [https://xmlns.greystate.dk/](https://xmlns.greystate.dk/)
where I've hosted the schemas for some of my XML applications for a long time.

If you peek through the code you'll probably discover a couple of things:

- It seems to have originated around April 2002
- It's written in Microsoft's **JScript** ASP variant
- The schemas are transformed to HTML using XSLT, because, *of course*
- The transformations are done using another legacy project of mine, [XMLObject()](https://xmlobject.greystate.dk)
- It's using my `Server.Transfer()` trick to hide the `.asp` part of the URLs,
but keeping the logic in a single file ([process.asp](process.asp)).
- I was using a source code control system called **RCS** at the time

## Why are all the namespace URIs using HTTP when the site is running on HTTPS?

This is the beauty of the way namespace URIs have always been specified - there does not have to be
a resource at the URI - it just has to be unique (within the scope it's supposed to be used).

This means that while I've decided to put a representation of them on their respective URLs
(the HTTP version works fine as well - I'm not currently redirecting them), I can use HTTPS
without breaking any applications that use them.



Let me know if there's something you'd like me to explain further - I might still remember :D

/Chriztian, December 2020
