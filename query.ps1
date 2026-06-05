$token = "4ca791077acbdd7d6afd5ca8d1cd12e6430fe1c0"
$headers = @{ "Authorization" = "token $token" }
$baseUri = "http://localhost:3001/api/v1/repos/admin/SmartFI"

$pr = Invoke-RestMethod -Uri "$baseUri/pulls/107" -Headers $headers
$files = Invoke-RestMethod -Uri "$baseUri/pulls/107/files" -Headers $headers
$commits = Invoke-RestMethod -Uri "$baseUri/pulls/107/commits" -Headers $headers
$i96 = Invoke-RestMethod -Uri "$baseUri/issues/96" -Headers $headers
$i97 = Invoke-RestMethod -Uri "$baseUri/issues/97" -Headers $headers
$i98 = Invoke-RestMethod -Uri "$baseUri/issues/98" -Headers $headers

[PSCustomObject]@{
    PR_Title = $pr.title
    PR_Body = $pr.body
    Files = $files.filename
    Commits = $commits.commit.message
    Issue96 = "$($i96.title): $($i96.body)"
    Issue97 = "$($i97.title): $($i97.body)"
    Issue98 = "$($i98.title): $($i98.body)"
} | ConvertTo-Json
