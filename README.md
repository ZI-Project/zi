
![Zi-Logo](https://github.com/user-attachments/assets/9aa65698-f9ed-482b-8c8b-94142239245e)
# zi

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
