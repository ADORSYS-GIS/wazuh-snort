# Snort 3 Build and Packaging

This repository automates the process of building and packaging Snort 3 for `amd64` and `arm64` architectures using GitHub Actions.

## Objective

The goal of this project is to simplify the Snort 3 build and packaging process. By leveraging GitHub Actions, you can automatically generate `.deb` packages for Snort 3, eliminating the need for manual builds.

## How to Use

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/ADORSYS-GIS/wazuh-snort.git
   cd wazuh-snort
   ```

2. **Trigger a Build:**
   - Push changes to the `main` branch or open a pull request to automatically trigger the build and packaging process.

3. **Retrieve the Packages:**
   - After the build completes, download the generated `.deb` packages from the corresponding GitHub Release.

## License

This project is licensed under the MIT License.