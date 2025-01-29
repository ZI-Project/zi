// purpose: print the marker
const std = @import("std");

pub fn printShellMarker(allocater: std.mem.Allocator, psMarker: *std.ArrayList(u8)) !void {
    const stdout = std.io.getStdOut().writer();

    const strippedSize = std.mem.replacementSize(u8, psMarker.items, "\"", "");
    const strippedMarker: []u8 = try allocater.alloc(u8, strippedSize);
    defer allocater.free(strippedMarker);
    _ = std.mem.replace(u8, psMarker.items, "\"", "", strippedMarker);

    var tokens = try tokenize(strippedMarker, allocater);
    defer tokens.deinit();

    var finalMarker = std.ArrayList(u8).init(allocater);
    defer finalMarker.deinit();

    for (tokens.items) |item| {
        if (!std.mem.eql(u8, item, tokens.items[0])) {
            try finalMarker.appendSlice(" ");
        }

        if (std.mem.count(u8, item, "$CWD") > 0) {
            const cwd = try std.fs.cwd().realpathAlloc(allocater, ".");
            defer allocater.free(cwd);
            var splitCWD = std.mem.split(u8, cwd, "/");

            var topPathName: ?[]const u8 = undefined;

            while (splitCWD.next()) |split| {
                topPathName = split;
            }

            if (std.mem.eql(u8, topPathName orelse "", "")) {
                topPathName = "/";
            }

            const dir = topPathName orelse "";

            // https://stackoverflow.com/questions/77550399/how-can-i-replace-all-instances-of-a-character-in-a-string-in-zig
            // i love zig but the docs are just not there yet
            const size = std.mem.replacementSize(u8, item, "$CWD", dir);
            const newItem = try allocater.alloc(u8, size);
            defer allocater.free(newItem);
            _ = std.mem.replace(u8, item, "$CWD", dir, newItem);

            try finalMarker.appendSlice(newItem);
        } else {
            try finalMarker.appendSlice(item);
        }
    }

    try stdout.print("{s}", .{finalMarker.items});
    try stdout.print(" ", .{});
}

fn tokenize(line: []const u8, allocater: std.mem.Allocator) !std.ArrayList([]const u8) {
    var tokens = std.mem.split(u8, line, " ");
    var tokenList = std.ArrayList([]const u8).init(allocater);

    while (tokens.next()) |token| {
        try tokenList.append(token);
    }

    return tokenList;
}
