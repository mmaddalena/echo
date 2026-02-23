$pathsToAdd = @(
  "C:\msys64\mingw64\bin",
  "C:\msys64\usr\bin"
)

$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

foreach ($path in $pathsToAdd) {
  if ($currentPath -notlike "*$path*") {
    $currentPath = "$path;$currentPath"
  }
}

[Environment]::SetEnvironmentVariable("Path", $currentPath, "User")

Write-Host "MSYS2 paths configured successfully."