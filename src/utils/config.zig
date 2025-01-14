// purpose: provide functions for config support
const std = @import("std");
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
    if (!try fileExists(configDir)) {
        try writeDefaultConfig(configDir);
    }
}

fn writeDefaultConfig(path: []const u8) !void {
    var file = try std.fs.cwd().createFile(path, .{});
    defer file.close();

    const defaultConfig = "@defaultPWD = $HOME";

    try file.writeAll(defaultConfig);
}

// this will and should be moved to a file named file.zig if anything that is not config.zig uses it
fn fileExists(path: []const u8) !bool {
    // https://nofmal.github.io/zig-with-example/file/ kinda stolen from here lol
    const file = std.fs.cwd().openFile(path, .{}) catch |err| switch (err) {
        error.FileNotFound => return false,
        else => return err,
    };
    defer file.close();
    return true;
}
