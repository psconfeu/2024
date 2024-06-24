class Car : base
{
    [string]$color
    [int]$speed

    Car([string]$color, [int]$speed)
    {
        $this.color = $color
        $this.speed = $speed
    }

    # Car ([string]$properties)
    # {
    #     $this.color, $this.speed = $properties -split ','
    # }

    Car ([PScustomObject]$Properties)
    {
        Write-verbose -Message 'Casting PSCustomObject to Car'
        $this._setProperties($Properties)
    }

    Car ([System.Collections.IDictionary]$Properties)
    {
        Write-verbose -Message 'Casting IDictionary to Car'
        $this._setProperties($Properties)
        # $this.color = $Properties.color
        # $this.speed = $Properties.speed
    }


    [void]Drive()
    {
        Write-Host "Driving at $($this.speed) mph"
    }
}