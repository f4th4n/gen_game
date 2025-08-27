# API docs

## Account

Channel: "gen_game"
Description: Account management for user creation and authentication

### Actions

#### 1. Create account

event: "create_account"

payload:

```json
{
  "username": "indonesia",
  "display_name": "Indonesia Player",
  "avatar_url": "https://example.com/avatar.jpg",
  "lang": "en",
  "timezone": "UTC",
  "email": "player@example.com",
  "wallet": "0x1234...",
  "metadata": {}
}
```

Required fields: `username`
Optional fields: `display_name`, `avatar_url`, `lang`, `timezone`, `email`, `wallet`, `metadata`

Response:
```json
{
  "id": 1,
  "username": "indonesia",
  "display_name": "Indonesia Player",
  "avatar_url": "https://example.com/avatar.jpg",
  "lang": "en",
  "timezone": "UTC",
  "email": "player@example.com",
  "wallet": "0x1234...",
  "metadata": {},
  "inserted_at": "2025-08-27T10:00:00Z",
  "updated_at": "2025-08-27T10:00:00Z"
}
```

## Session Management

Channel: "public"
Description: Session and token management

### Actions

#### 1. Create session

event: "create_session"

payload:

```json
{
  "username": "indonesia"
}
```

Response:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

## OAuth Social Login

### HTTP Endpoints

OAuth authentication is handled through HTTP endpoints, not WebSocket channels.

#### 1. Initiate OAuth Flow

**Social Login:**
```
GET /auth/google?token=<websocket_token>
```

**Account Linking:**
```
GET /auth/google?token=<websocket_token>&link_mode=true
```

Parameters:
- `token` (required): WebSocket session token for receiving results
- `link_mode` (optional): Set to "true" to link OAuth provider to existing account

#### 2. OAuth Callback

```
GET /auth/google/callback
```

This is handled automatically by the OAuth provider. Results are sent via WebSocket to the client using the provided token.

### WebSocket Events

After OAuth flow completion, results are pushed to the WebSocket connection:

#### OAuth Result Event

event: "oauth_result"

**Social Login Success:**
```json
{
  "success": true,
  "token": "new_jwt_token_here",
  "account": {
    "id": 1,
    "username": "indonesia",
    "display_name": "Indonesia Player"
  },
  "msg": "Social login successful"
}
```

**Account Linking Success:**
```json
{
  "success": true,
  "msg": "OAuth provider linked successfully",
  "account": {
    "id": 1,
    "username": "indonesia"
  },
  "linked_providers": ["google"]
}
```

**OAuth Error:**
```json
{
  "success": false,
  "error": "account_not_found",
  "msg": "You must create an account first before using social login"
}
```

### Social Login Constraints

1. **Account Requirement**: Only players with an existing GenGame account can use social login or link OAuth providers
2. **Unique Constraints**: Each OAuth account can only be linked to one GenGame account
2. **Provider Limits**: Each GenGame account can only link one account per OAuth provider

### OAuth Management

Channel: "gen_game"
Description: Manage OAuth provider links

#### 1. List OAuth Links

event: "list_oauth_links"

payload: `{}`

Response:
```json
{
  "linked_providers": ["google", "github"]
}
```

#### 2. Unlink OAuth Provider

event: "unlink_oauth_provider"

payload:

```json
{
  "provider": "google"
}
```

Response:
```json
{
  "msg": "Provider unlinked successfully"
}
```

### Supported OAuth Providers

- `google` - Google OAuth 2.0

### Error Codes

- `missing_token` - No token provided for OAuth flow
- `invalid_token` - Invalid or expired token
- `account_not_found` - Account not found (social login requires existing account)
- `provider_already_linked` - OAuth provider already linked to account
- `provider_uid_already_exists` - OAuth account already linked to another GenGame account
- `cannot_use_social_login` - Account cannot use social login
- `oauth_failed` - OAuth authentication failed
- `oauth_not_configured` - OAuth provider not configured on server
- `provider_not_linked` - Trying to unlink provider that isn't linked