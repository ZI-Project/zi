// purpose: implements the cd command
const std = @import("std");
const marker = @import("../utils/marker.zig");
const stdout = std.io.getStdOut().writer();

var defaultPWD: []const u8 = "/home";

pub fn cd(input: []u8, allocater: std.mem.Allocator) !void {
    var args = std.mem.split(u8, input, " ");
    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "cd")) {
            continue;
        } else if (std.mem.eql(u8, arg, "..")) {
            const cwd = try std.fs.cwd().realpathAlloc(allocater, ".");
            defer allocater.free(cwd);

            const parent = getParentDir(cwd);

            var parent_dir = try std.fs.cwd().openDir(parent, .{});

            defer parent_dir.close();

            try parent_dir.setAsCwd();
        } else if (std.mem.eql(u8, arg, "~")) {
            const homeDir = defaultPWD;
            var dir = try std.fs.cwd().openDir(homeDir, .{});

            defer dir.close();

            try dir.setAsCwd();
        } else if (std.mem.count(u8, arg, "$") > 0) {
            const indexOfVarMarker: ?usize = std.mem.indexOf(u8, arg, "$");
            if (indexOfVarMarker == null) {
                return error.NoVarSet;
            }
            const envVarKey = arg[indexOfVarMarker.? + 1 ..];
            const envVar: []u8 = std.process.getEnvVarOwned(allocater, envVarKey) catch {
                return error.InvalidVar;
            };

            var dir = try std.fs.cwd().openDir(envVar, .{});

            defer dir.close();

            try dir.setAsCwd();
        } else {
            var dir = try std.fs.cwd().openDir(arg, .{});

            defer dir.close();

            try dir.setAsCwd();
        }
    }
    try marker.printShellMarker(allocater);
}

fn getParentDir(dir: []const u8) []const u8 {
    const last_delimiter = std.mem.lastIndexOf(u8, dir, "/");
    if (last_delimiter == 0) {
        return "/";
    }
    return dir[0..last_delimiter.?];
}

pub fn setDefaultPWD(pwd: []const u8) !void {
    defaultPWD = pwd;
    var dir = try std.fs.cwd().openDir(defaultPWD, .{});

    defer dir.close();

    try dir.setAsCwd();
}
