USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OFFERTA_ALLEGATI_FROM_BANDO_SEMPLIFICATO]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OFFERTA_ALLEGATI_FROM_BANDO_SEMPLIFICATO] as
select 
	idHeader as ID_FROM
	,DescrizioneRichiesta as Descrizione
	,/*AllegatoRichiesto*/ ''  as Allegato
	,Obbligatorio
	,AnagDoc
	,TipoFile
	,' Descrizione ' as NotEditable
	, RichiediFirma
 from Document_Bando_DocumentazioneRichiesta


GO
