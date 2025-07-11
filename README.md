# github-actions-docker-build

Automatically build a Docker image on GitHub Actions, hosted on GitHub Container Registry

## 1. Setup

Fork this repository, or add all its contents into an existing repository. You
will need a GitHub account to continue.


## 2. Customize the image

The [Dockerfile] defines the Docker image. Refer to [Docker Docs] for examples
on how to make changes to this file.

Once the Dockerfile has been updated on GitHub, it will automatically trigger a
build of the image on GitHub Container Registry as an image tagged with the
repository's name and owner.

> [!NOTE]
> The first push in a repository may fail due to lack of GitHub permissions on a
> package that hasn't been created yet. Subsequent pushes should succeed.

[Dockerfile]: ./Dockerfile
[Docker Docs]: https://docs.docker.com/build/building/packaging/

## 3. Customize the automatic build

### Trigger

The automatic build is defined in [docker.yml], a GitHub Actions workflow. By
default, it is set to run:

1. on pushes to the `main` branch that change certain files
2. on manual invocation from the workflow webpage (repository > Actions > docker)

You can tweak this to use other [workflow triggers].

[workflow triggers]: https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows

### Platform

By default, the build is done only for the native platform of the GitHub runner,
`linux/amd64`. If you want to build for other platforms, you can pass
[`--platform`] to `./build --platform` or more directly by modifying the `docker
buildx build` command within that script. If doing this, you may need to enable
emulation by uncommenting the line for `docker/setup-qemu-action@v3` in
[docker.yml].

Note that building for non-native platforms introduces complications and can
slow the build process. See the Docker's official guide for more information:
[Building multi-platform images]

[`--platform`]: https://docs.docker.com/reference/cli/docker/buildx/build/#platform
[Building multi-platform images]: https://docs.docker.com/build/building/multi-platform/#building-multi-platform-images

## Common issues

### Error when pulling/running: `docker: no matching manifest …`

This happens when the image was built for a platform that differs from the
machine you are running Docker on. For example, this would happen if the image
is built for `linux/amd64` and you are using a Mac running on Apple silicon
(M1/M2/etc.). Some ways to address this:

1. Build the image for your machine's platform using emulation ([instructions]).
   Typically this means a slower and more error-prone build process but faster
   run times.
2. Pull the image with the image's intended platform explicitly (e.g. `docker
   pull --platform=linux/amd64`) and run using emulation. Typically this means a
   faster build process but slower run times.
3. Build the image locally. Typically this is the fastest combination of build
   and run times, but the build process can be error-prone and it isn't
   automated via GitHub Actions.

[instructions]: #platform

### `docker pull` permission denied

If you repository is public, log out and try again.

    docker logout ghcr.io

If your repository is private, log in, follow prompts, and try again.

    docker login ghcr.io

### `docker push` permission denied

[Configure `GITHUB_TOKEN`](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository#configuring-the-default-github_token-permissions) to have read and write permissions.

## References

Based on work in https://github.com/nextstrain/docker-base.

<!-- global references -->

[docker.yml]: ./.github/workflows/docker.yml
