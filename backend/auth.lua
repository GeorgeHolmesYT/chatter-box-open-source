local auth = {
    config = {
        JWT_SECRET = "your-secret-key",
        TOKEN_EXPIRY = 86400,
        REFRESH_EXPIRY = 604800
    }
}

local function generate_token(user_id)
    local header = {
        alg = "HS256",
        typ = "JWT"
    }
    
    local payload = {
        user_id = user_id,
        exp = os.time() + auth.config.TOKEN_EXPIRY,
        iat = os.time()
    }
    
    return jwt.encode(header, payload, auth.config.JWT_SECRET)
end

function auth.validate_user(username, password)
    local user = db:fetch_user(username)
    if user and crypto.verify_password(password, user.password_hash) then
        return {
            token = generate_token(user.id),
            user_id = user.id,
            username = user.username
        }
    end
    return nil, "Invalid credentials"
end

function auth.register_user(user_data)
    local password_hash = crypto.hash_password(user_data.password)
    local user = {
        username = user_data.username,
        email = user_data.email,
        password_hash = password_hash,
        created_at = os.time()
    }
    
    return db:insert_user(user)
end

return auth
