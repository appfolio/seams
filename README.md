# seams

Break up your monolith by identifying [seams]((http://www.informit.com/articles/article.aspx?p=359417&seqNum=2)) in your database schema!

## Problem statement

Why would you need this?

If you have a large monolith application backed by a complex database schema, you might want to break it apart. In order to break it apart, you first need to identify seams.

For example, let's say you have an app consisting of 1,000 source code files and 100 database tables. You might want to break out the "product" module or the "marketing" section, or what have you.

You might look at this problem from a code-first perspective, or a database-first perspective.
This tool only considers the latter.
For a code-first perspective, check out Shopify's [ideas](https://engineering.shopify.com/blogs/engineering/deconstructing-monolith-designing-software-maximizes-developer-productivity) (and hopefully open-source tools in the future).

Formal problem statement:

Given a database schema with a number of tables and foreign key constraints,
pick a subset of tables `initial_set` from the schema
expand the subset to `min_set`, which should contain `initial_set` and satisfy all foreign key constraints

## System requirements

It doesn't matter which language your application is written in.
However, it *does* matter which database you are using.
The current implementation is using the `mysql2` gem and has been verified for MySQL Server 5.6 and 5.7.
I believe the code should be portable enough, but this is the "Minimum Viable Product": just one file of Ruby code.

## Usage

This `irb` session should explain how to use it:
```
require './seams'
# pass a set of MySQL options
seams = Seams.new(database: "yourdb", username: "youruser")
initial_set = Set.new(["users", "products"])
seams.gather(initial_set) # prints set of tables that belong inside seam
```

Further explorations:
```
# debug output shows algorithm in action
seams = Seams.new(database: "yourdb", username: "youruser", debug: true)
# show available public methods
seams.methods.sort - Object.methods
# print entire schema
seams.show_tables
seams.gather(Set.new) # should return null set
seams.gather(seams.show_tables) # should return entire schema
```
