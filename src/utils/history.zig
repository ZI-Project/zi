// purpose: allow you to see commands you ran in the past
const std = @import("std");
const fileUtils = @import("file.zig");

pub fn initHistory(allocater: std.mem.Allocator) !void {
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

    _ = std.fs.cwd().makeDir(cacheDir) catch {};
    _ = std.fs.cwd().makeDir(ziCacheDir) catch {};
    if (!try fileUtils.fileExists(historyFile)) {
        _ = std.fs.cwd().createFile(historyFile, .{}) catch {};
    }
}

pub fn addToHistory(allocater: std.mem.Allocator, line: []const u8) !void {
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

    var file = try std.fs.cwd().openFile(historyFile, .{});
    const fullHistory = try file.readToEndAlloc(allocater, 1000000);
    var arrayToAppend = std.ArrayList(u8).init(allocater);

    defer {
        file.close();
        allocater.free(fullHistory);
        arrayToAppend.deinit();
    }

    try arrayToAppend.appendSlice(fullHistory);
    try arrayToAppend.appendSlice(line);
    try arrayToAppend.appendSlice("\n");

    var newFile = try std.fs.cwd().createFile(historyFile, .{});
    defer newFile.close();
    try newFile.writer().writeAll(arrayToAppend.items);
}

pub fn clearHistory(allocater: std.mem.Allocator) !void {
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

    _ = std.fs.cwd().deleteFile(historyFile) catch {};

    _ = std.fs.cwd().makeDir(cacheDir) catch {};
    _ = std.fs.cwd().makeDir(ziCacheDir) catch {};
    _ = std.fs.cwd().createFile(historyFile, .{}) catch {};
}
