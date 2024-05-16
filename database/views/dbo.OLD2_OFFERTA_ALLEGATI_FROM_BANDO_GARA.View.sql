USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_OFFERTA_ALLEGATI_FROM_BANDO_GARA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD2_OFFERTA_ALLEGATI_FROM_BANDO_GARA] as
	select 
		idHeader as ID_FROM
		,cast(DescrizioneRichiesta as nvarchar(500))as Descrizione
		,AllegatoRichiesto as Allegato
		,Obbligatorio
		,AnagDoc
		,TipoFile
		,' Descrizione ' as NotEditable
		, isnull(RichiediFirma,'0') as RichiediFirma

	 from Document_Bando_DocumentazioneRichiesta






GO
