import { appendFileSync, existsSync, mkdirSync, renameSync, statSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

// Observe exits without logging credentials, request arguments or conversation text.
const root = dirname(fileURLToPath(import.meta.url));
const log = resolve(root, '.runtime/data/mcp-diagnostics.jsonl');
function record(event, detail = {}) {
  if (!log) return;
  try {
    mkdirSync(dirname(log), { recursive: true });
    if (existsSync(log) && statSync(log).size > 512 * 1024) renameSync(log, log + '.previous');
    appendFileSync(log, JSON.stringify({ time: new Date().toISOString(), pid: process.pid,
      ppid: process.ppid, event, ...detail }) + '\n');
  } catch { /* Diagnostics must not interfere with the MCP protocol. */ }
}

process.on('uncaughtExceptionMonitor', (error, origin) => record('uncaught_exception', {
  origin, name: error.name, message: error.message, stack: error.stack,
}));
process.on('exit', code => record('exit', { code }));
process.stdin.on('end', () => record('stdin_end'));
process.stdin.on('close', () => record('stdin_close'));
const entry = resolve(root, 'plugins/work-conversation/server.mjs');
record('start', { node: process.version });
// Preserve the existing server's standalone-entry check and tool implementation.
process.argv[1] = resolve(entry);
await import(pathToFileURL(process.argv[1]).href);
