# Agents

Guidance for any coding agent working in this repository.

- Repository contract: [CLAUDE.md](CLAUDE.md)
- Estate-wide conventions: https://github.com/JorisJonkers-dev/workspace/blob/main/CLAUDE.md

## What it holds

The estate's FlareSolverr image: a `Dockerfile` and start script in `flaresolverr`. The repository publishes the image only.

## Build and test

After building the image, run the restricted smoke test CI runs (it needs Docker):

```bash
scripts/smoke-test.sh <flaresolverr-image>
```
