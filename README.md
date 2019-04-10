# seams

Break up your monolith by identifying [seams](http://www.informit.com/articles/article.aspx?p=359417&seqNum=2) in your database schema!

## Problem statement

Why would you need this?

If you have a large monolith application backed by a complex database schema, you might want to break it apart. In order to break it apart, you first need to identify seams that can become service boundaries.

Using [Domain-Driven Design (DDD)](http://dddcommunity.org/learning-ddd/what_is_ddd/), you might want to break out the "product" [bounded context](https://www.martinfowler.com/bliki/BoundedContext.html) or the "marketing" bounded context, or what have you. However, it can be hard to wrap your head around the entire database schema, not to mention the whole codebase.

You might look at this problem from a code-first perspective, or a database-first perspective.
This tool only considers the latter.
For a code-first perspective, check out Shopify's [ideas](https://engineering.shopify.com/blogs/engineering/deconstructing-monolith-designing-software-maximizes-developer-productivity) (and hopefully open-source tools in the future).

Formal problem statement:

    Given a database schema with a number of tables and foreign key constraints,
    pick a subset of tables `initial_set` from the schema, then expand the subset to `min_set`.
    A solution for `min_set` should contain `initial_set` and satisfy all foreign key constraints.

This tool allows you to explore your database schema and `find` one seam, or `solve` for all the seams.

## System requirements

It doesn't matter which language your application is written in.
However, it *does* matter which database you are using.
Seams uses the ANSI SQL [information schema](https://en.wikipedia.org/wiki/Information_schema).

The current implementation is using the `mysql2` gem and has been verified for MySQL Server 5.6 and 5.7.
I believe the code should be portable enough, but this is the "Minimum Viable Product": just one file of Ruby code.

## Usage

This `irb` session should explain how to use it:
```
require './seams'
# pass a set of MySQL options
seams = Seams.new(database: "yourdb", username: "youruser")
initial_set = Set.new(["users", "products"])
seams.find(initial_set)
seams.solve # returns set of sets that are separated by seams
```

Further explorations:
```
# debug output shows algorithm in action
seams = Seams.new(database: "yourdb", username: "youruser", debug: true)
seams.methods.sort - Object.methods # show available public methods
seams.find(Set.new) # should return null set
all_tables = seams.list_tables # print entire schema
seams.find(all_tables) # should return entire schema
```
