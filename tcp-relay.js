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
// With acpx:
//   acpx --agent "node tcp-relay.js" exec "hello"
//

const net = require("net");

const host = process.argv[2] || process.env.ACP_HOST || "127.0.0.1";
const port = parseInt(process.argv[3] || process.env.ACP_PORT || "8000", 10);

const socket = net.createConnection({ host, port }, () => {
  process.stdin.pipe(socket);
  socket.pipe(process.stdout);
});

socket.on("error", (err) => {
  process.stderr.write(`tcp-relay: ${err.message}\n`);
  process.exit(1);
});

socket.on("close", () => process.exit(0));
process.stdin.on("end", () => socket.end());
