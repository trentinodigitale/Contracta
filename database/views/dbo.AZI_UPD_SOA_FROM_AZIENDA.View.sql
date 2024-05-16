USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_UPD_SOA_FROM_AZIENDA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[AZI_UPD_SOA_FROM_AZIENDA]
AS
SELECT     a.aziRagioneSociale,
			a.aziPartitaIVA, 
			AttachAttestazioneSOA, 
			DataAttestazioneSOA ,
            a.IdAzi, NoteSOA , 
            a.IdAzi AS ID_FROM

FROM         dbo.Aziende as a LEFT OUTER JOIN dbo.Document_Aziende as b 
						on a.IdAzi = b.idazi and isOld = 0 and TipoOperAnag in ('AZI_PERGIUR','AZI_UPD_SOA' )

GO
