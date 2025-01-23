// purpose: provide critical functions for running .zi files
const std = @import("std");
const ArrayList = std.ArrayList;
const cd = @import("../commands/cd.zig");
const exit = @import("../commands/exit.zig");
const execute = @import("../utils/execute.zig");
const marker = @import("../utils/marker.zig");
const file = @import("../utils/file.zig");

// @constCast is everywhere lol

// the u8 is not a char it is return code
pub fn runZiFile(path: []const u8, allocater: std.mem.Allocator, envVarMap: *std.StringHashMap([]u8), shortens: *std.StringHashMap([]u8)) !u8 {
    const stdout = std.io.getStdOut().writer();

    if (!try file.fileExists(path)) {
        try stdout.print("file does not exist", .{});
        return 1;
    }
    const ziFile = try file.fileReadAll(path, allocater);
    defer allocater.free(ziFile);

    var ziFileLines = std.mem.split(u8, ziFile, "\n");

    while (ziFileLines.next()) |line| {
        if (std.mem.startsWith(u8, line, "exit")) {
            try exit.exit();
        } else if (std.mem.startsWith(u8, line, "cd")) {
            cd.cd(@constCast(line), allocater, false, envVarMap) catch |err| {
                try stdout.print("zi interpreter error:\n\ncd returned: {}\n\n", .{err});
            };
        } else if (std.mem.startsWith(u8, line, "@defaultPWD")) {
            var tokenList = try tokenize(line, allocater);

            defer tokenList.deinit();

            if (tokenList.items.len == 1 or !std.mem.eql(u8, tokenList.items[1], "=")) {
                try stdout.print("zi interpreter error:\n\nexpected: = after: {s}\n\n", .{tokenList.items[0]});
                return 1;
            }

            if (tokenList.items.len == 3 and std.mem.count(u8, tokenList.items[2], "$") > 0) {
                const indexOfVarMarker: ?usize = std.mem.indexOf(u8, tokenList.items[2], "$");
                if (indexOfVarMarker == null) {
                    try stdout.print("zi interpreter error:\n\n im as clueless as you please make a github issue and attach the zi file\n\n", .{});
                    return 1;
                }
                const envVarKey = tokenList.items[2][indexOfVarMarker.? + 1 ..];
                const envVar = try std.process.getEnvVarOwned(allocater, envVarKey);
                try cd.setDefaultPWD(envVar);
            } else if (tokenList.items.len == 3) {
                try cd.setDefaultPWD(tokenList.items[2]);
            } else {
                try stdout.print("zi interpreter error:\n\nexpected: (value) after: {s}\n\n", .{tokenList.items[1]});
                return 1;
            }
        } else if (std.mem.startsWith(u8, line, "@set")) {
            var tokenList = try tokenize(line, allocater);

            defer tokenList.deinit();

            const indexOfMarker: ?usize = std.mem.indexOf(u8, tokenList.items[0], "@set");
            if (indexOfMarker == null) {
                try stdout.print("zi interpreter error:\n\n unknown error please make a github issue with the .zi file attached\n\n", .{});
                return 1;
            }

            if (tokenList.items.len == 1 or !std.mem.eql(u8, tokenList.items[1], "=")) {
                try stdout.print("zi interpreter error:\n\nexpected: = after: {s}\n\n", .{tokenList.items[0]});
                return 1;
            }

            if (tokenList.items.len < 3) {
                try stdout.print("zi interpreter error:\n\nexpected: (value) after: =\n\n", .{});
                return 1;
            }

            const newVarKey: []const u8 = tokenList.items[0][indexOfMarker.? + 4 ..];

            var newShortenVal = ArrayList(u8).init(allocater);
            defer newShortenVal.deinit();

            for (tokenList.items[2..]) |item| {
                if (!std.mem.eql(u8, tokenList.items[2], item)) {
                    try newShortenVal.appendSlice(" ");
                }
                try newShortenVal.appendSlice(item);
            }

            // btw this gets deallocated later
            const clonedVarVal = try allocater.alloc(u8, newShortenVal.items.len);
            const clonedVarKey = try allocater.alloc(u8, newVarKey.len);
            std.mem.copyForwards(u8, clonedVarVal, @constCast(newShortenVal.items));
            std.mem.copyForwards(u8, clonedVarKey, @constCast(newVarKey));

            try envVarMap.put(clonedVarKey, clonedVarVal);
        } else if (std.mem.startsWith(u8, line, "@PS1")) {
            var tokenList = try tokenize(line, allocater);

            defer tokenList.deinit();

            const indexOfMarker: ?usize = std.mem.indexOf(u8, tokenList.items[0], "@PS1");
            if (indexOfMarker == null) {
                try stdout.print("zi interpreter error:\n\n unknown error please make a github issue with the .zi file attached\n\n", .{});
                return 1;
            }

            if (tokenList.items.len == 1 or !std.mem.eql(u8, tokenList.items[1], "=")) {
                try stdout.print("zi interpreter error:\n\nexpected: = after: {s}\n\n", .{tokenList.items[0]});
                return 1;
            }

            if (tokenList.items.len < 3) {
                try stdout.print("zi interpreter error:\n\nexpected: (value) after: =\n\n", .{});
                return 1;
            }

            var newPsVal = ArrayList(u8).init(allocater);
            defer newPsVal.deinit();

            for (tokenList.items[2..]) |item| {
                if (!std.mem.eql(u8, tokenList.items[2], item)) {
                    try newPsVal.appendSlice(" ");
                }

                try newPsVal.appendSlice(item);
            }

            try stdout.print("{s}", .{newPsVal.items});
        } else if (std.mem.startsWith(u8, line, "@shorten")) {
            var tokenList = try tokenize(line, allocater);

            defer tokenList.deinit();

            const indexOfMarker: ?usize = std.mem.indexOf(u8, tokenList.items[0], "@shorten");
            if (indexOfMarker == null) {
                try stdout.print("zi interpreter error:\n\n unknown error please make a github issue with the .zi file attached\n\n", .{});
                return 1;
            }

            if (tokenList.items.len == 1 or !std.mem.eql(u8, tokenList.items[1], "=")) {
                try stdout.print("zi interpreter error:\n\nexpected: = after: {s}\n\n", .{tokenList.items[0]});
                return 1;
            }

            if (tokenList.items.len < 3) {
                try stdout.print("zi interpreter error:\n\nexpected: (value) after: =\n\n", .{});
                return 1;
            }

            var newShortenVal = ArrayList(u8).init(allocater);
            defer newShortenVal.deinit();

            const newShortenKey: []const u8 = tokenList.items[0][indexOfMarker.? + 8 ..];

            for (tokenList.items[2..]) |item| {
                if (!std.mem.eql(u8, tokenList.items[2], item)) {
                    try newShortenVal.appendSlice(" ");
                }
                try newShortenVal.appendSlice(item);
            }

            // btw this gets deallocated later
            const clonedShortenVal = try allocater.alloc(u8, newShortenVal.items.len);
            const clonedShortenKey = try allocater.alloc(u8, newShortenKey.len);
            std.mem.copyForwards(u8, clonedShortenVal, @constCast(newShortenVal.items));
            std.mem.copyForwards(u8, clonedShortenKey, @constCast(newShortenKey));

            try shortens.put(clonedShortenKey, clonedShortenVal);
        } else if (std.mem.eql(u8, line, "")) {
            continue;
        } else if (line[0] == '#') {
            continue;
        } else {
            execute.execute(@constCast(line), allocater, false, envVarMap) catch |err| {
                try stdout.print("zi interpreter error:\n\nexecuted: {s} and it returned {}\n\n", .{ line, err });
                return 1;
            };
        }
    }

    return 0;
}

// if this function is called make sure to defer deinit the output
fn tokenize(line: []const u8, allocater: std.mem.Allocator) !std.ArrayList([]const u8) {
    var tokens = std.mem.split(u8, line, " ");
    var tokenList = ArrayList([]const u8).init(allocater);

    while (tokens.next()) |token| {
        try tokenList.append(token);
    }

    return tokenList;
}
