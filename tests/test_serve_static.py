import errno
import io
from contextlib import redirect_stdout
import unittest

from scripts import serve_static


class ServeStaticTests(unittest.TestCase):
    def test_open_server_advances_past_busy_ports(self):
        attempts = []

        class FakeServer:
            def __init__(self, address, handler):
                del handler
                host, port = address
                attempts.append((host, port))
                if port < 8002:
                    raise OSError(errno.EADDRINUSE, "Address already in use")
                self.server_address = address

        port, server = serve_static.open_server(
            "_site",
            start_port=8000,
            host="127.0.0.1",
            max_attempts=5,
            server_class=FakeServer,
        )

        self.assertEqual(port, 8002)
        self.assertEqual(server.server_address, ("127.0.0.1", 8002))
        self.assertEqual(
            attempts,
            [("127.0.0.1", 8000), ("127.0.0.1", 8001), ("127.0.0.1", 8002)],
        )

    def test_open_server_does_not_mask_other_bind_errors(self):
        class PermissionDeniedServer:
            def __init__(self, address, handler):
                del address, handler
                raise OSError(errno.EPERM, "Operation not permitted")

        with self.assertRaises(OSError) as error:
            serve_static.open_server(
                "_site",
                start_port=8000,
                host="127.0.0.1",
                server_class=PermissionDeniedServer,
            )

        self.assertEqual(error.exception.errno, errno.EPERM)

    def test_serve_handles_keyboard_interrupt(self):
        class InterruptingServer:
            def __init__(self, address, handler):
                del handler
                self.server_address = address

            def __enter__(self):
                return self

            def __exit__(self, exc_type, exc, traceback):
                del exc_type, exc, traceback

            def serve_forever(self):
                raise KeyboardInterrupt

        output = io.StringIO()

        with redirect_stdout(output):
            serve_static.serve(
                "_site",
                start_port=8000,
                host="127.0.0.1",
                server_class=InterruptingServer,
            )

        self.assertIn("Starting local server at http://127.0.0.1:8000", output.getvalue())
        self.assertIn("Server stopped", output.getvalue())


if __name__ == "__main__":
    unittest.main()
