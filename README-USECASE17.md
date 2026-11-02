# Use Case 17: Build Backup and Restore Evidence

Use Case 17: Backup and Restore Evidence

Lab scope:
- Kubernetes context: docker-desktop
- Namespace: backup-restore-lab
- Database: PostgreSQL
- Object storage: MinIO
- Test table: public.recovery_claims
- Safe test record: ID 1701

Successful workflow:
1. Created safe lab data in PostgreSQL.
2. Captured the record before backup.
3. Created a PostgreSQL backup using a Kubernetes Job.
4. Stored the backup on a Kubernetes PVC.
5. Uploaded the backup artifact to a MinIO bucket.
6. Deleted only the safe test record.
7. Confirmed the record was missing.
8. Downloaded the backup artifact from MinIO.
9. Restored the record using a Kubernetes restore Job.
10. Verified the application-side database reader could read the recovered record.

Controlled failure:
Public MinIO images and legacy binary downloads were unavailable.
The final archived community source release was built into a local lab image,
imported into the Docker Desktop Kubernetes node, and used only inside this lab.

RTO:
For this lab, RTO is the time between the controlled deletion and successful
verification of the recovered record. The command evidence records the start,
restore duration, and recovery completion time.

RPO:
The backup was taken immediately before the controlled deletion and no valid
application updates occurred between backup and deletion. Therefore, no test
records were lost in this exercise. In a real system, RPO would be limited by
the configured backup frequency.

Success result:
The real lab record existed before backup, disappeared after controlled
deletion, and returned after restoration from the MinIO backup artifact.

## Evidence

- Data before backup: `usecase17-evidence/data-before-backup.txt`
- Data after deletion: `usecase17-evidence/data-after-deletion.txt`
- Data after restore: `usecase17-evidence/data-after-restore.txt`
- Backup output: `usecase17-evidence/postgres-backup-job.txt`
- MinIO upload: `usecase17-evidence/minio-backup-upload.txt`
- Restore output: `usecase17-evidence/postgres-restore-output.txt`
- Duration summary: `usecase17-evidence/recovery-duration-summary.txt`

## Automation

- `scripts/usecase17/run-backup.sh`
- `scripts/usecase17/run-restore.sh`

## Interview Answer

I do not call a backup successful until restoration is tested. I backed up real PostgreSQL lab data, uploaded it to MinIO, deleted the safe test record, restored it through Kubernetes Jobs, and verified the recovered record through the application-side database reader.
