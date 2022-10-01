Import-Module Az
Import-Module AzureAd

Connect-AzAccount
Connect-AzureAd

$SubPRD = "Sub.ID - Inserir ID da SUB"
$SubHML = "Sub.ID - Inserir ID da SUB"
$SubDev = "Sub.ID - Inserir ID da SUB"
$SubDR = "Sub.ID - Inserir ID da SUB"
$createdby =  "cloud@adm.com"
$managedby = "azure portal"

$RG = Read-host "Digite o nome do resource group a ser criado sem o environment EX: nomedorg"
$keeper = Read-host "Digite o Keeper EX: cloud@adm.com"

Write-host "1 - Subscription de Prod"
Write-host "2 - Subscription de HML"
Write-host "3 - Subscription de Dev"
Write-host "4 - Subscription de DR"
Write-host "5 - Todas as Subscription"

$read = Read-host "escolha de 1 a 5"

$RGSufixo = New-Object PSObject -Property @{
    PRD = "-prd-rg"
    HML = "-hml-rg"
    DEV = "-dev-rg"
    DR  = "-dr-rg"
}


switch ($read) {
    1 {
        Select-Azsubscription -subscriptionid $SubPRD
        $RG = $RG + $RGSufixo.prd
        [string]$RBACContributor = 'rbac-' + $RG + '-contributor'
        [string]$RBACReader = 'rbac-' + $RG + '-reader'
        $EnvAzure = "HML"
        New-AzureADGroup -DisplayName $RBACContributor -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
        New-AzureADGroup -DisplayName $RBACReader -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
        New-AzResourceGroup -Name $RG -Location "EastUS 2" -Tag @{keeper=$keeper; Env=$EnvAzure; CreatedBy=$createdby; ManagedBy=$managedby }
        $GroupContributorID = (Get-AzADGroup -DisplayName $RBACContributor).id
        $GroupReaderID = (Get-AzADGroup -DisplayName $RBACReader).id
        Do {
             Write-host "Deseja adicionar membros aos grupos de HML?"
             Write-host "0 - Nao desejo ou finalizar loop"
             Write-host "1 - Adicionar Membro ao Grupo Contributor"
             Write-host "2 - Adicionar Membro ao Grupo Reader"
             $groupoption = Read-host "Escolha sua opção"
             
                if ($groupoption -eq 0 ) { $loop = 0}
                if ($groupoption -eq 1 ) {
                    
                    Write-host "Insira o login do usuário nome.sobrenome"
                    $login = Read-host
                    $login = $login+"@clearsale.com.br"
                    $UserID = (Get-AzADUser -ObjectId $login).id
                    Add-AzureADGroupMember -ObjectId $GroupContributorID -RefObjectId $UserID
                    $loop = 1
                }
                if ($groupoption -eq 2 ) {
                    
                    Write-host "Insira o login do usuário nome.sobrenome"
                    $login = Read-host
                    $login = $login+"@clearsale.com.br"
                    $UserID = (Get-AzADUser -ObjectId $login).id
                    Add-AzureADGroupMember -ObjectId $GroupReaderID -RefObjectId $UserID
                    $loop = 2
                }

       } Until ($loop -eq 0)
                    Start-Sleep -seconds 30
                    New-AzRoleAssignment -ObjectId $GroupContributorID -RoleDefinitionName Contributor -ResourceGroupName $RG
                    New-AzRoleAssignment -ObjectId $GroupReaderID -RoleDefinitionName Reader -ResourceGroupName $RG
       break
     }
    2 {
        Select-Azsubscription -subscriptionid $SubHML
        $RG = $RG + $RGSufixo.hml
        $RBACContributor = 'rbac-' + $RG + '-contributor'
        $RBACReader = 'rbac-' + $RG + '-reader'
        $EnvAzure = "HML"
        New-AzureADGroup -DisplayName $RBACContributor -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
        New-AzureADGroup -DisplayName $RBACReader -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
        New-AzResourceGroup -Name $RG -Location "EastUS 2" -Tag @{keeper=$keeper; Env=$EnvAzure; CreatedBy=$createdby; ManagedBy=$managedby }
        $GroupContributorID = (Get-AzADGroup -DisplayName $RBACContributor).id
        $GroupReaderID = (Get-AzADGroup -DisplayName $RBACReader).id
        Do {
             Write-host "Deseja adicionar membros aos grupos de HML?"
             Write-host "0 - Nao desejo ou finalizar loop"
             Write-host "1 - Adicionar Membro ao Grupo Contributor"
             Write-host "2 - Adicionar Membro ao Grupo Reader"
             $groupoption = Read-host "Escolha sua opção"
             
                if ($groupoption -eq 0 ) { $loop = 0}
                if ($groupoption -eq 1 ) {
                    
                    Write-host "Insira o login do usuário nome.sobrenome"
                    $login = Read-host
                    $login = $login+"@clearsale.com.br"
                    $UserID = (Get-AzADUser -ObjectId $login).id
                    Add-AzureADGroupMember -ObjectId $GroupContributorID -RefObjectId $UserID
                    $loop = 1
                }
                if ($groupoption -eq 2 ) {
                    
                    Write-host "Insira o login do usuário nome.sobrenome"
                    $login = Read-host
                    $login = $login+"@clearsale.com.br"
                    $UserID = (Get-AzADUser -ObjectId $login).id
                    Add-AzureADGroupMember -ObjectId $GroupReaderID -RefObjectId $UserID
                    $loop = 2
                }

       } Until ($loop -eq 0)
                    Start-Sleep -seconds 30
                    New-AzRoleAssignment -ObjectId $GroupContributorID -RoleDefinitionName Contributor -ResourceGroupName $RG 
                    New-AzRoleAssignment -ObjectId $GroupReaderID -RoleDefinitionName Reader -ResourceGroupName $RG 
       break
     }
    3 {
        Select-Azsubscription -subscriptionid $SubDev
        $RG = $RG + $RGSufixo.dev
        $RBACContributor = 'rbac-' + $RG + '-contributor'
        $RBACReader = 'rbac-' + $RG + '-reader'
        $EnvAzure = "DEV"
        New-AzureADGroup -DisplayName $RBACContributor -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
        New-AzureADGroup -DisplayName $RBACReader -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
        New-AzResourceGroup -Name $RG -Location "EastUS 2" -Tag @{keeper=$keeper; Env=$EnvAzure; CreatedBy=$createdby; ManagedBy=$managedby }
        $GroupContributorID = (Get-AzADGroup -DisplayName $RBACContributor).id
        $GroupReaderID = (Get-AzADGroup -DisplayName $RBACReader).id
        Do {
             Write-host "Deseja adicionar membros aos grupos de DEV?"
             Write-host "0 - Nao desejo ou finalizar loop"
             Write-host "1 - Adicionar Membro ao Grupo Contributor"
             Write-host "2 - Adicionar Membro ao Grupo Reader"
             $groupoption = Read-host "Escolha sua opção"
             
                if ($groupoption -eq 0 ) { $loop = 0}
                if ($groupoption -eq 1 ) {
                    
                    Write-host "Insira o login do usuário nome.sobrenome"
                    $login = Read-host
                    $login = $login+"@clearsale.com.br"
                    $UserID = (Get-AzADUser -ObjectId $login).id
                    Add-AzureADGroupMember -ObjectId $GroupContributorID -RefObjectId $UserID
                    $loop = 1
                }
                if ($groupoption -eq 2 ) {
                    
                    Write-host "Insira o login do usuário nome.sobrenome"
                    $login = Read-host
                    $login = $login+"@clearsale.com.br"
                    $UserID = (Get-AzADUser -ObjectId $login).id
                    Add-AzureADGroupMember -ObjectId $GroupReaderID -RefObjectId $UserID
                    $loop = 2
                }

       } Until ($loop -eq 0)
                    Start-Sleep -seconds 30
                    New-AzRoleAssignment -ObjectId $GroupContributorID -RoleDefinitionName Contributor -ResourceGroupName $RG 
                    New-AzRoleAssignment -ObjectId $GroupReaderID -RoleDefinitionName Reader -ResourceGroupName $RG 
       break
     }
    4 {
        Select-Azsubscription -subscriptionid $SubDR
        $RG = $RG + $RGSufixo.dr
        $RBACContributor = 'rbac-' + $RG + '-contributor'
        $RBACReader = 'rbac-' + $RG + '-reader'
        $EnvAzure = "DR"
        New-AzureADGroup -DisplayName $RBACContributor -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
        New-AzureADGroup -DisplayName $RBACReader -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
        New-AzResourceGroup -Name $RG -Location "EastUS 2" -Tag @{keeper=$keeper; Env=$EnvAzure.DR; CreatedBy=$createdby; ManagedBy=$managedby }
        $GroupContributorID = (Get-AzADGroup -DisplayName $RBACContributor).id
        $GroupReaderID = (Get-AzADGroup -DisplayName $RBACReader).id
        Do {
             Write-host "Deseja adicionar membros aos grupos de DEV?"
             Write-host "0 - Nao desejo ou finalizar loop"
             Write-host "1 - Adicionar Membro ao Grupo Contributor"
             Write-host "2 - Adicionar Membro ao Grupo Reader"
             $groupoption = Read-host "Escolha sua opção"
             
                if ($groupoption -eq 0 ) { $loop = 0}
                if ($groupoption -eq 1 ) {
                    
                    Write-host "Insira o login do usuário nome.sobrenome"
                    $login = Read-host
                    $login = $login+"@clearsale.com.br"
                    $UserID = (Get-AzADUser -ObjectId $login).id
                    Add-AzureADGroupMember -ObjectId $GroupContributorID -RefObjectId $UserID
                    $loop = 1
                }
                if ($groupoption -eq 2 ) {
                    
                    Write-host "Insira o login do usuário nome.sobrenome"
                    $login = Read-host
                    $login = $login+"@clearsale.com.br"
                    $UserID = (Get-AzADUser -ObjectId $login).id
                    Add-AzureADGroupMember -ObjectId $GroupReaderID -RefObjectId $UserID
                    $loop = 2
                }

       } Until ($loop -eq 0)
                    Start-Sleep -seconds 30
                    New-AzRoleAssignment -ObjectId $GroupContributorID -RoleDefinitionName Contributor -ResourceGroupName $RG 
                    New-AzRoleAssignment -ObjectId $GroupReaderID -RoleDefinitionName Reader -ResourceGroupName $RG 
       break
    }
    5 {
        $Subscription = Get-AzSubscription | ?{($_.Name -like "*- AZ*") -and ($_.Name -notlike "*CORP*")}

        foreach ($sub in $Subscription) {
        $RGLoop = $null
        Select-Azsubscription -subscription $sub
        if ($sub.Name -like "*PRD*") {
        $EnvAzure = "PRD"
        $RGloop = $RG + $RGSufixo.PRD}
        if ($sub.Name -like "*HML*") {
        $EnvAzure = "HML"
        $RGloop = $RG + $RGSufixo.HML}
        if ($sub.Name -like "*DEV*") {
        $EnvAzure = "DEV"
        $RGloop = $RG + $RGSufixo.DEV}
        if ($sub.Name -like "*DR*")  {
        $EnvAzure = "DR"
        $RGloop = $RG + $RGSufixo.DR}
        $RBACContributor = 'rbac-' + $RGloop + '-contributor'
        $RBACReader = 'rbac-' + $RGloop + '-reader'
        New-AzureADGroup -DisplayName $RBACContributor -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
        New-AzureADGroup -DisplayName $RBACReader -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
        New-AzResourceGroup -Name $RGloop -Location "EastUS 2" -Tag  @{keeper=$keeper; Env=$EnvAzure; CreatedBy=$createdby; ManagedBy=$managedby }
        $GroupContributorID = (Get-AzADGroup -DisplayName $RBACContributor).id
        $GroupReaderID = (Get-AzADGroup -DisplayName $RBACReader).id
        $GroupContributorID = "$GroupContributorID"
        $GroupReaderID = "$GroupReaderID"
        $SubName = $Sub.Name
        Do {
             Write-host "Deseja adicionar membros aos grupos de $SubName"
             Write-host "0 - Nao desejo ou finalizar loop"
             Write-host "1 - Adicionar Membro ao Grupo Contributor"
             Write-host "2 - Adicionar Membro ao Grupo Reader"
             $groupoption = Read-host "Escolha sua opção"
             
                if ($groupoption -eq 0 ) { $loop = 0}
                if ($groupoption -eq 1 ) {
                    
                    Write-host "Insira o login do usuário nome.sobrenome"
                    $login = Read-host
                    $login = $login+"@clearsale.com.br"
                    $UserID = (Get-AzADUser -ObjectId $login).id
                    $UserID = "$UserID"
                    Add-AzureADGroupMember -ObjectId $GroupContributorID -RefObjectId $UserID
                    $loop = 1
                }
                if ($groupoption -eq 2 ) {
                    
                    Write-host "Insira o login do usuário nome.sobrenome"
                    $login = Read-host
                    $login = $login+"@clearsale.com.br"
                    $UserID = (Get-AzADUser -ObjectId $login).id
                    Add-AzureADGroupMember -ObjectId $GroupReaderID -RefObjectId $UserID
                    $loop = 2
                }
            } Until ($loop -eq 0)
                    Start-Sleep -Seconds 30
                    New-AzRoleAssignment -ObjectId $GroupContributorID -RoleDefinitionName Contributor -ResourceGroupName $RGloop 
                    New-AzRoleAssignment -ObjectId $GroupReaderID -RoleDefinitionName Reader -ResourceGroupName $RGloop } 
        
                    break
    }
    Default { "opcao invalida"}
}
