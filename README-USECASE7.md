# Use Case 7: Automate Operations with Ansible and Vault

## Goal

Use Ansible for a repeatable Linux server operation and Vault for safe secret storage and rotation.

## Lab components

- Mac: Ansible control machine
- usecase7-host: Linux host managed by Ansible
- usecase7-vault: local Vault development server

## Ansible proof

- Ansible ping proved access to the Linux host.
- A bad inventory produced a controlled connection failure.
- The correct inventory restored access.
- Check mode previewed the configuration change.
- The first playbook run created the configuration.
- The second run reported changed=0 and proved idempotency.

## Vault proof

- A lab secret was stored at secret/midhlab/app.
- The username was read separately.
- The password remained masked.
- The password was rotated.
- Vault metadata recorded a second secret version.

## Security

No real passwords, Vault tokens or credentials are stored in Git.
