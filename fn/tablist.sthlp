.-
help for ^tablist^
.-

Tabulate Giving Output Like a List
----------------------------------

Syntax
------

  ^tablist^ variable(s) [, ^s^ort( f | +f | v) list_options]

The ^tablist^ command is useful when you want to make crosstabs of 
variables but you want the results to be in a list type format.  An "n" way
crosstab implies the need for some kind of an "n" way table.  Instead, 
^tablist^ treats each variable as a column makes an "n" way table by using
"n" columns for the variables.  This is especially useful when each variable
has a small number of values, since this can yield a very compressed table
summarizing the data.

Options
-------

By default, the data is sorted by the frequency of each combination, from the
most frequent to the least frequent.  You can use the ^sort( )^ option to
override this

  ^sort(f)^  - Sort by freq., from most frequent to least frequent (the default).
  ^sort(+f)^ - Sort by freq., from least frequent to most frequent.
  ^sort(v)^  - Sort by the values of the variables listed.

list_options contain any of the options for the list command.

Example
-------

. ^tablist x1 x2 x3 x4^
. ^tablist x1 x2 x3 x4, sort(+f)^
. ^tablist x1 x2 x3 x4, sort(v)^
. ^tablist x1 x2 x3 x4, divider noheader^

Author
------

Statistical Consulting Group
Institute for Digital Research and Education, UCLA
idrestat@ucla.edu 
