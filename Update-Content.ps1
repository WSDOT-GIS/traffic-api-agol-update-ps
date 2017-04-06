Import-Module .\ArcGis.psm1

$configFile = ".\config.json"

# Load the config info
if ((Test-Path $configFile) -eq $false) {
    Write-Error "$configFile not found"
}
$config = Get-Content $configFile | ConvertFrom-Json

$portal = Get-Portal $config.username $config.password "https://www.arcgis.com/sharing/rest" 'https://wsdot.maps.arcgis.com'
$searchResults = $portal.Search('TravelerInfo type: "Feature Service"')

if ($searchResults.results.Length -eq 1) {
    Write-Debug "Found one search result"
    $hostedService = $searchResults.results[0]
} elseif ($searchResults.results.Length -gt 1) {
    Write-Error "More than one matching result was returned. Only expected a single result."
} else {
    Write-Debug "No results were returned from the search. TODO: create new feature service from FGDB."
}

Remove-Module ArcGis

return $hostedService