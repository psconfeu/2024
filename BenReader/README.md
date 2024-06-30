# PSCONFEU2024
Another PowerShell conference... in this economy??!!

## What is in this folder?

Contained within this folder, you will find the slides and demo code for the following talks:

- SSH & PowerShell: All you need to manage EVERYTHING! 🚀
- No Passwords, No Problem: Secure Azure Authentication with MSAL & PowerShell

## File Structure
📦BenReader  
 ┣ 📂AUTH  `Root folder containing demo code for session "No Passwords, No Problem: Secure Azure Authentication with MSAL & PowerShell"`  
 ┃ ┣ 📂AuthIsEasy  `Sample project to get MSAL libraries from NuGet`  
 ┃ ┣ 📂AzFunctions  `Demo function app showing Managed Identity and Service Principal auth`  
 ┃ ┣ 📜1.AuthIsEasy.ps1  `Demo code to interact with MSAL in PowerShell`  
 ┃ ┣ 📜2.AuthIsFun.ps1 `Demo code showcasing "native" WAM authentication`    
 ┃ ┣ 📜MSAL.ppsx `Slides for session`  
 ┃ ┣ 📜3.ILikeMsi.ps1 `Demo code showing how to send Graph permissions to a managed identity`    
 ┣ 📂SSH  `Contains demo code for session "SSH & PowerShell: All you need to manage EVERYTHING! 🚀"`  
 ┃ ┣ 📜Get-VMNetworkInfo.ps1 `Code to get IPAddresses of local VMs`  
 ┃ ┣ 📜SSHARC-Demos.ps1  `Demo code for community demo`   
 ┃ ┗ 📜ssh-demos.ps1  `Demo code for SSH session`  
 ┃ ┣ 📜SSH.ppsx `Slides for session`  
 ┣ 📜README.md  
 ┗ 📜azure-pipelines.yml `Demo pipeline showing how to authenticate to Graph in an azure pipeline`

