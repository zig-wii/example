// Provide dependencies designed for PCs for the main function
// none at the moment

// Set the main function to be the portable version of main inside app.zig
const app = @import("app.zig");

pub fn main() void {
    app.main();
}