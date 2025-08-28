# Flow

This document describes the core flows in GenGame for game creation, player management, and OAuth social login.

## 1. How Games Are Created

The game creation process involves several steps with hooks for server authoritative actions:

### Game Creation Flow

```mermaid
sequenceDiagram
    participant C as Client
    participant GC as GenGameChannel
    participant GH as GameHandler
    participant SA as ServerAuthoritative
    participant GP as Gameplay
    participant S as Storage

    C->>GC: create_match(token)
    GC->>GH: create_match(params, socket)

    Note over GH: Verify token
    GH->>PlayerSession: verify(token)
    PlayerSession-->>GH: {:ok, username}

    Note over GH: Generate match ID
    GH->>GH: Ecto.UUID.generate()

    Note over GH: Before create hook
    GH->>SA: dispatch_event(:before_create_match, payload)
    SA-->>GH: {:ok, validated_payload}

    Note over GH: Create match
    GH->>GP: create_match(username, match_id)
    GP->>S: set(match_id, game_struct)
    S-->>GP: :ok
    GP-->>GH: :ok

    Note over GH: After create hook
    GH->>SA: dispatch_event(:after_create_match, payload)
    SA-->>GH: {:ok, _}

    GH-->>GC: {:reply, {:ok, %{match_id: match_id}}, socket}
    GC-->>C: match_id
```

### Detailed Steps

1. **Client Request**: Client sends `create_match` message with authentication token
2. **Token Verification**: Server verifies the player session token to get username
3. **Match ID Generation**: Server generates a unique UUID for the match
4. **Before Create Hook**: Dispatches `before_create_match` event for server authoritative validation
5. **Game Creation**: Creates a new game struct with initial state:
   - Status: `:started`
   - Players: `[owner_username]`
   - Created timestamp
   - Empty public/private/readonly states
6. **Storage**: Stores the game in distributed ETS storage
7. **After Create Hook**: Dispatches `after_create_match` event for post-creation actions
8. **Response**: Returns the match ID to the client

### Game Structure

```elixir
%Game{
  players: [username],           # List of player usernames
  public_state: %{},            # Client-modifiable state via relay
  private_state: %{},           # Server-only state (not visible to clients)
  read_only_state: %{},         # Read-only state visible to clients
  created_at: timestamp,        # Creation timestamp
  status: :started              # Game status (:open, :started, :finished)
}
```

## 2. How Players Are Created

Player creation involves both account creation and session management:

### Player Account Creation Flow

```mermaid
sequenceDiagram
    participant C as Client
    participant GC as GenGameChannel
    participant AH as AccountHandler
    participant SA as ServerAuthoritative
    participant A as Accounts
    participant DB as Database

    C->>GC: create_account(account_data)
    GC->>AH: create_account(payload, socket)

    Note over AH: Before create hook
    AH->>SA: dispatch_event(:before_create_account, payload)
    SA-->>AH: {:ok, validated_payload}

    Note over AH: Create account
    AH->>A: create_account(attrs)
    A->>DB: INSERT account
    DB-->>A: {:ok, account} | {:error, changeset}
    A-->>AH: result

    alt Account created successfully
        Note over AH: After create hook
        AH->>SA: dispatch_event(:after_create_account, %{account: account})
        SA-->>AH: {:ok, _}
        AH-->>GC: {:reply, {:ok, account}, socket}
        GC-->>C: account_data
    else Account creation failed
        AH-->>GC: {:reply, {:error, error_msg}, socket}
        GC-->>C: error
    end
```

### Player Session Creation Flow

```mermaid
sequenceDiagram
    participant C as Client
    participant PC as PublicChannel
    participant SH as SessionHandler
    participant SA as ServerAuthoritative
    participant PS as PlayerSession

    C->>PC: create_session(username)
    PC->>SH: create_session(%{"username" => username}, socket)

    Note over SH: Before create hook
    SH->>SA: dispatch_event(:before_create_session, payload)
    SA-->>SH: {:ok, _}

    Note over SH: Create session token
    SH->>PS: create(username)
    PS-->>SH: jwt_token

    Note over SH: After create hook
    SH->>SA: dispatch_event(:after_create_session, %{token: token})
    SA-->>SH: {:ok, _}

    SH-->>PC: {:reply, {:ok, %{token: token}}, socket}
    PC-->>C: session_token
```

### Detailed Player Creation Steps

#### Account Creation

