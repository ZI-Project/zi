// purpose: provide functions for file handling
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

pub fn fileWrite(path: []const u8, data: []const u8) !void {
    var file = try std.fs.cwd().createFile(path, .{});
    defer file.close();

    try file.writeAll(data);
}

pub fn fileReadAll(path: []const u8, allocater: std.mem.Allocator) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const out = try file.readToEndAlloc(allocater, 1000000);

    return out;
}
