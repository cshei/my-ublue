# This stage is responsible for holding onto
# your config without copying it directly into
# the final image
FROM scratch AS stage-config
COPY ./config /config

# Copy modules
# The default modules are inside blue-build/modules
# Custom modules overwrite defaults
FROM scratch AS stage-modules
COPY --from=ghcr.io/blue-build/modules:latest /modules /modules
COPY ./modules /modules

# Bins to install
# These are basic tools that are added to all images.
# Generally used for the build process. We use a multi
# stage process so that adding the bins into the image
# can be added to the ostree commits.
FROM scratch AS stage-bins
COPY --from=gcr.io/projectsigstore/cosign /ko-app/cosign /bins/cosign
COPY --from=docker.io/mikefarah/yq /usr/bin/yq /bins/yq
COPY --from=ghcr.io/blue-build/cli:latest-installer /out/bluebuild /bins/bluebuild

# Keys for pre-verified images
# Used to copy the keys into the final image
# and perform an ostree commit.
#
# Currently only holds the current image's
# public key.
FROM scratch AS stage-keys
COPY cosign.pub /keys/my-ublue-bazzite-deck.pub


# Main image
FROM ghcr.io/ublue-os/bazzite-deck:latest as my-ublue-bazzite-deck
ARG RECIPE=recipes/recipe-bazzite-deck.yml
ARG IMAGE_REGISTRY=localhost
ARG CONFIG_DIRECTORY="/tmp/config"
ARG MODULE_DIRECTORY="/tmp/modules"
ARG IMAGE_NAME="my-ublue-bazzite-deck"
ARG BASE_IMAGE="ghcr.io/ublue-os/bazzite-deck"

# Key RUN
RUN --mount=type=bind,from=stage-keys,src=/keys,dst=/tmp/keys \
  mkdir -p /usr/etc/pki/containers/ \
  && cp /tmp/keys/* /usr/etc/pki/containers/ \
  && ostree container commit

# Bin RUN
RUN --mount=type=bind,from=stage-bins,src=/bins,dst=/tmp/bins \
  mkdir -p /usr/bin/ \
  && cp /tmp/bins/* /usr/bin/ \
  && ostree container commit

# Module RUNs
RUN \
--mount=type=bind,from=stage-config,src=/config,dst=/tmp/config,rw \
--mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli:v0.8.11-build-scripts,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-my-ublue-bazzite-deck-latest,sharing=locked \
  /tmp/scripts/run_module.sh 'files' '{"type":"files","files":[{"usr":"/usr"}]}' \
  && ostree container commit
RUN \
--mount=type=bind,from=stage-config,src=/config,dst=/tmp/config,rw \
--mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli:v0.8.11-build-scripts,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-my-ublue-bazzite-deck-latest,sharing=locked \
  /tmp/scripts/run_module.sh 'rpm-ostree' '{"type":"rpm-ostree","repos":["https://pkgs.tailscale.com/stable/fedora/tailscale.repo","https://copr.fedorainfracloud.org/coprs/wezfurlong/wezterm-nightly/repo/fedora-%OS_VERSION%/wezfurlong-wezterm-nightly-fedora-%OS_VERSION%.repo"],"install":["binutils","borgbackup","btop","cascadia-fonts-all","clang","clang-devel","cmake","cockpit","cockpit-machines","cockpit-ostree","cockpit-podman","cockpit-system","gcc","gcc-c++","golang","gparted","htop","hyperfine","igt-gpu-tools","jetbrains-mono-fonts-all","kitty","libvirt","lldb","meld","mercurial","mold","mosh","mpv","python3-devel","ripgrep","sshfs","strace","tailscale","virt-manager","wezterm","yt-dlp","zsh"],"remove":null}' \
  && ostree container commit
RUN \
--mount=type=bind,from=stage-config,src=/config,dst=/tmp/config,rw \
--mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli:v0.8.11-build-scripts,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-my-ublue-bazzite-deck-latest,sharing=locked \
  /tmp/scripts/run_module.sh 'default-flatpaks' '{"type":"default-flatpaks","notify":true,"system":{"repo-url":"https://dl.flathub.org/repo/flathub.flatpakrepo","repo-name":"flathub","install":null,"remove":null},"user":{"repo-url":"https://dl.flathub.org/repo/flathub.flatpakrepo","repo-name":"flathub"}}' \
  && ostree container commit
RUN \
--mount=type=bind,from=stage-config,src=/config,dst=/tmp/config,rw \
--mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli:v0.8.11-build-scripts,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-my-ublue-bazzite-deck-latest,sharing=locked \
  /tmp/scripts/run_module.sh 'script' '{"type":"script","scripts":["fix-symlinks.sh","install-chezmoi.sh","install-ms-fonts.sh","install-vscode.sh"]}' \
  && ostree container commit
RUN \
--mount=type=bind,from=stage-config,src=/config,dst=/tmp/config,rw \
--mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli:v0.8.11-build-scripts,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-my-ublue-bazzite-deck-latest,sharing=locked \
  /tmp/scripts/run_module.sh 'signing' '{"type":"signing"}' \
  && ostree container commit

RUN rm -fr /tmp/* /var/* && ostree container commit

# Labels are added last since they cause cache misses with buildah
LABEL org.blue-build.build-id="02e5dcb1-11fc-40c6-9035-e927de25f4cd"
LABEL org.opencontainers.image.title="my-ublue-bazzite-deck"
LABEL org.opencontainers.image.description="A starting point for further customization of uBlue images. Make your own! https://ublue.it/making-your-own/"
LABEL io.artifacthub.package.readme-url=https://raw.githubusercontent.com/blue-build/cli/main/README.md