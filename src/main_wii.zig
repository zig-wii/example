// Provide dependencies designed for the Wii for the main function
const ogc = @import("ogc/ogc.zig");
pub const Pad = ogc.Pad;
pub const Video = ogc.Video;

pub const os = @import("std_compat/os_wii.zig");

// Set the main function to be the portable version of main inside app.zig
const app = @import("app.zig");

export fn main(_: c_int, _: [*]const [*:0]const u8) void {
    app.main();
}

// Phantom value for discerning between wii and non-wii platforms
pub const platform_wii: void = void;