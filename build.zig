const std = @import("std");

pub fn build(b: *std.Build) void {
    const zashi_dep = b.dependency("zashi", .{});

    const zashi_exe = zashi_dep.artifact("zashi");
    const run_server = b.addRunArtifact(zashi_exe);
    run_server.addArgs(&.{ "serve", "--root" });
    run_server.addFileArg(.{ .path = "static" });
    if (b.option(u16, "port", "port to listen on for the development server")) |port| {
        run_server.addArgs(&.{ "-p", b.fmt("{d}", .{port}) });
    }

    const run_step = b.step("serve", "Run the local development web server");
    run_step.dependOn(&run_server.step);
}
