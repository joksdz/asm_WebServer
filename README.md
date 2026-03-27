# asm_WebServer

A minimal HTTP/1.0 web server written in **x86-64 assembly** (Intel syntax) for Linux.

## Overview

This project implements a bare-metal web server using Linux syscalls directly, with no C runtime or external libraries. It handles basic **GET** and **POST** HTTP requests and serves static files from the working directory.

## Features

- Listens on **port 8080**
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
then run it as ``./web``

Place the files you want to serve (e.g. `index.html`) in the same directory as the binary, then open your browser and navigate to `http://localhost/index.html` (with port :8080 ).

## Project Structure

| File | Description |
|------|-------------|
| `web.s` | Assembly source code for the web server |
| `web.o` | Compiled object file |
| `index.html` | Sample HTML page served by the server |



## Limitations (i will try to fix these at some point )

- Buffer size is fixed at **10 KB** for both requests and file reads
- No HTTPS / TLS support
- Runs HTTP/1.0 only (no keep-alive)
- Minimal error handling (doest check for file existence on get and always returns 200 ok lol )

# Sources : 
- https://pwn.college/computing-101/
- https://man7.org/linux/man-pages/man2/
- filippo.io/linux-syscall-table/
- https://beej.us/guide/bgnet/pdf/bgnet_usl_c_1.pdf
