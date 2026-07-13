Get-ChildItem -Path "c:\Users\PAULO\Desktop\HELPI-ADM\lib" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $changed = $false

    # Remove const from FaIcon
    if ($content -match 'const FaIcon\(') {
        $content = $content -replace 'const FaIcon\(', 'FaIcon('
        $changed = $true
    }

    # Fix _detailRow IconData to dynamic
    if ($content -match 'Widget _detailRow\(IconData icon') {
        $content = $content -replace 'Widget _detailRow\(IconData icon', 'Widget _detailRow(dynamic icon'
        $changed = $true
    }

    # Fix Icon( to FaIcon( only when inside _detailRow - line with "Icon(icon,"
    if ($content -match 'Icon\(icon,') {
        $content = $content -replace 'Icon\(icon,', 'FaIcon(icon,'
        $changed = $true
    }

    if ($changed) {
        Set-Content $_.FullName -Value $content -NoNewline
        Write-Output ("Fixed: " + $_.Name)
    }
}
