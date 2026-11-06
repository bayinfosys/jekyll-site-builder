# jekyll-site-builder

A container image that builds a Jekyll site from a mounted directory.
Ruby, Jekyll and the gems are in the image, so the directory being built
needs no Gemfile, no bundle and no Ruby installation. The same image runs
on a workstation and in CI, so a local build and a deployed build use the
same toolchain.

## Image

```
ghcr.io/bayinfosys/jekyll-site-builder:<tag>
```

| Component           | Version                  |
|---------------------|--------------------------|
| Ruby                | 3.3                      |
| Jekyll              | 4.3 (pinned by the lock) |
| kramdown-parser-gfm | pinned by the lock       |

`Gemfile.lock` fixes every gem version. A tag always builds the same
toolchain.

## Build a site

```bash
docker run \
  --rm \
  --user "$(id -u):$(id -g)" \
  -e HOME=/tmp \
  -v "$PWD/site":/site \
    ghcr.io/bayinfosys/jekyll-site-builder:v1.0.0
```

The site source is the mounted directory. The output is written to
`site/_site`, and Jekyll also writes `site/.jekyll-cache`.

`--user` makes the output belong to you, not root. `HOME=/tmp` gives
Bundler and Jekyll a writable home directory under that user.

## Preview

```bash
docker run \
  --rm \
  --user "$(id -u):$(id -g)" \
  -e HOME=/tmp \
  -p 4000:4000 \
  -v "$PWD/site":/site \
    ghcr.io/bayinfosys/jekyll-site-builder:v1.0.0 \
      serve --host 0.0.0.0
```

Then open http://localhost:4000.

## Other commands

Arguments after the image name replace `build` and are passed to `jekyll`:

```bash
    ... jekyll-site-builder:v1.0.0 build --verbose
    ... jekyll-site-builder:v1.0.0 doctor
```

## GitHub Actions and Pages

    - name: Build site
```
      run: >
        docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp
        -v "$PWD/site":/site ghcr.io/bayinfosys/jekyll-site-builder:v1.0.0

    - uses: actions/upload-pages-artifact@v3
      with:
        path: site/_site
```

With the repository's Pages source set to GitHub Actions,
`actions/deploy-pages` publishes the uploaded directory. Nothing built is
committed to the repository.

## Adding a plugin

1. Add the gem to `Gemfile`.
2. Regenerate the lock:
```
docker run \
  --rm \
  --user "$(id -u):$(id -g)" \
  -e HOME=/tmp \
  -v "$PWD":/w \
  -w /w ruby:3.3-slim \
    sh -c 'bundle lock && bundle lock --add-platform x86_64-linux aarch64-linux'
```

3. Tag a new version.

The site's own `_config.yml` must also list the plugin under `plugins:`.

## Releasing

Every push builds the image and builds a one-page test site with it.
Pushing a tag `vX.Y.Z` also publishes `ghcr.io/bayinfosys/jekyll-site-builder:vX.Y.Z`
and `:latest`.

## Building the image locally

```bash
docker build -t jekyll-site-builder:dev .
```
