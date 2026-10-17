# Use Case 10: Troubleshoot Jenkins Agent Failure

## Goal

Diagnose and recover a Jenkins agent failure that prevents a pipeline from starting, while proving that the application code is not the cause.

## Lab Boundary

This lab uses a dedicated local Jenkins inbound agent and does not stop the Jenkins controller or modify unrelated jobs.

```text
Required pipeline label: usecase10-agent
Recovery node name: usecase10-agent-v2
Executors: 1
Connection: WebSocket
```

## Tools

- Jenkins controller on `http://localhost:8080`
- Dedicated Jenkins inbound agent
- GitLab repository
- Docker Desktop
- Docker Hub registry endpoint
- Git and Java

## Repository and Branch

```text
Repository: midhtech-group2/3-tier-architecture
Branch: usecase/10-jenkins-agent-failure
Pipeline: jenkins/usecase10/Jenkinsfile
```

The use-case files remain on the separate branch and are not merged into `main`.

## Pipeline Checks

The Jenkins pipeline is restricted to the `usecase10-agent` label and performs four checks:

1. **Agent Check** — records the Jenkins node, workspace, host, user, and Java version.
2. **Docker Check** — runs `docker version` and `docker info` from the agent.
3. **Registry Network Check** — connects to Docker Hub and expects HTTP `401`, proving that the endpoint is reachable and requires authentication.
4. **Application Code Check** — records Git workspace state and proves that the repository reached the agent.

## Controlled Failure

The dedicated Jenkins agent was offline. Jenkins successfully retrieved the Jenkinsfile from GitLab but displayed:

```text
Still waiting to schedule task
'usecase10-agent' is offline
```

This placed the job in the queue before any application build, test, or deployment stage started.

## Investigation

The investigation checked:

- Jenkins queue message
- Node online status and assigned label
- Presence of the `agent.jar` process
- Docker availability
- GitLab SCM authentication
- Registry network access
- Application working-tree state

No `agent.jar` process was found during the failure. Docker Desktop was available, GitLab supplied the Jenkinsfile successfully, and no application-code correction was required.

## Recovery

A replacement WebSocket node named `usecase10-agent-v2` was connected with the same `usecase10-agent` label. Jenkins then assigned the queued job to the new executor.

The same pipeline completed its agent, Docker, registry, and Git checks. It was run again without changing the Jenkinsfile or application code.

## Evidence Files

```text
usecase10-evidence/ROOT-CAUSE-REPORT.md
usecase10-evidence/queue-symptom-time.txt
usecase10-evidence/agent-process-during-failure.txt
usecase10-evidence/docker-info-during-failure.txt
usecase10-evidence/git-status-during-failure.txt
usecase10-evidence/agent-recovery-time.txt
usecase10-evidence/agent-process-after-recovery.txt
usecase10-evidence/application-commit.txt
usecase10-evidence/application-changes-before-rerun.txt
usecase10-evidence/successful-rerun-time.txt
usecase10-evidence/git-status-after-rerun.txt
```

The empty `agent-process-during-failure.txt` file is expected: the process search returned no running Jenkins agent.

Screenshots should show the queued job, offline node, recovered online node, successful pipeline stages, registry response, and final `SUCCESS` result. Screenshots must not expose Jenkins agent secrets or GitLab tokens.

## Success Criteria

- Jenkins retrieves the Jenkinsfile from GitLab.
- The pipeline is visibly queued while its required agent is offline.
- The agent status and process state are investigated.
- Docker and registry connectivity are checked.
- A matching agent is restored.
- The same pipeline succeeds without an application-code change.
- The root cause, recovery, verification, and prevention actions are documented.

## Security

Jenkins agent secrets, GitLab tokens, and registry passwords must stay in their credential stores. They must not be committed, copied into evidence, printed in logs, or shown in screenshots. An exposed agent secret must be replaced before continuing.

## Cleanup

After evidence is saved, stop the foreground agent with **Control+C**. In Jenkins, delete the temporary `usecase10-agent-v2` node if the lab is finished. Keep the pipeline job and branch only when they are needed for review.

## Interview Answer

I first determine whether a pipeline failure comes from code, dependencies, the environment, or CI infrastructure. In this lab Jenkins retrieved the pipeline definition from GitLab but could not schedule it because the required agent was offline. I confirmed the missing agent process, checked Docker and registry access, restored a matching WebSocket agent, and reran the same pipeline successfully without changing application code. That proved the delivery machine was the failure point.
