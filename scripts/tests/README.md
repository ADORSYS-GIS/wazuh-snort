# Run Pytest

This repository features a GitHub Actions workflow that automatically executes Pytest tests for your project. The workflow performs several tasks: it checks out your code, sets up the environment, installs required dependencies, and runs tests to verify that Snort and Wazuh are properly configured.


## Testing

The tests use `pytest` and `testinfra` to verify system configuration. Here’s a summary of the tests:

### Dependencies Installation

- **`install_dependencies` fixture**: Installs necessary dependencies based on the operating system (Ubuntu/Debian or Alpine). If the OS is not supported, the test fails.

### Snort Installation

- **`test_snort_is_installed`**: Checks if Snort is installed on the system.
- **`test_snort_conf_file_exists`**: Verifies that the `snort.conf` configuration file exists.
- **`test_snort_interface_configuration`**: Ensures the default network interface is present in the `snort.debian.conf` file.

### OSSEC Configuration

- **`test_update_ossec_conf_linux`**: Checks if the `ossec.conf` file has been updated correctly with Snort configurations.

## Setup and Configuration

To ensure the GitHub Actions workflow runs properly, you need to have:

- Python 3.9 or the version specified in the `setup-python` action.
- A script located at `scripts/install.sh` for installing Snort.
- The `testinfra` Python package for running system checks.

### Running Tests Locally

To run the tests locally, follow these steps:

1. Install the required Python packages:
   ```bash
   pip install pytest pytest-testinfra
   ```

2. Ensure that all system dependencies are installed. the wazuh agent should be already installed:
   ```bash
   sudo apt-get update
   sudo apt-get install -y curl gnupg2 iproute2
   ```

3. Run the tests:
   ```bash
   pytest -vv scripts/tests/test_install.py
   ```

## Contributing

If you’d like to contribute to this project, please follow the standard GitHub flow: fork the repository, create a feature branch, commit your changes, and submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
