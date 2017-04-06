[uri]$defaultRootUri = "https://www.arcgis.com/sharing/rest"

class Token {
    [string] $token
    [System.DateTimeOffset] $expires
    Token($response) {
        $this.token = $response.token;
        $this.expires = [System.DateTimeOffset]::FromUnixTimeMilliseconds($response.expires)
    }
}

class Portal {
    [uri] $rootUri = $defaultRootUri;
    [string] $username;
    [string] $password;
    [uri] $referrer;
    [Token] $_token;
    Portal([uri]$rootUri, [uri]$referrer, [string]$username, [string]$password) {
        $this.rootUri = $rootUri;
        $this.username = $username;
        $this.password = $password;
        $this.referrer = $referrer;
    }
    [Token] GetToken() {
        if (($this._token -and $this._token.expires -gt [System.DateTimeOffset]::Now()) -eq $false) {
            $params = @{
                username = $this.username;
                password = $this.password;
                expiration = '60'
                referer = $this.referrer
                f = 'json'
            }
            $tokenUri = "$($this.rootUri)/generateToken"
            $response = Invoke-RestMethod -Uri $tokenUri -Method Post -Body $params
            $this._token = New-Object Token $response
        }
        return $this._token
    }
    [psobject]Search($q) {
        $params = @{
            q = 'TravelerInfo type:"Feature Service"'
            token = $this.GetToken().token
            f = "json"
        }
        $response = Invoke-RestMethod -Uri "$($this.rootUri)/search" -Method Get -Body $params
        if ($response.error) {
            Write-Error $response.error
        }
        # $response = Invoke-WebRequest -Uri "$($this.rootUri)/search" -Method Get -Body $params
        return $response
    }
}

function Get-Portal {
    param([string]$Username, [string]$Password, [uri]$RootUri = $defaultRootUri, [uri]$Referrer = $defaultRootUri)
    return New-Object Portal($RootUri, $Referrer, $Username, $Password)
}

Export-ModuleMember -Function Get-Portal