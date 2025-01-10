// purpose: implements the cd command
const std = @import("std");
const marker = @import("../utils/marker.zig");
const stdout = std.io.getStdOut().writer();
const allocater = std.heap.page_allocator;

pub fn cd(input: []u8) !void {
    var args = std.mem.split(u8, input, " ");
    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "..")) {
            const cwd = try std.fs.cwd().realpathAlloc(allocater, ".");
            defer allocater.free(cwd);

            const parent = try getParentDir(cwd);

            var parent_dir = try std.fs.cwd().openDir(parent, .{});

            defer parent_dir.close();

            try parent_dir.setAsCwd();
            try marker.printShellMarker();
        }
    }
}

fn getParentDir(dir: []const u8) ![]const u8 {
    const last_delimiter = std.mem.lastIndexOfScalar(u8, dir, '/');
    if (last_delimiter == null) {
        return error.SplitError;
    }
    return dir[0..last_delimiter.?];
}
