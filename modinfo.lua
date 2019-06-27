name = "Composting Together"
version = "0.2.3"
description = "Version " .. version .. "\n\n Adds a compost pile to the game. Make the best out of your spoiled food!"
author = "s1m13"

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
        hover = "The amount of poop that is produced while composting. Higher is easier.",
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
        hover = "The duration it takes to produce poop.",
        options = {
            { description = "Long", data = "realistic" },
            { description = "Default", data = "default" },
            { description = "Short", data = "efficient" },
        },
        default = "default",
    },

    {
        name = "cost",
        label = "Cost",
        hover = "The cost of the compostpile to build initially. Lower is easier.",
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
        hover = "The bonus you receive in the form of poop after triggering the fertile soil advantage (read the documentation). Higher is easier.",
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
        hover = "Whether or not fireflies can be spawned after composting (read the documentation). Always is easiest.",
        options = {
            { description = "Always", data = "always" },
            { description = "On", data = "on" },
            { description = "Off", data = "off" },
        },
        default = "on",
    },
}
