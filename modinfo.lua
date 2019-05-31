name = "Composting Together"
description = "Adds a compost pile to the game. Make the best out of your spoiled food!"
author = "s1m13"

version = "0.2.0"

api_version = 10

dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false
dst_compatible = true

icon_atlas = "compostingtogether.xml"
icon = "compostingtogether.tex"

forumthread = "/topic/30589-mod-request-compost-piles/"

all_clients_require_mod = true
client_only_mod = false
server_filter_tags = { "composting", "compost", "structure", "manure", "production" }


configuration_options =
{
    {
        name = "poop_amount",
        label = "Poop amount",
        options = {
            { description = "Low", data = "low" },
            { description = "Default", data = "default" },
            { description = "High", data = "high" },
        },
        default = "default",
    },

    {
        name = "compost_duration",
        label = "Compost duration",
        options = {
            { description = "Realistic", data = "realistic" },
            { description = "Default", data = "default" },
            { description = "Efficient", data = "efficient" },
        },
        default = "default",
    },

    {
        name = "cost",
        label = "Cost",
        options = {
            { description = "Low", data = "low" },
            { description = "Default", data = "default" },
            { description = "High", data = "high" },
        },
        default = "default",
    },

    {
        name = "fertile_soil_advantage",
        label = "Fertile soil advantage",
        options = {
            { description = "Low", data = "low" },
            { description = "Default", data = "default" },
            { description = "High", data = "high" },
        },
        default = "default",
    },

    {
        name = "spawn_fireflies",
        label = "Attract Fireflies",
        options = {
            { description = "Always", data = "always" },
            { description = "On", data = "on" },
            { description = "Off", data = "off" },
        },
        default = "on",
    },
}
