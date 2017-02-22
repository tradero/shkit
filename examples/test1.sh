#!/bin/sh
#set -x

. array.subr
. debug.subr
. lines.subr
. string.subr
. escape.subr
. grep.subr
. pf.subr

pf=/etc/pf.conf

reset_pf      $pf
fix_eof_line  $pf

# file manipulation PoC

iface="e"$(ifconfig | egrep "(: flag|inet )" | sed 'N;s/\n/ /' | egrep -v '(lo|vlan)[0-9]:' | sed 's/flags.*inet//' | awk '{ print $1 $2 }' | cut -d: -f1)

upsert_before $pf 'ext_if=.*' 'ext_if="'$iface'"' '^(.*=.*|set|scrub|table|nat|rdr|pass|block)' '# INTERFACES\next_if="'$iface'"\n\n\n'

if [ $(check_pf_line 'nat on $ext_if from ($jls_if:network) to ! ($jls_if:network) -> ($ext_if:0)') -eq 0 ]; then
	insert_after $pf "^(.*=.*|set|scrub|table(\n|.)*table)" "$(join '\n'\
		'\n# NAT'\
		'nat on $ext_if from ($jls_if:network) to ! ($jls_if:network) -> ($ext_if:0)'\
        	'nat on $int_if from ($jls_if:network) to ! ($jls_if:network) -> ($int_if:0)'\
        )"
else
#	echo "skipping nat settings - already set"
fi

insert_after  $pf "nat" "# /NAT"
insert_before $pf "rdr" "# REDIRECTS"
insert_after  $pf "rdr" "# /REDIRECTS\n\n# PASS\n#"


