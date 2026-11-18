# my-ublue &nbsp; [![bluebuild](https://github.com/cshei/my-ublue/actions/workflows/build.yml/badge.svg)](https://github.com/cshei/my-ublue/actions/workflows/build.yml)

Custom [Universal Blue](https://universal-blue.org/) OS images built daily with [BlueBuild](https://blue-build.org/).

## Image Variants

| Image | Base Image | Recipe | Notes |
| :--- | :--- | :--- | :--- |
| `ghcr.io/cshei/my-ublue:latest` | `ghcr.io/ublue-os/silverblue-main:latest` | `recipes/recipe.yml` | GNOME desktop |
| `ghcr.io/cshei/my-ublue-kde:latest` | `ghcr.io/ublue-os/kinoite-main:latest` | `recipes/recipe-kde.yml` | KDE Plasma desktop |
| `ghcr.io/cshei/my-ublue-bazzite-deck:latest` | `ghcr.io/ublue-os/bazzite-deck:latest` | `recipes/recipe-bazzite-deck.yml` | Bazzite Deck gaming image |
| `ghcr.io/cshei/my-ublue-kde-nvidia:latest` | `ghcr.io/ublue-os/kinoite-nvidia:latest` | `recipes/recipe-kde-nvidia.yml` | Frozen on Fedora 44 (upstream `kinoite-nvidia` retired) |

## Installation

To switch an existing Fedora Atomic / Universal Blue installation to one of these images (replace `my-ublue` with your preferred variant):

### Using `bootc` (Fedora 41+ / Bazzite)

1. Switch to the unsigned image first to install the signing keys and policies:
   ```bash
   sudo bootc switch ghcr.io/cshei/my-ublue:latest
   sudo systemctl reboot
   ```
2. Switch to the enforced signed image:
   ```bash
   sudo bootc switch --enforce-container-sigpolicy ghcr.io/cshei/my-ublue:latest
   sudo systemctl reboot
   ```

### Using `rpm-ostree`

1. Rebase to the unsigned image first to install the signing keys and policies:
   ```bash
   rpm-ostree rebase ostree-unverified-registry:ghcr.io/cshei/my-ublue:latest
   systemctl reboot
   ```
2. Rebase to the signed image:
   ```bash
   rpm-ostree rebase ostree-image-signed:docker://ghcr.io/cshei/my-ublue:latest
   systemctl reboot
   ```

All recipes track `image-version: latest` from upstream Universal Blue, so `:latest` automatically follows new Fedora major releases when upstream promotes them.

## ISO

You can generate an offline installation ISO using the [BlueBuild ISO instructions](https://blue-build.org/how-to/generate-iso/).

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading `cosign.pub` from this repository and running:

```bash
cosign verify --key cosign.pub ghcr.io/cshei/my-ublue:latest
```
