---
sidebar_position: 1
---

# Overview

You can extend GenGame functionality beyond its capability with **hooks**. Hooks let you run your own function in between events, so you can achieve thing like server authoritative actions.

There are 2 ways implement hooks.

1. Using Elixir
2. Using any other programming language via HTTP server

We'll explain about this on the next session.

# Details

Here is available hooks:

<table>
  <tr>
    <th>Hook Name</th>
    <th>Payload</th>
    <th>Response</th>
    <th>Detail</th>
  </tr>
  
  <tr>
    <td>rpc</td>
    <td>arbritrary JSON</td>
    <td>arbritrary JSON</td>
    <td>Called when GenGame client exec an RPC. The payload is as-is from the client, and any response will be sent back to the client.</td>
  </tr>

  <tr>
    <td>before_create_match</td>
    <td>
      ```json
      {
        username: string
        match_id: string
      }
      ```
    </td>
    <td>
      ```json
      {
        username: string
        match_id: string
      }
      ```
    </td>
    <td>Called before match is created</td>
  </tr>
  <tr>
    <td>after_create_match</td>
    <td>
      ```json
      {
        username: string
        match_id: string
      }
      ```
    </td>
    <td>
      ignored
    </td>
    <td>Called before match is created</td>
  </tr>
  <tr>
    <td>before_create_session</td>
    <td>
      work in progress
    </td>
    <td>
      work in progress
    </td>
    <td></td>
  </tr>
  <tr>
    <td>after_create_session</td>
    <td>
      work in progress
    </td>
    <td>
      work in progress
    </td>
    <td></td>
  </tr>
  
  <tr>
    <td>before_create_account</td>
    <td>
      work in progress
    </td>
    <td>
      work in progress
    </td>
    <td></td>
  </tr>
  <tr>
    <td>after_create_account</td>
    <td>
      work in progress
    </td>
    <td>
      work in progress
    </td>
    <td></td>
  </tr>
</table>
