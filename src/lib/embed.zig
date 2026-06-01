const std = @import("std");
const zigcord = @import("zigcord");

pub fn getUrl(allocator: std.mem.Allocator, hero: []const u8) ![]u8 {
    const segments = &[_][]const u8{ "https://github.com/AhhhSaturn/Archmother/blob/main/assets/", hero, ".png?raw=true" };

    const url_raw = try std.mem.join(allocator, "", segments);

    const size = std.mem.replacementSize(u8, url_raw, " ", "%20");
    const url = try allocator.alloc(u8, size);
    _ = std.mem.replace(u8, url_raw, " ", "%20", url);

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
