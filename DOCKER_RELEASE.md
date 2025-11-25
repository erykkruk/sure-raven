# Docker Release Instructions

## Releasing a New Docker Image to GitHub Container Registry

### Prerequisites
1. Docker Desktop installed and running
2. Access to GitHub Container Registry (ghcr.io)
3. Proper authentication to push to `ghcr.io/erykkruk/sure-raven`

### Steps to Release

1. **Build the Docker image with a specific version tag**
   ```bash
   docker build -t ghcr.io/erykkruk/sure-raven:1.0.1 --no-cache .
   ```
   - Use `--no-cache` to ensure a fresh build without cached layers
   - Replace `1.0.1` with your desired version number

2. **Tag the image as latest (optional)**
   ```bash
   docker tag ghcr.io/erykkruk/sure-raven:1.0.1 ghcr.io/erykkruk/sure-raven:latest
   ```

3. **Verify the image was built**
   ```bash
   docker images ghcr.io/erykkruk/sure-raven
   ```

4. **Login to GitHub Container Registry (if not already logged in)**
   ```bash
   docker login ghcr.io
   ```
   - Use your GitHub username
   - Use a GitHub Personal Access Token with `write:packages` permission as password

5. **Push the versioned image**
   ```bash
   docker push ghcr.io/erykkruk/sure-raven:1.0.1
   ```

6. **Push the latest tag (if created)**
   ```bash
   docker push ghcr.io/erykkruk/sure-raven:latest
   ```

### Version Numbering Convention
- Use semantic versioning: `MAJOR.MINOR.PATCH`
  - `MAJOR`: Breaking changes
  - `MINOR`: New features, backward compatible
  - `PATCH`: Bug fixes and minor updates
- Example: `1.0.1`, `1.1.0`, `2.0.0`

### Verify Release
Check that the image is available at:
- https://github.com/erykkruk/sure-raven/pkgs/container/sure-raven

### Current Versions
- `1.0.1` - Current release
- `latest` - Points to the most recent version