# REWRITE IN PROGRESS

![zi-banner-smol](https://github.com/user-attachments/assets/12cfa71b-721b-4a7e-84c7-159b8220b97a)

banner made by [@Sophed](https://github.com/Sophed)

# About:

**zi** is a non-POSIX shell written in zig

**Docs can be found**: [Here](https://github.com/ZI-Project/zi/wiki)

## Support:

**:x:: no support**

**⚠️: community support**

**✔: full support**

| Operating System  | Supported     |
| -------------     | ------------- |
| Windows           | :x:           |
| Mac               | ⚠️             |
| FreeBSD           | ✔             |
| Linux             | ✔             |

## Features:
* Interpreter to run .zi files
* Easy to configure
* Shell changers which are special commands that change properties about the shell
* Basic shell commands like: ``cd``, ``help``, ``exit``

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
