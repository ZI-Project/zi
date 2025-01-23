// purpose: print the marker
const std = @import("std");

pub fn printShellMarker(allocater: std.mem.Allocator, psMarker: *std.ArrayList([]u8)) !void {
    const stdout = std.io.getStdOut().writer();
    try printShellMarkDir(allocater);
    try stdout.print("zi~> ", .{});
}

fn printShellMarkDir(allocater: std.mem.Allocator) !void {
    const stdout = std.io.getStdOut().writer();
    const cwd = try std.fs.cwd().realpathAlloc(allocater, ".");
    defer allocater.free(cwd);
    var splitCWD = std.mem.split(u8, cwd, "/");

    var topPathName: ?[]const u8 = undefined;

    while (splitCWD.next()) |split| {
        topPathName = split;
    }

    if (topPathName.?.len == 0) {
        topPathName = "/";
    }
    try stdout.print("{s} ", .{topPathName.?});
}
