# From Programming Elixir 1.3 by Dave Thomas

# find the user and group ids for the _lp user it /etc/passwd

# (This script demonstrates the 'with' keyword for binding limiting scope and
# handling matching failures)

content = "Now is the time"

lp = with {:ok, file} = File.open("/etc/passwd"),
          content = IO.read(file, :all),
            :ok = File.close(file),
            [_, uid, gid] = Regex.run( ~r/_lpxx:.*?:(\d+):(\d+)/,content) do
       "Group: #{gid}, User: #{uid}"
     end

IO.puts lp # => Group: 26, User: 26
IO.puts content # => "Now is the time" (line 11 doesn't change it)

# Line 13 will raise a MatchError if that regex doesn't match anything. If we
# change it to use <- instead of =, e.g.
#
# [_, uid, gid] <- Regex.run( ~r/_lpxx:.*?:(\d+):(\d+)/,content) do
#
# It'll return nil instead.
