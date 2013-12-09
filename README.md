stylight-christmas-seating
==========================

Simple script to take the hassle out of making a company seating plan.
(Needs npm and coffeescript installed).

Put the list of people in a `csv` file formatted like the `data.csv` and run :

    coffee script.coffee [params]

It gives you `output.csv` with the same list plus the table for each person at each round.

Parameters
-----------

+   `-f path` : input filepath (default: `data.csv`)
+   `-v` : see it running
+   `-R rounds` : number of rounds (default: 3)
+   `-t tables` : number of tables, will be adjusted to fit -p (default: 12)
+   `-p people` : number of people per table (default: 8)
+   `-d max` : maximum number of people from a given department at a table (default: 2)
+   `-r max` : maximum number of people with the same previous round at a table (default: 1)

The script is useful but will stop if it can place people, so don't use too strict tests.

Examples
---------

You can run it with our list of Middle Earth characters (see [here](http://www.behindthename.com/namesakes/list/tolkien/race)) for exemple :

    coffee script.coffee -p 16 -d 6 -r 3 -v -R 4

works, and

    coffee script.coffee -p 16 -d 2 -r 3 -v -R 4

doesn't.