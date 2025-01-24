// purpose: print the marker
const std = @import("std");

pub fn printShellMarker(allocater: std.mem.Allocator, psMarker: *std.ArrayList(u8)) !void {
    const stdout = std.io.getStdOut().writer();

    const strippedMarker: []u8 = try allocater.alloc(u8, psMarker.items.len);
    defer allocater.free(strippedMarker);
    _ = std.mem.replace(u8, psMarker.items, "\"", "", strippedMarker);

    var tokens = try tokenize(strippedMarker, allocater);
    defer tokens.deinit();

    var finalMarker = std.ArrayList(u8).init(allocater);
    defer finalMarker.deinit();

    for (tokens.items) |item| {
        if (!std.mem.eql(u8, item, tokens.items[0])) {
            try stdout.print(" ", .{});
        }
        // try overflowing this >_<
        const dir = try printDir(allocater);
        const newItem: []u8 = try std.mem.replaceOwned(u8, allocater, item, "$CWD", dir);
        try stdout.print("{s}", .{newItem});
    }

    try stdout.print(" ", .{});
}

fn printDir(allocater: std.mem.Allocator) ![]const u8 {
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
    return topPathName.?;
}

fn tokenize(line: []const u8, allocater: std.mem.Allocator) !std.ArrayList([]const u8) {
    var tokens = std.mem.split(u8, line, " ");
    var tokenList = std.ArrayList([]const u8).init(allocater);

    while (tokens.next()) |token| {
        try tokenList.append(token);
    }

    return tokenList;
}
