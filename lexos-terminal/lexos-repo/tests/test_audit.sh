#!/usr/bin/env bash
# Teste lexos-audit (validation des cibles, phrase d'autorisation, aucune option dangereuse) avec un faux nmap/curl.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; T="$(mktemp -d)"; mkdir -p "$T/bin" "$T/home"
sed "s#@PREFIX@#$T#g; s#^\#!.*#\#!/usr/bin/env bash#" "$HERE/../src/lexos-core/bin/lexos-audit" > "$T/bin/lexos-audit"; chmod +x "$T/bin/lexos-audit"
printf '#!/bin/sh\necho "FAKE-NMAP $*" >> "%s/calls"\n' "$T" > "$T/bin/nmap"
printf '#!/bin/sh\necho "FAKE-CURL $*" >> "%s/calls"\n' "$T" > "$T/bin/curl"; chmod +x "$T/bin/nmap" "$T/bin/curl"
export HOME="$T/home" PATH="$T/bin:$PATH"; fail=0
ok() { if eval "$2"; then echo "OK   $1"; else echo "FAIL $1"; fail=1; fi; }

LEXOS_AUDIT_SOURCE=1 . "$T/bin/lexos-audit"
for h in 192.168.1.20 localhost mon-nas.local 10.0.0.1 example.com; do ok "valid_host accepte $h" "valid_host $h"; done
for h in "" -oN 192.168.1.256 1.2.3 1.2.3.4.5 "a b" 'x;y' '$(id)' .a a. a..b "-sS" '1.2.3.4:80'; do ok "valid_host refuse '$h'" "! valid_host '$h'"; done
for c in 192.168.1.0/24 10.0.0.8/29 127.0.0.1/32; do ok "valid_cidr accepte $c" "valid_cidr $c"; done
for c in 10.0.0.0/8 192.168.0.0/16 1.2.3.4/33 1.2.3.4/23 1.2.3.4 -x/24 abc/24; do ok "valid_cidr refuse $c" "! valid_cidr $c"; done
for p in 192.168.1.5 10.1.2.3 172.16.0.1 172.31.9.9 127.0.0.1 localhost; do ok "privé : $p" "est_prive $p"; done
for p in 8.8.8.8 172.15.0.1 172.32.0.1 example.com 11.0.0.1; do ok "public : $p" "! est_prive $p"; done
ok "autorise IP privée sans phrase" "autorise 192.168.1.5 </dev/null"
ok "refuse public sans phrase" "! autorise 8.8.8.8 </dev/null 2>/dev/null"
ok "refuse public mauvaise phrase" "! (echo 'oui oui' | autorise 8.8.8.8 2>/dev/null)"
ok "accepte public avec la phrase exacte" "(echo \"J'AI L'AUTORISATION\" | autorise 8.8.8.8 2>/dev/null)"

# Menu complet : « 3 » (ports) sur une cible privée -> nmap -sT, jamais -sS/-O/-A
: > "$T/calls"; printf '3\n192.168.1.20\n\n0\n' | "$T/bin/lexos-audit" >/dev/null 2>&1
ok "menu 3 lance nmap -sT -Pn" "grep -q 'FAKE-NMAP -sT -Pn -sV --top-ports 1000 192.168.1.20' '$T/calls'"
: > "$T/calls"; printf '3\n-oN /tmp/x\n0\n' | "$T/bin/lexos-audit" >/dev/null 2>&1
ok "menu 3 refuse une option injectée" "[ ! -s '$T/calls' ]"
: > "$T/calls"; printf '3\n8.8.8.8\nnon\n0\n' | "$T/bin/lexos-audit" >/dev/null 2>&1
ok "cible publique sans phrase -> rien lancé" "[ ! -s '$T/calls' ]"
: > "$T/calls"; printf '2\n10.0.0.0/8\n0\n' | "$T/bin/lexos-audit" >/dev/null 2>&1
ok "réseau /8 refusé" "[ ! -s '$T/calls' ]"
: > "$T/calls"; printf '2\n192.168.1.0/24\n\n0\n' | "$T/bin/lexos-audit" >/dev/null 2>&1
ok "menu 2 lance nmap -sn" "grep -q 'FAKE-NMAP -sn 192.168.1.0/24' '$T/calls'"
: > "$T/calls"; printf '1\n\n0\n' | "$T/bin/lexos-audit" >/dev/null 2>&1
ok "menu 1 scanne 127.0.0.1" "grep -q 'FAKE-NMAP -sT -Pn --top-ports 1000 127.0.0.1' '$T/calls'"
: > "$T/calls"; printf '4\nhttp://192.168.1.20:8080/x\n\n0\n' | "$T/bin/lexos-audit" >/dev/null 2>&1
ok "menu 4 curl -sI avec --" "grep -q 'FAKE-CURL -sI --max-time 15 -- http://192.168.1.20:8080/x' '$T/calls'"
: > "$T/calls"; printf '4\nhttp://192.168.1.20/$(id)\n0\n' | "$T/bin/lexos-audit" >/dev/null 2>&1
ok "menu 4 refuse une URL piégée" "[ ! -s '$T/calls' ]"
ok "journal audit.log écrit" "grep -q nmap '$HOME/.lexos/audit.log'"
ok "jamais -sS/-O/-A dans le script" "! grep -Eq 'nmap[^\"]* (-sS|-O|-A|-sU)( |\")' '$HERE/../src/lexos-core/bin/lexos-audit'"
echo; [ $fail = 0 ] && echo "TOUT OK" || echo "ÉCHECS"; exit $fail
