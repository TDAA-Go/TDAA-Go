"""Serve the generated site, advancing to the next port when one is busy."""

from __future__ import annotations

import argparse
import errno
import functools
import http.server
import os
from pathlib import Path


DEFAULT_PORT = 8000
DEFAULT_MAX_ATTEMPTS = 100


class ReusableThreadingHTTPServer(http.server.ThreadingHTTPServer):
    allow_reuse_address = True


def open_server(
    directory: str | os.PathLike[str],
    *,
    start_port: int = DEFAULT_PORT,
    host: str = "",
    max_attempts: int = DEFAULT_MAX_ATTEMPTS,
    server_class: type[http.server.ThreadingHTTPServer] = ReusableThreadingHTTPServer,
):
    """Return ``(port, server)`` for the first bindable port at or above start."""

    if start_port < 1 or start_port > 65535:
        raise ValueError("start_port must be between 1 and 65535")
    if max_attempts < 1:
        raise ValueError("max_attempts must be at least 1")

    site_dir = Path(directory)
    handler = functools.partial(http.server.SimpleHTTPRequestHandler, directory=site_dir)
    last_port = min(65535, start_port + max_attempts - 1)

    for port in range(start_port, last_port + 1):
        try:
            return port, server_class((host, port), handler)
        except OSError as error:
            if error.errno != errno.EADDRINUSE or port == last_port:
                raise

    raise RuntimeError("No available port found")


def display_host(host: str) -> str:
    return "localhost" if host in ("", "0.0.0.0") else host


def serve(
    directory: str | os.PathLike[str],
    *,
    start_port: int = DEFAULT_PORT,
    host: str = "",
    max_attempts: int = DEFAULT_MAX_ATTEMPTS,
    server_class: type[http.server.ThreadingHTTPServer] = ReusableThreadingHTTPServer,
) -> None:
    port, server = open_server(
        directory,
        start_port=start_port,
        host=host,
        max_attempts=max_attempts,
        server_class=server_class,
    )
    with server:
        print(f"Starting local server at http://{display_host(host)}:{port}", flush=True)
        print("Press Ctrl+C to stop", flush=True)
        try:
            server.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped", flush=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", nargs="?", default="_site")
    parser.add_argument("--port", type=int, default=DEFAULT_PORT)
    parser.add_argument("--host", default="")
    parser.add_argument("--max-attempts", type=int, default=DEFAULT_MAX_ATTEMPTS)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    serve(
        args.directory,
        start_port=args.port,
        host=args.host,
        max_attempts=args.max_attempts,
    )


if __name__ == "__main__":
    main()
