# Run Snort Tests Using PowerShell and Testinfra

This repository features a GitHub Actions workflow that automatically executes tests for your project. The workflow performs several tasks: it checks out your code, sets up the environment, installs required dependencies, and runs tests to verify that Snort and Wazuh are properly configured on both Linux and Windows.

## Testing

The tests use `pytest`, `testinfra`, and PowerShell to verify system configuration. Here’s a summary of the tests:

### Dependencies Installation

- **`install_dependencies` fixture**: Installs necessary dependencies based on the operating system (Ubuntu/Debian or Windows). If the OS is not supported, the test fails.

### Snort Installation

- **`test_snort_is_installed`**: Checks if Snort is installed on the system.
- **`test_snort_conf_file_exists`**: Verifies that the `snort.conf` configuration file exists.
- **`test_snort_interface_configuration`**: Ensures the default network interface is present in the `snort.debian.conf` file.

### OSSEC Configuration

- **`test_update_ossec_conf_linux`**: Checks if the `ossec.conf` file has been updated correctly with Snort configurations.

## Setup and Configuration

To ensure the GitHub Actions workflow runs properly, you need to have:

- Python 3.9 or the version specified in the `setup-python` action.
- For Linux:
  - A script located at `scripts/install.sh` for installing Snort.
- For Windows:
  - A PowerShell script located at `scripts/snort.ps1` for installing and configuring Snort and Wazuh agent.
  - A PowerShell test script located at `scripts/tests/test.ps1` for running tests.

### Running Tests Locally

To run the tests locally, follow these steps:

1. **Install the required Python packages:**
   ```bash
   pip install pytest pytest-testinfra
   ```

2. **Ensure that all system dependencies are installed and wazuh-agent have to be installed already:**
   ```bash
   sudo apt-get update
   sudo apt-get install -y curl gnupg2 iproute2
   ```

3. **For Windows:**
   - Ensure you have PowerShell installed and configured.
   - Run the following commands:
     ```powershell
     # Install required packages
     pip install pytest pytest-testinfra

     # Run the Snort and Wazuh installation and configuration script
     .\scripts\snort.ps1

     # Run the tests
     .\scripts\tests\test.ps1
     ```

4. **For Linux:**
   - Run the tests with:
     ```bash
     pytest -vv scripts/tests/test_install.py
     ```

### PowerShell Test Script

The `scripts/tests/test.ps1` PowerShell script includes various tests to ensure that Snort and Wazuh are correctly installed and configured. Here’s an overview of what the script does:

- **Initialize a list to store test results**.
- **Define a function `Run-Test`** to run each test and log the results.
- **Define test scripts** to check the existence of Snort and Wazuh files, verify configurations, and check environment variables.
- **Run all defined tests** and output the results.







