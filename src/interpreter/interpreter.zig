// purpose: provide critical functions for running .zi files
const std = @import("std");
const ArrayList = std.ArrayList;
const stdout = std.io.getStdOut().writer();
const cd = @import("../commands/cd.zig");
const execute = @import("../utils/execute.zig");
const marker = @import("../utils/marker.zig");
const file = @import("../utils/file.zig");

// the u8 is not a char it is return code
pub fn runZiFile(path: []const u8, allocater: std.mem.Allocator) !u8 {
    if (!try file.fileExists(path)) {
        try stdout.print("file does not exist", .{});
        return 1;
    }
    const ziFile = try file.fileReadAll(path);

    var ziFileLines = std.mem.split(u8, ziFile, "\n");

    var tokenList = ArrayList([]const u8).init(allocater);
    var lineList = ArrayList([]const u8).init(allocater);
    defer {
        tokenList.deinit();
        lineList.deinit();
    }
    while (ziFileLines.next()) |line| {
        var tokens = std.mem.split(u8, line, " ");
        while (tokens.next()) |token| {
            try tokenList.append(token);
        }
        try lineList.append(line);
    }
    var i: u8 = 0;
    while (i <= lineList.items.len - 1) : (i += 1) {
        execute.execute(@constCast(lineList.items[i]), allocater, false) catch {};
    }
    i = 0;
    while (i <= tokenList.items.len - 1) : (i += 1) {
        if (std.mem.eql(u8, tokenList.items[i], "@defaultPWD")) {
            if (!std.mem.eql(u8, tokenList.items[i + 1], "=")) {
                return 1;
            }
            if (std.mem.count(u8, tokenList.items[i + 2], "$") > 0) {
                const indexOfVarMarker: ?usize = std.mem.indexOf(u8, tokenList.items[i + 2], "$");
                if (indexOfVarMarker == null) {
                    return 1;
                }
                const envVarKey = tokenList.items[i + 2][indexOfVarMarker.? + 1 ..];
                const envVar = try std.process.getEnvVarOwned(allocater, envVarKey);

                try cd.setDefaultPWD(envVar);
            }
        }
    }

    return 0;
}
