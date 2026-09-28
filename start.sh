#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
PROJECT_ROOT="$(pwd)"
PORT="${PORT:-3000}"
WEB_DIR="${OPENCODE_WEB_DIR:-/home/runner/work/_temp/omgithub-web}"
DIST_DIR="$PROJECT_ROOT/dist"
/usr/bin/time -p mkdir -p "$DIST_DIR"
/usr/bin/time -p mkdir -p "$WEB_DIR"
# Install + build when a package project exists; otherwise ensure static output.
if /usr/bin/time -p test -f "$PROJECT_ROOT/package.json"; then
  if /usr/bin/time -p grep -q '"vite"' "$PROJECT_ROOT/package.json"; then
    if /usr/bin/time -p test -f "$PROJECT_ROOT/package-lock.json"; then
      /usr/bin/time -p npm ci --no-audit --no-fund
    else
      /usr/bin/time -p npm install --no-audit --no-fund
    fi
    /usr/bin/time -p npx vite build
    /usr/bin/time -p test -f "$DIST_DIR/index.html"
  else
    echo "Unsupported package project: customize start.sh and deployment output." >&2
    exit 1
  fi
else
  # No package project: generate the built static directory if missing.
  if ! /usr/bin/time -p test -f "$DIST_DIR/index.html"; then
    if /usr/bin/time -p test -f "$PROJECT_ROOT/index.html"; then
      /usr/bin/time -p cp "$PROJECT_ROOT/index.html" "$DIST_DIR/index.html"
    else
      /usr/bin/time -p bash -c 'cat > "$0" <<"HTML"
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>PlayGround</title>
<style>
:root { color-scheme: light dark; }
body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; margin: 0; min-height: 100vh; display: grid; place-items: center; background: #0f172a; color: #f1f5f9; }
.card { max-width: 640px; padding: 48px; text-align: center; background: #1e293b; border-radius: 24px; box-shadow: 0 20px 60px rgba(0,0,0,.35); }
h1 { font-size: 2.5rem; margin: 0 0 12px; }
p { font-size: 1.125rem; line-height: 1.6; color: #cbd5e1; }
.badge { display: inline-block; font-size: .8rem; letter-spacing: .12em; text-transform: uppercase; color: #38bdf8; margin-bottom: 16px; }
a { color: #38bdf8; }
</style>
</head>
<body>
<main class="card">
<div class="badge">OMGithub &bull; PlayGround</div>
<h1>PlayGround is live</h1>
<p>Static preview serving correctly. Edit <code>start.sh</code> build output to ship your app.</p>
<p><a href="https://omgithub.com">Built with OMGithub</a></p>
</main>
</body>
</html>
HTML' "$DIST_DIR/index.html"
    fi
  fi
fi
/usr/bin/time -p test -f "$DIST_DIR/index.html"
/usr/bin/time -p bash -c 'printf "%s" "{\"project\":\"$0\",\"directory\":\"$1\"}" > "$2/deployment-output.json"' "$PROJECT_ROOT" "$DIST_DIR" "$WEB_DIR"
/usr/bin/time -p cat "$WEB_DIR/deployment-output.json"
echo ""
# Serve the built static directory in the foreground.
/usr/bin/time -p python3 -m http.server "$PORT" --bind 0.0.0.0 --directory "$DIST_DIR"
