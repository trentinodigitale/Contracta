USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_REPERTORIO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_REPERTORIO]
AS
SELECT 
IdRepertorio, StatoRepertorio, Conto, Rep, NaturaAtto, CAST(Oggetto AS nvarchar(200)) AS Oggetto,
TipoContratto, DataStipula, DataInizio, DataFine, DurataAnni, Serie, NumRegistrazione, DataRegistrazione,
Corrispettivo, DepositoCauzionale, UfficioRegistro, UffRogante, Importo, TassaRegistrazione, NumMarche,NumMarche2,ProtocolloBando,
ValMarche, ValMarche2,ImportoMarche2,ImportoMarche, DirittiSegreteria, DirittiAccesso, DirittiRogito, SpesePostali, Saldo,NumReversale,DataReversale,ImportoComplessivo, CAST(NoteProgetto AS nvarchar(200)) AS NoteProgetto, idAggiudicatrice as Fornitore
, DataStipula as DataStipulaA,DirittiSegreteria * 0.675 as Spettanze
FROM         dbo.Document_Repertorio

GO
