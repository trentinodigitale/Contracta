USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_CAMBIO_UTENTE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MAIL_CAMBIO_UTENTE]
AS
SELECT  
'I' as LNG,   
 C.id as IdDoc,
 (Select pfuNome from ProfiliUtente where idpfu=C2.Value) as Mittente, 
 (Select pfuNome from ProfiliUtente where idpfu=C1.Value) as NuovoUtente, 
 C.ID as ID_FROM,
 C.ProtocolloRiferimento ,
 C.Body 

FROM         ctl_doc as C
inner join CTL_DOC_VALUE C1 on ID=C1.IDHEADER and C1.DZT_NAME='UtenteInGestione'
inner join CTL_DOC_VALUE C2 on ID=C2.IDHEADER and C2.DZT_NAME='Utente'
--inner join ProfiliUtente on C.Idpfu=ProfiliUtente.IdPfu
where TipoDoc='CAMBIO_UTENTE' 

GO
