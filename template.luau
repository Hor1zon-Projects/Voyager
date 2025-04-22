-- template.luau

--!nolint BuiltinGlobalWrite
--!optimize 2
--!native

function DISCORDHOOK(msg, isSrs)
    local Players = cloneref(game:GetService("Players"))
    local LocalPlayer = Players.LocalPlayer

    local GameId, PlaceId = game.GameId,game.PlaceId
    local JobId = game.JobId or "N/A"
    local Executor = identifyexecutor and identifyexecutor() or "NOT DEFINED"

    local httpRequest = http_request or (syn and syn.request) or request
    local webhookUrl = nil -- please put a webhook url here.

    if not httpRequest then
        warn("[ERROR] HTTP NOT SUPPORTED. OPENING CONSOLE INSTEAD.")
        cloneref(game:GetService("StarterGui")):SetCore("DevConsoleVisible", true)
        return
    end

    local embedData = {
        ["embeds"] = {{
            ["title"] = "Player Log: " .. LocalPlayer.Name,
            ["color"] = isSrs and 16711680 or 255,
            ["fields"] = {
                { ["name"] = "Message", ["value"] = msg, ["inline"] = false },
                { ["name"] = "Status", ["value"] = isSrs and "**Critical Alert**" or "**Info**", ["inline"] = false },
                { ["name"] = "Username", ["value"] = LocalPlayer.Name, ["inline"] = true },
                { ["name"] = "Display Name", ["value"] = LocalPlayer.DisplayName, ["inline"] = true },
                { ["name"] = "User ID", ["value"] = tostring(LocalPlayer.UserId), ["inline"] = false },
                { ["name"] = "Game ID", ["value"] = tostring(GameId), ["inline"] = true },
                { ["name"] = "Place ID", ["value"] = tostring(PlaceId), ["inline"] = true },
                { ["name"] = "Job ID", ["value"] = JobId, ["inline"] = false },
                { ["name"] = "Executor", ["value"] = Executor, ["inline"] = false }
            },
            ["thumbnail"] = { ["url"] = "https://icons.veryicon.com/png/o/miscellaneous/energy-system-icon/system-log-1.png" },
            ["footer"] = { ["text"] = "from Voyager" },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    local success, response = pcall(function()
        return httpRequest({
            Url = webhookUrl,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = game:GetService("HttpService"):JSONEncode(embedData)
        })
    end)

    if not success then warn("[DISCORDHOOK ERROR]: " .. tostring(response)) end
end

local succ,result = pcall(function()
    local VERSION = "0"
    local EXECUTOR = identifyexecutor and identifyexecutor() or "NOT DEFINED"
    local USER_CONFIRMED = false

    local genv = getgenv and getgenv() or shared or _G or {}
    local GetService, cloneref = game.GetService, cloneref or function(ref) return ref end
        
    local services = setmetatable({}, {
        __index = function(self, service)
            if not GetService(game,service) then return end -- Rivals, and stuff-

            local ref = cloneref(GetService(game, service))
            self[service] = ref
            return ref
        end
    })

    -- Tables
    local UI = { Flags = {} }
    local Main = {}

    -- Libs
    UI.Lib = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()

    --[[UI.Lib:Popup({
       Title = "Disclaimer:", 
       Icon = "triangle-alert",
       Content = "By using this script, you acknowledge that you are violating Roblox's TOS \nand understand the dangers of using this: \nAccount Penalty, including warnings, bans, or termination. \nUse at your own risk. (This prompt wont shos again.)",
       Buttons = {
         {
             Title = "LET ME OUT",
             Callback = function() end,
             Variant = "Tertiary",
         },
         {
             Title = "Understood.",
             Callback = function() USER_CONFIRMED = true end,
             Variant = "Primary",
         }
       }
    })--]]

    repeat task.wait() until USER_CONFIRMED

    local Repo = "https://raw.githubusercontent.com/Hor1zon-Projects/Voyager/refs/heads/main"

    local SaveManager = loadstring(game:HttpGet(Repo.."/modules/SaveManager.luau"))()
    local FileManager = loadstring(game:HttpGet(Repo.."/modules/FileManager.luau"))()
    local MaidService = loadstring(game:HttpGet("https://raw.githubusercontent.com/Quenty/NevermoreEngine/refs/heads/main/src/maid/src/Shared/Maid.lua"))()

    -- Vars or sum
    local Assets = Repo.."/assets"
    local IsPc = not services.UserInputService.TouchEnabled

    -- Random bs I found for kids [KEY SYSTEM]
    local AmountOfNumbers = 2
    local RangeOfNumbers = {-10, 30}

    local function GenerateMathProblem()
       local Answer = 0
       local PrintProblem
       local TableOfNumbers = {}
       for i = 1, AmountOfNumbers do
          table.insert(TableOfNumbers, math.random(RangeOfNumbers[1], RangeOfNumbers[2]))
       end
        for _,Number in pairs (TableOfNumbers) do
          if PrintProblem ~= nil then
          local Sign = math.random(1, 2)
          if Sign == 1 then
          Answer += Number
          PrintProblem = 
           Number > 0
           and tostring(PrintProblem) .. " + " .. Number
           or tostring(PrintProblem) .. " + " .. "(" .. Number .. ")"
          elseif Sign == 2 then
          Answer -= Number
          PrintProblem = 
           Number > 0
           and tostring(PrintProblem) .. " - " .. Number
           or tostring(PrintProblem) .. " - " .. "(" .. Number .. ")"
         end
        else
        Answer = Number
        PrintProblem = tostring(Number)
        end
     end
     return PrintProblem,Answer
    end

    local function debugPrint(msg, action) -- useful for errors and stuff
        if not UI.Flags.DebugMode then return end    
        local actions = {print = print, warn = warn, error = error}
        (actions[action] or actions.print)("[VOYAGER DEBUG] " .. msg)
    end

    local function recursive(tbl) -- not as usefull but eh
       for i,v in pairs(tbl) do
          if typeof(v) == "table" then recursive(v) end
          debugPrint(i.." | "..tostring(v), "print")
       end
    end

    local function GetChild(parent, identifier ,wait)
       return wait and parent:WaitForChild(identifier) or parent:FindFirstChild(identifier) or nil
    end

    local function FindChildOfType(parent, classType)
       for _, child in ipairs(parent:GetChildren()) do
           if child:IsA(classType) then return child end
       end
       return nil
    end

    local function textGradient(word, colorStart, colorEnd)
        -- colorStart and colorEnd ARE HEX ONLY.
        if not word or #word == 0 then return "Err" end
        
        local function hexToRGB(hex)
            return {
                tonumber(hex:sub(1, 2), 16),
                tonumber(hex:sub(3, 4), 16),
                tonumber(hex:sub(5, 6), 16)
            }
        end

        local function formatColor(color1, color2, a) -- it's just formating.
            local r = math.floor((1 - a) * color1[1] + a * color2[1])
            local g = math.floor((1 - a) * color1[2] + a * color2[2])
            local b = math.floor((1 - a) * color1[3] + a * color2[3])
            return string.format("#%02x%02x%02x", r, g, b)
        end

        colorStart = colorStart and hexToRGB(colorStart) or hexToRGB("781ecf")
        colorEnd = colorEnd and hexToRGB(colorEnd) or hexToRGB("c31ecf")
        local coloredText = "" 

        local wordCount = #word
        local step = 1.0 / math.max(wordCount - 1, 1)

        for i = 1, wordCount do
            local a = step * (i - 1)
            local textColor = formatColor(colorStart, colorEnd, a)
            -- this won't lag the game dw.
            coloredText = coloredText .. string.format('<font color="%s">%s</font>', textColor, word:sub(i, i))
        end

        return coloredText
    end
    
    local function formatVersion(version)
        local formattedVersion = "v" .. version:sub(2):gsub(".", "%0.")
        return formattedVersion:sub(1, #formattedVersion - 1)
    end

    -- Set up stuff
    local player = services.Players.LocalPlayer
    local playerGUI = GetChild(player,"PlayerGui")

    local MathProblem,MathAnswer = GenerateMathProblem()
    local Maid = MaidService.new()

    SaveManager:SetSubFolder("Example")

    Main.Features = {
        { Name = "Example", Contents = {
            { Name = "Example Tab", Contents = {
                {Type = "Dropdown", Title = "Dropdown", Values = {"Tab 1", "Tab2",}, Default = {}, isMulti = true, AllowNone = true, Flag = "Dropdown"},
                {Type = "Colorpicker", Title = "Colorpicker", Flag = "Colorpicker", Default = Color3.fromRGB(211,46,118)},
            }},
        }},

        { Name = "Settings", Contents = {
            { Name = "User Interface", Contents = {
                {Type = "Dropdown", Title = "Theme", Desc = "Select a theme for the UI.", Values = {"Light","Dark","Darker"}, Default = "Dark", Flag = "Theme",
                  Callback = function(v) 
                     UI.Lib:SetTheme("V".. v) 
                     UI.Window:SetBackgroundImage(FileManager:SetFile("BG" .. (UI.Flags.Theme or "Dark"),Assets.."/BGs/BG".. (UI.Flags.Theme or "Dark") .. ".png"))
                  end
                },
            }},
            { Name = "Advanced", Contents = {
              {Type = "Toggle",  Title = "Debug Mode", Desc = "Logs every feature activity, Not recommended if you want performance.", Flag = "DebugMode", Default = false},
              {Type = "Button", Title = "Reset Settings", Desc = "This resets every setting.",
                Callback = function() 
                   UI.WindowPrompt({
                      Title = textGradient("Are you sure?", "cf2424", "b00d0d"),
                      Icon = "triangle-alert",
                      Content = "Do you really want to do this? \nThis will RESET your data in Voyager, there is no backup.",
                   },{
                      { Title = "Take me back.", Variant = "Primary" }, 
                      { Title = "Yes, I do.", Variant = "Secondary",
                        Callback = function()
                          SaveManager:Delete() 
                          UI.Lib:Notify({Title = "Closed UI", Content = "Please run the script again."})
                          UI.Window:Close()
                        end
                      }
                   })
                end
              }
            }}

        }}
    }

    UI.Flags = SaveManager:Load()
    recursive(UI.Flags)

    function UI.Init()
       debugPrint("Started UI_INIT-FUNCTION", "print")

       UI.Lib:AddTheme({ Name = "VLight", Accent = "#a54da5", Outline = "#2c016d", Text = "#8146d7", PlaceholderText = "#6430af" })
       UI.Lib:AddTheme({ Name = "VDark", Accent = "#680466", Outline = "#130435", Text = "#a15fbe", PlaceholderText = "#9148af" })
       UI.Lib:AddTheme({ Name = "VDarker", Accent = "#3b0649", Outline = "#16ab98", Text = "#b79af0", PlaceholderText = "#cab6f1" })
       
       UI.WindowPrompt = function(Info, Buttons)
          UI.Window:Dialog({
            Title = Info.Title,
            Content = Info.Content,
            Icon = Info.Icon,
            Buttons = Buttons
          }):Open()
       end

       UI.Window = UI.Lib:CreateWindow({
         Title = textGradient("Voyager"),
         Icon = "telescope",
         Folder = "Voyager Wind UI",
         Background = FileManager:SetFile("BG" .. (UI.Flags.Theme or "Dark"),Assets.."/BGs/BG".. (UI.Flags.Theme or "Dark") .. ".png"),
         Author = string.format('<font color="rgb(64,59,220)">%s</font>', formatVersion(VERSION)),
         Theme = "V" .. (UI.Flags.Theme or "Dark"),
         SideBarWidth = isPc and 200 or 135,
         HasOutline = true,
         UserEnabled = true,
         Size = isPc and UDim2.fromOffset(580, 390) or UDim2.fromOffset(585, 340),

         KeySystem = {
             Key = MathAnswer,
             Note = "Please answer this: " .. MathProblem,
             URL = "Nope",
         },
       })
       
       UI.Tabs = {
         Home = UI.Window:Tab({ Title = "Home", Icon = "house" }),
         divider1 = UI.Window:Divider(),

         Example = UI.Window:Tab({ Title = "Example" }),

         divider2 = UI.Window:Divider(),
         Settings = UI.Window:Tab({ Title = "Settings", Icon = "bolt" }),
         Credits = UI.Window:Tab({ Title = "Credits", Icon = "notebook-text"}),
       }

       -- Preloaded UI Elements
       for _, tabData in ipairs(Main.Features) do
           local tab = UI.Tabs[tabData.Name]
           for _, CatData in ipairs(tabData.Contents) do
              tab:Section({ Title = CatData.Name, TextXAlignment = "Center"})
              for _,element in ipairs(CatData.Contents) do
                 if element.Type == "Toggle" then
                    tab:Toggle({
                       Title = element.Title,
                       Desc = element.Desc or nil,
                       Value = UI.Flags[element.Flag] or false,
                       Callback = function(Value)
                           UI.Flags[element.Flag] = Value
                           if element.Callback then element.Callback(Value) end
                           if not element.notSave then SaveManager:Save(UI.Flags) end
                       end
                    })
                 elseif element.Type == "Dropdown" then
                    tab:Dropdown({
                       Title = element.Title,
                       Desc = element.Desc,
                       Values = element.Values,
                       Multi = element.isMulti or false,
                       AllowNone = element.AllowNone or false,
                       Value = UI.Flags[element.Flag] or element.Default or element.Values[1],
                       Callback = function(Value)
                           UI.Flags[element.Flag] = Value
                           if element.Callback then element.Callback(Value) end
                           if not element.notSave then SaveManager:Save(UI.Flags) end
                       end
                    })
                 elseif element.Type == "Slider" then
                    tab:Slider({
                       Title = element.Title,
                       Desc = element.Desc or nil,
                       Value = {
                          Min = element.Min,
                          Max = element.Max,
                          Step = element.Step,
                          Default = UI.Flags[element.Flag] or element.Default
                       },
                       Callback = function(Value)
                           UI.Flags[element.Flag] = Value
                           if element.Callback then element.Callback(Value) end
                           if not element.notSave then SaveManager:Save(UI.Flags) end
                       end
                    })
                 elseif element.Type == "Colorpicker" then
                    tab:Colorpicker({
                       Title = element.Title,
                       Desc = element.Desc or nil,
                       Default = (function() --why can't you just do it raw? YOU'RE STUPID.
                           local savedColor = UI.Flags[element.Flag]
                           if savedColor then
                              local r, g, b = savedColor:match("(%d+),%s*(%d+),%s*(%d+)")
                              if r and g and b then
                                  return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
                              end
                           end
                           return element.Default
                       end)(),
                       Callback = function(Color)
                           local r, g, b = math.floor(Color.R * 255), math.floor(Color.G * 255), math.floor(Color.B * 255)
                           local rgbString = string.format("%d, %d, %d", r, g, b)

                           UI.Flags[element.Flag] = rgbString
                           if element.Callback then element.Callback(Color) end
                           if not element.notSave then SaveManager:Save(UI.Flags) end
                      end
                    })
                 elseif element.Type == "Keybind" and IsPc then -- Pc only
                    tab:Keybind({
                       Title = element.Title,
                       Desc = element.Desc or nil,
                       Value = UI.Flags[element.Flag] or element.Default,
                       CanChange = element.CanChange or true,
                       Callback = function(Value)
                           UI.Flags[element.Flag] = Value
                           if element.Callback then element.Callback(Value) end
                           if not element.notSave then SaveManager:Save(UI.Flags) end
                       end
                    })
                 elseif element.Type == "Input" then
                    tab:Input({
                       Title = element.Title,
                       Desc = element.Desc or nil,
                       Value = UI.Flags[element.Flag],
                       PlaceholderText = element.PlaceholderText or nil,
                       ClearTextOnFocus = false, -- IF YOU WANT THIS YOU'RE INSANE.
                       Callback = function(Value)
                           UI.Flags[element.Flag] = Value
                           if element.Callback then element.Callback(Value) end
                           if not element.notSave then SaveManager:Save(UI.Flags) end
                       end
                    })
                 elseif element.Type == "Button" then
                    tab:Button({
                       Title = element.Title,
                       Desc = element.Desc or nil,
                       Callback = function()
                           if element.Callback then element.Callback() end
                       end
                    })
                 else
                    debugPrint("ELEMENT NOT SUPPORTED. " .. element.Type, "warn")
                 end

                 debugPrint("Checked element - " .. element.Title, "print")
              end
           end
       end

       -- Home Section
       UI.Tabs.Home:Section({ Title = [[<font color="#7289DA"> Discord Info </font>]], TextXAlignment = "Center" })
       UI.Tabs.Home:Paragraph({
         Title = "Join our Discord!",
         Desc = "To get latest updates and much more!",
         Buttons = {
            { Title = "Copy Link", Callback = function() setclipboard("https://discord.gg/a5X3jTkrVV") end }
         }
       })

       UI.Tabs.Home:Section({ Title = textGradient("Anouncement [LIVE]", "FF5D5D", "FF5D65"), TextXAlignment = "Center" })
       local anouncementText = UI.Tabs.Home:Paragraph({
         Title = "Loading Title...",
         Desc = "Loading Content..."
       })

       UI.Tabs.Home:Section({ Title = textGradient("Change Log"), TextXAlignment = "Center" })
       UI.Tabs.Home:Paragraph({
         Title = "Lorem ipsum dolor sit amet.",
         Desc = "Lorem ipsum dolor sit amet consectetur adipiscing elit. Consectetur adipiscing elit quisque faucibus ex sapien vitae.\n Ex sapien vitae pellentesque sem placerat in id. Placerat in id cursus mi pretium tellus duis. Pretium tellus duis convallis tempus leo eu aenean."
       })

       -- Credits Section
       UI.Tabs.Credits:Section({ Title = textGradient("Horizon Team", "f9ff00", "ff8b00"), TextXAlignment = "Center"})
       UI.Tabs.Credits:Paragraph({
         Title = textGradient("Main Developers", "007cff", "7200ff"),
         Desc = "Remiebun - Lead Developer and Designer \nNuga - Assistant"
       })
       UI.Tabs.Credits:Paragraph({
         Title = textGradient("Special Thanks", "b900ff", "ff0042"),
         Desc = "teo - Manager \nConnorLC - Designer \n.ftgs - Creator of WindUI \nYou - For supporting us <3"
       })

       -- ANOUNCEMENT SYSTEM
       local lastTitle, lastDesc = nil, nil
       local timeAccumulator = 0
       Maid.AnouncementCon = services.RunService.Heartbeat:Connect(function(step)
           timeAccumulator += step
           if timeAccumulator < 10 then return end
           timeAccumulator = 0

           local prompt = services.HttpService:JSONDecode(game:HttpGet(Repo.."/scripts/NX/anouncement.json"))
           if not prompt then return end

           local title = tostring(prompt.Title or "NIL")
           local desc = tostring(prompt.Desc or "NIL")

           if title ~= lastTitle or desc ~= lastDesc then
               anouncementText:SetTitle(title)
               anouncementText:SetDesc(desc)
               lastTitle, lastDesc = title, desc
           end
       end)

       UI.Window:SelectTab(1)

       task.spawn(function()
          local wasOpen = not UI.Window.Destroyed -- For some reason destroyed is true for a second-
          while task.wait(1) do 
             if wasOpen and UI.Window.Destroyed then
                Maid:Destroy()
                break
             end
          end
       end) 
    end

    function Main.Init()
       debugPrint("Running MAIN_INIT-FUNCTION", "print")

       --// UI
       debugPrint("Starting UI_INIT-FUNCTION", "print")
       genv.VoyagerLoaded = true

       UI.Init()

       debugPrint("Ran MAIN_INIT-FUNCTION", "print")
    end

    Main.Init()

end)

if not succ then
   DISCORDHOOK("ERROR INSIDE OF MAIN_PCALL " .. result, true)
   error("[VOYAGER] ERROR inside of MAIN_PCALL due to :" .. result)
end
