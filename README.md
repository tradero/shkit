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
