const zigcord = @import("zigcord");
const std = @import("std");

pub fn getOption(option_name: []const u8, options: []const zigcord.model.interaction.ApplicationCommandInteractionDataOption) ?zigcord.model.interaction.ApplicationCommandInteractionDataOption {
    for (options) |option| {
        if (std.mem.eql(u8, option.name, option_name)) {
            return option;
        }
    }
    return null;
}
