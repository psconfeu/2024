# Here: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_classes?view=powershell-7.4#exporting-classes-with-type-accelerators

class Plane
{
    [string]$color
    [int]$speed

    Plane([string]$color, [int]$speed)
    {
        $this.color = $color
        $this.speed = $speed
    }

    Plane ([PScustomObject]$Properties)
    {
        Write-verbose -Message 'Casting PSCustomObject to Car'
        $this._setProperties($Properties)
    }

    Plane ([System.Collections.IDictionary]$Properties)
    {
        Write-verbose -Message 'Casting IDictionary to Car'
        $this._setProperties($Properties)
        # $this.color = $Properties.color
        # $this.speed = $Properties.speed
    }

    hidden [void] _setProperties([Object]$Properties)
    {
        $Properties.psobject.properties.name.Foreach{
            $this.$_ = $Properties.$_
        }
    }

    [void]Drive()
    {
        Write-Host "Driving at $($this.speed) mph"
    }
}

# Define the types to export with type accelerators.
$ExportableTypes =@(
    [plane]
)
# Get the internal TypeAccelerators class to use its static methods.
$TypeAcceleratorsClass = [psobject].Assembly.GetType(
    'System.Management.Automation.TypeAccelerators'
)
# Ensure none of the types would clobber an existing type accelerator.
# If a type accelerator with the same name exists, throw an exception.
$ExistingTypeAccelerators = $TypeAcceleratorsClass::Get
foreach ($Type in $ExportableTypes) {
    if ($Type.FullName -in $ExistingTypeAccelerators.Keys) {
        $Message = @(
            "Unable to register type accelerator '$($Type.FullName)'"
            'Accelerator already exists.'
        ) -join ' - '

        throw [System.Management.Automation.ErrorRecord]::new(
            [System.InvalidOperationException]::new($Message),
            'TypeAcceleratorAlreadyExists',
            [System.Management.Automation.ErrorCategory]::InvalidOperation,
            $Type.FullName
        )
    }
}
# Add type accelerators for every exportable type.
foreach ($Type in $ExportableTypes) {
    $TypeAcceleratorsClass::Add($Type.FullName, $Type)
}
# Remove type accelerators when the module is removed.
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    foreach($Type in $ExportableTypes) {
        $TypeAcceleratorsClass::Remove($Type.FullName)
    }
}.GetNewClosure()