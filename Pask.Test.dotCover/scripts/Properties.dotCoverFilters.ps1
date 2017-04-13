Set-Property dotCoverFilters -Value (-Join (
    "-:module=*Test*", 
    @{
        $true="";
        $false=(";{0}" -f ((Get-BuildProperty dotCoverFilters "") -replace "`n|\n|`r`n|\r\n", ";"))
    }[[String]::IsNullOrWhiteSpace($(Get-BuildProperty dotCoverFilters ""))]
))

Set-Property dotCoverAttributeFilters -Value (-Join (
    "System.Diagnostics.CodeAnalysis.ExcludeFromCodeCoverageAttribute;System.CodeDom.Compiler.GeneratedCodeAttribute", 
    @{
        $true="";
        $false=(";{0}" -f ((Get-BuildProperty dotCoverAttributeFilters "") -replace "`n|\n|`r`n|\r\n", ";"))
    }[[String]::IsNullOrWhiteSpace((Get-BuildProperty dotCoverAttributeFilters ""))]
))