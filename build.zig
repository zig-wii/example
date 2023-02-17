const std = @import("std");
const builtin = @import("builtin");
const print = std.fmt.allocPrint;

pub const Options = struct {
    name: []const u8,
    root_src: []const u8 = "src/main.zig",
    wii_ip: ?[]const u8 = null,
    textures: ?[]const u8 = null,
    dolphin: []const u8 = switch (builtin.target.os.tag) {
        .macos => "Dolphin",
        .windows => "Dolphin.exe",
        else => "dolphin-emu",
    },
};

pub fn build(builder: *std.build.Builder) !void {
    _ = try target_wii(builder, .{ .root_src = "src/main_wii.zig", .name = "wiiko" });
    _ = try target_native(builder, .{ .root_src = "src/main_native.zig", .name = "wiiko_native" });
}

pub fn target_wii(builder: *std.build.Builder, comptime options: Options) !*std.build.LibExeObjStep {
    // ensure devkitpro is installed
    const devkitpro = try print(builder.allocator, "{s}/zig-devkitpro", .{builder.build_root.path.?});
    const base_folder = try std.fs.openDirAbsolute(builder.build_root.path.?, .{});
    base_folder.access("zig-devkitpro", .{}) catch |err| if (err == error.FileNotFound) {
        const repository = switch (builtin.target.os.tag) {
            .macos => "https://github.com/zig-wii/devkitpro-mac",
            .windows => "https://github.com/zig-wii/devkitpro-windows",
            else => "https://github.com/zig-wii/devkitpro-linux",
        };
        try command(builder.allocator, builder.build_root.path.?, &.{ "git", "clone", repository, devkitpro });
    };
    const ext = if (builtin.target.os.tag == .windows) ".exe" else "";

    // set build options   
    const build_options = std.build.ObjectOptions {
        .name = options.name,
        .root_source_file = std.build.FileSource{ .path = options.root_src},
        .target = .{
            .cpu_arch = .powerpc,
            .os_tag = .freestanding,
            .abi = .eabi,
            .cpu_model = .{ .explicit = &std.Target.powerpc.cpu.@"750" },
            .cpu_features_add = std.Target.powerpc.featureSet(&.{.hard_float}),
        },
        // Required to be non-Debug to avoid printing stack traces, which requires stepping through linked libraries (no implementaion for Wii) 
        .optimize = .ReleaseSafe,
    };
    
    const obj = builder.addObject(build_options);
    obj.setOutputDir("zig-out");
    obj.linkLibC();
    // For some reason, obj.setLibCFile doesn't make a difference on whether the output compiles properly.
    obj.setLibCFile(std.build.FileSource{ .path = comptime cwd() ++ "/libc.txt" });
    obj.addIncludePath(try print(builder.allocator, "{s}/libogc/include", .{devkitpro}));
    obj.addIncludePath(try print(builder.allocator, "{s}/devkitPPC/powerpc-eabi/include", .{devkitpro}));
    // Force compiler to use futexes instead of pthreads
    obj.single_threaded = true;

    // ensure images in textures are converted to tpl
    if (options.textures) |textures| {
        const dir = try base_folder.openDir(textures, .{ .iterate = true });
        var iter = dir.iterate();
        while (try iter.next()) |entry| {
            if (std.mem.endsWith(u8, entry.name, ".png")) {
                const input = try print(builder.allocator, "{s}/{s}", .{ textures, entry.name });
                const conv = try print(builder.allocator, "{s}/tools/bin/gxtexconv" ++ ext, .{devkitpro});
                try command(builder.allocator, builder.build_root, &.{ conv, "-i", input });
            }
        }
    }

    // build both elf and dol
    const flags = .{ "-logc", "-lm" };
    const gcc = try print(builder.allocator, "{s}/devkitPPC/bin/powerpc-eabi-gcc" ++ ext, .{devkitpro});
    const libogc = try print(builder.allocator, "-L{s}/libogc/lib/wii", .{devkitpro});
    const elf2dol = try print(builder.allocator, "{s}/tools/bin/elf2dol" ++ ext, .{devkitpro});
    const elf = builder.addSystemCommand(&(.{ gcc, "zig-out/" ++ options.name ++ ".o", "-g", "-DGEKKO", "-mrvl", "-mcpu=750", "-meabi", "-mhard-float", "-Wl,-Map,zig-out/.map", libogc } ++ flags ++ .{ "-o", "zig-out/" ++ options.name ++ ".elf" }));
    const dol = builder.addSystemCommand(&.{ elf2dol, "zig-out/" ++ options.name ++ ".elf", "zig-out/" ++ options.name ++ ".dol" });
    builder.default_step.dependOn(&dol.step);
    dol.step.dependOn(&elf.step);
    elf.step.dependOn(&obj.step);

    // run dol in dolphin
    const run_step = builder.step("run", "Run in Dolphin");
    const emulator = builder.addSystemCommand(&.{ options.dolphin, "-a", "LLE", "-e", "zig-out/" ++ options.name ++ ".dol" });
    run_step.dependOn(&dol.step);
    run_step.dependOn(&emulator.step);

    // deploy dol to wii over network if wii_ip set
    if (options.wii_ip) |wii_ip| {
        const deploy_step = builder.step("deploy", "Deploy to Wii");
        const program = try print(builder.allocator, "{s}/tools/bin/wiiload" ++ ext, .{devkitpro});
        const wiiload = builder.addSystemCommand(&.{ program, "zig-out/" ++ options.name ++ ".dol" });
        wiiload.setEnvironmentVariable("WIILOAD", "tcp:" ++ wii_ip);
        deploy_step.dependOn(&dol.step);
        deploy_step.dependOn(&wiiload.step);
    }

    // debug stack dump addresses using powerpc-eabi-addr2line
    const line_step = builder.step("line", "Get line from crash address");
    line_step.dependOn(&dol.step);
    if (builder.args) |args| {
        for (args) |arg| {
            const program = try print(builder.allocator, "{s}/devkitPPC/bin/powerpc-eabi-addr2line" ++ ext, .{devkitpro});
            const addr2line = builder.addSystemCommand(&.{ program, "-e", "zig-out/" ++ options.name ++ ".elf", arg });
            line_step.dependOn(&addr2line.step);
        }
    }

    // return obj
    return obj;
}

pub fn target_native(builder: *std.build.Builder, comptime options: Options) !*std.build.LibExeObjStep {
    // set build options   
    const build_options = std.build.ExecutableOptions {
        .name = options.name,
        .root_source_file = std.build.FileSource{ .path = options.root_src},
        // Required to be non-Debug to avoid printing stack traces, which requires stepping through linked libraries (no implementaion for Wii) 
        .optimize = .Debug,
    };
    
    const native_exe = builder.addExecutable(build_options);
    native_exe.setOutputDir("zig-out");

    const native_step = builder.step("native", "build native executable");
    native_step.dependOn(&native_exe.step);

    return native_exe;
}

fn cwd() []const u8 {
    return std.fs.path.dirname(@src().file) orelse unreachable;
}

// Runs shell command
fn command(allocator: std.mem.Allocator, dir: []const u8, argv: []const []const u8) !void {
    var child = std.ChildProcess.init(argv, allocator);
    child.cwd = dir;
    child.stderr = std.io.getStdErr();
    child.stdout = std.io.getStdOut();
    _ = try child.spawnAndWait();
}
