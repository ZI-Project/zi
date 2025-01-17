// purpose: allow you to see commands you ran in the past
const std = @import("std");

pub fn initHistory(allocater: std.mem.Allocator) !void {
    const homeDir = try std.process.getEnvVarOwned(allocater, "HOME");
    const cacheDir = try std.fs.path.join(allocater, &[_][]const u8{ homeDir, ".cache" });
    const ziCacheDir = try std.fs.path.join(allocater, &[_][]const u8{ cacheDir, "zi" });
    const historyFile = try std.fs.path.join(allocater, &[_][]const u8{ ziCacheDir, "history.txt" });

    _ = std.fs.cwd().makeDir(cacheDir) catch {};
    _ = std.fs.cwd().makeDir(ziCacheDir) catch {};
    _ = std.fs.cwd().createFile(historyFile, .{}) catch {};
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
}
