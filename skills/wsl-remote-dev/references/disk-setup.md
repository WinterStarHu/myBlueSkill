# Disk Setup (when install target drive doesn't exist)

If `wsl --import` fails with `Wsl/Service/CreateInstance/MountDisk/ERROR_PATH_NOT_FOUND`, the target drive letter doesn't exist yet (unpartitioned space).

## Check

```powershell
Get-Disk | Format-Table Number,FriendlyName,@{n='SizeGB';e={[math]::Round($_.Size/1GB,1)}},@{n='FreeGB';e={[math]::Round(($_.Size-$_.AllocatedSize)/1GB,1)}},PartitionStyle
Get-Partition -DiskNumber 0 | Format-Table PartitionNumber,DriveLetter,@{n='SizeGB';e={[math]::Round($_.Size/1GB,1)}},Type
```

Look for unallocated space (`FreeGB > 0` with no partition on it).

## Create + format (admin)

```powershell
# Use all unallocated space, auto-assign letter
New-Partition -DiskNumber 0 -UseMaximumSize -AssignDriveLetter | Format-Table
# Format as NTFS with label
Format-Volume -DriveLetter D -FileSystem NTFS -NewFileSystemLabel "Data" -Confirm:$false
```

This only touches unallocated space; existing partitions (C:, recovery) are untouched.

## Caution

- If you format a drive that already has a WSL `ext4.vhdx` on it, **the import is destroyed**. Always partition/format **before** `wsl --import`, never after.
- If you accidentally format over an imported WSL, `wsl --unregister Ubuntu`, recreate the directory, and re-import.
