param(
    [ValidateSet('zh', 'en')][string]$Language = 'zh',
    [string]$Output
)

$ErrorActionPreference = 'Stop'
if (!$Output) { $Output = Join-Path $PSScriptRoot $(if ($Language -eq 'zh') { 'entry.zh.png' } else { 'entry.png' }) }
$Chinese = @{
    'WORLD IN ONE FRAME' = '一图看世界'
    'FRI  /  20 NOV 2026' = '周五 / 2026年11月20日'
    'Across the divide' = '隔岸之间'
    'UKRAINE' = '乌克兰'
    'Russia strikes overnight' = '俄罗斯发动夜间袭击'
    'Missiles and drones hit Kyiv bridges and the power grid.' = '导弹和无人机击中基辅的桥梁及电网。'
    'At least 8 killed, officials say' = '官员称至少 8 人死亡'
    'BRUSSELS' = '布鲁塞尔'
    'UK and EU reset ties' = '英国与欧盟重整关系'
    'Summit tackles food trade' = '峰会讨论食品贸易'
    'and youth mobility.' = '以及青年流动议题。'
    'MYANMAR / ROHINGYA' = '缅甸 / 罗兴亚人'
    'Groups urge sanctions' = '团体呼吁制裁'
    'After the UN court''s' = '联合国法院于 11 月 19 日'
    '19 Nov genocide ruling.' = '就种族灭绝案作出裁决。'
    'EDITORIAL ILLUSTRATION' = '新闻插画'
    'REPORTING  /  AP + REUTERS' = '消息来源 / 美联社与路透社'
}

Add-Type -AssemblyName System.Drawing
$canvas = [Drawing.Bitmap]::new(1000,1000)
$g = [Drawing.Graphics]::FromImage($canvas)
$g.SmoothingMode = 'AntiAlias'
$g.TextRenderingHint = 'AntiAliasGridFit'
function C($hex) { [Drawing.ColorTranslator]::FromHtml("#$hex") }
function Box($x,$y,$w,$h,$hex) {
    $b = [Drawing.SolidBrush]::new((C $hex))
    $g.FillRectangle($b,$x,$y,$w,$h)
    $b.Dispose()
}
function Oval($x,$y,$w,$h,$hex) {
    $b = [Drawing.SolidBrush]::new((C $hex))
    $g.FillEllipse($b,$x,$y,$w,$h)
    $b.Dispose()
}
function Line($x,$y,$u,$v,$hex,$width=2) {
    $p = [Drawing.Pen]::new((C $hex),$width)
    $g.DrawLine($p,$x,$y,$u,$v)
    $p.Dispose()
}
function Poly($coords,$hex) {
    $pts = for($i=0; $i -lt $coords.Count; $i+=2) {
        [Drawing.Point]::new($coords[$i],$coords[$i+1])
    }
    $b = [Drawing.SolidBrush]::new((C $hex))
    $g.FillPolygon($b,[Drawing.Point[]]$pts)
    $b.Dispose()
}
function Draw-Text($s,$x,$y,$size,$hex,$face='Arial',$style='Bold') {
    if ($Language -eq 'zh') { $s = $Chinese[$s]; $face = 'Microsoft YaHei UI' }
    $f = [Drawing.Font]::new($face,$size,[Drawing.FontStyle]$style,[Drawing.GraphicsUnit]::Pixel)
    $b = [Drawing.SolidBrush]::new((C $hex))
    $format = [Drawing.StringFormat]::GenericTypographic
    while ($Language -eq 'zh' -and $size -gt 12 -and $g.MeasureString($s,$f,2048,$format).Width -gt (974 - $x)) {
        $f.Dispose()
        $size--
        $f = [Drawing.Font]::new($face,$size,[Drawing.FontStyle]$style,[Drawing.GraphicsUnit]::Pixel)
    }
    $g.DrawString($s,$f,$b,[single]$x,[single]$y,$format)
    $format.Dispose()
    $b.Dispose()
    $f.Dispose()
}
$ink = '192938'
$paper = 'F6EBD7'
$gold = 'F5CD77'
$mist = 'A9D3D0'
$red = 'F29071'
Box 0 0 1000 1000 $paper
Box 0 0 1000 11 $ink
Draw-Text 'WORLD IN ONE FRAME' 45 29 24 $ink
Draw-Text 'FRI  /  20 NOV 2026' 714 29 24 $ink
Line 46 70 954 70 $ink
Draw-Text 'Across the divide' 44 78 84 $ink 'Georgia'
Box 0 193 1000 459 $ink
Draw-Text 'UKRAINE' 47 209 24 $gold
Draw-Text 'Russia strikes overnight' 44 239 59 $paper 'Georgia'
Draw-Text 'Missiles and drones hit Kyiv bridges and the power grid.' 47 318 29 $paper