1. **Client Request**: Client sends account data (username, display_name, etc.)
2. **Before Create Hook**: Server authoritative validation
3. **Database Insert**: Creates account record with validation:
   - Required: `username`
   - Optional: `display_name`, `avatar_url`, `lang`, `timezone`, `metadata`, `email`, `wallet`
   - Unique constraint on username
4. **After Create Hook**: Post-creation server actions
5. **Response**: Returns account data or validation errors

#### Session Creation

1. **Username Submission**: Client provides username for session
2. **Before Session Hook**: Server authoritative validation
3. **Token Generation**: Creates JWT token with very long expiration (1000 years)
4. **After Session Hook**: Post-session creation actions
5. **Token Response**: Returns JWT token for authentication

### Player Joining Games

```mermaid
sequenceDiagram
    participant C as Client
    participant GCh as GameChannel
    participant GH as GameHandler
    participant GP as Gameplay
    participant PS as PlayerSession
    participant P as Presence

    C->>GCh: join("game:match_id", %{"token" => token})
    GCh->>GH: join(match_id, token, socket)

    Note over GH: Verify game exists
    GH->>GP: check(match_id)
    GP-->>GH: :exist | :not_found

    Note over GH: Verify player token
    GH->>PS: verify(token)
    PS-->>GH: {:ok, username} | {:error, reason}

    alt Valid game and token
        Note over GH: Update presence
        GH->>GH: send(self(), :update_presence)
        GH->>P: track(socket, username, metadata)
        GH-->>GCh: {:ok, socket_with_assigns}
        GCh-->>C: join_success
    else Invalid game or token
        GH-->>GCh: {:error, error_msg}
        GCh-->>C: join_failure
    end
```

## 3. OAuth Social Login Flow

OAuth social login allows users to authenticate using their existing social media accounts while maintaining session state via WebSocket.

### Social Login Flow

```mermaid
sequenceDiagram
    participant C as Client
    participant WS as WebSocket
    participant GC as GenGameChannel
    participant B as Browser
    participant OP as OAuthProvider
    participant AC as AuthController
    participant OLM as OAuthLinkMiddleware
    participant A as Accounts
    participant PS as PlayerSession
    participant PubSub as PubSub

    Note over C: Client has WebSocket token
    C->>B: Open OAuth URL with token
    B->>AC: GET /auth/google?token=ws_token
    AC->>OLM: Middleware processes request
    OLM->>OLM: Store token in session
    OLM->>OP: Redirect to OAuth provider
    OP-->>B: OAuth consent screen
    B->>OP: User authorizes
    OP->>AC: Callback with auth data
    
    Note over AC: Process OAuth callback
    AC->>A: get_by_oauth_provider(provider, uid)
    
    alt Account found (existing link)
        A-->>AC: account
        AC->>PS: create(username)
        PS-->>AC: new_jwt_token
        AC->>PubSub: broadcast oauth_result
        AC-->>B: Success HTML page
        PubSub->>WS: {:oauth_result, result}
        WS->>C: oauth_result event with new token
    else Account not found
        A-->>AC: nil
        AC->>PubSub: broadcast oauth_result
        AC-->>B: Error HTML page
        PubSub->>WS: {:oauth_result, error}
        WS->>C: oauth_result event with error
    end
```

### Account Linking Flow

```mermaid
sequenceDiagram
    participant C as Client
    participant WS as WebSocket
    participant GC as GenGameChannel
    participant B as Browser
    participant OP as OAuthProvider
    participant AC as AuthController
    participant OLM as OAuthLinkMiddleware
    participant A as Accounts
    participant PS as PlayerSession
    participant PubSub as PubSub

    Note over C: Client has existing account + token
    C->>B: Open OAuth URL with token + link_mode=true
    B->>AC: GET /auth/google?token=ws_token&link_mode=true
    AC->>OLM: Middleware processes request
    OLM->>OLM: Store token + link_mode in session
    OLM->>OP: Redirect to OAuth provider
    OP-->>B: OAuth consent screen
    B->>OP: User authorizes
    OP->>AC: Callback with auth data
    
    Note over AC: Process linking callback
    AC->>PS: verify(token)
    PS-->>AC: {:ok, username}
    AC->>A: get_by_username(username)
    A-->>AC: account
    
    alt Valid account and can use social login
        AC->>A: link_oauth_provider(account, auth)
        A-->>AC: {:ok, updated_account}
        AC->>PubSub: broadcast oauth_result
        AC-->>B: Success HTML page
        PubSub->>WS: {:oauth_result, success}
        WS->>C: oauth_result event with success
    else Cannot link (already linked, etc.)
        A-->>AC: {:error, reason}
        AC->>PubSub: broadcast oauth_result
        AC-->>B: Error HTML page
        PubSub->>WS: {:oauth_result, error}
        WS->>C: oauth_result event with error
    end
```

