# Build Snort & Deps

This folder contains scripts to build Snort3 from scratch on Ubuntu.
This is meant **for Ubuntu ONLY**.

## Usage

1. At the root of the project:
   ```bash
   docker run -it --rm -v $(pwd)/scripts/build:/app ubuntu /bin/sh -c "cd /app; bash"
   bash ./run.sh
   ```

   If you don't have docker, please install it first. If you don't want to install it, then:
    ```bash
    bash ./scripts/build/run.sh
    ```
2. Then wait till it's done. It will take a while. At the end, you'll have
   some results in the folder `output/`.