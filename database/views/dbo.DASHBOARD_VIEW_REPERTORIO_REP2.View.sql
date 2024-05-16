USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_REPERTORIO_REP2]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  VIEW [dbo].[DASHBOARD_VIEW_REPERTORIO_REP2]
AS
SELECT 
r.IdRepertorio, r.StatoRepertorio, r.Conto, r.Rep, r.NaturaAtto, CAST(r.Oggetto AS nvarchar(200)) AS Oggetto,
r.TipoContratto, r.DataStipula, r.DataInizio, r.DataFine, r.DurataAnni, r.Serie, r.NumRegistrazione, r.DataRegistrazione,
r.Corrispettivo, r.DepositoCauzionale, r.UfficioRegistro, r.UffRogante, r.Importo, r.TassaRegistrazione, r.NumMarche,r.NumMarche2,r.ProtocolloBando,
r.ValMarche, r.ValMarche2, r.DirittiSegreteria, r.DirittiAccesso, r.DirittiRogito, r.SpesePostali, r.Saldo,r.NumReversale,r.DataReversale,r.ImportoComplessivo
, CAST(r.NoteProgetto AS nvarchar(200)) AS NoteProgetto
, r.idAggiudicatrice as Fornitore
, r.DataStipula as DataStipulaA , 
cast( s.NumMandato as float ) as Mandato 
, case when isnull( cast( s.NumMandato as float ) , 0 ) = 0 then 0 else 1 end as DomMandato
, case when isnull( cast( i.NumMandato as float ) , 0 ) = 0 then 0 else 1 end as DomMandatoTR
, r.DatiBilancio 
 , s.DataMandato
, i.NumMandato 
, i.DataMandato as DataMandatoImpReg
, r.ImportoMarche2 + r.ImportoMarche as ImportoMarche
, Saldo + DirittiSegreteria + DirittiAccesso + SpesePostali as totMANDATO
, i.NumMandato + ' - ' + right( convert( varchar(10) , i.DataMandato , 121 ) , 2) + '/' +
						 substring( convert( varchar(10) , i.DataMandato , 121 ) , 6,2) + '/' +
						left( convert( varchar(10) , i.DataMandato , 121 ) , 4) as NumDataTR

, s.NumMandato + ' - ' + right( convert( varchar(10) , s.DataMandato , 121 ) , 2) + '/' +
						 substring( convert( varchar(10) , s.DataMandato , 121 ) , 6,2) + '/' +
						left( convert( varchar(10) , s.DataMandato , 121 ) , 4) as NumDataSC

FROM         dbo.Document_Repertorio r
	left outer join Document_Sistemazione_Contabile s on s.ID_Repertorio = IdRepertorio
	left outer join Document_ImpostaReg i on i.ID_Repertorio = IdRepertorio

GO
