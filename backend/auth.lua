local auth = require "auth"
local http = require "http"
local json = require "json"

local server = {
    port = 8080,
    routes = {}
}

server.routes["/api/auth/register"] = function(request)
    local user_data = json.decode(request.body)
    local user, err = auth.register_user(user_data)
    
    if user then
        return {
            status = 200,
            body = json.encode(user)
        }
    end
    
    return {
        status = 400,
        body = json.encode({ error = err })
    }
end

server.routes["/api/auth/login"] = function(request)
    local credentials = json.decode(request.body)
    local result, err = auth.validate_user(
        credentials.username,
        credentials.password
    )
    
    if result then
        return {
            status = 200,
            body = json.encode(result)
        }
    end
    
    return {
        status = 401,
        body = json.encode({ error = err })
    }
end

http.create_server(server.port, function(request)
    local handler = server.routes[request.path]
    if handler then
        return handler(request)
    end
    
    return {
        status = 404,
        body = "Not Found"
    }
end)

print("Server running on port " .. server.port)
