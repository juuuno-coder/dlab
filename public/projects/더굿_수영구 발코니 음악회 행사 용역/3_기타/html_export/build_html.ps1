$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root='D:\디랩\260203_수영구 발코니 음악회 행사 용역 입찰 공고'
$outDir=Join-Path $root 'html_export'
$src=Join-Path $root '2_제안\2026 광안리 발코니 음악회 행사 용역 제안.pptx'
if (!(Test-Path $src)) { throw ("PPTX not found: " + $src) }
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$localPptx=Join-Path $outDir 'source.pptx'
Copy-Item -Path $src -Destination $localPptx -Force
$extractDir=Join-Path $outDir '_pptx'
if (Test-Path $extractDir) { Remove-Item -Recurse -Force $extractDir }
New-Item -ItemType Directory -Force -Path $extractDir | Out-Null
[IO.Compression.ZipFile]::ExtractToDirectory($localPptx, $extractDir)
# Copy images
$mediaDir=Join-Path $extractDir 'ppt\media'
$imgOut=Join-Path $outDir 'assets\img'
New-Item -ItemType Directory -Force -Path $imgOut | Out-Null
if (Test-Path $mediaDir) {
  Get-ChildItem -Path $mediaDir -File | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination (Join-Path $imgOut $_.Name) -Force
  }
}
# Helpers
function Decode-XmlEntities([string]$s){
  if ($null -eq $s) { return '' }
  $s = $s -replace '&amp;','&'
  $s = $s -replace '&lt;','<'
  $s = $s -replace '&gt;','>'
  $s = $s -replace '&quot;','"'
  $s = $s -replace '&#39;', [string][char]39
  return $s
}
function HtmlEscape([string]$s){
  if ($null -eq $s) { return '' }
  return [System.Security.SecurityElement]::Escape($s)
}
# Build slide data (text + images) using regex to avoid XML parse issues
$slidesDir=Join-Path $extractDir 'ppt\slides'
$relsDir=Join-Path $extractDir 'ppt\slides\_rels'
$slideFiles=Get-ChildItem -Path $slidesDir -Filter 'slide*.xml' | Sort-Object Name
$slides=@()
foreach ($sf in $slideFiles) {
  $xmlText=Get-Content -Raw -Encoding UTF8 $sf.FullName
  $textMatches=[regex]::Matches($xmlText,'<a:t>(.*?)</a:t>',[System.Text.RegularExpressions.RegexOptions]::Singleline)
  $texts=@()
  foreach ($m in $textMatches) { $texts += (Decode-XmlEntities $m.Groups[1].Value) }
  $joined=($texts | Where-Object { $_ -and $_.Trim() -ne '' }) -join ' '

  $relPath=Join-Path $relsDir ($sf.Name + '.rels')
  $imgList=@()
  if (Test-Path $relPath) {
    $relText=Get-Content -Raw -Encoding UTF8 $relPath
    $blips=[regex]::Matches($xmlText,'r:embed="(rId\d+)"')
    foreach ($b in $blips) {
      $rid=$b.Groups[1].Value
      $relMatch=[regex]::Match($relText, 'Id="' + [regex]::Escape($rid) + '"[^>]*Target="([^"]+)"')
      if ($relMatch.Success) {
        $target=$relMatch.Groups[1].Value
        if ($target -like '../media/*') { $target=$target.Substring(9) }
        $imgList += $target
      }
    }
  }
  $slides += [PSCustomObject]@{ file=$sf.Name; text=$joined; images=($imgList | Select-Object -Unique) }
}
# Extract docx text for expansion
$docxPaths=@(
  (Join-Path $root '1_공고\과업지시서(2026년 광안리 발코니 음악회).docx'),
  (Join-Path $root '1_공고\제안요청서(2026년 광안리 발코니 음악회).docx'),
  (Join-Path $root '1_공고\공고문(2026년 광안리 발코니 음악회).docx')
)
$docxText=@()
foreach ($dp in $docxPaths) {
  if (!(Test-Path $dp)) { continue }
  $tmp=Join-Path $outDir ("_docx_" + [IO.Path]::GetFileNameWithoutExtension($dp))
  if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }
  New-Item -ItemType Directory -Force -Path $tmp | Out-Null
  [IO.Compression.ZipFile]::ExtractToDirectory($dp, $tmp)
  $docXml=Join-Path $tmp 'word\document.xml'
  if (Test-Path $docXml) {
    $raw=Get-Content -Raw -Encoding UTF8 $docXml
    $raw=$raw -replace '</w:p>','\n'
    $raw=$raw -replace '<[^>]+>',' '
    $raw=Decode-XmlEntities $raw
    $raw=$raw -replace '\s+',' '
    $docxText += $raw.Trim()
  }
}
# Chunk docx text into pages
$chunks=@()
$allText=($docxText -join ' ')
if ($allText) {
  $max=650
  for ($i=0; $i -lt $allText.Length; $i+=$max) {
    $len=[Math]::Min($max, $allText.Length-$i)
    $chunks += $allText.Substring($i,$len)
  }
}
# Build HTML
$htmlPath=Join-Path $outDir 'index.html'
$sb=New-Object System.Text.StringBuilder
$null=$sb.AppendLine('<!doctype html>')
$null=$sb.AppendLine('<html lang="ko">')
$null=$sb.AppendLine('<head>')
$null=$sb.AppendLine('<meta charset="utf-8">')
$null=$sb.AppendLine('<meta name="viewport" content="width=device-width,initial-scale=1">')
$null=$sb.AppendLine('<title>2026 광안리 발코니 음악회 제안서 (HTML)</title>')
$null=$sb.AppendLine('<style>')
$cssLines=@(
":root{--bg:#0f1623;--fg:#e9eef7;--muted:#9fb0c7;--accent:#5ad1ff;--card:#162035;--grid:#1f2a40}",
"*{box-sizing:border-box}",
"body{margin:0;font-family:system-ui,Segoe UI,Apple SD Gothic Neo,Malgun Gothic,sans-serif;background:var(--bg);color:var(--fg)}",
"header{padding:24px 40px;border-bottom:1px solid var(--grid);position:sticky;top:0;background:linear-gradient(180deg,#0f1623 0%,#101a2b 100%);z-index:2}",
"header h1{margin:0;font-size:20px;letter-spacing:.2px}",
"header p{margin:6px 0 0;color:var(--muted);font-size:13px}",
"main{padding:24px 40px;display:grid;grid-template-columns:repeat(auto-fill,minmax(360px,1fr));gap:16px}",
".slide{background:var(--card);border:1px solid var(--grid);border-radius:12px;padding:16px;min-height:220px;display:flex;flex-direction:column;gap:10px}",
".slide h2{margin:0;font-size:14px;color:var(--accent)}",
".slide p{margin:0;color:var(--fg);font-size:13px;line-height:1.55}",
".imggrid{display:grid;grid-template-columns:repeat(auto-fill,minmax(140px,1fr));gap:8px}",
".imggrid img{width:100%;height:100px;object-fit:cover;border-radius:8px;border:1px solid #22304a;background:#0b1220}",
".footer{padding:20px 40px;color:var(--muted);font-size:12px}",
"@media print{header,.footer{display:none}body{background:white;color:black}main{grid-template-columns:1fr}.slide{page-break-inside:avoid;border:1px solid #ddd}}"
)
foreach ($l in $cssLines) { $null=$sb.AppendLine($l) }
$null=$sb.AppendLine('</style>')
$null=$sb.AppendLine('</head>')
$null=$sb.AppendLine('<body>')
$null=$sb.AppendLine('<header>')
$null=$sb.AppendLine('<h1>2026 광안리 발코니 음악회 행사 용역 제안 (HTML 추출)</h1>')
$null=$sb.AppendLine('<p>PPTX 텍스트 + 이미지 추출, 공고/과업/요청서 텍스트를 추가해 50페이지 내외로 확장합니다.</p>')
$null=$sb.AppendLine('</header>')
$null=$sb.AppendLine('<main>')
$idx=1
foreach ($s in $slides) {
  $safe=HtmlEscape $s.text
  if ([string]::IsNullOrWhiteSpace($safe)) { $safe='(텍스트 없음)' }
  $null=$sb.AppendLine('<section class="slide">')
  $null=$sb.AppendLine('<h2>Slide ' + $idx + '</h2>')
  $null=$sb.AppendLine('<p>' + $safe + '</p>')
  if ($s.images -and $s.images.Count -gt 0) {
    $null=$sb.AppendLine('<div class="imggrid">')
    foreach ($img in $s.images) {
      $src='assets/img/' + $img
      $null=$sb.AppendLine('<img src="' + $src + '" alt="' + $img + '">')
    }
    $null=$sb.AppendLine('</div>')
  }
  $null=$sb.AppendLine('</section>')
  $idx++
}
# Add extra pages from docx chunks to reach ~50 pages
$target=50
if ($idx -le $target) {
  $ci=0
  while ($idx -le $target -and $ci -lt $chunks.Count) {
    $safe=HtmlEscape $chunks[$ci]
    $null=$sb.AppendLine('<section class="slide">')
    $null=$sb.AppendLine('<h2>Reference ' + $idx + '</h2>')
    $null=$sb.AppendLine('<p>' + $safe + '</p>')
    $null=$sb.AppendLine('</section>')
    $idx++; $ci++
  }
}
# If still short, add image bank pages
if ($idx -le $target) {
  $allImgs=Get-ChildItem -Path $imgOut -File | Select-Object -ExpandProperty Name
  $perPage=8
  $pos=0
  while ($idx -le $target -and $pos -lt $allImgs.Count) {
    $null=$sb.AppendLine('<section class="slide">')
    $null=$sb.AppendLine('<h2>Image Bank ' + $idx + '</h2>')
    $null=$sb.AppendLine('<div class="imggrid">')
    for ($k=0; $k -lt $perPage -and ($pos+$k) -lt $allImgs.Count; $k++) {
      $img=$allImgs[$pos+$k]
      $src='assets/img/' + $img
      $null=$sb.AppendLine('<img src="' + $src + '" alt="' + $img + '">')
    }
    $null=$sb.AppendLine('</div>')
    $null=$sb.AppendLine('</section>')
    $idx++; $pos+=$perPage
  }
}
$null=$sb.AppendLine('</main>')
$null=$sb.AppendLine('<div class="footer">생성: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm') + '</div>')
$null=$sb.AppendLine('</body>')
$null=$sb.AppendLine('</html>')
[IO.File]::WriteAllText($htmlPath, $sb.ToString(), [Text.Encoding]::UTF8)
Write-Host ("HTML generated: " + $htmlPath)
Write-Host ("Slides extracted: " + $slides.Count)
Write-Host ("Images copied: " + ((Get-ChildItem -Path $imgOut -File | Measure-Object).Count))
Write-Host ("Docx chunks: " + $chunks.Count)
