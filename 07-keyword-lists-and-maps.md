# Keyword Lists and Maps

Welcome to associative data types (hashes, dictionaries, associative arrays,
etc) in Elixir!

# Keyword List

Ruby Equivalent: arrays of pairs, accessed with assoc and rassoc, etc.

A Keyword List in Elixir is a `List` made up of `Tuples` such that each tuple
contains two elements and the first element is an atom:

```
iex(1)> list = [{:a, 42}, {:b, 13}]
[a: 42, b: 13]
iex(2)> list == [a: 42, b: 13]
true
```

The array with key: val sequences appears to be syntactic sugar.

Because they're lists, you manipulate them like lists, e.g. `++` to add a new
item:

```
iex(3)> list ++ [c: 69]
[a: 42, b: 13, c: 69]
```

And the removal thing works the same as with lists and arrays:

```
iex(7)> list2 = list ++ [c: 69]
[a: 42, b: 13, c: 69]
iex(8)> list2 -- [b: 13]
[a: 42, c: 69]
```

Because these work like associative arrays, my money says the keys are not
unique. Testing...

```
# YUP!
iex(9)> list2
[a: 42, b: 13, c: 69]
iex(10)> list2 ++ [a: 14, a: 66]
[a: 42, b: 13, c: 69, a: 14, a: 66]

# And the subtraction is also nonunique:
iex(12)> list3 = list2 ++ [a: 42, a: 66] # add another a: 42
[a: 42, b: 13, c: 69, a: 42, a: 66]      # now we have 2
iex(13)> list3 -- [a: 42]                # take one away
[b: 13, c: 69, a: 42, a: 66]             # still have one left
```

Elixir provides the same "last argument to a function can be a hash without
brackets" thing as Ruby, but because Erlang favors immutability and recursive
list traversal, Elixir does it with keywoard lists instead of hashes, and it's
the square brackets that can be omitted, not the curlies.

A bonus to this, however, is that to build up an OO DSL like
ActiveRecord::Relation, you can do it all in one function and just handle the
keyword list in sequence. Here's an Ecto database query:

```
query = from w in Weather,
    where w.precipitation > 0,
    where w.temp > 20,
    select: w
```

Even more importantly, the `if` function in Elixir is a macro wrapped around a
boolean expression, and the `then` and `else` clauses are part of a keyword
list:

```
iex> if false, do: :this, else: :that
:that
```

Manipulating keyword lists is tons of fun and a major whizbang geewhiz of
Elixir. You'll want to look at the `Keyword` module for the various methods you
can call and use. For example, Ruby's `Array#assoc(arg)` method, which returns
the first array that whose first element matches `arg`, has a twin in
`Keyword.get`. Some differences present themselves, however: Interestingly,
there is no cognate for `Array#rassoc(arg)` (which returns the first array whose
_last_ element matches `arg`). Also in Ruby the arrays can have any number of
elements, allowing you to hide extra data in the middle of each subarray. Also,
Ruby sort of begins and ends with `assoc` and `rassoc` because this type of data
access is quite out of favor in the Ruby world. In Elixir, however, where there
are only two types of primary collections (Lists and Arrays), there are also
only two primary associative collections, and Keyword Lists are the "List"
version of this. (Maps are the Array version--think Hashes and you've got the
idea.) Because Keyword Lists are a fairly primary data type, the `Keyword`
module presents loads of methods. Use `h Keyword` for the full list, but for
example here's some of the ways you can read keyed information:

```elixir
fetch(keywords, key)               # returns {:ok, value} or :error
fetch!(keywords, key)              # returns value or raises KeyError
get(keywords, key, default \\ nil) # returns value or default (or nil)
get_and_update(keywords, key, fn)  # this one's too bizarro to believe. I can

                                   # only assume it has real use
                                   # somewhere. Okay, so fn receives the value
                                   # (rhs of the pair), and must return a pair
                                   # tuple. The return value from get_and_update
                                   # is a pair tuple. The first element is the
                                   # same as the first element returned from
                                   # fn. The second element is the entire
                                   # keywords list, but with the value for the
                                   # given key updated to be the second element
                                   # returned from fn. Clear as mud? Check it
                                   # out:
kwlist
# => [a: 42, b: 13, a: 42, b: 13, a: 66, b: 66, a: 12, a: 13, a: 9]
Keyword.get_and_update(kwlist, :a, fn value -> {value*3, value*2} end)
# => {126, [a: 84, b: 13, a: 42, b: 13, a: 66, b: 66, a: 12, a: 13, a: 9]}
#      ^        ^
#      |        |
#      |       Here's the first :a tuple updated with the rhs, value*2
#     And here's the lhs, value*3
```

There's lots more. `take` and `pop` and `split`, and still these are all just
ways to select and read data. There's loads of ways of updating and editing as
well. Just remember a couple of key Erlang concepts that are always lurking
under the hood:

1. You never really update anything. When you change the list, you are actually
   getting a new list.
2. Keyword Lists are _Lists_, which means operations on them happen in linear
   time and can get expensive when the list is large.

# Maps

Welcome to hashes! Er, maps! Elixir maps are like the old-school C hashes we
learned in CS 200. Specifically that the key actually gets _hashed_ to find a
bin and that means that means that old blast from the past "hashes have no
defined enumerable order" comes a-rollin' back around on the guitar.

Create a map with `%{}`. Keys can be anything hashable, e.g. `%{:a => 2, 2 =>
:b}`.

Maps are very match-friendly, and will match on a subset of a map:

```

iex(1)> h = %{:a => 1, 2 => :b}
%{2 => :b, :a => 1}
iex(2)> h[:a]
1
iex(3)> h[2]
:b
iex(4)> h[:c]
nil
iex(5)> %{} = h           # this matches because %{} is a subset of ANY map
%{2 => :b, :a => 1}
iex(6)> %{:a => a} = h    # this matches with capture
%{2 => :b, :a => 1}
iex(7)> a
1
iex(8)> %{3 => c} = h     # but you gotta match at least ONE pair to match
** (MatchError) no match of right hand side value: %{2 => :b, :a => 1}
```

The `Map` module provides a very similar API to the `Keyword` module,
e.g. `get` and `fetch` and `get_and_update`, etc.

Maps can be updated with this totally batshit syntax:

`%{map | old_key => new_value}`

But again, remember: this is Erlang. Modify _means copy_.

```
iex(10)> h = %{2 => :b, :a => 1}
%{2 => :b, :a => 1}
iex(11)> %{h | 2 => :c}
%{2 => :c, :a => 1}
iex(12)> h
%{2 => :b, :a => 1} # Modify means copy, yo
```

Maps also provide Fetching- or Hashie-like access, where if the key is present
and an atom, you can access it almost like a function call:

```
iex(13)> h.a
1
iex(14)> h.2    # integer != atom
** (SyntaxError) iex:14: syntax error before: 2
```

# Nested Data Structures

Here we go. It's time for lists of maps and maps of lists of maps of maps of
lists of lists and so on, all the way down...

But wait. There's also cool functions for manipulating these structures. This
harks back to FP's love for bare data structures instead of Objects.
