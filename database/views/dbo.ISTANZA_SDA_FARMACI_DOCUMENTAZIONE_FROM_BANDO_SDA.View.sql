USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ISTANZA_SDA_FARMACI_DOCUMENTAZIONE_FROM_BANDO_SDA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[ISTANZA_SDA_FARMACI_DOCUMENTAZIONE_FROM_BANDO_SDA]  as
select 
  D1.id as ID_FROM ,
  [DescrizioneRichiesta] as Descrizione,
   TipoFile,
  [TipoFile] as TipoEstensione,
  AllegatoRichiesto as allegato,
  Obbligatorio ,
  ' Descrizione ' as NotEditable,
	idRow 	,
  AnagDoc,
   isnull( d.richiedifirma, '0') as richiedifirma
  
  
  
  from CTL_DOC D1
  inner join Document_Bando_DocumentazioneRichiesta d on d.idHeader=D1.id

GO
