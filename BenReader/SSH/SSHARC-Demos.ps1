# Basic AzArc SSH Connection
$machineResourceGroup = "ExampleResourceGroup"
$machineName = "ExampleMachine"
$localUser = "Contoso/ExampleUser"
$remoteSshPort = 22
az arc ssh arc --resource-group $machineResourceGroup --name $machineName --local-user $localUser --port $remoteSshPort

# SSH Tunneling with AzArc - local port forwarding is configured as below
# -L localPort:RemoteIpAddress:RemotePort
# Local port 42069 is forwarded to the remote machine's RDP port (3389)
# specifically we are connecting to the remote machine and looking for any available 3389 port on localhost
# if you want to be specific about what device you want the remote port to be on, 
# you can change localhost to the IP address. Example, the device you are connecting to is on 192.168.0.10
# but the Remote port is actually on 192.1678.0.11, change the example below to reflect that, instead of localhost
az arc ssh arc --resource-group $machineResourceGroup --name $machineName --local-user $localUser --port $remoteSshPort -- -L 42069:localhost:3389

