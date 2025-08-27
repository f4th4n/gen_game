# Users

This guide shows how to create accounts, authenticate users, and use OAuth social login using the GenGame JavaScript client.

## Getting Started

### Initialize GenGame Client

```js
import { GenGame } from './gen_game'

// Create GenGame client instance
const genGame = new GenGame('localhost', 4000)

// Connect to the server
await genGame.connect()
```

## Device Authentication

Device authentication creates a temporary session for device-specific operations.

```js
// Authenticate with a device ID (creates temporary session)
const deviceToken = await genGame.authenticateDevice('device-123')
console.log('Device token:', deviceToken)
```

## Account Creation

Create a new user account with username and optional display information.

```js
// Create a new account
try {
  const account = await genGame.createAccount({
    username: 'player123',
    display_name: 'Player 123',
    email: 'player@example.com'  // optional
  })
  
  console.log('Account created:', account)
  // Output: { id: 1, username: 'player123', display_name: 'Player 123', ... }
  
} catch (error) {
  console.error('Account creation failed:', error.msg)
}
```

Account creation supports these fields:
- `username` (required) - Unique username (alphanumeric and underscore only)
- `display_name` (optional) - Display name for the user
- `email` (optional) - User's email address
- `avatar_url` (optional) - URL to user's avatar image
- `lang` (optional) - User's language preference
- `timezone` (optional) - User's timezone
- `wallet` (optional) - Wallet address for crypto integrations
- `metadata` (optional) - Additional custom data

## Session Management

After creating an account, you need to create a session to get an authentication token.

```js
// Create session for existing account (manual approach using Connection)
import Connection from './connection'

const { channel } = await Connection.joinChannel(genGame.state.connection, 'public')
const { token } = await Connection.send(channel, 'create_session', { 
  username: 'player123' 
})

// Update connection with the new token
await Connection.refreshToken(genGame.state.connection, 'gen_game', token)

console.log('Session token:', token)
```

## OAuth Social Login

OAuth social login allows users to authenticate using their existing social media accounts.

### Social Login (For Existing Accounts)

Use social login to authenticate users who have already linked their OAuth accounts:

```js
// Social login with Google
try {
  const result = await genGame.authenticateGoogle()
  
  if (result.success && result.token) {
    console.log('Google login successful!')
    console.log('New token:', result.token)
    console.log('Account:', result.account)
    
    // You need to manually update the connection with the new token
    await Connection.refreshToken(genGame.state.connection, 'gen_game', result.token)
    console.log('Connection updated with new token')
    
    // Now you can use other GenGame methods that require authentication
  }
} catch (error) {
  console.error('Google login failed:', error.message)
  // Common errors:
  // - "You must create an account first before using social login"
  // - "OAuth authentication failed"
}
```

### Account Linking

Link OAuth providers to existing accounts:

```js
// First, make sure you have an account token
// (from account creation + session or previous login)

// Link Google account to current account
try {
  const result = await genGame.linkGoogle(accountToken)
  
  console.log('Google linked successfully!')
  console.log('Linked providers:', result.linked_providers)
  
} catch (error) {
  console.error('Linking failed:', error.message)
  // Common errors:
  // - "This OAuth provider is already linked to your account"
  // - "This Google account is already linked to another GenGame account"
  // - "Invalid or expired token"
}
```

### OAuth Provider Management

```js
// List linked OAuth providers
try {
  const result = await genGame.getLinkedProviders()
  console.log('Linked providers:', result.linked_providers)
  // Output: ["google", "github"] or []
  
} catch (error) {
  console.error('Failed to get providers:', error.message)
}

// Unlink OAuth provider
try {
  const result = await genGame.unlinkGoogle()
  console.log('Google unlinked successfully!')
  
} catch (error) {
  console.error('Unlink failed:', error.message)
  // Common errors:
  // - "Provider not linked to this account"
  // - "No account token available"
}
```

## Complete Workflow Example

Here's a complete workflow showing account creation, session management, and OAuth:

```js
import { GenGame } from './gen_game'
import Connection from './connection'

const genGame = new GenGame('localhost', 4000)
await genGame.connect()

// Step 1: Start with device authentication
const deviceToken = await genGame.authenticateDevice('my-device-id')
console.log('Device authenticated')

// Step 2: Create a new account
try {
  const account = await genGame.createAccount({
    username: 'newplayer',
    display_name: 'New Player',
    email: 'newplayer@example.com'
  })
  
  console.log('Account created:', account)
  
  // Step 3: Create session for the account
  const { channel } = await Connection.joinChannel(genGame.state.connection, 'public')
  const { token } = await Connection.send(channel, 'create_session', { 
    username: account.username 
  })
  
  // Update connection with account token
  await Connection.refreshToken(genGame.state.connection, 'gen_game', token)
  console.log('Session created, now logged in with account token')
  
  // Step 4: Link Google account (optional)
  try {
    const linkResult = await genGame.linkGoogle(token)
    console.log('Google account linked!')
    
    // Step 5: List linked providers
    const providers = await genGame.getLinkedProviders()
    console.log('Linked providers:', providers.linked_providers)
    
  } catch (linkError) {
    console.log('Google linking failed:', linkError.message)
  }
  
} catch (error) {
  console.error('Account creation failed:', error.msg)
}

// Alternative: Social login (if account already exists and is linked)
try {
  const socialResult = await genGame.authenticateGoogle()
  
  if (socialResult.success) {
    console.log('Logged in via Google!')
    console.log('Account:', socialResult.account)
    
    // Manually update connection with the new token
    await Connection.refreshToken(genGame.state.connection, 'gen_game', socialResult.token)
    console.log('Connection updated with Google login token')
  }
  
} catch (error) {
  console.log('Social login not available:', error.message)
}
```

## Error Handling

Common error scenarios and how to handle them:

```js
// Account creation errors
try {
  await genGame.createAccount({ username: 'test!' })
} catch (error) {
  if (error.msg?.username) {
    console.error('Username error:', error.msg.username)
    // "Username only alphanumeric and _"
  }
}

// OAuth errors
try {
  await genGame.authenticateGoogle()
} catch (error) {
  switch (error.message) {
    case 'You must create an account first before using social login':
      console.log('Need to create account first')
      break
    case 'OAuth authentication failed':
      console.log('User cancelled or OAuth provider error')
      break
    default:
      console.error('Unexpected error:', error.message)
  }
}

// Linking errors
try {
  await genGame.linkGoogle(token)
} catch (error) {
  if (error.message.includes('already linked')) {
    console.log('Provider already linked to this or another account')
  } else if (error.message.includes('Invalid token')) {
    console.log('Need to refresh session')
  }
}
```

## Important Notes

- **Account Requirement**: Social login only works for users who have created a GenGame account first and linked their OAuth provider.

- **Token Management**: OAuth social login returns a new token that you must manually update using `Connection.refreshToken()`.

- **Multiple Sessions**: Users can have multiple active sessions. Each social login creates a new session token.

- **Provider Constraints**: Each GenGame account can only link one account per OAuth provider (e.g., one Google account per GenGame account).

## Unity / C#

```cs
var client = new Client("localhost", 4000);
await client.AuthenticateDeviceAsync("dev-123");
```

### TODO: create docs for social login in C# client too  
