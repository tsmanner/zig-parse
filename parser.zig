//! Simple parser experiment in zig
//! API:
//!   Parser - Accepts an item to match with, returning a type that can consume
//!            a string at runtime to match.
//!
//!   any - Matches against any one of it's arguments
//!   {} - Matches the value of a previously matched rule, by name
//!        e.g. `Parser.match()`

const std = @import("std");

pub fn Parser(comptime matcher: anytype) type {
    const info = @typeInfo(matcher);
    
}

pub fn Any(comptime alternatives: anytype) type {
    comptime const Alternatives = @TypeOf(alternatives);
    comptime const info = @typeInfo(Alternatives);
    switch (info) {
        .Pointer => |Pointer| if (@typeInfo(info.Pointer.child).Array.child == u8) {
            return AnyChar(alternatives);
        } else {
            unreachable;
        },
        .Array => |Array| if (Array.child == u8) {
            return AnyChar(alternatives);
        } else {
            unreachable; // AnyArray(alternatives);
        },
        .Struct => |Struct| unreachable, // AnyStruct(alternatives),
        else => unreachable,
    }
}


fn AnyChar(comptime alternatives: []const u8) type {
    return struct {
        const Self = @This();
        pub const Result = struct { match: u8, remainder: []const u8 };
        pub fn match(text: []const u8) ?Result {
            if (text.len > 0) {
                if (std.mem.indexOfPos(u8, alternatives, 0, text[0..1])) |pos| {
                    return Result{ .match = text[0], .remainder = text[1..] };
                }
            }
            return null;
        }
    };
}

test "Any" {
    if (Any("abcde").match("a foo foo bar")) |result| {
        try std.testing.expectEqual(result.match, 'a');
        try std.testing.expectEqualStrings(result.remainder, " foo foo bar");
    } else {
        unreachable;
    }
    if (Any("bcde").match("a foo foo bar")) |result| {
        unreachable;
    }
}

pub const ParseError = error {
    NoMatch,
    NoMatchingAlternative,
};
