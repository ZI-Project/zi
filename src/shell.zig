// purpose: setup the base for the shell
const std = @import("std");
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();
const allocater = std.heap.page_allocator;
const ChildProcess = std.process.Child;

pub fn shell() !void {
    try printShellMarker();
    while (true) {
        const input: []u8 = try stdin.readUntilDelimiterAlloc(allocater, '\n', 10000);
        defer allocater.free(input);

        if (input.len == 0) {
            try printShellMarker();
            continue;
        }

        if (std.mem.eql(u8, input, "exit")) {
            // RELEASE ME
            std.process.exit(0);
        }

        execute(input) catch {
            try stdout.print("Error most likely a invalid command\n", .{});
            try printShellMarker();
        };
    }
}

pub fn printShellMarker() !void {
    try printShellMarkDir();
    try stdout.print("zi> ", .{});
}

pub fn printShellMarkDir() !void {
    const cwd = try std.fs.cwd().realpathAlloc(allocater, ".");
    var splitCWD = std.mem.split(u8, cwd, "/");

    var topPathName: ?[]const u8 = undefined;

    while (splitCWD.next()) |split| {
        topPathName = split;
    }

    try stdout.print("[{s}] ", .{topPathName.?});
}

// questionable coding will happen here
pub fn execute(input: []u8) !void {
    var cmdArgs = std.mem.split(u8, input, " ");
    var args = std.ArrayList([]const u8).init(allocater);
    defer args.deinit();

    while (cmdArgs.next()) |arg| {
        try args.append(arg);
    }

    // https://cookbook.ziglang.cc/08-02-external.html only docs i could find on how to do something like this
    var cmd = ChildProcess.init(args.items, allocater);
    cmd.stdout_behavior = .Inherit;
    cmd.stderr_behavior = .Inherit;

    _ = try cmd.spawn();
    _ = try cmd.wait();

    try printShellMarker();
}
