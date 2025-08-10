# Validation Instructions

This document provides step-by-step instructions to validate that the ToDo application is properly deployed and configured in Kubernetes.

## Prerequisites

- Kubernetes cluster is running
- `kubectl` is configured to connect to your cluster
- All resources have been deployed using `./bootstrap.sh`

## 1. Validate App is Running

### Check Pod Status
```bash
kubectl get pods -n todoapp
```
**Expected output:** Pod should be in `Running` status with `READY` showing `1/1`.

### Check Deployment Status
```bash
kubectl get deployment todoapp -n todoapp
```
**Expected output:** Deployment should show `READY` as `1/1` and `AVAILABLE` as `1`.

### Check Application Logs
```bash
kubectl logs -n todoapp deployment/todoapp
```
**Expected output:** No error messages, Django application should start successfully.

### Test Application Endpoints
```bash
# Get the pod name
POD_NAME=$(kubectl get pods -n todoapp -l app=todoapp -o jsonpath='{.items[0].metadata.name}')

# Test health endpoint
kubectl exec -n todoapp $POD_NAME -- curl -s http://localhost:8080/api/health
```
**Expected output:** HTTP 200 response indicating the app is healthy.

```bash
# Test readiness endpoint
kubectl exec -n todoapp $POD_NAME -- curl -s http://localhost:8080/api/ready
```
**Expected output:** HTTP 200 response indicating the app is ready.

## 2. Validate ConfigMap Data is Mounted as Files

### Check ConfigMap Mount Point
```bash
# Get the pod name
POD_NAME=$(kubectl get pods -n todoapp -l app=todoapp -o jsonpath='{.items[0].metadata.name}')

# List files in the configs directory
kubectl exec -n todoapp $POD_NAME -- ls -la /app/configs/
```
**Expected output:** Should show files corresponding to ConfigMap keys:
- `PYTHONUNBUFFERED` file should be present

### Verify ConfigMap File Contents
```bash
# Check the content of the PYTHONUNBUFFERED file
kubectl exec -n todoapp $POD_NAME -- cat /app/configs/PYTHONUNBUFFERED
```
**Expected output:** Should display `1` (the value from the ConfigMap).

### Verify Mount is Read-Only
```bash
# Try to write to the configs directory (should fail)
kubectl exec -n todoapp $POD_NAME -- touch /app/configs/test_file
```
**Expected output:** Should return an error indicating the filesystem is read-only.

### Check ConfigMap Environment Variable
```bash
# Verify the environment variable is also set
kubectl exec -n todoapp $POD_NAME -- env | grep PYTHONUNBUFFERED
```
**Expected output:** Should show `PYTHONUNBUFFERED=1`.

## 3. Validate Secret Data is Mounted as Files

### Check Secret Mount Point
```bash
# List files in the secrets directory
kubectl exec -n todoapp $POD_NAME -- ls -la /app/secrets/
```
**Expected output:** Should show files corresponding to Secret keys:
- `SECRET_KEY` file should be present

### Verify Secret File Contents
```bash
# Check the content of the SECRET_KEY file (be careful with sensitive data)
kubectl exec -n todoapp $POD_NAME -- cat /app/secrets/SECRET_KEY | head -c 20
```
**Expected output:** Should display the first 20 characters of the decoded secret key.

### Verify Mount is Read-Only
```bash
# Try to write to the secrets directory (should fail)
kubectl exec -n todoapp $POD_NAME -- touch /app/secrets/test_file
```
**Expected output:** Should return an error indicating the filesystem is read-only.

### Check Secret Environment Variable
```bash
# Verify the environment variable is also set (first few characters only for security)
kubectl exec -n todoapp $POD_NAME -- bash -c 'echo $SECRET_KEY | head -c 20'
```
**Expected output:** Should show the first 20 characters of the secret key.

## 4. Validate PersistentVolume Mount

### Check PersistentVolume Status
```bash
kubectl get pv pv-data
```
**Expected output:** PV should be in `Bound` status.

### Check PersistentVolumeClaim Status
```bash
kubectl get pvc pvc-data -n todoapp
```
**Expected output:** PVC should be in `Bound` status and bound to `pv-data`.

### Verify Data Directory Mount
```bash
# Check if the data directory is mounted
kubectl exec -n todoapp $POD_NAME -- ls -la /app/data/
```
**Expected output:** Should show the mounted directory (may be empty initially).

### Test Write Permissions on Data Volume
```bash
# Test writing to the data directory
kubectl exec -n todoapp $POD_NAME -- touch /app/data/test_file.txt
kubectl exec -n todoapp $POD_NAME -- ls -la /app/data/test_file.txt
```
**Expected output:** File should be created successfully, indicating read-write access.

### Clean Up Test File
```bash
kubectl exec -n todoapp $POD_NAME -- rm /app/data/test_file.txt
```

## 5. Additional Validation Commands

### Check All Resources
```bash
# Get overview of all todoapp resources
kubectl get all -n todoapp
```

### Check Resource Events
```bash
# Check for any events or issues
kubectl get events -n todoapp --sort-by='.lastTimestamp'
```

### Port Forward for Local Testing (Optional)
```bash
# Forward port to test the application locally
kubectl port-forward -n todoapp deployment/todoapp 8080:8080
```
Then open `http://localhost:8080` in your browser to test the web interface.
