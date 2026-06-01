const std = @import("std");
const zigcord = @import("zigcord");

pub fn getUrl(allocator: std.mem.Allocator, hero: []const u8) ![]u8 {
    const segments = &[_][]const u8{ "https://github.com/AhhhSaturn/Archmother/blob/main/assets/", hero, ".png?raw=true" };

    const url = try std.mem.join(allocator, "", segments);

    return url;
}

pub fn createEmbed(hero: []const u8, url: []const u8) !zigcord.model.Message.Embed {
    std.log.debug("url: {s}", .{url});

    const embed: zigcord.model.Message.Embed = .{
        .title = .initSome(hero),
        .image = .initSome(zigcord.model.Message.Embed.Media{ .url = .initSome(url) }),
        .type = .initSome(zigcord.model.Message.Embed.EmbedType.image),
    };
    return embed;
}
