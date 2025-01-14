const std = @import("std");

pub fn fileExists(path: []const u8) !bool {
    // https://nofmal.github.io/zig-with-example/file/ kinda stolen from here lol
    const file = std.fs.cwd().openFile(path, .{}) catch |err| switch (err) {
        error.FileNotFound => return false,
        else => return err,
    };
    defer file.close();
    return true;
}
