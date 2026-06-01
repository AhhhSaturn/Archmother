const zigcord = @import("zigcord");
const std = @import("std");
const embed = @import("../lib/embed.zig");

pub fn registerRandomCommand(application_id: zigcord.model.Snowflake, endpoint_client: *zigcord.EndpointClient) !zigcord.model.Snowflake {
    const command_result = try endpoint_client.createGlobalApplicationCommand(application_id, .{
        .name = "random",
        .description = "pick a random deadlock hero.",
    });
    defer command_result.deinit();

    const command = switch (command_result.value()) {
        .ok => |ok| ok,
        .err => |err| {
            std.log.err("error: {f}", .{std.json.fmt(err, .{})});
            return error.DiscordError;
        },
    };
    return command.id;
}

pub fn executeRandomCommand(endpoint_client: *zigcord.EndpointClient, interaction: zigcord.model.interaction.Interaction, allocator: std.mem.Allocator, io: std.Io) !void {
    std.log.debug("received random command", .{});

    const hero = getRandom(io);

    const url = try embed.getUrl(allocator, hero);
    defer allocator.free(url);

    const result = try endpoint_client.createInteractionResponse(interaction.id, interaction.token, .initChannelMessageWithSource(.{
        .embeds = .initSome(&.{try embed.createEmbed(hero, url)}),
    }));
    defer result.deinit();

    std.log.debug("picked random: {s}", .{hero});
}

fn getRandom(io: std.Io) []const u8 {
    const heroes = [_][]const u8{ "Abrams", "Apollo", "Bebop", "Billy", "Calico", "Celeste", "The Doorman", "Drifter", "Dynamo", "Graves", "Gray Talon", "Haze", "Holliday", "Infernus", "Ivy", "Kelvin", "Lady Geist", "Lash", "McGinnis", "Mina", "Mirage", "Mo & Krill", "Paige", "Paradox", "Pocket", "Rem", "Seven", "Shiv", "Silver", "Sinclair", "Venator", "Victor", "Vindicta", "Viscous", "Vyper", "Warden", "Wraith", "Yamato" };

    const rng: std.Random.IoSource = .{ .io = io };
    const rand = rng.interface();

    const hero_index = rand.uintLessThan(u8, heroes.len);

    return heroes[hero_index];
}
