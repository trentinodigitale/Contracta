USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OFFERTA_ALLEGATI_FROM_ODC]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OFFERTA_ALLEGATI_FROM_ODC] as
select 
	d.id as ID_FROM
	,DescrizioneRichiesta as Descrizione
	,/*AllegatoRichiesto*/ ''  as Allegato
	,Obbligatorio
	,AnagDoc
	,TipoFile
	,' Descrizione ' as NotEditable
	, RichiediFirma
 from 
	CTL_doc d
		inner join Document_Bando_DocumentazioneRichiesta on idheader = d.linkeddoc


GO
