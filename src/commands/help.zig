// purpose: implement the help command very helpful
const std = @import("std");
const marker = @import("../utils/marker.zig");
const ArrayList = std.ArrayList;

pub fn help(allocater: std.mem.Allocator, psMarker: *std.ArrayList(u8)) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Help:\n", .{});

    var list = ArrayList([]const u8).init(allocater);
    defer list.deinit();

    var dir = try std.fs.cwd().openDir("/bin", .{ .iterate = true });
    defer dir.close();

    var walker = try dir.walk(allocater);
    defer walker.deinit();

    while (try walker.next()) |file| {
        try stdout.print("{s}\n", .{file.basename});
    }

    try marker.printShellMarker(allocater, psMarker);
}
