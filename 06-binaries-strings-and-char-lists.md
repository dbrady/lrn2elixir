# Binaries, Strings and Char Lists

# UTF-8

Elixir uses it. That is all you really need to know here.

# Binaries (and bitstrings)

Use `<<>>` to define a binary. Also a common trick in Elixir is to append the
null byte to a string to see its inner binary representation:

```
iex(1)> "hello" <> <<0>>
<<104, 101, 108, 108, 111, 0>>
iex(2)> "💩" <> <<0>>
<<240, 159, 146, 169, 0>>
```

Each number given to a binary is meant to represent a byte and therefore must go
up to 255. Binaries allow modifiers to be given to store numbers biggers than
255 or to convert a code point to its UTF-8 representation:

```
iex(1)> <<255>>
<<255>>
iex(2)> <<256>> # truncated
<<0>>
iex(3)> <<256 :: size(16)>> # use 16 bits to store the number
<<1, 0>>
iex(4)> <<256 :: utf8>> # the number is a code point
"Ā"
iex(5)> <<256 :: utf8, 0>>
<<196, 128, 0>>
iex(6)> # ^ representation and concatenation? So representation happens at each
number?
nil
iex(7)> <<256 :: size(16), 256 :: size(32)>>
<<1, 0, 0, 0, 1, 0>>
iex(8)> # YUP.
nil
```

Q. What happens if we pass *smaller* sizes?
A. The sizes stay with the representation:

```
iex(1)> <<1 :: size(1)>>
<<1::size(1)>>
iex(2)> <<0::size(1)>> # truncates to 0
<<0::size(1)>>
iex(3)> is_binary(<<1::size(1)>>)
false
iex(4)> # wat
nil
iex(5)> is_bitstring(<<1::size(1)>>)
true
iex(6)> # wat... ok. binary != bitstring
nil
iex(7)> # and perhaps binary ~~ string
nil
iex(8)> bit_size(<<1::size(1)>>)
1
iex(9)> bit_size(<<1::size(1), 0::size(1), 1::size(1)>>)
3
```

Okay. Binary !~~ string. Binary simply means bitstring with a size modulo 8.

We can match on bitstrings and binaries:

```
iex(10)> <<0, 1, x>> = <<0, 1, 9>>
<<0, 1, 9>>
iex(11)> x
9
```

...but size matters:

```
iex(12)> <<0, 1, x>> = <<0, 1, 4, 9>>
** (MatchError) no match of right hand side value: <<0, 1, 4, 9>>
```

EXCEPT... okay, see, each element in a binary is meant to be 8 bits. Arity can
go out the window if you simply declare x to be a binary, meaning it can collect
the rest of the bitstring... but only if it has a multiple of 8 bits:

```
iex(14)> <<0, 1, x :: binary>> = <<0, 1, 4 :: size(3), 9 :: size(5)>>
<<0, 1, 137>>
iex(15)> <<0, 1, x :: binary>> = <<0, 1, 4 :: size(3), 9 :: size(4)>>
** (MatchError) no match of right hand side value: <<0, 1, 73::size(7)>>
```

...or declare it as a bitstring and screw it, you can have whatever you want:

```
iex(15)> <<0, 1, x :: bitstring>> = <<0, 1, 4 :: size(3), 9 :: size(4)>>
<<0, 1, 73::size(7)>> # BOOM. 7 bits, y'all
```

And yes, concatenation of strings works with matching:

```
iex(16)> "FirstName: " <> name = "FirstName: Dave"
"FirstName: Dave"
iex(17)> name
"Dave"
```

Crazy.

# Char Lists

A char list is nothing more than a list of code points. Create them with
single-quoted literals, e.g.. `'hello'`.

`is_list('hello')` returns true.

Char lists are used frequently in Erlang, as it does not support binaries. To
interact with existing Erlang libraries, make use of `to_string/1` and
`to_charlist/1` to convert back and forth.
