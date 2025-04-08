-- FileManager.luau
local FileManager = {}

FileManager.BaseFolder = "Voyager"
FileManager.AssetsFolder = FileManager.BaseFolder .. "/assets"

if not isfolder(FileManager.BaseFolder) then makefolder(FileManager.BaseFolder) end
if not isfolder(FileManager.AssetsFolder) then makefolder(FileManager.AssetsFolder) end

function FileManager:SetFile(fileName, fileUrl, fileExtension)
    fileExtension = fileExtension or ".png"
    local filePath = self.AssetsFolder .. "/" .. fileName .. fileExtension

    if not isfile(filePath) then
        self:DownloadFile(fileName, fileUrl, fileExtension)
    end

    return self:GetAsset(fileName, fileExtension)
end

function FileManager:DownloadFile(fileName, fileUrl, fileExtension)
    assert(fileName, "[FileManager] File name is required.")
    assert(fileUrl, "[FileManager] File URL is required.")
    fileExtension = fileExtension or ".png"

    local filePath = self.AssetsFolder .. "/" .. fileName .. fileExtension

    if isfile(filePath) then
        return filePath
    end

    local success, result = pcall(function()
        return game:HttpGet(fileUrl, true)
    end)

    if success and result then
        writefile(filePath, result)
        return filePath
    else
        warn("[FileManager] Failed to download file:", result)
        return nil
    end
end

function FileManager:GetAsset(fileName, fileExtension)
    fileExtension = fileExtension or ".png"
    local filePath = self.AssetsFolder .. "/" .. fileName .. fileExtension

    if isfile(filePath) then
        if getsynasset then
            return getsynasset(filePath)
        elseif getcustomasset then
            return getcustomasset(filePath)
        else
            warn("[FileManager] Executor does not support custom assets.")
            return nil
        end
    else
        warn("[FileManager] File not found:", filePath)
        return nil
    end
end

return FileManager
