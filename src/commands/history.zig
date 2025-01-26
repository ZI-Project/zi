const std = @import("std");
const historyUtil = @import("../utils/history.zig");
const file = @import("../utils/file.zig");

pub fn history(input: []u8, allocater: std.mem.Allocator) !void {
    const homeDir = try std.process.getEnvVarOwned(allocater, "HOME");
    const cacheDir = try std.fs.path.join(allocater, &[_][]const u8{ homeDir, ".cache" });
    const ziCacheDir = try std.fs.path.join(allocater, &[_][]const u8{ cacheDir, "zi" });
    const historyFile = try std.fs.path.join(allocater, &[_][]const u8{ ziCacheDir, "history.txt" });
    defer {
        allocater.free(homeDir);
        allocater.free(cacheDir);
        allocater.free(ziCacheDir);
        allocater.free(historyFile);
    }

    const stdout = std.io.getStdOut().writer();
    var args = std.mem.split(u8, input, " ");
    var dontPrint: bool = false;
    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "history")) {
            continue;
        } else if (std.mem.eql(u8, arg, "-c")) {
            try historyUtil.clearHistory(allocater);
            dontPrint = true;
        }
    }
    if (!dontPrint) {
        const fullHistory: []const u8 = try file.fileReadAll(historyFile, allocater);
        defer allocater.free(fullHistory);
        try stdout.print("{s}", .{fullHistory});
    }
}
