#!/bin/bash

# Function to print an error message and exit
function error_exit {
    echo "$1" >&2
    exit 1
}

# Fetch the latest stable release information using the GitHub API
echo "Fetching the latest stable Neovim release information..."
releases_json=$(curl -s https://api.github.com/repos/neovim/neovim/releases)
if [ -z "$releases_json" ]; then
    error_exit "Failed to fetch release information. Got an empty response."
fi

# Determine the correct asset name for the platform
platform=$(uname -m)
if [ "$platform" == "x86_64" ]; then
    asset_name="nvim-macos-x86_64.tar.gz"
elif [ "$platform" == "arm64" ] || [ "$platform" == "aarch64" ]; then
    asset_name="nvim-macos-arm64.tar.gz"
else
    error_exit "Unsupported platform: $platform"
fi

# Filter out pre-releases and drafts using jq
latest_stable_release=$(echo "$releases_json" | jq -r '[.[] | select(.prerelease == false and .draft == false)][0]')
latest_release_url=$(echo "$latest_stable_release" | jq -r ".assets[] | select(.name == \"$asset_name\") | .browser_download_url")
release_version=$(echo "$latest_stable_release" | jq -r ".tag_name")

if [[ -z "$latest_release_url" ]]; then
    error_exit "Failed to parse the latest stable release URL from the JSON response."
fi

echo "Latest stable release: $release_version"
echo "Latest stable release URL: $latest_release_url"

# Download the latest Neovim release
echo "Downloading the latest Neovim release..."
curl -LO "$latest_release_url" || error_exit "Failed to download Neovim."

# Extract the downloaded tarball
echo "Extracting Neovim..."
tar xzf "$asset_name" || error_exit "Failed to extract Neovim."

# Find the extracted directory
extracted_dir=$(echo "$asset_name" | sed 's/.tar.gz//')

# Log the contents of the extracted directory
echo "Contents of the extracted directory:"
ls "./${extracted_dir}/bin" -l

# Remove existing nvim installations if present
if [ -f /usr/local/bin/nvim ]; then
    echo "Removing old Neovim binary..."
    sudo rm /usr/local/bin/nvim || error_exit "Failed to remove old Neovim binary."
fi

# Remove existing nvim runtime files if present
if [ -d /usr/local/share/nvim ]; then
    echo "Removing old Neovim runtime files..."
    sudo rm -rf /usr/local/share/nvim || error_exit "Failed to remove old Neovim runtime files."
fi

# Move Neovim to a standard location
echo "Moving Neovim to /usr/local/bin..."
sudo mv "./${extracted_dir}/bin/nvim" /usr/local/bin/nvim || error_exit "Failed to move nvim to /usr/local/bin."
sudo cp -r "./${extracted_dir}/share/nvim/runtime" /usr/local/share/nvim/ || error_exit "Failed to copy runtime files."

# Clean up the downloaded and extracted files
echo "Cleaning up..."
rm -rf "$asset_name" "$extracted_dir"

# Set VIMRUNTIME environment variable
export VIMRUNTIME=/usr/local/share/nvim/runtime

# Verify the installation
echo "Verifying Neovim installation..."
hash -r  # clear cached commands to ensure the new binary is found
nvim_version=$(nvim --version | head -n 1) || error_exit "Verification failed."
echo "Current nvim version: $nvim_version"
if [[ "$nvim_version" != *"$release_version"* ]]; then
    error_exit "Mismatch: the installed nvim version ($nvim_version) does not match the downloaded version ($release_version)"
else
    echo "Successfully updated to: $nvim_version"
fi

echo "Neovim update completed successfully."

