# shkit

### requirements
- most of the libs in shkit depends only on /bin/sh
- "lines" library requires pcregrep

### debug.subr
To use debug.subr after including it in your file, You need to set DEBUG env variable. Example usage:
```sh
debug "section1" "some text to print"
debug "section2" "some text to print"
debug "section1" "some text to print"
debug "section2" "some text to print"
```
You should see nice and colored output for each section.

### lines.subr
| Function | Description |
| --- | --- |
| `check_line $filename $pattern` | check if regex $pattern line exists in $filename |
| `insert_before $filename $pattern $text` | insert $text into $filename before regex $pattern |
| `insert_after $filename $pattern $text` | insert $text into $filename after regex $pattern |
| `fix_eof_line $filename` | insert empty line at the end of the file - if doesn't exists |
| `update $filename $pattern $text` | replace $pattern in $filename with $text |

and the most awesome:

| Function | Description |
| --- | --- |
| `upsert_before $filename $pattern $text $pattern2 $text2` | if $pattern doesn't exist insert $text2 before $pattern2 regex otherwise replace $pattern in $filename with $text |
| `upsert_after $filename $pattern $text $pattern2 $text2` | (not implemented yet) |

```
sample usage of upsert_before:
$filename  = $pf = /etc/pf.conf
$pattern  = "ext_if=.*" - update stage, we are using this regex to find the line we want to update
$text     = 'ext_if="hn0"' - paste this text in place of the line founded by $pattern
$pattern2 = "^(.*=|set|scrub|table|nat|rdr|pass|block)" - find block before which we will paste $text2
$text2    = "# INTERFACES\\......" - text which will be pasted in place which was found by $pattern2

upsert_before $pf "ext_if=.*" 'ext_if="hn0"' "^(.*=|set|scrub|table|nat|rdr|pass|block)" "# INTERFACES\\
ext_if=\"hn0\"\\
\\
"
```

### array
We are assuming, that arrays is a string where each words represents an item of array.
For example: "foo bar baz", is an array of three items.

array_random "foo bar baz" - random word should be returned

## what it does to your files?
reference (r&d doc): https://gist.github.com/krzysztofantczak/ab3233ec700c27f2f59222653656cde6

/etc/pf.conf content
```
nat on

rdr on
```

```sh
DEBUG=* ./test1.sh
```

output
```
20:15:36 fixeof     fixing missing line
20:15:36 before     MSIZE: 3
20:15:36 before     inserting at line: 1
20:15:36 after      MSIZE: 2
20:15:36 after      inserting at line: 3
20:15:36 after      MSIZE: 8
20:15:36 after      inserting at line: 9
20:15:36 before     MSIZE: 11
20:15:36 before     inserting at line: 11
20:15:36 after      MSIZE: 12
20:15:36 after      inserting at line: 13
# INTERFACES
ext_if="hn0"

# NAT
nat on $ext_if from ($jls_if:network) to ! ($jls_if:network) -> ($ext_if:0)
nat on $int_if from ($jls_if:network) to ! ($jls_if:network) -> ($int_if:0)

nat on
# /NAT

# REDIRECTS
rdr on
# /REDIRECTS

# PASS
#
```

after running the same command again:
```
20:18:28 after      already patched, skipping...
20:18:28 before     already patched, skipping...
20:18:28 after      already patched, skipping...
# INTERFACES
ext_if="hn0"

# NAT
nat on $ext_if from ($jls_if:network) to ! ($jls_if:network) -> ($ext_if:0)
nat on $int_if from ($jls_if:network) to ! ($jls_if:network) -> ($int_if:0)

nat on
# /NAT

# REDIRECTS
rdr on
# /REDIRECTS

# PASS
#

```
