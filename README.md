# Go Version Manager

A simple, lightweight shell script to install and switch between multiple Go versions on Linux and macOS.

## Installation

```bash
curl -O https://raw.githubusercontent.com/7e3b/go-version-manager/main/gvm.sh
chmod +x gvm.sh
sudo cp gvm.sh /usr/local/bin/gvm
```

Add GVM's active Go version to your `PATH`:

### Bash

```bash
echo 'export PATH="$HOME/.gvm/current/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Zsh

```bash
echo 'export PATH="$HOME/.gvm/current/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## Usage

Install and activate a Go version:

```bash
gvm 1.24.4
```

If the version is already installed, GVM simply switches to it.

```bash
gvm 1.25.0
```

Switch back to a previously installed version:

```bash
gvm 1.24.4
```

Verify the active version:

```bash
go version
```

## What it does

* Detects your operating system and CPU architecture
* Supports Linux and macOS
* Supports AMD64 and ARM64
* Downloads the requested Go version from `go.dev`
* Installs multiple Go versions side-by-side
* Automatically switches between installed versions
* Uses a symbolic link to manage the active version
* Stores Go versions in `~/.gvm`
* Does not require `sudo` to install or switch Go versions
* Cleans up temporary files after installation

## Directory Structure

GVM stores Go versions in your home directory:

```text
~/.gvm/
├── versions/
│   ├── 1.24.4/
│   ├── 1.25.0/
│   └── 1.25.1/
└── current -> versions/1.25.1
```

The active Go installation is available through:

```text
~/.gvm/current/bin/go
```

## Requirements

* Linux or macOS
* `bash`
* `curl` or `wget`
* `tar`

No Go installation or `sudo` privileges are required.

## Supported Platforms

| Operating System | Architecture          |
| ---------------- | --------------------- |
| Linux            | AMD64                 |
| Linux            | ARM64                 |
| macOS            | AMD64                 |
| macOS            | ARM64 (Apple Silicon) |

## Examples

```bash
gvm 1.24.4
gvm 1.23.6
gvm 1.21.12
```

Once installed, switching between versions is as simple as:

```bash
gvm 1.24.4
go version

gvm 1.25.0
go version
```

## Troubleshooting

### `gvm: command not found`

Make sure `/usr/local/bin` is in your `PATH`:

```bash
echo $PATH
```

Alternatively, invoke the script directly:

```bash
/usr/local/bin/gvm 1.24.4
```

### `go: command not found`

Make sure GVM's active Go directory is in your `PATH`:

```bash
export PATH="$HOME/.gvm/current/bin:$PATH"
```

For Bash, add it to:

```text
~/.bashrc
```

For Zsh, add it to:

```text
~/.zshrc
```

Then reload your shell configuration.

### Download failed

Make sure you have an active internet connection and that the requested Go version exists on `go.dev`.

### Unsupported operating system or architecture

GVM currently supports:

* Linux AMD64
* Linux ARM64
* macOS AMD64
* macOS ARM64
