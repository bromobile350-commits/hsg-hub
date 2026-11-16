#!/bin/bash
# HSG FB auto-reply: point this Mac at the hub's new address (11-17, ngrok replaced by Cloudflare) and fetch the
# program version that Cloudflare lets through. No secrets in here (the key is read from this Mac's own config).
python3 - <<'PY'
import json, os, py_compile, subprocess, time
d = os.path.expanduser("~/hsgclau-workspace/fbmp/bridge")
p = d + "/config.json"
url = json.loads(subprocess.run(["curl", "-fsSL", "https://bromobile350-commits.github.io/hsg-hub/hub_url.json?t=%d" % time.time()],
                                capture_output=True, text=True, check=True).stdout)["url"]
c = json.load(open(p))
old = c["hub"]["url"]
c["hub"]["url"] = url
json.dump(c, open(p + ".tmp", "w"), ensure_ascii=False, indent=2)
os.replace(p + ".tmp", p)
print("hub address:", old, "->", url)
new = d + "/fbmp_bridge.py.new"
subprocess.run(["curl", "-fsSL", "-H", "X-Hub-Key: " + str(c["hub"]["key"]), "-o", new, url + "/update/file?path=bridge/fbmp_bridge.py"], check=True)
py_compile.compile(new, doraise=True)
if "hsg-fbmp/1.0" in open(new, encoding="utf-8").read():
    os.replace(d + "/fbmp_bridge.py", d + "/fbmp_bridge.py.bak.fix")
    os.replace(new, d + "/fbmp_bridge.py")
    print("program replaced with the new version")
PY
launchctl kickstart -k gui/$(id -u)/com.hsg.fbmp-bridge && echo "OK - done / 完成"
