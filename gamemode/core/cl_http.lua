AddCSLuaFile()

if SERVER then
    return
end

local ip_parts = string.Split(game.GetIPAddress(), ":")
HttpServer = {}

function HttpServer.GetPath(path)
    return "http://" .. ip_parts[1] .. ":" .. 28015 .. "/" .. path
end

function sym.Http(path, method, body, headers, contenttype)
    local p = sym.promise()
    
    local req = {}
    function req.failed(reason)
        print("HTTP error: " .. reason)
    end

    function req.success(code, body, headers)
        print("HTTP_RESPONSE", path, color_white, ": ", body)
        p:Complete(body, code, headers)
    end

    
    print("HTTP_REQUEST", "Callout to ", path)

    req.method = method or "GET"
    req.url = path
    req.type = contenttype or "text/plain; charset=utf-8"
    req.headers = headers

    if istable(body) then
        req.parameters = body
    else
        req.body = body
    end 

    HTTP(req)

    return p
end

function HttpServer.Send(path, method, body, headers, contenttype)
    headers = headers or {}
    headers["Sym-Key"] = HttpServer.Key

    local p = sym.Http(HttpServer.GetPath(path), method, body, headers, contenttype)
    return p
end

-- fileName = string
-- data = the data
-- type = mime i.e. image/png 
function HttpServer.EncodeFile(fileName, data, type)
    -- Read the file to send it via HTTP
    local boundary = "---------------------------" .. os.time()
    local body = ""

    -- Construct the multipart form data body
    body = body .. "--" .. boundary .. "\r\n"
    --body = body .. 'Content-Disposition: form-data; name="file"; filename="' .. fileName .. '"\r\n'
    body = body .. 'Content-Disposition: form-data; name="file"; filename="' .. fileName .. '"\r\n'
    body = body .. "Content-Type: " .. type .. "\r\n\r\n"
    body = body .. data
    body = body .. "\r\n--" .. boundary .. "--\r\n"

    return body, "multipart/form-data; boundary=" .. boundary
end