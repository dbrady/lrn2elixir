# Case, Cond and If

Notes from http://elixir-lang.org/getting-started/case-cond-and-if.html

# Case

Compare against many patterns. Note again that we are _matching_, not testing
equality, which means we can play assignment games.

```
iex(1)> case {1, 2, 3} do
...(1)>   {4, 5, 6} ->
...(1)>     "This clause won't match"
...(1)>   {1, x, 3} ->
...(1)>     "This clause will match and bind x to 2 in this clause"
...(1)>   _ ->
...(1)>     "This clause would match any value"
...(1)> end
"This clause will match and bind x to 2 in this clause"
```

Note that x is bound to 2 but only _in this clause:_

```
iex(2)> x
warning: variable "x" does not exist and is being expanded to "x()", please use
parentheses to remove the ambiguity or change the variable name
  iex:2

  ** (CompileError) iex:2: undefined function x/0
```

If you want to pattern match against an existing variable, remember to pin it
with `^`:

```
iex(1)> x = 1
1
iex(2)> case 10 do
...(2)> ^x -> "Won't match"
...(2)> x -> "Will match, but will bind x to #{x}"
...(2)> _ -> "Will match"
...(2)> end
"Will match, but will bind x to 10"
iex(3)> "But back outside the clause, x goes back to #{x}"
"But back outside the clause, x goes back to 1"
```

Clause allow extra conditions to be specified via guards:

```
iex(4)> case {1, 2, 3} do
...(4)>   {1, x, 3} when x > 0 -> "Will match"
...(4)>   _ -> "Would match if guard clause were not satisfied"
...(4)> end
"Will match"
```

## Expressions in guard clauses

Elixir "imports and allows" the following expressions in guards by default:

* Comparison operators (`==`, `!=`, `===`, `!==`, `>`, `>=`, `<`, `<=`)
* boolean operators (`and`, `or`, `not`)
* arithmetic operations (`+`, `-`, `*`, `/`)
* arithmetic unary operators (`+`, `-`)
* binary concatenation operator (`<>`)
* the `in` operator as long as the right side is a range or a list
* all of the following type check functions:
  * `is_atom/1`
  * `is_binary/1`
  * `is_bitstring/1`
  * `is_boolean/1`
  * `is_float/1`
  * `is_function/1`
  * `is_function/2`
  * `is_integer/1`
  * `is_list/1`
  * `is_map/1`
  * `is_nil/1`
  * `isnumber/1`
  * `is_pid/1`
  * `is_port/1`
  * `is_reference/1`
  * `is_tuple/1`
* plus these functions:
  * `abs(number)`
  * `binary_part(binary, start, length)`
  * `bit_size(bitstring)`
  * `byte_size(bitstring)`
  * `div(integer, integer)`
  * `elem(tuple, n)`
  * `hd(list)`
  * `length(list)`
  * `map_size(map)`
  * `node()`
  * `node(pid | ref | port)`
  * `rem(integer, integer)`
  * `round(number)`
  * `self()`
  * `tl(list)`
  * `trunc(number)`
  * `tuple_size(tuple)`

Additionally, users may define their own guards. For example, the Bitwise module
defines guards as  functions and operators: `bnot`, `~~~`, `&&&`, `bor`, `|||`,
`bxor`, `^^^`, `bsl`, `<<<`, `bsr`, `>>>`.

Note that while boolean operators such as `and`, `or`, `not` are allowed in
guards, the more general operators `&&`, `||`, and `!` are _not_.

Keep in mind that errors in guards do not leak but instad make the guard
fail. This means that e.g. an ArgumentError in a guard clause will not be
reraised; the guard clause will just fail.

```
iex(6)> case 1 do
...(6)> x when hd(x) -> "Won't match because ArgumentError"
...(6)> x -> "Got #{x}"
...(6)> end
"Got 1"
iex(7)> hd(1)
** (ArgumentError) argument error
    :erlang.hd(1)
```

If none of the clauses match, an error is raised (so you'd better cover the
pattern space or else have a \_ matcher at the end).

```
iex(7)> case :ok do
...(7)> :error -> "Won't match"
...(7)> end
** (CaseClauseError) no case clause matching: :ok
```

Note anonymous functions can also have multiple clauses and guards. Also notice
that the function doesn't declare a case, it simply IS one (and it matches
against its received arguments):

```
iex(7)> f = fn
...(7)> x, y when x > 0 -> x + y
...(7)> x, y -> x * y
...(7)> end
#Function<12.118419387/2 in :erl_eval.expr/5>
iex(8)> f.(1, 3)
4
iex(9)> f.(-1, 3)
-3
```

Also note that case statements can match multiple arities but anonymous
functions cannot:

```
# Mixed arity in a case is :ok
iex(10)> case {1,2,3} do
...(10)> {a} -> "Matches #{a}"
...(10)> {a, b} -> "Matches #{a}, #{b}"
...(10)> {a, b, c} -> "Matches #{a}, #{b}, #{c}"
...(10)> _ -> "Matches nothing"
...(10)> end
"Matches 1, 2, 3"

# Mixed arity in a function is :error
iex(11)> f2 = fn
...(11)> x, y -> x * y
...(11)> x, y, z -> x * y * z
...(11)> end
** (CompileError) iex:11: cannot mix clauses with different arities in function definition
```

# Cond

Case is good for matching something against multiple patterns, but what if you
don't have a "something" to match, and simply want to find the first condition
that evaluates to true? Enter `cond`:

```
iex(1)> cond do
...(1)> 2 + 2 == 5 -> "Nope"
...(1)> 2 * 2 == 3 -> "Still nope"
...(1)> 1 + 1 == 2 -> "Nnnnkidding, this works"
...(1)> end
"Nnnnkidding, this works"
```

Like `case`, you'll get an error (`CondClauseError` in this case) if none of the
conditions evaluates to true, so like matching against \_ in a case, you might
need to have a final conditon that simply reads `true -> ...`

`cond` will evaluate single items for truthiness, but have a care as errors are
leaky, e.g. trying to skip over `tl([])` won't work; it'll blow up.

# if and unless

Besides `case` and `cond`, Elixir also provides the macros `if/2` and `unless/2`
which are useful when you need to check for only one condition:

```
iex(4)> if true do
...(4)>   "This works"
...(4)> end
"This works"
iex(5)> unless false do
...(5)>   "This also works"
...(5)> end
"This also works"
```

# do/end blocks

Note: `if/2` is a macro and has wackyfun details that I don't understand. The
macro takes the block and expands it to a keywoard list, which is apparently
"Elixir's regular syntax". For example:

`if foo, do: bar, else: baz`

It turns out that do/end blocks are syntactic sugar built on top of the keywords
one.

The other gotcha is to remember that do/end is automatically bound to the
_outermost_ function call. This is a syntax error:

```
iex(7)> is_number if true do
...(7)> 1+2
...(7)> end
** (CompileError) iex:7: undefined function is_number/2
```

The good news is, like in Ruby, you can get around this with explicit parens:

```
iex(7)> is_number(if true do
...(7)> 1 + 2
...(7)> end)
true
```
