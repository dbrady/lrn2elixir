# Learn To Elixir: Notes

* iex ~~ irb
* elixir <filename> ~~ ruby <filename>
* elixirc ??? (compiler?)

# Basic Types

``` elixir
1         # integer
0x1F      # integer as hex
1.0       # float
true      # boolean (note: booleans are atoms)
:atom     # atom / symbol
"elixir"  # string
[1, 2, 3] # list
{1, 2, 3} # tuple
```

There are `is_<type>` methods for all of these but one: `is_integer/1`, `is_float/1`,
`is_boolean/1`, `is_atom`, `is_list`, `is_tuple` all work.

`is_string` does not exist:

```
iex(8)> h is_string/1
No documentation for is_string/1 was found
```

This seems to be because strings are represented internally in Elixir as
binaries, which are a sequence of bytes:

```
iex(26)> is_binary "hello"
true
```

There are others, however:

* `is_number/1` returns true if the argument is a float or an integer.
* `is_function/1` returns true if the argument is a reference/pointer to a
  function.
* `is_function/2` takes a var and an arity, and returns true if the argument is
  a reference or pointer to a function of that arity

# String are UTF-8

Just saying.

```
iex(1)> is_binary "¿Qué?"
true
iex(2)> byte_size "¿Qué?"
7
```

The word "¿Qué?" is 7 bytes in UTF-8 because ¿ and é are both 2-byte Unicode
sequences.

(Windows users may need to run chcp 65001 before entering iex to make things
display correctly.)

You can get a string's code point with `?`:

```
iex> ?a
97
iex> ?¿
191
iex> ?é
233
```

And then sanity returns: `String.length/1` returns the count of printable
characters, not bytes:

```
iex(7)> String.length "¿Qué?"
5
```

