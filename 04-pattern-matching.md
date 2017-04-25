# Pattern Matching

# Match Operator

`=` is actually called the _match_ operator, and this is where Elixir starts to
get weird:

```
iex(1)> x = 1
1
iex(2)> 1 = x
1
iex(3)> 2 = x
** (MatchError) no match of right hand side value: 1
```

`1 = x` is a valid operation because 1 _matches_ x.

No, before you ask: you cannot assign a variable on the right-hand side. If `x`
was not set to 1, you would not get a MatchError, but instead a CompileError
because Erlange thinks you're trying to call a function `x/0`.

But yes, _matching_ against an unknown variable, with the variable on the
left-hand side, will perform assignment. This is funky and weird and cool
because you can match tuples and lists in Erlang the same way you match arrays
in Ruby, but this is called _Pattern Matching_.

# Pattern Matching

```
iex(4)> {a, b, c} = {:hello, "pants", 42}
{:hello, "pants", 42}
iex(5)> a
:hello
iex(6)> b
"pants"
iex(7)> c
42
```

...which presumably means that we can start doing some really funky stuff with
partially-explicit tuples. This works, and that's cool, but I don't know if it's
useful (presumably we'd want to catch the MatchError if "pants" didn't match):

```
iex(8)> {d, "pants", e} = {:hello, "pants", 42}
{:hello, "pants", 42}
iex(9)> d
:hello
iex(10)> e
42
```

(Okay, yep, a later example has a pattern match like `{:ok, result} = {:ok,
13}`, so I presume we're building up to the (in)famous Erlang pattern-matching
method dispatch stuff.)

MatchError will show up if the tuples are different sizes, but the debug message
could possibly be less cryptic--unless size mismatches are so common in the real
Elixir world that they don't deserve a special error message?

```
iex(1)> {a, b, c} = {:hello, "pants"}
** (MatchError) no match of right hand side value: {:hello, "pants"}
```

You can match lists the same way, too: `[a, b, c] = [1, 2, 3]`

But here's a weird one: lists support matching on their own head and tail:

```
iex(1)> [head | tail] = [1, 2, 3]
[1, 2, 3]
iex(2)> head
1
iex(3)> tail
[2, 3]
```

Nifty!

Now here's a bit I don't understand yet but I suspect it's an important
statement of how things work under the hood: "The `[head |tail]` format is not
only used on pattern matching but also for prepending items to a list:

```
iex> list = [1, 2, 3]
[1, 2, 3]
iex> [0 | list]
[0, 1, 2, 3]
```

Now presumably, that `[0 | list]` all by itself on a line is significant. I
don't see a `=` anywhere in there, but Erlang or Elixir may be pattern-matching
against :[, :element, :|, list, :] or similar.

# Pin

Variables in Elixir can be rebound:

```
iex> x = 1
1
iex> x = 2
2
```

But what do you do if you want to _match_ against x instead of rebinding it, and
don't want to stick it on the right-hand-side (for example because there's a
rebindable variable on that side, too)? Answer: you pin the variable with ^.

```
iex(1)> x = 1
1
iex(2)> ^x = 2
** (MatchError) no match of right hand side value: 2

iex(2)> {y, ^x} = {2, 1}
{2, 1}
iex(3)> y
2
iex(4)> 1
1
```

So here's another weirdfun one: if you mention a variable on the left-hand side,
it gets assigned, right? But what happens if you mention it more than once?
Answer: it's a match, which means that all the instances must match the same
value. Assignment still happens, but all the instances must be the same.

```
iex(1)> {x, x} = {1, 1}
{1, 1}
iex(2)> {y, y} = {1, 2}
** (MatchError) no match of right hand side value: {1, 2}
```

# Underscore

The exception to this rule is the underscore. Underscore matches anything,
cannot be read back from, and if it appears more than once, does not have to be
the same variable:

```
iex(2)> [_, z, _] = [1, 2, 3]
[1, 2, 3]
iex(3)> z
2
iex(4)> _
** (CompileError) iex:4: unbound variable _
```

Note that Elixir does something different when it sees an unknown value _other_
than the underscore:

```
iex> q
warning: variable "q" does not exist and is being expanded to "q()", please use
parentheses to remove the ambiguity or change the variable name
  iex:4

  ** (CompileError) iex:4: undefined function q/0
```

The one big exception to all this is that you cannot make method calls on the
left-hand-side of a match:

```
iex(4)> length([1, [2], 3])
3
iex(5)> 3 = length([1, [2], 3])
3
iex(6)> length([1, [2], 3]) = 3
** (CompileError) iex:6: illegal pattern
```

...so there's that. :/
