# Flow

This document describes the core flows in GenGame for game creation and player management.

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

## Key Components

### Storage System

- **Distributed ETS**: Games stored in memory across cluster nodes
- **Auto-sync**: Changes automatically synchronized between nodes
- **PubSub**: Real-time updates via Phoenix PubSub

### Authentication

- **JWT Tokens**: Phoenix.Token for session management
- **Username-based**: Tokens contain username as payload

### Server Authoritative Hooks

- **Before/After Events**: Hooks for validation and side effects
- **Elixir Modules**: Direct function calls in same BEAM VM
- **HTTP Hooks**: External service integration via HTTP requests
- **Custom RPC**: Extensible remote procedure calls

### Real-time Features

- **Phoenix Channels**: WebSocket connections for real-time communication
- **Presence**: Track online players per game
- **State Relay**: Real-time state synchronization between players
