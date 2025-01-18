![zi-banner-smol](https://github.com/user-attachments/assets/12cfa71b-721b-4a7e-84c7-159b8220b97a)

banner made by [@Sophed](https://github.com/Sophed)

# Compiling from source:

## Requirements:
* zig

Arch Linux:
``sudo pacman -S zig``

Mac OS:
``brew install zig``

Fedora:
``dnf install zig``

Gentoo:
``emerge -av dev-lang/zig``

## Step 1.
Clone this repo:
```bash
git clone https://github.com/CoolPuppyKid/zi.git
```
## Step 2.
```bash
cd zi
zig build -Doptimize=ReleaseFast
./zig-out/bin/zi
```