### OAuth Link Management Flow

```mermaid
sequenceDiagram
    participant C as Client
    participant GC as GenGameChannel
    participant OLH as OauthLinkHandler
    participant PS as PlayerSession
    participant A as Accounts

    Note over C: List linked providers
    C->>GC: list_oauth_links({})
    GC->>OLH: list_oauth_links(params, socket)
    OLH->>PS: verify(token)
    PS-->>OLH: {:ok, username}
    OLH->>A: get_by_username(username)
    A-->>OLH: account
    OLH->>A: list_linked_providers(account)
    A-->>OLH: ["google", "github"]
    OLH-->>GC: {:reply, {:ok, %{linked_providers: providers}}, socket}
    GC-->>C: linked_providers

    Note over C: Unlink provider
    C->>GC: unlink_oauth_provider({"provider" => "google"})
    GC->>OLH: unlink_oauth_provider(params, socket)
    OLH->>PS: verify(token)
    PS-->>OLH: {:ok, username}
    OLH->>A: get_by_username(username)
    A-->>OLH: account
    OLH->>A: unlink_oauth_provider(account, "google")
    A-->>OLH: :ok
    OLH-->>GC: {:reply, {:ok, %{msg: "Provider unlinked successfully"}}, socket}
    GC-->>C: success_message
```
### Detailed Social Login Steps

#### Social Login

1. **OAuth URL Generation**: Client requests an OAuth login URL, passing the current WebSocket token.
2. **OAuth Redirect**: Browser navigates to the OAuth provider's consent screen via the generated URL.
3. **User Authorization**: User authenticates and authorizes the app with the OAuth provider.
4. **Callback Handling**: OAuth provider redirects back to the server's callback endpoint with authentication data.
5. **Session Association**: Server middleware stores the original WebSocket token and processes the OAuth data.
6. **Account Lookup**: Server checks if an account is already linked to the OAuth provider and user ID.
7. **Token Issuance**: If account exists, a new JWT session token is generated for the user.
8. **Result Broadcast**: Server broadcasts the OAuth result (success or error) to the client via PubSub and WebSocket.
9. **Client Receives Token**: Client receives the new session token or error message and updates authentication state.

#### Account Linking

1. **Link Mode Initiation**: Client requests OAuth login with `link_mode=true` and current session token.
2. **OAuth Consent**: User authorizes the app with the OAuth provider.
3. **Callback Handling**: Server receives OAuth callback and verifies the session token.
4. **Account Verification**: Server fetches the account associated with the token.
5. **Provider Linking**: Server links the OAuth provider to the account if not already linked.
6. **Result Broadcast**: Server broadcasts the linking result (success or error) to the client via PubSub and WebSocket.
7. **Client Updates State**: Client updates linked providers list or displays error.

#### OAuth Link Management

1. **List Linked Providers**: Client requests a list of linked OAuth providers; server verifies token and returns provider list.
2. **Unlink Provider**: Client requests to unlink a provider; server verifies token, unlinks provider, and returns success message.


## Key Components

### Storage System

- **Distributed ETS**: Games stored in memory across cluster nodes
- **Auto-sync**: Changes automatically synchronized between nodes
- **PubSub**: Real-time updates via Phoenix PubSub
- **PostgreSQL**: Persistent storage for accounts and OAuth links

### Authentication

- **JWT Tokens**: Phoenix.Token for session management
- **Username-based**: Tokens contain username as payload
- **OAuth Integration**: Social login tokens replace existing session tokens
- **Multi-session Support**: Users can have multiple active sessions

### Server Authoritative Hooks

- **Before/After Events**: Hooks for validation and side effects
- **Elixir Modules**: Direct function calls in same BEAM VM
- **HTTP Hooks**: External service integration via HTTP requests
- **Custom RPC**: Extensible remote procedure calls

### Real-time Features

- **Phoenix Channels**: WebSocket connections for real-time communication
- **Presence**: Track online players per game
- **State Relay**: Real-time state synchronization between players
