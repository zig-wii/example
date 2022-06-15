const std = @import("std");
const ogc = @import("vendor/ogc/build.zig");

pub fn build(builder: *std.build.Builder) !void {
    var obj = try ogc.target_wii(builder, .{ .name = "example", .wii_ip = "192.168.11.171" });
    obj.addPackagePath("ogc", "vendor/ogc/src/main.zig");
}
