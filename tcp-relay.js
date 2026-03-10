#!/usr/bin/env node
//
// stdio-to-TCP relay for connecting ACP clients (like acpx) to a remote
// Copilot ACP server running in TCP mode.
//
// Usage:
//   node tcp-relay.js [host] [port]
//
// Defaults to 127.0.0.1:8000. Override via arguments or environment:
//   ACP_HOST=192.168.1.50 ACP_PORT=8000 node tcp-relay.js
//
// The relay rewrites the cwd in session/new requests to the container's
// working directory, since the client and server have different filesystems.
// Override the remote cwd with ACP_CWD (default: /copilot-home).
//
// With acpx:
//   acpx --agent "node tcp-relay.js" exec "hello"
//

const net = require("net");

const host = process.argv[2] || process.env.ACP_HOST || "127.0.0.1";
const port = parseInt(process.argv[3] || process.env.ACP_PORT || "8000", 10);
const remoteCwd = process.env.ACP_CWD || "/copilot-home";

const socket = net.createConnection({ host, port }, () => {
  socket.pipe(process.stdout);

  let buffer = "";
  process.stdin.on("data", (chunk) => {
    buffer += chunk.toString();
    let idx;
    while ((idx = buffer.indexOf("\n")) !== -1) {
      const line = buffer.slice(0, idx);
      buffer = buffer.slice(idx + 1);
      try {
        const msg = JSON.parse(line);
        if (msg.method === "session/new" && msg.params) {
          msg.params.cwd = remoteCwd;
        }
        socket.write(JSON.stringify(msg) + "\n");
      } catch {
        socket.write(line + "\n");
      }
    }
  });
  process.stdin.on("end", () => {
    if (buffer.length > 0) socket.write(buffer);
    socket.end();
  });
});

socket.on("error", (err) => {
  process.stderr.write(`tcp-relay: ${err.message}\n`);
  process.exit(1);
});

socket.on("close", () => process.exit(0));
