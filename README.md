# seams
Identify seams in your database

A [seam](http://www.informit.com/articles/article.aspx?p=359417&seqNum=2) is a place where you can alter behavior in your program without editing in that place.

Given a database schema S
with a number of tables and foreign key constraints,
pick a subset of tables S1 from schema S
expand the subset to Smin which should contain S1 and satisfy all foreign key constraints
