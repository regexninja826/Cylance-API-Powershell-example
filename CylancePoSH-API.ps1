
$currentScriptDirectory = Get-Location
$dllname = "jose-jwt.dll"
[System.IO.Directory]::SetCurrentDirectory($currentScriptDirectory)
 $LocalDllPath = Join-Path $currentScriptDirectory $dllname
[Reflection.Assembly]::LoadFile($LocalDllPath)|Out-Null


function Get-Token{
	$jti_val = [guid]::NewGuid()
	$tid_val = #tennant_id goes here
	$app_id = #application ID goes here
	$app_secret = [System.Text.Encoding]::UTF8.GetBytes#("appsecret goese in here");
	$datetimenow = [DateTimeOffset]::UtcNow
	$iat = $datetimenow.ToUnixTimeSeconds()
	$exp = $datetimenow.AddMinutes(10).ToUnixTimeSeconds()
	$iss = "http://cylance.com"
	$AUTH_URL = 'https://protectapi.cylance.com/auth/v2/token'
	$claim = [ordered]@{"exp"=$exp;"iat"=$iat;"iss"=$iss;"sub"=$app_id;"tid"=$tid_val;"jti"=$jti_val}|ConvertTo-Json
	$token=[Jose.JWT]::Encode($claim,$app_secret,[Jose.JwsAlgorithm]::HS256)
	$payload = @{"auth_token"=$token}|ConvertTo-Json


	$resp = Invoke-RestMethod -Method Post -Uri $AUTH_URL -Body $payload -ContentType "application/json; charset=utf-8"
	Write-Output $resp
	
	return $resp.access_token

}


$token = Get-Token

$results = Invoke-RestMethod -Method Get -ContentType 'application/json' -Headers  @{ Authorization = "Bearer:$token" } -Uri "https://protectapi.cylance.com/devices/v2"
Write-Output $results

$token=""