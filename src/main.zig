const std = @import("std");
const ArrayList = std.ArrayList(u8);

pub usingnamespace Sushi;

const Sushi = struct {
    data: ArrayList,

    pub fn from(alloc: std.mem.Allocator, data: []const u8) !Sushi {
        var string = Sushi{
            .data = ArrayList.init(alloc),
        };
        try string.data.appendSlice(data);
        return string;
    }
    pub fn free(self: Sushi) void {
        self.data.deinit();
    }
    pub fn copy(self: Sushi) !Sushi {
        return self.from(self.data.allocator, self.data.items);
    }

    pub fn append(self: *Sushi, data: []const u8) !void {
        try self.data.appendSlice(data);
    }
    pub fn eql(self: Sushi, otherString: []const u8) bool {
        return std.mem.eql(u8, self.data.items, otherString);
    }
    pub fn indexOf(self: Sushi, searchString: []const u8) ?usize {
        const selfStr = self.data.items;
        pos: for (0..selfStr.len - searchString.len + 1) |curr_i| {
            for (searchString, 0..) |check_char, check_i| {
                if (check_char != selfStr[curr_i + check_i]) continue :pos;
            }
            return curr_i;
        }
        return null;
    }
    pub fn includes(self: Sushi, searchString: []const u8) bool {
        const pos = self.indexOf(searchString);
        return pos != null;
    }
    //pub fn replace(self: Str, searchValue: []const u8, replaceValue: []const u8) void {
    //    _ = replaceValue;
    //    _ = searchValue;
    //    _ = self;
    //    return;
    //}
    pub fn str(self: Sushi) []const u8 {
        return self.data.items;
    }
    pub fn toLowerCase(self: *Sushi) void {
        for (self.data.items, 0..) |char, i| {
            if (!(64 < char and char < 91)) continue;
            self.data.items[i] = char + 32;
        }
    }
    pub fn toUpperCase(self: *Sushi) void {
        for (self.data.items, 0..) |char, i| {
            if (!(96 < char and char < 123)) continue;
            self.data.items[i] = char - 32;
        }
    }
    //pub fn trim(self: Str) void {
    //    _ = self;
    //    return;
    //}
};

test "Core Test" {
    const alloc = std.testing.allocator;
    var str = try Sushi.from(alloc, "Chiissu!!");
    defer str.free();

    try str.append("Yes");
    try std.testing.expect(str.indexOf("!!").? == 7);
    try std.testing.expect(str.includes("!!"));
    try std.testing.expect(!str.includes("BS"));
    str.toLowerCase();
    try std.testing.expect(str.eql("chiissu!!yes"));
    str.toUpperCase();
    try std.testing.expect(str.eql("CHIISSU!!YES"));
}
