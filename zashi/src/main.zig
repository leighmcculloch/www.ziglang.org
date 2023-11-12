const std = @import("std");
const Allocator = std.mem.Allocator;

const usage =
    \\usage: zashi serve [options]
    \\
    \\options:
    \\    -p [port]        set the port number to listen on
    \\
;

var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();
    const gpa = general_purpose_allocator.allocator();

    const args = try std.process.argsAlloc(arena);

    if (args.len < 2) fatal("missing subcommand argument", .{});

    const cmd_name = args[1];
    if (std.mem.eql(u8, cmd_name, "serve")) {
        return cmdServe(gpa, arena, args[2..]);
    } else {
        fatal("unrecognized subcommand: '{s}'", .{cmd_name});
    }
}

fn fatal(comptime format: []const u8, args: anytype) noreturn {
    std.debug.print(format, args);
    std.process.exit(1);
}

fn cmdServe(gpa: Allocator, arena: Allocator, args: []const []const u8) !void {
    _ = arena;

    var listen_port: u16 = 0;

    {
        var i: usize = 0;
        while (i < args.len) : (i += 1) {
            const arg = args[i];
            if (std.mem.eql(u8, arg, "-p")) {
                i += 1;
                if (i >= args.len) fatal("expected arg after '{s}'", .{arg});
                listen_port = std.fmt.parseInt(u16, args[i], 10) catch |err| {
                    fatal("unable to parse port '{s}': {s}", .{ args[i], @errorName(err) });
                };
            } else {
                fatal("unrecognized arg: '{s}'", .{arg});
            }
        }
    }

    var server = std.http.Server.init(gpa, .{});
    defer server.deinit();

    const address = try std.net.Address.parseIp("127.0.0.1", listen_port);
    try server.listen(address);
    const server_port = server.socket.listen_address.in.getPort();
    std.debug.print("Listening at http://127.0.0.1:{d}/\n", .{server_port});

    try serve(gpa, &server);
}

fn serve(gpa: Allocator, s: *std.http.Server) !void {
    var header_buffer: [1024]u8 = undefined;
    accept: while (true) {
        var res = try s.accept(.{
            .allocator = gpa,
            .header_strategy = .{ .static = &header_buffer },
        });
        defer res.deinit();

        while (res.reset() != .closing) {
            res.wait() catch |err| switch (err) {
                error.HttpHeadersInvalid => continue :accept,
                error.EndOfStream => continue,
                else => return err,
            };
            try handleRequest(&res);
        }
    }
}

fn handleRequest(res: *std.http.Server.Response) !void {
    const server_body: []const u8 = "message from server!\n";
    res.transfer_encoding = .{ .content_length = server_body.len };
    try res.headers.append("content-type", "text/plain");
    try res.headers.append("connection", "close");
    try res.send();

    var request_buffer: [8 * 1024]u8 = undefined;
    const n = try res.readAll(&request_buffer);
    const request_body = request_buffer[0..n];
    std.debug.print("request_body:\n{s}\n", .{request_body});

    _ = try res.writer().writeAll(server_body);
    try res.finish();
}
