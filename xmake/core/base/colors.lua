--!The Make-like Build Utility based on Lua
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 
-- Copyright (C) 2015 - 2017, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        colors.lua
--

-- define module
local colors = colors or {}

-- load modules
local emoji = emoji or require("base/emoji")

-- the 256 color keys
--
-- from https://github.com/hoelzro/ansicolors
--
colors._keys256 = 
{
    -- attributes
    reset       = 0
,   clear       = 0
,   default     = 0
,   bright      = 1
,   dim         = 2
,   underline   = 4
,   blink       = 5
,   reverse     = 7
,   hidden      = 8

    -- foreground 
,   black       = 30
,   red         = 31
,   green       = 32
,   yellow      = 33
,   blue        = 34
,   magenta     = 35
,   cyan        = 36
,   white       = 37

    -- background 
,   onblack     = 40
,   onred       = 41
,   ongreen     = 42
,   onyellow    = 43
,   onblue      = 44
,   onmagenta   = 45
,   oncyan      = 46
,   onwhite     = 47
}

-- the 24bits color keys
--
-- from https://github.com/hoelzro/ansicolors
--
colors._keys24 = 
{
    -- attributes
    reset       = 0
,   clear       = 0
,   default     = 0
,   bright      = 1
,   dim         = 2
,   underline   = 4
,   blink       = 5
,   reverse     = 7
,   hidden      = 8

    -- foreground 
,   black       = "38;2;0;0;0"
,   red         = "38;2;255;0;0"
,   green       = "38;2;0;255;0"
,   yellow      = "38;2;255;255;0"
,   blue        = "38;2;0;0;255"
,   magenta     = "38;2;255;0;255"
,   cyan        = "38;2;0;255;255"
,   white       = "38;2;255;255;255"

    -- background 
,   onblack     = "48;2;0;0;0"
,   onred       = "48;2;255;0;0"
,   ongreen     = "48;2;0;255;0"
,   onyellow    = "48;2;255;255;0"
,   onblue      = "48;2;0;0;255"
,   onmagenta   = "48;2;255;0;255"
,   oncyan      = "48;2;0;255;255"
,   onwhite     = "48;2;255;255;255"
}

-- the escape string
colors._escape = string.char(27) .. '[%sm'

-- support 256 colors?
function colors.has256()

    -- this is supported if be not windows
    if os.host() ~= "windows" then
        return true
    end

    -- this is supported if exists ANSICON envirnoment variable on windows
    return os.getenv("ANSICON") 
end

-- support 24bits true colors
function colors.truecolor()

    -- this is supported if be not windows
    if os.host() ~= "windows" then
--        return true
    end
end

-- make rainbow color code by the index of characters
--
-- @param index     the index of characters
-- @param seed      the seed, 0-255, default: random
-- @param freq      the frequency, default: 0.1
-- @param spread    the spread, default: 3.0 
--
--
function colors.rainbow(index, seed, freq, spread)

    -- init values
    seed   = seed
    freq   = freq or 0.1
    spread = spread or 3.0
    index  = seed + index / spread

    -- make colors
    local red   = math.sin(freq * index + 0) * 127 + 128
    local green = math.sin(freq * index + 2 * math.pi / 3) * 127 + 128
    local blue  = math.sin(freq * index + 4 * math.pi / 3) * 127 + 128

    -- make code
    return string.format("%d;%d;%d", red, green, blue)
end

-- translate colors from the string
-- 
-- colors:
--
-- "${red}hello"
-- "${onred}hello${clear} xmake"
-- "${bright red underline}hello"
-- "${dim red}hello"
-- "${blink red}hello"
-- "${reverse red}hello xmake"
--
-- true colors:
--
-- "${255;0;0}hello"
-- "${on;255;0;0}hello${clear} xmake"
-- "${bright 255;0;0 underline}hello"
-- "${bright on;255;0;0 0;255;0}hello${clear} xmake"
--
-- emoji:
--
-- "${beer}hello${beer}world"
--
function colors.translate(str)

    -- check string
    if not str then
        return nil
    end

    -- patch reset
    str = "${reset}" .. str .. "${reset}"

    -- translate it
    str = string.gsub(str, "(%${(.-)})", function(_, word) 

        -- not supported? ignore it
        if not colors.has256() and not colors.truecolor() then
            return ""
        end

        -- attempt to translate to emoji first
        local emoji_str = emoji.translate(word)
        if emoji_str then
            return emoji_str
        end

        -- get keys
        local keys = colors._keys256
        if colors.truecolor() then
            keys = colors._keys24
        end

        -- make color buffer
        local buffer = {}
        for _, key in ipairs(word:split("%s+")) do

            -- get the color code
            local code = keys[key]
            if not code and key:find(";", 1, true) and colors.truecolor() then
                if key:startswith("on;") then
                    code = key:gsub("on;", "48;2;")
                else
                    code = "38;2;" .. key
                end
            end
            assert(code, "unknown color: " .. key)

            -- save this code
            table.insert(buffer, code)
        end

        -- format the color buffer
        return colors._escape:format(table.concat(buffer, ";"))
    end)

    -- ok
    return str
end

-- return module
return colors
