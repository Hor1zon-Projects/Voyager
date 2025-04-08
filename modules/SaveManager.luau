-- SaveManager.luau
local SaveManager = {}
local HttpService = cloneref(game:GetService("HttpService"))

SaveManager.Folder = "Voyager"
SaveManager.SubFolder = nil
SaveManager.FileName = "config.json"

if not isfolder(SaveManager.Folder) then
    makefolder(SaveManager.Folder)
end

function SaveManager:SetSubFolder(Name)
    self.SubFolder = Name and Name:gsub("[^%w%._-]", "_") or nil
    local folderPath = self.Folder .. (self.SubFolder and ("/" .. self.SubFolder) or "")
    if self.SubFolder and not isfolder(folderPath) then
        makefolder(folderPath)
    end
end

function SaveManager:Load()
    local filePath = self:GetFilePath()
    if not isfile(filePath) then return {} end
    return HttpService:JSONDecode(readfile(filePath))
end

function SaveManager:Save(flags)
    local filePath = self:GetFilePath()
    local folderPath = self.Folder .. (self.SubFolder and ("/" .. self.SubFolder) or "")
    if self.SubFolder and not isfolder(folderPath) then
        makefolder(folderPath)
    end
    writefile(filePath, HttpService:JSONEncode(flags))
end

function SaveManager:Delete()
    local filePath = self:GetFilePath()
    if isfile(filePath) then delfile(filePath) end
end

function SaveManager:ListConfigs()
    local path = self.Folder
    if self.SubFolder then path = path .. "/" .. self.SubFolder end
    if not isfolder(path) then return {} end
    
    local configs = {}
    for _, file in ipairs(listfiles(path)) do
        if file:match("%.json$") then
            table.insert(configs, file:match("([^/]+)%.json$"))
        end
    end
    return configs
end

function SaveManager:GetFilePath()
    local path = self.Folder
    if self.SubFolder then path = path .. "/" .. self.SubFolder end
    return path .. "/" .. self.FileName
end

return SaveManager
