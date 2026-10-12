# Vault Lab

Vault runs locally in a Docker development container.

Secret path:

secret/midhlab/app

The secret contains a lab username and password.

Security rules:

- Do not commit the password to Git.
- Do not save the password in evidence.
- Display the password only as MASKED.
- Use Vault development mode only for local practice.

This lab proves that the secret can be stored, safely checked and rotated.
