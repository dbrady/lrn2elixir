# Basic Operators

My notes from [http://elixir-lang.org/getting-started/basic-operators.html](http://elixir-lang.org/getting-started/basic-operators.html)

* Arithmetic: `+`, `-`, `*`, `/`, `div/2` and `rem/2`
* Lists: `++/2`, `--/2`
* String Concatenation: `<>/2`

# Boolean operators

Yay!

* Just like Ruby, we have `&&/||/!` and `and/or/not`!
* Just like Ruby, they mean different things!
* _BUT THEY MEAN **DIFFERENT** DIFFERENT THINGS!_
* TL;DR in Ruby the words have lower operator precedence than the symbols. In
  Elixir the words work exclusively with booleans, while the symbols are
  tolerant of any object e.g. false and nil are falsey, everything else is
  truthy.
* Just like Ruby, the last value in a successful chain will be returned
* Just like Ruby, only nil and false are falsey
* Just like Ruby, 0 is truthy
* Just like Ruby, if a short-circuit stops at nil or false, it will return nil
  or false respectively, e.g. `0 && 3 && false` evaluates to false, while `0 &&
  3 && nil` evaluates to nil. You probably didn't know Ruby did that. I
  certainly didn't. I only noticed right now when I was checking, because now
  with Erlang _it actually matters_.

Here's how the spelled-out-word boolean operators throw down with non-boolean
types:

```
iex(11)> 5 and true
** (BadBooleanError) expected a boolean on left-side of "and", got: 5
```

`not` does the same thing on the right-hand side but it's an ArgumentError
because syntax:

```
iex(11)> not 3
** (ArgumentError) argument error
    :erlang.not(3)
```

`or` and `and` both short-circuit.

(If you recall your erlang, these map directly to `andalso` and `orelse`
operators in Erlang.)

# Comparison Operators

The usual suspects. `==`, `!=`, `===`, `!==`, `<`, `>`, `<=`, `>=`.

`==` checks same value regardless of type; e.g. `1 == 1.0` is true
`===` requires same value AND same type: `1 === 1.0` is false

Comparison is _very_ forgiving. You might get false, but you probably won't get
an error. You can compare strings to numbers to atoms to lists. Just keep in
mind that they group together regardless of value. For example, numbers are the
least of all classes. There is no integer that will sort larger than a string
containing a number:

```
iex(24)> 1000000000 < "42"
true
```

The object sort order is: `number < atom < reference < function < port < pid,
tuple < map < list < bitstring`

# Further Details

Check out the [Operator Reference](https://hexdocs.pm/elixir/master/operators.html)

There's a bunch more operators coming, like `&&&` and `|>` and `~~~`.
