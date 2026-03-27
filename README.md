# asm_WebServer

A minimal HTTP/1.0 web server written in **x86-64 assembly** (Intel syntax) for Linux.

## Overview

This project implements a bare-metal web server using Linux syscalls directly, with no C runtime or external libraries. It handles basic **GET** and **POST** HTTP requests and serves static files from the working directory.

## Features

- Listens on **port 80**
- Handles **GET** requests – reads and serves static files from disk
- Handles **POST** requests – writes the request body to a file on disk
- Returns `HTTP/1.0 200 OK` on success and `HTTP/1.0 404 FUCK YOU` for unknown methods
- **Forks** a new child process for each incoming connection, allowing concurrent clients
- Written entirely in x86-64 Intel-syntax assembly using Linux syscalls

## Requirements

- Linux (x86-64)
- GNU Assembler (`as`) and linker (`ld`), or `gcc` for linking

## Building

Assemble and link manually:

```bash
as -o web.o web.s
ld -o web web.o
```

Or use `gcc` as the linker:

```bash
as -o web.o web.s
gcc -o web web.o -nostdlib -no-pie
```

## Running

The server must be run as **root** (or with appropriate capabilities) because it binds to port 80:

```bash
sudo ./web
```

Place the files you want to serve (e.g. `index.html`) in the same directory as the binary, then open your browser and navigate to `http://localhost/index.html`.

## Project Structure

| File | Description |
|------|-------------|
| `web.s` | Assembly source code for the web server |
| `web.o` | Compiled object file |
| `index.html` | Sample HTML page served by the server |

## How It Works

1. **Socket creation** – `socket(AF_INET, SOCK_STREAM, 0)`
2. **Bind** – binds to `0.0.0.0:80`
3. **Listen** – waits for incoming connections
4. **Accept loop** – accepts a client connection and forks:
   - **Parent** – closes the client fd and loops back to `accept`
   - **Child** – handles the request, then exits
5. **Request parsing**:
   - Reads up to 10 KB from the client socket
   - Checks whether the request starts with `GET` or `POST`
   - **GET**: null-terminates the path, opens the file, reads it, and writes `200 OK` + file contents back to the client
   - **POST**: finds `\r\n\r\n` to locate the body, opens the target file, and writes the body to it
   - **Other**: responds with `404 FUCK YOU`

## Syscall Reference

| Syscall | Number | Purpose |
|---------|--------|---------|
| `read`  | 0 | Read from socket / file |
| `write` | 1 | Write to socket / file |
| `open`  | 2 | Open a file |
| `close` | 3 | Close a file descriptor |
| `socket`| 41 | Create a TCP socket |
| `bind`  | 49 | Bind socket to address |
| `listen`| 50 | Listen for connections |
| `accept`| 43 | Accept a connection |
| `fork`  | 57 | Fork a child process |
| `exit`  | 60 | Exit the process |

## Limitations

- Buffer size is fixed at **10 KB** for both requests and file reads
- No HTTPS / TLS support
- Runs HTTP/1.0 only (no keep-alive)
- Minimal error handling

## License

This project is provided as-is for educational purposes.
