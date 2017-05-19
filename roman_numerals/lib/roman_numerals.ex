defmodule RomanNumerals do
  @moduledoc """
  CLI script
  """

  def main(args) do
    hd(args) |> String.to_integer |> int_to_roman(length(args)>1) |> puts
  end

  def puts(item) do
    IO.puts inspect(item)
  end

  def int_to_roman(number, space_numerals_out \\ false) do
    glue = if space_numerals_out, do: " ", else: ""
    roman_digitize(number) |> List.flatten |> Enum.join(glue)
  end

  def roman_digitize(number) when number >= 4_000_000, do: raise "Number too large to be expressed by Romans; await fall of Rome, invent Algebra, or retry with Sumerian-based counting system"
  def roman_digitize(number), do: roman_digitize(number, 0)
  def roman_digitize(0, 0), do: ""
  def roman_digitize(number, power) when number >= 10, do: [roman_digitize(div(number, 10), power+1)] ++ [roman_digitize(rem(number, 10), power)]
  def roman_digitize(digit, power) do
    table = %{
      0 => [],           #
      1 => [0],          # I
      2 => [0, 0],       # II
      3 => [0, 0, 0],    # III
      4 => [0, 1],       # IV
      5 => [1],          # V
      6 => [1, 0],       # VI
      7 => [1, 0, 0],    # VII
      8 => [1, 0, 0, 0], # VIII
      9 => [0, 2]        # IX
    }

    digits = "IVXLCDMV̅X̅L̅C̅D̅M̅"


    table[digit] |> Enum.map(fn (i) -> String.at(digits, power*2+i) end) |> Enum.join("")
  end
end
