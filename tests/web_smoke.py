"""Boot the exported web build in headless Chromium and prove it runs.

Serves dist/ over HTTP (the wasm loader refuses file://), waits for
``window.__gameReady`` (set by WebBridge after the first frame), holds the
throttle key and checks ``window.__rally.progress`` grows -- i.e. Jolt and the
input map work in the browser -- then screenshots the canvas and rejects a
blank frame. Exit 0 on success; any failure raises.
"""

from __future__ import annotations

import http.server
import statistics
import sys
import threading
from functools import partial
from pathlib import Path

from playwright.sync_api import Page, sync_playwright

DIST = Path(__file__).resolve().parent.parent / "dist"
PORT = 8765
READY_TIMEOUT_MS = 60_000
DRIVE_SECONDS = 8
MIN_PROGRESS_M = 15.0
MIN_PIXEL_STDDEV = 8.0


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    """SimpleHTTPRequestHandler without per-request logging."""

    def log_message(self, *_args: object) -> None:
        return


def serve() -> http.server.ThreadingHTTPServer:
    """Serve dist/ on PORT in a daemon thread."""
    handler = partial(QuietHandler, directory=str(DIST))
    server = http.server.ThreadingHTTPServer(("127.0.0.1", PORT), handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    return server


def drive(page: Page) -> float:
    """Hold W for DRIVE_SECONDS and return the reported stage progress."""
    page.locator("canvas").first.focus()
    page.keyboard.down("w")
    page.wait_for_timeout(DRIVE_SECONDS * 1000)
    page.keyboard.up("w")
    telemetry = page.evaluate("window.__rally")
    return float(telemetry["progress"])


def frame_stddev(png: bytes) -> float:
    """Spread of the screenshot's bytes; a blank canvas is a flat line."""
    sample = png[len(png) // 4 : len(png) // 4 + 20_000]
    return statistics.pstdev(sample)


def main() -> int:
    """Run the smoke test; non-zero exit means the web build is broken."""
    if not (DIST / "index.html").exists():
        print(f"missing {DIST}/index.html: run scripts/export_web.sh first", file=sys.stderr)
        return 2
    server = serve()
    try:
        with sync_playwright() as playwright:
            browser = playwright.chromium.launch(args=["--use-gl=angle", "--use-angle=swiftshader"])
            page = browser.new_page(viewport={"width": 1280, "height": 720})
            errors: list[str] = []
            page.on("pageerror", lambda err: errors.append(str(err)))
            page.goto(f"http://127.0.0.1:{PORT}/index.html")
            page.wait_for_function("window.__gameReady > 0", timeout=READY_TIMEOUT_MS)
            progress = drive(page)
            spread = frame_stddev(page.screenshot())
            browser.close()
    finally:
        server.shutdown()
    print(f"web smoke: progress={progress:.1f} m, frame stddev={spread:.1f}, page errors={len(errors)}")
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    if progress < MIN_PROGRESS_M:
        print(f"car did not move (progress {progress:.1f} m < {MIN_PROGRESS_M})", file=sys.stderr)
        return 1
    if spread < MIN_PIXEL_STDDEV:
        print("canvas looks blank", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
