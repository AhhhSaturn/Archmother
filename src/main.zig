const std = @import("std");
const zigcord = @import("zigcord");
const Io = std.Io;
const random_command = @import("commands/random.zig");

pub const std_options: std.Options = .{ .log_level = switch (@import("builtin").mode) {
    .Debug, .ReleaseSafe => .debug,
    .ReleaseFast => .info,
    .ReleaseSmall => .err,
} };

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;
    const token = init.environ_map.get("TOKEN") orelse {
        std.log.err("env var TOKEN is required.", .{});
        std.process.exit(1);
    };

    var endpoint_client = zigcord.EndpointClient.init(io, allocator, .{ .bot = token });
    defer endpoint_client.deinit();

    var gateway_client = try zigcord.gateway.Client.init(io, allocator, token, zigcord.model.Intents{});
    defer gateway_client.deinit();

    const app_id = gateway_client.getReadyEvent().application.id;
    std.log.info("authenticated as {s}", .{gateway_client.json_ws_client.ready_event.?.event.user.username});

    const random_command_id = try random_command.registerRandomCommand(app_id, &endpoint_client);

    while (true) {
        const event = try gateway_client.readEvent();
        defer event.deinit();

        switch (event.event orelse continue) {
            .interaction_create => |interaction| {
                switch (interaction.data.asSome() orelse continue) {
                    .application_command => |cmd| {
                        if (cmd.id == random_command_id) {
                            try random_command.executeRandomCommand(&endpoint_client, interaction, allocator, io);
                        }
                    },
                    else => continue,
                }
            },
            else => continue,
        }
    }
}
