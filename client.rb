remote_file 'C:\winx64_12101_client.zip' do
  source node['br_OracleClient_win']['OracleClient-Repo']
  action :create_if_missing
end

powershell_script "Setup-Oracle-Client" do
  code <<-EOH
    param ([Parameter(Mandatory=$false)][string]$environmentName ="dev",[Parameter(Mandatory=$false)][string]$oracleClientDownloadPath = "C:/winx64_12101_client.zip")
    Set-StrictMode -Version latest
    $ErrorActionPreference = "Stop"
    $installationDrive                      = "c:"
    $realativePathForOracleClient           = "win_12.1.0.2/client/"
    $OracleClientSetupFile                  = "setup.exe"
    $relativePathForOracleHome              = "/app/client/product/12.1.0/client_1"
    $relativePathForNetworkAdmin            = "/network/admin"
    $tnsNamesOraDefaultFileName             = "tnsnames.ora"
    $fileSeparator                          = "_"
    $pathSeparator                          = "/"
    $relativeUnzipLocation                  = "/AservePackage/software/"
    $realativePathForResponseFile           = "response/client.rsp"
    $absolutPathForOracleHome           = $installationDrive            + $relativePathForOracleHome
    $oracleClientUnzipLocation          = $installationDrive            + $relativeUnzipLocation
    $responseFilePath                   = $oracleClientUnzipLocation    + $realativePathForOracleClient         + $realativePathForResponseFile
    $oracleClientSetupFilePath          = $oracleClientUnzipLocation    + $realativePathForOracleClient         + $OracleClientSetupFile
    $oracleClientSilentInstallArguments = "-silent -waitforcompletion -noconsole -responseFile " + $responseFilePath
    Function UnzipOracleClientPackage() {
      Write-Host "Unzipping Oracle package"
      Expand-Archive -Path $oracleClientDownloadPath -DestinationPath $oracleClientUnzipLocation
    }
    Function InstallOracleClient() {
      Write-Host "Starting installation of oracle client"
      Start-Process -FilePath $oracleClientSetupFilePath -ArgumentList $oracleClientSilentInstallArguments -NoNewWindow -Wait
    }
   Function main() {
      UnzipOracleClientPackage
      InstallOracleClient
    }
    main
    EOH
  not_if 'test-path C:/app/client/product/12.1.0/client_1'
end
