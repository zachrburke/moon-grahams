moon-grahams
============

A bayesion analyzer based on Paul Grahams essay on spam filtering found here http://www.paulgraham.com/spam.html

Written using Moonscript, a language that compiles in the Lua scripting language.  Can be found here http://moonscript.org/

To Use
======

Bad sentiment contains tokens you want to filter against and good sentiment contains tokens you want to get through the filter.   By default the data just uses good and bad movie reviews for the good and bad sentiment respectively.  

To try it out, just enter the command

```
moon test.moon "the statement you are testing"
```

