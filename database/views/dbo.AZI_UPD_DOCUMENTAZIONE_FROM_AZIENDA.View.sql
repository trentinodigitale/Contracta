USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_UPD_DOCUMENTAZIONE_FROM_AZIENDA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[AZI_UPD_DOCUMENTAZIONE_FROM_AZIENDA]
AS
SELECT IdAzi AS ID_FROM
     ,  IdAzi
     ,  IdAzi as Azienda
     , Data as  aziDataCreazione
     , aziRagioneSociale
     , aziPartitaIVA
     , aziIdDscFormaSoc
     , aziE_Mail
     , aziIndirizzoLeg
     , aziLocalitaLeg
     , aziProvinciaLeg
     , aziStatoLeg
     , aziCAPLeg
     , aziTelefono1
     , aziTelefono2
     , aziFAX
     , aziSitoWeb
     
 FROM Aziende
LEFT JOIN CTL_DOC ON IdAzi = IdPfu







GO
