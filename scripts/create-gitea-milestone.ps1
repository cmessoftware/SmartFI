$ErrorActionPreference='Stop'

$remoteUrl = git remote get-url gitea
$m = [regex]::Match($remoteUrl,'^http://(?<user>[^:]+):(?<token>[^@]+)@(?<host>[^/]+)/(?<org>[^/]+)/(?<repo>[^.]+)\.git$')
if(-not $m.Success){ throw "No se pudo parsear remote gitea: $remoteUrl" }

$hostName=$m.Groups['host'].Value
$org=$m.Groups['org'].Value
$repo=$m.Groups['repo'].Value

$token=$null
if(Test-Path '.env'){
  foreach($line in Get-Content '.env'){
    if($line -match '^\s*GITEA_TOKEN\s*=\s*(.*)\s*$'){
      $v=$matches[1].Trim()
      if(($v.StartsWith('"') -and $v.EndsWith('"')) -or ($v.StartsWith("'") -and $v.EndsWith("'"))){
        $v=$v.Substring(1,$v.Length-2)
      }
      $token=$v
    }
  }
}
if(-not $token){ $token=$m.Groups['token'].Value }

$headers=@{ Authorization = "token $token" }
$api = "http://$hostName/api/v1/repos/$org/$repo/milestones"
$title = 'dbt-debt-records-budget-integration'
$description = 'DBT module rollout: debt-records as source of truth with budget integration, fractional installments (2 decimals), and analytics.'

$existing = Invoke-RestMethod -Method Get -Uri "${api}?state=all" -Headers $headers
$target = $existing | Where-Object { $_.title -eq $title } | Select-Object -First 1

if($target){
  Write-Output "EXISTS #$($target.id) title=$($target.title) state=$($target.state)"
  if($target.html_url){ Write-Output "URL=$($target.html_url)" }
  exit 0
}

$payload = @{ title=$title; description=$description } | ConvertTo-Json
$new = Invoke-RestMethod -Method Post -Uri $api -Headers $headers -ContentType 'application/json' -Body $payload
Write-Output "CREATED #$($new.id) title=$($new.title) state=$($new.state)"
if($new.html_url){ Write-Output "URL=$($new.html_url)" }
