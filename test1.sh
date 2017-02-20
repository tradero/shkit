#!/bin/sh
#set -x

. /root/.salva/shell/array.subr
. /root/.salva/shell/debug.subr
. /root/.salva/shell/lines.subr

check_pf_line () {
	check_line /etc/pf.conf "$1"
}

reset_pf () {
	cp /etc/pf.conf.backup /etc/pf.conf
	return
}

#reset_pf
clear;

pf=/etc/pf.conf
fix_eof_line $pf

upsert_before $pf "ext_if=.*" 'ext_if="hn0"' "^(.*=|set|scrub|table|nat|rdr|pass|block)" "# INTERFACES\\
ext_if=\"hn0\"\\
\\
"

if [ $(check_pf_line 'nat on \$ext_if from \(\$jls_if:network\) to ! \(\$jls_if:network\) -> \(\$ext_if:0\)') -eq 0 ]; then
	insert_after $pf "^(.*=.*|set|scrub|table(\n|.)*table)" "\\
# NAT\\
nat on \$ext_if from (\$jls_if:network) to ! (\$jls_if:network) -> (\$ext_if:0)\\
nat on \$int_if from (\$jls_if:network) to ! (\$jls_if:network) -> (\$int_if:0)\\
"
fi
	insert_after $pf "nat" "# /NAT\\
"
	insert_before $pf "rdr" "# REDIRECTS\\
"
	insert_after $pf "rdr" "# /REDIRECTS\\
\\
# PASS\\
#\\
"
#fi

cat /etc/pf.conf

