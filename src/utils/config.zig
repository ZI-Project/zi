// purpose: provide functions for config support
const std = @import("std");
const file = @import("file.zig");
const interpreter = @import("../interpreter/interpreter.zig");

pub fn init(allocater: std.mem.Allocator, envVarList: *std.StringHashMap([]u8), shortens: *std.StringHashMap([]u8)) !void {
    const stdout = std.io.getStdOut().writer();

    const homeDir = try std.process.getEnvVarOwned(allocater, "HOME");
    const configDot = try std.fs.path.join(allocater, &[_][]const u8{ homeDir, ".config" });
    const ziDir = try std.fs.path.join(allocater, &[_][]const u8{ configDot, "zi" });
    const configDir = try std.fs.path.join(allocater, &[_][]const u8{ ziDir, "rc.zi" });

    _ = std.fs.cwd().makeDir(configDot) catch {};

    defer {
        allocater.free(configDir);
        allocater.free(ziDir);
        allocater.free(configDot);
    }

    defer allocater.free(homeDir);

    _ = std.fs.cwd().makeDir(ziDir) catch {};
    if (!try file.fileExists(configDir)) {
        const defaultConfig = "@defaultPWD = $HOME\n@shortenls = ls --color=auto\n";
        try file.fileWrite(configDir, defaultConfig);
    } else {
        if (try interpreter.runZiFile(configDir, allocater, envVarList, shortens) > 0) {
            try stdout.print("following errors above occurred in file: {s}\n", .{configDir});
        }
    }
}
