function Convert-RomanToArabic {
    param (
        [Parameter(Mandatory=$true)]
        [string]$roman
    )
    $roman = $roman.ToUpper()
    $romanValues = [ordered]@{
        'M'  = 1000
        'CM' = 900
        'D'  = 500
        'CD' = 400
        'C'  = 100
        'XC' = 90
        'L'  = 50
        'XL' = 40
        'X'  = 10
        'IX' = 9
        'V'  = 5
        'IV' = 4
        'I'  = 1
    }
     
    while ($roman.Length -gt 0) {
        foreach ($romanValue in $romanValues.GetEnumerator()) {
            if ($roman.StartsWith($romanValue.Key)) {
                $arabicValue += $romanValue.Value
                $roman = $roman.Substring($romanValue.Key.Length)
                break
            }
        }
    }

    return $arabicValue
}

#  (Get-Content -Path "C:\Users\resto\Documents\flutter\rememberall\lib\shakespeareSonnets.txt" | Select-String -Pattern "Sonnet [IVXLCDM]+$" | %{
#     $_ -replace '.*Sonnet ([IVXLCDM]+).*', '$1'})| %{"Sonnet $(Convert-RomanToArabic $_)"}
    
# Get-Content -Path "C:\Users\resto\Documents\flutter\rememberall\lib\shakespeareSonnets.txt" | ForEach-Object {
#     if ($_ -match "Sonnet [IVXLCDM]+$") {
#         $roman = $_ -replace '.*Sonnet ([IVXLCDM]+).*', '$1'
#         "Sonnet $(Convert-RomanToArabic $roman)"
#     } else {
#         $_
#     }
# }
   
Get-Content -Path "C:\Users\resto\Documents\flutter\rememberall\lib\shakespeareSonnets.txt" | ForEach-Object {
    if ($_ -match "Sonnet [IVXLCDM]+$") {
        $roman = $_ -replace '.*Sonnet ([IVXLCDM]+).*', '$1'
        $output = "SONNET $(Convert-RomanToArabic $roman)"
    } else {
        $output = $_
    }
    Add-Content -Path "C:\Users\resto\Documents\flutter\rememberall\lib\songsb.txt" -Value $output
}


    #$updatedText = [regex]::Replace($text, '\b([IVXLCDM]+)\b', { param($match) RomanToArabic($match.Groups[1].Value) })

 #   //et-Content -Path $file -Value $updatedText

#//Get-Numerals -file C:\Users\resto\Documents\flutter\rememberall\lib\shakespeareSonnets.txt