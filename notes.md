# Learn To Elixir: Notes

* iex ~~ irb
* elixir <filename> ~~ ruby <filename>
* elixirc ??? (compiler?)

# Basic Types

```elixir
1         # integer
0x1F      # integer as hex
1.0       # float
true      # boolean
:atom     # atom / symbol
"elixir"  # string
[1, 2, 3] # list
{1, 2, 3} # tuple
```

# Math

Watch out: 10 / 2 returns 5.0, because / always returs a float. Use `div/2` for
integer division and `rem/2` for modulo.

```
iex(1)> 10 / 2
5.0
iex(2)> div 10, 2
5
iex(3)> rem 10, 3
1
```
