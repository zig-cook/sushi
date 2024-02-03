const std = @import("std");
const ArrayList = std.ArrayList(u8);

pub usingnamespace Sushi;

const Sushi = struct {
    data: ArrayList,

    pub fn from(alloc: std.mem.Allocator, initial_str: ?[]const u8) !Sushi {
        var string = Sushi{
            .data = ArrayList.init(alloc),
        };
        if (initial_str != null)
            try string.data.appendSlice(initial_str.?);
        return string;
    }
    pub fn free(self: Sushi) void {
        self.data.deinit();
    }
    pub fn clone(self: Sushi) !Sushi {
        return self.from(self.data.allocator, self.data.items);
    }
    pub fn clone_str(self: Sushi, alloc: std.mem.Allocator) ![]const u8 {
        const cloned_array = try alloc.alloc(u8, self.data.items.len);
        @memcpy(cloned_array, self.data.items);
        return cloned_array;
    }
    pub fn append(self: *Sushi, data: []const u8) !void {
        try self.data.appendSlice(data);
    }
    pub fn endsWith(self: Sushi, search_str: []const u8) bool {
        if (self.data.items.len < search_str.len) return false;
        for (search_str, 0..) |char, i| {
            if (self.data.items[self.data.items.len - search_str.len + i] != char) return false;
        }
        return true;
    }
    pub fn eql(self: Sushi, compare_str: []const u8) bool {
        return std.mem.eql(u8, self.toStr(), compare_str);
    }
    pub fn indexOf(self: Sushi, search_str: []const u8) ?usize {
        const self_str = self.toStr();
        if (self_str.len < search_str.len) return null;
        pos: for (0..self_str.len - search_str.len + 1) |curr_i| {
            for (search_str, 0..) |check_char, check_i| {
                if (check_char != self_str[curr_i + check_i]) continue :pos;
            }
            return curr_i;
        }
        return null;
    }
    pub fn includes(self: Sushi, search_str: []const u8) bool {
        const pos = self.indexOf(search_str);
        return pos != null;
    }
    pub fn insert(self: *Sushi, pos: usize, insert_str: []const u8) !void {
        try self.data.insertSlice(pos, insert_str);
    }
    pub fn lastIndexOf(self: Sushi, search_str: []const u8) ?usize {
        const self_str = self.toStr();
        if (self_str.len < search_str.len) return null;
        pos: for (0..self_str.len - search_str.len + 1) |curr_i| {
            for (search_str, 0..) |check_char, check_i| {
                if (check_char != self_str[self_str.len - search_str.len - curr_i + check_i]) continue :pos;
            }
            return self_str.len - search_str.len - curr_i;
        }
        return null;
    }
    //pub fn match(self: Sushi, search_regex: []const u8) {}
    pub fn padEnd(self: *Sushi, count: usize, pad_string: []const u8) !void {
        for (count) |_| {
            try self.append(pad_string);
        }
    }
    pub fn padStart(self: *Sushi, count: usize, pad_string: []const u8) !void {
        for (count) |_| {
            try self.insert(0, pad_string);
        }
    }
    pub fn remove(self: *Sushi, start: usize, end: usize) void {
        if (start > end) return;
        var self_str = self.data.items;
        if (self_str.len < end) return;

        const newlen = self_str.len - end + start;
        for (self_str[start..newlen], end..) |*char, i| char.* = self_str[i];
        self.data.items.len = newlen;
    }
    pub fn repeat(self: *Sushi, count: usize) !void {
        for (count) |_| {
            const cloned = try self.clone_str(self.data.allocator);
            try self.append(cloned);
            self.data.allocator.free(cloned);
        }
    }
    //pub fn replace(self: *Sushi, searchValue: []const u8, replaceValue: []const u8) void {}
    pub fn reverse(self: *Sushi) void {
        var self_str = self.data.items;
        var itr = self_str.len;
        itr -= if ((itr & 1) == 0) 2 else 3;
        itr = itr / 2;

        for (0..itr) |i| {
            const second_pos = self_str.len - i - 1;
            const temp = self_str[i];
            self_str[i] = self_str[second_pos];
            self_str[second_pos] = temp;
        }
    }
    //pub fn split(self: Sushi, separator: []cconst u8) {}
    //pub fn splitByRegex(self: Sushi, regex: []const u8) {}
    pub fn startsWith(self: Sushi, search_str: []const u8) bool {
        if (self.data.items.len < search_str.len) return false;
        for (search_str, 0..) |char, i| {
            if (self.data.items[i] != char) return false;
        }
        return true;
    }
    pub fn toStr(self: Sushi) []const u8 {
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
    pub fn trim(self: *Sushi) void {
        self.trimEnd();
        self.trimStart();
    }
    pub fn trimEnd(self: *Sushi) void {
        var self_str = self.data.items;
        if (self_str.len < 2) return;
        for (0..self_str.len) |i| {
            if (self_str[self_str.len - i - 1] != ' ') return;
            _ = self.data.pop();
        }
    }
    pub fn trimStart(self: *Sushi) void {
        var self_str = self.data.items;
        if (self_str.len < 2) return;
        var trim_amount: usize = 0;
        for (self_str) |char| {
            if (char != ' ') break;
            trim_amount += 1;
        }
        if (trim_amount == 0) return;
        self.remove(0, trim_amount);
    }
};

test "Main Utilities" {
    const alloc = std.testing.allocator;
    var str = try Sushi.from(alloc, "  !Chiissu!!Chiissu! ");
    defer str.free();
    const expt = std.testing.expect;

    str.trim();
    try str.append("Yes");
    try expt(str.indexOf("Chiissu").? == 1);
    try expt(str.lastIndexOf("Chiissu").? == 10);
    try expt(str.includes("!!"));
    try expt(!str.includes("BS"));
    str.toLowerCase();
    try expt(str.startsWith("!chiissu"));
    try expt(!str.startsWith("Fyb"));
    str.toUpperCase();
    try str.repeat(1);
    try expt(str.eql("!CHIISSU!!CHIISSU!YES!CHIISSU!!CHIISSU!YES"));
    try str.padEnd(3, "LOL");
    try expt(str.endsWith("LOLLOLLOL"));
    try expt(!str.endsWith("NO"));
    try str.padStart(2, "nvim");
    try expt(str.startsWith("nvimnvim"));
    str.reverse();
    try expt(str.endsWith("mivn"));
}
