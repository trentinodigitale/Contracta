USE [AFLink_TND]
GO
/****** Object:  View [dbo].[COM_DPE_RISPOSTA_FROM_COM_DPE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[COM_DPE_RISPOSTA_FROM_COM_DPE] as
select 
	Document_Com_DPE.IdCom,
	Document_Com_DPE.IdCom as ID_FROM,
	Document_Com_DPE.IdCom as LinkedDoc,
	DataScadenzaCom,
	[owner] as Destinatario_User,
	Name as Titolo,
	Protocollo as ProtocolloRiferimento,
	DataCreazione as DataCompilazione,
	StatoCom,
	RichiestaRisposta,
	DataScadenza,
	NotaCom,
	--IdAzi,
	'FORNITORI' as JumpCheck
from dbo.Document_Com_DPE 
	--left outer join dbo.Document_Com_DPE_Fornitori  on Document_Com_DPE_Fornitori.IdCom=Document_Com_DPE.IdCom
where Deleted = 0
GO
