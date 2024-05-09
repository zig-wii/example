const std = @import("std");
const ogc = @import("vendor/ogc/build.zig");

pub fn build(builder: *std.build.Builder) !void {
    var obj = try ogc.target_wii(builder, .{ .name = "example" });
    obj.addModule("ogc", builder.createModule(.{
        .source_file = .{ .path = "vendor/ogc/src/main.zig" },
    }));
}
