const std = @import("std");
const ogc = @import("ogc");
const Pad = ogc.Pad;
const Cuboid = ogc.Cuboid;

export fn main(_: c_int, _: [*]const [*:0]const u8) void {
    ogc.start(run, .perspective);
}

fn run(video: *ogc.Video) !void {
    // State
    var x: f32 = 0;
    var y: f32 = 0;
    var angle: f32 = 0;
    const speed: f32 = 0.1;

    while (true) {
        // Set camera
        video.set_camera(.{ .perspective = .{ .target = .{ .x = x, .y = y, .z = -1 } } });

        // Movement
        for (Pad.update()) |controller, i| {
            if (controller) {
                x -= Pad.stick_x(i) * speed;
                y -= Pad.stick_y(i) * speed;
                if (Pad.button_down(.start, i)) std.os.exit(0);
            }
        }

        // Create cuboid with different colors
        var cube = Cuboid.init(0, 0, -10, 2, 2, 2, 0xAABBCCFF);
        cube.set_colors(.{
            0x000000FF,
            0xFF0000FF,
            0xFFFF00FF,
            0xFFFFFFFF,
            0x00FFFFFF,
            0x0000FFFF,
        });

        // Rotation
        angle += 1;
        const center = cube.center();
        cube.rotate_x(center, angle);
        cube.rotate_z(center, angle / 8);

        // Draw square
        video.start();
        cube.draw();
        video.finish();
    }
}
