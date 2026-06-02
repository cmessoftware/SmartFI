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
$msApi = "http://$hostName/api/v1/repos/$org/$repo/milestones?state=all"
$milestones = Invoke-RestMethod -Method Get -Uri $msApi -Headers $headers
$ms = $milestones | Where-Object { $_.title -eq 'dbt-debt-records-budget-integration' } | Select-Object -First 1
if(-not $ms){ throw 'No se encontro milestone dbt-debt-records-budget-integration' }

$msId = [int]$ms.id
$updated = @()
for($i=135; $i -le 152; $i++){
  $issueApi = "http://$hostName/api/v1/repos/$org/$repo/issues/$i"
  $payload = @{ milestone = $msId } | ConvertTo-Json
  $res = Invoke-RestMethod -Method Patch -Uri $issueApi -Headers $headers -ContentType 'application/json' -Body $payload
  $updated += "#$($res.number) => $($res.milestone.title)"
}

"UPDATED_COUNT=$($updated.Count)"
$updated | ForEach-Object { $_ }
