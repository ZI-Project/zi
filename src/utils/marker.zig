const stdout = std.io.getStdOut().writer();
const std = @import("std");
const allocater = std.heap.page_allocator;

pub fn printShellMarker() !void {
    try printShellMarkDir();
    try stdout.print("zi> ", .{});
}

fn printShellMarkDir() !void {
    const cwd = try std.fs.cwd().realpathAlloc(allocater, ".");
    defer allocater.free(cwd);
    var splitCWD = std.mem.split(u8, cwd, "/");

    var topPathName: ?[]const u8 = undefined;

    while (splitCWD.next()) |split| {
        topPathName = split;
    }

    try stdout.print("[{s}] ", .{topPathName.?});
}
