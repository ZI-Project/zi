// purpose: setup the base for the shell
const std = @import("std");
const exit = @import("commands/exit.zig");
const cd = @import("commands/cd.zig");
const marker = @import("utils/marker.zig");
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();
const allocater = std.heap.page_allocator;
const ChildProcess = std.process.Child;

pub fn shell() !void {
    try marker.printShellMarker();
    while (true) {
        const input: []u8 = try stdin.readUntilDelimiterAlloc(allocater, '\n', 10000);
        defer allocater.free(input);

        if (input.len == 0) {
            try marker.printShellMarker();
            continue;
        }

        if (std.mem.eql(u8, input, "exit")) {
            // RELEASE ME
            try exit.exit();
        }

        if (std.mem.count(u8, input, "cd") > 0) {
            cd.cd(input) catch {
                try stdout.print("Error most likely my bad coding\n", .{});
                try marker.printShellMarker();
            };
        } else {
            execute(input) catch {
                try stdout.print("Error most likely a invalid command\n", .{});
                try marker.printShellMarker();
            };
        }
    }
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

    try marker.printShellMarker();
}
