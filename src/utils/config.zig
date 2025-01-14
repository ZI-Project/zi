// purpose: provide functions for config support
const std = @import("std");
const file = @import("file.zig");
const allocater = std.heap.page_allocator;
const stdout = std.io.getStdOut().writer();

pub fn init() !void {
    const homeDir = try std.process.getEnvVarOwned(allocater, "HOME");
    const configDot = try std.fs.path.join(allocater, &[_][]const u8{ homeDir, ".config" });
    const ziDir = try std.fs.path.join(allocater, &[_][]const u8{ configDot, "zi" });
    const configDir = try std.fs.path.join(allocater, &[_][]const u8{ ziDir, "rc.zi" });
    defer {
        allocater.free(configDir);
        allocater.free(ziDir);
        allocater.free(configDot);
    }

    defer allocater.free(homeDir);

    _ = std.fs.cwd().makeDir(ziDir) catch {};
    if (!try file.fileExists(configDir)) {
        try writeDefaultConfig(configDir);
    }
}

fn writeDefaultConfig(path: []const u8) !void {
    var confFile = try std.fs.cwd().createFile(path, .{});
    defer confFile.close();

    const defaultConfig = "@defaultPWD = $HOME";

    try confFile.writeAll(defaultConfig);
}
