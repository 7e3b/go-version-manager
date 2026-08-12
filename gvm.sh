#!/bin/bash

# Go Version Manager
# Usage: ./gvm.sh <version>
# Example: ./gvm.sh 1.24.4

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# GVM directories
GVM_DIR="${HOME}/.gvm"
VERSIONS_DIR="${GVM_DIR}/versions"
CURRENT_LINK="${GVM_DIR}/current"

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if version argument is provided
if [ $# -eq 0 ]; then
    print_error "Please provide Go version as argument"
    echo "Usage: $0 <version>"
    echo "Example: $0 1.24.4"
    exit 1
fi

GO_VERSION="$1"

# Validate version format
if [[ ! "$GO_VERSION" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
    print_error "Invalid version format."
    echo "Use format X.Y or X.Y.Z (e.g., 1.24 or 1.24.4)"
    exit 1
fi

# Convert X.Y to X.Y.0
if [[ "$GO_VERSION" =~ ^[0-9]+\.[0-9]+$ ]]; then
    GO_VERSION="${GO_VERSION}.0"
    print_info "Version format adjusted to: ${GO_VERSION}"
fi

# Detect operating system
OS="$(uname -s)"

case "$OS" in
    Linux)
        GO_OS="linux"
        ;;
    Darwin)
        GO_OS="darwin"
        ;;
    *)
        print_error "Unsupported operating system: ${OS}"
        print_info "Supported operating systems: Linux, macOS"
        exit 1
        ;;
esac

# Detect architecture
ARCH="$(uname -m)"

case "$ARCH" in
    x86_64)
        GO_ARCH="amd64"
        ;;
    arm64|aarch64)
        GO_ARCH="arm64"
        ;;
    *)
        print_error "Unsupported architecture: ${ARCH}"
        print_info "Supported architectures: amd64, arm64"
        exit 1
        ;;
esac

print_info "Operating system: ${GO_OS}"
print_info "Architecture: ${GO_ARCH}"

# Paths
INSTALL_DIR="${VERSIONS_DIR}/${GO_VERSION}"
DOWNLOAD_FILE="go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz"
DOWNLOAD_URL="https://go.dev/dl/${DOWNLOAD_FILE}"

# Create GVM directories
mkdir -p "${VERSIONS_DIR}"

# Check if requested version is already installed
if [ -d "${INSTALL_DIR}" ]; then
    print_info "Go ${GO_VERSION} is already installed."
else
    print_info "Go ${GO_VERSION} is not installed."
    print_info "Download URL: ${DOWNLOAD_URL}"

    # Create temporary directory
    TEMP_DIR="$(mktemp -d)"
    DOWNLOAD_PATH="${TEMP_DIR}/${DOWNLOAD_FILE}"

    cleanup() {
        rm -rf "${TEMP_DIR}"
    }

    trap cleanup EXIT

    # Download Go
    print_info "Downloading Go ${GO_VERSION}..."

    if command -v curl >/dev/null 2>&1; then
        curl -fL --progress-bar -o "${DOWNLOAD_PATH}" "${DOWNLOAD_URL}"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "${DOWNLOAD_PATH}" "${DOWNLOAD_URL}"
    else
        print_error "Neither curl nor wget is available."
        exit 1
    fi

    if [ ! -f "${DOWNLOAD_PATH}" ]; then
        print_error "Download failed."
        exit 1
    fi

    print_success "Download completed."

    # Extract into temporary directory
    EXTRACT_DIR="${TEMP_DIR}/extracted"

    mkdir -p "${EXTRACT_DIR}"

    print_info "Extracting Go ${GO_VERSION}..."

    tar -C "${EXTRACT_DIR}" -xzf "${DOWNLOAD_PATH}"

    if [ ! -d "${EXTRACT_DIR}/go" ]; then
        print_error "Go extraction failed."
        exit 1
    fi

    # Move Go installation into versions directory
    print_info "Installing Go ${GO_VERSION}..."

    mv "${EXTRACT_DIR}/go" "${INSTALL_DIR}"

    print_success "Go ${GO_VERSION} installed."
fi

# Switch current version
print_info "Switching to Go ${GO_VERSION}..."

ln -sfn "${INSTALL_DIR}" "${CURRENT_LINK}"

print_success "Go ${GO_VERSION} is now active."

# Verify
if [ -x "${CURRENT_LINK}/bin/go" ]; then
    INSTALLED_VERSION="$("${CURRENT_LINK}/bin/go" version)"
    print_success "${INSTALLED_VERSION}"
else
    print_error "Go installation verification failed."
    exit 1
fi

echo
print_info "Make sure this is in your PATH:"
echo
echo 'export PATH="$HOME/.gvm/current/bin:$PATH"'
echo
print_info "Then run:"
echo "go version"