# A cut-paper city and interrupted bridge above the Dnipro.
Oval 790 367 103 103 $gold
Oval 815 356 98 98 $ink
Poly @(0,472,89,452,169,468,252,429,365,462,461,434,588,473,704,447,818,477,925,441,1000,456,1000,565,0,565) '233C4D'
$random = [Random]::new(20112026)
for ($x=0; $x -lt 1000; $x+=22) {
    $h = $random.Next(12,76)
    Box $x (534-$h) 18 $h '304E60'
    if ($random.Next(0,4) -eq 0) { Box ($x+5) (543-$h) 5 4 $gold }
}
Box 0 532 1000 120 '28495E'
for ($i=0; $i -lt 120; $i++) {
    $x = $random.Next(0,974)
    $y = $random.Next(567,651)
    Line $x $y ($x+$random.Next(5,26)) $y '365D70' 1
}
foreach ($x in @(145,354,650,854)) {
    Poly @($x,525,($x+20),525,($x+25),619,($x-5),619) '779493'
}
foreach ($x in @(155,856)) {
    Line $x 451 $x 540 $mist 7
    foreach ($d in @(32,62,92)) {
        Line $x 457 ($x-$d) 521 $mist
        Line $x 457 ($x+$d) 521 $mist
    }
}
Poly @(0,517,463,517,479,526,464,532,469,541,0,541) $mist
Poly @(525,517,1000,517,1000,541,513,541,526,530,515,528) $mist
Poly @(498,504,484,478,507,493,530,471,520,502,546,511,515,515,504,541,494,520,470,516) $red
Line 630 378 538 463 $red 3
Line 585 377 536 421 'B76C62'
Line 707 387 650 433 'B76C62'
Box 32 570 541 57 $ink
Draw-Text 'At least 8 killed, officials say' 48 579 33 $paper

# The common horizon becomes a route and a scale beam.
Box 0 652 500 281 'D7E3DA'
Box 500 652 500 281 'EDDAC1'
Line 500 652 500 933 $ink
Draw-Text 'BRUSSELS' 45 674 23 $ink
Draw-Text 'UK and EU reset ties' 43 710 38 $ink 'Georgia'
Draw-Text 'Summit tackles food trade' 45 769 27 $ink 'Arial' 'Regular'
Draw-Text 'and youth mobility.' 45 804 27 $ink 'Arial' 'Regular'
Draw-Text 'MYANMAR / ROHINGYA' 533 674 23 $ink
Draw-Text 'Groups urge sanctions' 530 710 38 $ink 'Georgia'
Draw-Text 'After the UN court''s' 533 769 27 $ink 'Arial' 'Regular'
Draw-Text '19 Nov genocide ruling.' 533 804 27 $ink 'Arial' 'Regular'
Line 51 874 451 874 '457A76' 4
foreach ($x in @(59,443)) { Oval ($x-8) 866 16 16 '457A76' }
foreach ($x in @(177,220,263,306)) { Poly @($x,866,($x+11),874,$x,882) $ink }
Line 545 874 945 874 '9F5947' 4
Line 746 850 746 906 $ink 4
Line 722 906 770 906 $ink 4
foreach ($x in @(690,802)) {
    Line $x 874 ($x-14) 897 $ink
    Line $x 874 ($x+14) 897 $ink
    Poly @(($x-17),897,($x+17),897,($x+10),905,($x-10),905) $ink
}
Line 45 948 955 948 $ink
Draw-Text 'EDITORIAL ILLUSTRATION' 45 963 18 $ink
Draw-Text 'REPORTING  /  AP + REUTERS' 681 963 18 $ink
$canvas.Save($Output,[Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$canvas.Dispose()



