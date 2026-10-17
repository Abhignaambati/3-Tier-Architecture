# Use Case 10: Jenkins Agent Failure Root-Cause Report

## Incident Summary

A Jenkins pipeline could not start because no online agent matched the required `usecase10-agent` label.

## Visible Symptom

Jenkins successfully retrieved the pipeline definition from GitLab but displayed:

```text
Still waiting to schedule task
'usecase10-agent' is offline
```

The job remained queued before any application build or test stage started.

## Timeline

- Queue symptom recorded: `2026-10-16 16:46:50 IST`
- Agent recovery recorded: `2026-10-16 17:03:48 IST`
- Successful rerun recorded: `2026-10-16 17:06:43 IST`

## User Impact

The delivery pipeline was blocked. No build, test, Docker, registry, or deployment task could run on the assigned agent.

## First Check

The Jenkins queue message was checked first. It showed that the required label had no online executor. The Jenkins Nodes page was then used to confirm the node status and label.

## Investigation

1. Jenkins retrieved `jenkins/usecase10/Jenkinsfile` from GitLab successfully.
2. The pipeline required the `usecase10-agent` label.
3. The process check returned no running `agent.jar` process during the failure.
4. Docker Desktop responded successfully on the Mac.
5. Git recorded the same application commit during diagnosis and recovery.
6. The GitLab credential worked because Jenkins retrieved the pipeline definition.
7. The registry endpoint later returned HTTP `401`, proving network access and the expected authentication boundary.
8. The pipeline had not reached an application stage when the queue symptom appeared.

## Root Cause

The dedicated Jenkins inbound agent process was not running. Jenkins therefore had no online executor matching the `usecase10-agent` label.

The application code was not the cause because Jenkins was blocked at scheduling before it could execute the repository's build steps.

## Corrective Action

A replacement Jenkins WebSocket node was connected with the required label:

```text
Node name: usecase10-agent-v2
Label: usecase10-agent
Executors: 1
```

The exposed earlier connection secret was not reused. The Jenkinsfile and application code were not modified to recover the service.

## Recovery Verification

After the replacement agent connected:

1. Jenkins assigned the queued pipeline to the matching node.
2. The agent identity and Java checks completed.
3. Docker access completed.
4. Registry network access completed.
5. The application workspace check completed.
6. The pipeline finished successfully.
7. The same pipeline was run again without an application-code change.

## Evidence

- `queue-symptom-time.txt` records when the queued state was observed.
- `agent-process-during-failure.txt` is empty because no agent process matched the search.
- `docker-info-during-failure.txt` proves that Docker Desktop itself was available.
- `git-status-during-failure.txt` records repository state during the incident.
- `agent-recovery-time.txt` records when the node was restored.
- `agent-process-after-recovery.txt` confirms that an agent process was running.
- `application-commit.txt` records commit `f2d712632e95ef6864cfc2f050b2fdd937d0c045`.
- `application-changes-before-rerun.txt` shows that only evidence files were untracked.
- `successful-rerun-time.txt` records the successful rerun time.
- `git-status-after-rerun.txt` confirms that no application correction was introduced.

Jenkins screenshots provide the queue, offline node, recovered online node, stage results, and final successful status. Credentials and agent secrets are excluded from evidence.

## Prevention

1. Run persistent Jenkins agents as managed background services.
2. Monitor node availability and alert when a required label has no online executor.
3. Document node labels and validate them during agent provisioning.
4. Check Java, Docker, disk space, and registry connectivity when provisioning agents.
5. Keep GitLab and registry credentials in the Jenkins credential store.
6. Rotate any agent secret that is accidentally exposed.
7. Maintain a short agent recovery runbook.

## Why Application Code Was Not Changed

The queue message identified an unavailable CI executor before the build began. Changing application code could not bring the Jenkins agent online or create an executor for the queued job.

## Interview Explanation

I first separated the pipeline failure from the application. Jenkins retrieved the pipeline definition from GitLab but could not schedule it because the required agent was offline. I confirmed that the agent process was absent, checked Docker and repository state, restored a dedicated matching agent, and reran the same pipeline without changing application code. The successful rerun proved that the failure was in the CI infrastructure.
