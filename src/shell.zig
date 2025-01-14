// purpose: setup the base for the shell
const std = @import("std");
const exit = @import("commands/exit.zig");
const cd = @import("commands/cd.zig");
const marker = @import("utils/marker.zig");
const config = @import("utils/config.zig");
const execute = @import("utils/execute.zig");
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();
const allocater = std.heap.page_allocator;

pub fn shell() !void {
    try marker.printShellMarker();
    try config.init();
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
            cd.cd(input) catch |err| {
                try stdout.print("Unknown Error: {}\n", .{err});
                try marker.printShellMarker();
            };
        } else {
            execute.execute(input) catch {
                try stdout.print("Error most likely a invalid command\n", .{});
                try marker.printShellMarker();
            };
        }
    }
}
