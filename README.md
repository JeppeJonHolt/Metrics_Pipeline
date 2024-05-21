# Using the Docker Image to Produce Metrics on a Pipeline

This Docker image contains a compiled version of `metrics.exe`, designed to scan a provided .NET Framework solution. The primary intent is to facilitate the generation of Visual Studio Code metrics within CI pipelines, especially those like GitHub Actions.

## Prerequisites
Ensure you have Docker and Docker Compose installed on your development machine or CI pipeline environment.

## Usage Instructions

To use this Docker image effectively, follow these steps. Create or update a `docker-compose.yml` file with the following content:

```yaml
services:
  metrics:
    image: jeppeholt/metrics
    volumes:
      - ${PROJECT_DIR}:C:/app
      - C:/results:C:/results
    environment:
      - SOLUTION_NAME=${SOLUTION_NAME}
```

### Environment Variables

- `PROJECT_DIR`: This should be set to the root directory of your project.
- `SOLUTION_NAME`: This should be the name of your solution (the `.sln` file).
- By default, the results will be saved in the `C:/results` directory inside the container. This is mounted to `C:/results` on the host machine but can be easily changed.

### Steps to Run

1. **Setup Environment Variables**: Before running the Docker Compose command, ensure these environment variables are correctly set in your CI pipeline configuration or your local shell environment.
2. **Run Docker Compose**: Execute the following command to start the process:

    ```sh
    docker-compose up
    ```

Once the process completes, a file named `report.xml` will be deposited in the `C:/results` directory.

### Example in GitHub Actions

Here’s a simplified GitHub Actions workflow example to illustrate how you might integrate this Docker image:

```yaml
name: Generate Metrics

on: [push]

jobs:
  metrics:
    runs-on: windows-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v2

    - name: Set up Docker Compose
      run: docker-compose up

    env:
      PROJECT_DIR: ${{ github.workspace }}
      SOLUTION_NAME: 'YourSolutionName.sln'
```

### Customizing the Results Directory

You can modify the mount point of the results directory if you do not want it to default to `C:/results`. For example:

```yaml
services:
  metrics:
    image: jeppeholt/metrics
    volumes:
      - ${PROJECT_DIR}:C:/app
      - /custom/results/directory:C:/results
    environment:
      - SOLUTION_NAME=${SOLUTION_NAME}
```

After making these changes, simply run the Docker Compose command, and `report.xml` will be available in the specified results directory.

By following these steps, you can easily integrate .NET Framework solution metrics generation into your CI pipelines using this Docker image.