Elixir either treats strings pretty weirdly, or super awesomely, or possibly
both. It passes all of the tests in the
article
[The String Type Is Broken](https://mortoray.com/2013/11/27/the-string-type-is-broken/),
but if you actually click through you'll see it's an article about Elixir, not
about general strings. Anyway, some of the more common, but possibly ambiguous,
string operations, are broken. Given the other data type tests I'd expect
`is_string` to be a thing, but it's not. Also, to split a string up into strings
of one letter each, you use `String.codepoints/1`, not split:

```
iex(12)> String.codepoints "¿Qué?"
["¿", "Q", "u", "é", "?"]

```

Note that "noël" is gonna be a weird sucker anyway, because the e is present as
its own character, while the dieresis is presented as a unicode escape that says
"hey, print a dieresis, but do it over the preceding character, thank you
kindly". This is why "noël" turns out to be 6 bytes instead of 5:

```
iex(16)> byte_size "noe\u0308l"
6
iex(17)> String.codepoints "noe\u0308l"
["n", "o", "e", "̈", "l"]

```

Ruby very nearly gets this one right, splitting cleanly exactly the way we'd
expect, but when it reverses the string it does so quite naively, reversing the
e and the dieresis separately, which puts the dots above the l:

```
# Ruby
2.3.1 :010 > "noe\u0308l".split(//)
 => ["n", "o", "e", "̈", "l"]
 2.3.1 :011 > "noe\u0308l".reverse
  => "l̈eon"
```

Elixir feels clunky to me at first blush, but I have to admit it gets it right:

```
iex(20)> String.codepoints "noe\u0308l"
["n", "o", "e", "̈", "l"]
iex(21)> String.reverse "noe\u0308l"
"lëon"
```

# Math

Watch out: `//2` always returns a float. So 10 / 2 returns 5.0 and 10 / 3 returns
3.3333333333333335, not 5 and 3 respectively.

Use `div/2` for integer division and `rem/2` for modulo.

```
iex(1)> 10 / 2
5.0
iex(2)> div 10, 2
5
iex(3)> rem 10, 3
1
```

# Functions and Help

Describe functions by name and arity, e.g. `round/1` takes 1 argument while
`round/2` takes 2 arguments (and also does not exist, but if it did might accept a
precision or perhaps a rounding method as the second argument).

h() is the help function. `h/0` displays general help while `h/1` displays
documentation about a given function, e.g.

```
iex> h              # displays all help
iex> h is_integer/1 # displays help for is_integer(x)
iex> h ==/2         # displays help for x == y
```

i() is the info function. `i/1` displays info about a given variable:

```
iex> i 5.0
Term
  5.0
  Data type
    Float
    Reference modules
      Float
      Implemented protocols
        IEx.Info, Inspect, List.Chars, String.Chars
```

# Anonymous Functions

Exist, and can be created inline. Oh, _joy._

_Anonymous functions, usually written by other programmers, and containing
complicated logic and inevitably bugs, are on my top 10 list of features I
generally consider to be a defect. That said, I've only ever done significant
work with them in OO languages, procedural languages, and whatever JavaScript
is._

Anyway. In Elixir, we create them with `fn ... end`. They work like regular
functions but appear to have a weird invocation, requiring a dot and
parens. (Possibly because add is a variable, and waitaminute--I'm back in a
language with first-class functions! WOOT! DAY I GET FUNCSHAN POINTERZ)

```
iex(1)> add = fn a, b -> a + b end
#Function<12.118419387/2 in :erl_eval.expr/5>
iex(2)> add.(1, 2)
3
iex(3)> is_function add
true
iex(4)> is_function add, 2
true
iex(5)> is_function add, 1
false
iex(6)> add 1, 2
** (CompileError) iex:6: undefined function add/2
```

Okay, this IS nice: the dot is required because while functions are first-class
citizens, _anonymous_ functions _are not_. You can have a named function `add/2`
that exists simultaneously here. `add 1, 2` will only ever invoke the named
function, and `add.(1, 2)` will only ever invoke the anonymous one.

I want to hate this because I saw it abused so much in JavaScript, but
technically this does come directly from Scheme and LISP: You can define and
invoke in one go:

```
iex(10)> (fn a, b -> a * b end).(2, 3)
6
```

Anonymous functions form closures that can access surrounding vars, but they
cannot _modify_ surrounding state or vars:

```
iex(11)> y = 16
16
iex(12)> x = 42
42
iex(13)> (fn -> x = 3; x * y end).()
48
iex(14)> x
42
```

# (Linked) Lists

Square brackets create a list. Elements can be of any type.

They can be concatenated and subtracted with `++/2` and `--/2`. Note that `--/2`
does NOT work like Ruby! It removes each element once only:

```
# Ruby
2.3.1 :012 > [1,2,3,1,2,3,1,2,3] - [2]
 => [1, 3, 1, 3, 1, 3]
```

```
iex(17)> [1,2,3,1,2,3,1,2,3] -- [2]
[1, 3, 1, 2, 3, 1, 2, 3]

```

If you want to remove an element exactly twice, include it twice in the
subtrahend.

They both ignore misses, however: `[1,2,3] -- [4] # => [1,2,3]` -- this works
and does not raise an error or warning.

Note that it removes the first encounter of each element in the subtrahend,
regardless of order:

```
iex(1)> [1, true, 2, false, 3, true] -- [2, true]
[1, false, 3, true]
```

Note the first true was removed before the 2 was encountered.

## heads and tails

TL;DR `hd/1` == `car(list)` and `tl/1` == `cdr(list)`.

The `cdr` and `tl/1` of a single-element list is nil in both Scheme and Elixir
because the single element is the head and there is nothing (nil), BUT! Watch
out:

In Scheme, the `car` and `cdr` of an empty list are _also_ nil, while in Elixir
they are both ArgumentErrors. You can't have a tail without a head, and vice
versa, apparently.

```
iex(3)> tl([])
** (ArgumentError) argument error
    :erlang.tl([])
```

Because strings are binaries, it turns out that binaries are also
strings. That's not weird, right?

```
iex(3)> [104, 101, 108, 108, 111]
'hello'
```

NO WAIT--it's a trick. Notice the single quotes? That's not a string, that's
just a convenient representation of a binary list. "When Erlang sees a list of
printable ASCII numbers, Elixir will print that as a char list (literally a list
of characters). Char lists are quite common when interfacing with existing
Erlang code. Whenever you see a value in IEx and you are not quite sure what it
is, you can use the `i/1` to retrieve information about it."

If you try `i('hello')` you'll see it has Data type of List.

Note: Single- and double-quoted strings are _completely different
beasties_. Strings != Lists.

Lists work like linked lists in memory. They can be carved up, rearranged, split
and spliced without trashing memory. Accessing them by index or getting their
size, however, might be a costly operation. (I don't know how Elixir implements
them; I'd expect in 2017 they'd have a management block, I don't know if they'd
rather burn _O(n)_ counting up elements or burn the extra operations updating
the management block each time. Plus I don't know if any of this makes sense in
an FP world.) Update: from later on in the docs: sounds like they don't have a
management block. Updating lists is fast as long as we are fiddling with the
head, but mucking about at the tail of the list requires traversing the list.

# Cons Cells

Yup. Why hello there, LISP.

`[ x | y ]` is loosely akin to LISP's `(x . y)`. You can build a list the hard
way, e.g.

```
iex> list = [ 1 | [ 2 | [ 3 | []]]]
[1, 2, 3]
iex> [0 | list]
[0, 1, 2, 3]
```

# Tuples

Curly brackets denote tuples. Like lists the elements can be of any type. Tuples
are contiguous in memory (think of them like arrays, then). Indexes start from
zero. This makes sequential access and indexing fast.

```
iex(5)> i 5.0
Term
  5.0
  Data type
    Float
    Reference modules
      Float
      Implemented protocols
        IEx.Info, Inspect, List.Chars, String.Chars
```

Use `put_elem/3` to overwrite an element with a new value, but remember that
Elixir, like Erlang, only lets you set a variable once. `put_elem/3` is going to
give you back a whole new tuple. Any references to the existing tuple must
remain unchanged.

```
iex(5)> put_elem tuple, 1, "world"
{:ok, "world"}
iex(6)> tuple
{:ok, "hello"}

```

Note that you cannot grow the tuple with `put_elem/3`, you'll get an
ArgumentError if you try:

```
iex(5)> tuple2 = put_elem tuple, 2, "world"
** (ArgumentError) argument error
    :erlang.setelement(3, {:ok, "hello"}, "world")
```

# Lists vs. Tuples

Getting the size of a tuple or accessing an arbitrary element by index is very
fast. Indexing into a list or getting its size is a linear O(n)
operation. Manipulating a list is fast if you do it at the head. Manipulating a
tuple is always slow because it requires that the entire tuple be copied each
time.

NOTE: Only _prepending_ elements was mentioned. I do not know what happens in
Elixir if you try to shift the head off a list. I expect nothing happens, you
just get a new pointer to the cdr. I believe the list itself remains immutable
until it gets garbage collected.

Hmm, this would also mean that manipulating the last element of a list would
_also_ require copying the list!

push and pop are dead, long live unshift and shift!
