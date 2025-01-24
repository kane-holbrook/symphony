dotnet.load("symhttp")

sym.http = {}
sym.http.Paths = {}
sym.http.Players = sym.http.Players or weaktable(true, false)
sym.http.Keys = sym.http.Keys or weaktable(false, true)

local ip_parts
function sym.http.Start()
    HttpServer.Start(28015)
end

function HttpServer.Receive(req)
    local path = string.TrimLeft(string.lower(req.Path), "/")

    local ply = sym.http.Keys[req.Headers["sym-key"]]    
    local f = sym.http.Paths[path]

    if not f and not string.GetExtensionFromFilename(path) then
        local default = string.TrimRight(path, "/") .. "/" .. "index.htm"

        if sym.http.Paths[default] then
            return {
                StatusCode = 301,
                Headers = {
                    ["Redirect"] = default
                }
            }
        end
    end
   
    if f then
        local resp = {
            StatusCode = 200,
            ContentType = "text/html"
        }

        local content = f(ply, req, resp, path)
        content = content or ""

        if content == true then
            return resp
        else
            if istable(content) then
                content = util.TableToJSON(content)
                resp.Content = content
                resp.ContentType = "application/json"
            else
                resp.Content = content
                resp.ContentType = "text/html"
            end

            return resp
        end
    else
        return { 
            StatusCode = 404,
            ContentType = "text/html"
        }
    end
end

function sym.http.GetPath(path, type)
    ip_parts = ip_parts or string.Split(game.GetIPAddress(), ":")

    --type = type or "api"
    --if type == "" then
        --return "http://" .. ip_parts[1] .. ":" .. sym.http.LogPort:Get() .. "/" .. path
    --end

    type = ""

    return "http://" .. ip_parts[1] .. ":" .. 28015 .. "/" .. type .. "/" .. path
end

-- Relative to data/web
function sym.http.GetStatic(path)
    return sym.http.GetPath(path, "static")
end

-- ["extension"] = { "mimetype", isBinary? }
sym.http.MimeTypes = {
    ["htm"] = { "text/html", false },
    ["html"] = { "text/html", false },
    ["css"] = { "text/css", false },
    ["js"] = { "application/javascript", false },
    ["json"] = { "application/json", false },
    ["xml"] = { "application/xml", false },
    ["txt"] = { "text/plain", false },
    ["csv"] = { "text/csv", false },
    ["pdf"] = { "application/pdf", true },
    ["zip"] = { "application/zip", true },
    ["tar"] = { "application/x-tar", true },
    ["mp3"] = { "audio/mpeg", true },
    ["wav"] = { "audio/wav", true },
    ["ogg"] = { "audio/ogg", true },
    ["png"] = { "image/png", true },
    ["jpg"] = { "image/jpeg", true },
    ["jpeg"] = { "image/jpeg", true },
    ["gif"] = { "image/gif", true },
    ["bmp"] = { "image/bmp", true },
    ["webp"] = { "image/webp", true },
    ["ico"] = { "image/vnd.microsoft.icon", true },
    ["svg"] = { "image/svg+xml", false },
    ["mp4"] = { "video/mp4", true },
    ["avi"] = { "video/x-msvideo", true },
    ["mov"] = { "video/quicktime", true },
    ["mpeg"] = { "video/mpeg", true },
    ["webm"] = { "video/webm", true }
}

function sym.http.Cache(ply, request, response, path)
    response["Headers"]["Cache-Control"] = "Cache-Control: public, max-age=604800"
end

function sym.http.Hook(path, func, validator)
    path = string.lower(path)
    if (isstring(func)) then
        local filePath = filex.GetRelativePath(func, 1)
        local ext = string.GetExtensionFromFilename(filePath)
        
        if ext then
            func = function (ply, request, response, path)
                if validator then
                    
                    if (isbool(validator) and not ply) or not validator(ply, request, response, path) then
                        response.StatusCode = 403
                        return true
                    end
                end

                local mime = sym.http.MimeTypes[ext]
                if not mime then
                    mime = { "application/octet-stream", true }
                end
                
                response.ContentType = mime[1]
                response.Binary = mime[2]
                
                if response.Binary then
                    response.Content = util.Base64Encode(file.Read(filePath, "GAME"))
                else
                    response.Content = file.Read(filePath, "GAME")
                end

                return true
            end
        else
            local files, directories = file.Find(filePath .. "/*", "GAME")
            for k, v in pairs(files) do
                sym.http.Hook(path .. "/" .. v, "/" .. filePath .. "/" .. v)
            end

            for k, v in pairs(directories) do
                sym.http.Hook(path .. "/" .. v, "/" .. filePath .. "/" .. v)
            end

            return true
        end
    end

    sym.http.Paths[path] = func
end

function sym.http.Unhook(path)
    path = string.lower(path)
    sym.http.Paths[path] = nil
end

function sym.http.PlayerKey(ply)
    if sym.http.Players[ply] then
        return sym.http.Players[ply]
    end

    local key = util.SHA256(stringex.Random(128))
    sym.http.Players[ply] = key
    sym.http.Keys[key] = ply
    ply.HttpKey = key
    return key
end

function sym.http.GetPlayerByKey(key)
    return sym.http.Keys[key]

end

hook.Add("Think", "Sym.Http", function ()
    HttpServer.Tick()
end)