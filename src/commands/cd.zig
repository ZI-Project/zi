// purpose: implements the cd command
const std = @import("std");
const marker = @import("../utils/marker.zig");

var defaultPWD: []const u8 = "/home";

pub fn cd(input: []u8, allocater: std.mem.Allocator, printMarker: bool, map: *std.StringHashMap([]u8)) !void {
    var args = std.mem.split(u8, input, " ");
    while (args.next()) |arg| {
        try std.io.getStdOut().writer().print("{s}", .{arg});
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
            var envVar: ?[]const u8 = null;
            const indexOfVarMarker: ?usize = std.mem.indexOf(u8, arg, "$");
            if (indexOfVarMarker == null) {
                return error.CannotIndex;
            }
            const envVarKey = arg[indexOfVarMarker.? + 1 ..];
            if (std.process.getEnvVarOwned(allocater, envVarKey)) |val| {
                envVar = val;
            } else |err| {
                if (err == std.process.GetEnvVarOwnedError.EnvironmentVariableNotFound) {
                    envVar = map.get(envVarKey) orelse null;
                }
            }

            if (envVar == null) {
                return error.VarNotFound;
            }
            var dir = try std.fs.cwd().openDir(envVar.?, .{});

            defer dir.close();

            try dir.setAsCwd();
        } else {
            var dir = try std.fs.cwd().openDir(arg, .{});

            defer dir.close();

            try dir.setAsCwd();
        }
    }
    if (printMarker) {
        try marker.printShellMarker(allocater);
    }
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
}
