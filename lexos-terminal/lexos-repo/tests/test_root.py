#!/usr/bin/env python3
"""lexos-root : désactivé par défaut ; su/rish factices ; confirmation obligatoire sur un vrai pty."""
import os, pty, select, subprocess, sys, tempfile, time
HERE = os.path.dirname(os.path.abspath(__file__)); tmp = tempfile.mkdtemp()
b = os.path.join(tmp, "bin"); os.makedirs(b); home = os.path.join(tmp, "home"); os.makedirs(home)
src = open(os.path.join(HERE, "..", "src", "lexos-core", "bin", "lexos-root")).read().replace("#!@PREFIX@/bin/bash", "#!/usr/bin/env bash")
open(os.path.join(b, "lexos-root"), "w").write(src); os.chmod(os.path.join(b, "lexos-root"), 0o755)
def fake(name):
    p = os.path.join(b, name); open(p, "w").write(f'#!/bin/sh\necho "{name.upper()}-A-LANCE $*" >> "{tmp}/calls"\n'); os.chmod(p, 0o755)
for t in ("env", "bash", "head", "mkdir", "rm", "cat"):
    os.symlink(__import__("shutil").which(t), os.path.join(b, t))   # PATH réduit : pas de vrai su/rish de l'hôte
env = dict(os.environ, HOME=home, PATH=b); fails = []
def ck(n, c, x=""):
    print(("OK   " if c else "FAIL ") + n + ("" if c else "  -> " + x)); (c or fails.append(n))
def run(*a): return subprocess.run([os.path.join(b, "lexos-root"), *a], capture_output=True, text=True, env=env, start_new_session=True)
def run_tty(args, answer):
    m, s = pty.openpty()
    p = subprocess.Popen([os.path.join(b, "lexos-root"), *args], stdin=s, stdout=s, stderr=s, env=env, start_new_session=True,
        preexec_fn=lambda: __import__("fcntl").ioctl(0, __import__("termios").TIOCSCTTY, 0)); os.close(s); out = b""; sent = False; t = time.time()
    while time.time() - t < 15:
        r, _, _ = select.select([m], [], [], .2)
        if r:
            try: d = os.read(m, 4096)
            except OSError: break
            if not d: break
            out += d
            if not sent and b"confirmer" in out: os.write(m, (answer + "\n").encode()); sent = True
        elif p.poll() is not None: break
    p.wait(timeout=10); return out.decode(errors="replace")
calls = os.path.join(tmp, "calls")
ck("désactivé par défaut", "off" in run("status").stdout)
ck("run refusé quand off", run("run", "id").returncode == 1 and not os.path.exists(calls))
ck("on root refusé sans su", run("on", "root").returncode == 1)
ck("on shizuku refusé sans rish", run("on", "shizuku").returncode == 1)
fake("su"); fake("rish")
ck("on root accepté avec su", run("on", "root").returncode == 0 and "root" in run("status").stdout)
run_tty(["run", "id"], "non"); ck("non -> su pas lancé", not os.path.exists(calls))
run_tty(["run", "id"], ""); ck("Entrée -> su pas lancé", not os.path.exists(calls))
run_tty(["run", "id"], "oui"); ck("oui -> su lancé", os.path.exists(calls) and "SU-A-LANCE -c id" in open(calls).read())
r = subprocess.run([os.path.join(b, "lexos-root"), "run", "id"], input="oui\n", capture_output=True, text=True, env=env, start_new_session=True)
ck("sans terminal -> refusé", r.returncode == 1 and open(calls).read().count("SU-A-LANCE") == 1)
run("on", "shizuku"); open(calls, "w").close(); run_tty(["run", "id"], "oui"); ck("shizuku -> rish", "RISH-A-LANCE -c id" in open(calls).read())
run("off"); ck("off -> run refusé", run("run", "id").returncode == 1)
print("ÉCHECS :", fails or "aucun"); sys.exit(1 if fails else 0)
