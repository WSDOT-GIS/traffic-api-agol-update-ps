using module .\ArcGis.psm1

$configFile = ".\config.json"

# Load the config info
if ((Test-Path $configFile) -eq $false) {
    Write-Error "$configFile not found"
}
$config = Get-Content $configFile | ConvertFrom-Json

$portal = New-Object Portal @("https://www.arcgis.com/sharing/rest", 'https://wsdot.maps.arcgis.com', $config.username, $config.password)
$searchResults = $portal.Search('TravelerInfo type: "Feature Service"')

return $searchResults