#!/usr/bin/env python3
import argparse
import json
import logging
import os
import socket
import subprocess


class ListenThread:
    def __init__(self, port: int, token_file: str):
        # Socket item for listening to traffic
        self._log = logging.getLogger("remote.clipboard.server.log")
        self._log.info("Creating socket instance")
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.bind(("localhost", port))
        self._terminate = False
        with open(token_file) as f:
            self._allowed = [set(x.split()) for x in f.readlines()]

    def process_loop(self):
        self.socket.listen(5)
        self._terminate = False
        while not self._terminate:
            try:
                connection, address = self.socket.accept()
                self.parse_cb_message(connection.recv(65536))
            except KeyboardInterrupt:
                self._terminate = True

    def parse_cb_message(self, message: bytes):
        """
        Main method for processing message, only pass message to the system
        clipboard if message is valid
        """
        try:
            request = json.loads(message.decode("utf8"))
            domain = request["domain"]
            user = request["user"]
            token = request["token"]
            msg = request["msg"]
            assert set([domain, user, token]) in self._allowed
            cb_process = subprocess.Popen("wl-copy", shell=True, stdin=subprocess.PIPE)
            cb_process.stdin.write(request["msg"].encode("utf8"))
            cb_process.stdin.close()
            cb_process.wait()
        except KeyboardInterrupt as err:  # Passing interrupt signal to the main loop
            raise err
        # Generic errors
        except json.JSONDecodeError as err:
            self._log.error("Receive undefined JSON format" + str(err))
        except Exception as err:  # Generic error
            self._log.error("Undetermined error" + str(err))
            pass


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog=__file__, description="remote clipboard listening server"
    )
    parser.add_argument(
        "--port",
        "-p",
        type=int,
        default=9543,
        help="Port to listen for copy command traffic",
    )
    parser.add_argument(
        "--token_file",
        "-t",
        type=str,
        default=os.path.join(os.environ["HOME"], ".config/rcb/tokens.conf"),
        help="File listing valid domain name/token pair",
    )
    args = parser.parse_args()

    thread = ListenThread(args.port, args.token_file)
    thread.process_loop()
