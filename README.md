# Contracta
mirror progetto

# Database
sono predisposti due database: AFLink_TND (https://github.com/trentinodigitale/Contracta/blob/main/sater4.x/AFLink_TND.sql) e AFLink_TND_pub (utilizzato da Joomla per la parte portale).

# Application Server
# Abilitazioni rete:
- SQL Server
- AAC
- …
  
# Software installato:
- .net Framework 3.5 (turn Windows Feature on)
- .net Framework 4.8 (turn Windows Feature on)
- .net 6.0 runtime (download)
- .net 6.0 shared framework (download)
- .net 6.0 hosting bundle (download)
- Visual C++ redistributable 2012 (32/64bit) (download)
- php 5.6.30 (con sqlserver extension)
  - abilitazione della Windows Feature CGI
  - installazione di php (download)
  - copia nella cartella ext delle librerie per estensione sqlserver (download) e loro configurazione in php.ini
  - verifica/configurazione handler mapping per estensione *.php in IIS
- Microsoft ODBC Driver 11 for sql server (download)
- Chilkat (setup non disponibile, software proprietario)

# Struttura parte Web
A fronte di una struttura su filesystem D:\PortaleGareTelematiche\Web

	\AppLegacy → progetto OAuth2OpenID
	\EProcNext → progetto eProcurementNext.Razor
	\portale → portale Joomla
	\aflinkws (qualcosa relativo a afsoluzioni???)
	\WebAPI → progetto eProcurementNext.WebAPI
	\Services → progetto Protocollopitre
	\AF_WebFileManager → progetto AF_WebFileManager
	\WebApiFramework → progetto INIPEC

IIS è configurato come:
- default site che punta al path EProcNext (AppPool 4.0 integrated), configurare connection string in appsettings.json
  - application AppLegacy che punta al path AppLegacy (AppPool 2.0 integrated), configurare connection string in web.config
  - application portalegare che punta al path portale (AppPool 2.0 classic 32bit enabled), configurare server database in configuration.php
  - application aflinkws che punta al path aflinkws (AppPool 2.0 classic 32bit enabled)
  - application rest che punta al path WebAPI (AppPool 4.0 integrated)
  - application Services che punta al path Services (AppPool 4.0 integrated)
  - application TS_WebFileManager che punta al path AF_WebFileManager (AppPool 4.0 integrated)
  - application WebApiFramework che punta al path WebApiFramework (AppPool 4.0 integrated)

# Servizi a supporto
- D:\PortaleGareTelematiche\Server
- AfServiceStarter → \AFServiceStarter\AfServiceStarter.exe
- AFUpdate → \AFUpdate\AFUpdate.exe
- Servizio di aggiornamento automatico AFLink
- CTLServices → EprocNext.Services\eProcurementNext.Services.exe
  servizio per eseguire in background i processi dell'applicazione web eProcurementNext
- Pi.E.Tr.O. Service → IntSys\Server\IntServ.exe
