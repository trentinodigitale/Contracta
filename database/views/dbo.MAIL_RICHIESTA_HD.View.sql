USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_RICHIESTA_HD]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MAIL_RICHIESTA_HD]
AS
SELECT    
	C.ID as IdHeader,
	C.Id as IDDOC, 
	C.Titolo,
	C1.Value as ticket,
	C2.Value as Riferimento,
	C3.Value as Telefono,
	C4.Value as Email,
	C5.Value as Funzionalita,
	C6.Value as AltraFunzionalita,
	DMV_DescML as CodiceUrgenza,
	P.PfuNome as Operatore,
	C.Body as Descrizione,
	convert( varchar , C.Data , 103 ) as Data,
	'I' as LNG
FROM         
ctl_doc C
inner join ProfiliUtente P on P.IdPfu=C.IdPfu
left join CTL_DOC_VALUE C1 on C1.idHeader=C.id and C1.DSE_ID='TESTATA_SEGNALAZIONE' and C1.DZT_NAME='ticketAFS'
left join CTL_DOC_VALUE C2 on C2.idHeader=C.id and C2.DSE_ID='TESTATA_SEGNALAZIONE' and C2.DZT_NAME='NomeUtente'
left join CTL_DOC_VALUE C3 on C3.idHeader=C.id and C3.DSE_ID='TESTATA_SEGNALAZIONE' and C3.DZT_NAME='Telefono'
left join CTL_DOC_VALUE C4 on C4.idHeader=C.id and C4.DSE_ID='TESTATA_SEGNALAZIONE' and C4.DZT_NAME='EMAIL'
left join CTL_DOC_VALUE C5 on C5.idHeader=C.id and C5.DSE_ID='TESTATA_SEGNALAZIONE' and C5.DZT_NAME='Funzioni'
left join CTL_DOC_VALUE C6 on C6.idHeader=C.id and C6.DSE_ID='TESTATA_SEGNALAZIONE' and C6.DZT_NAME='AltraClassificazione'
left join CTL_DOC_VALUE C7 on C7.idHeader=C.id and C7.DSE_ID='TESTATA_SEGNALAZIONE' and C7.DZT_NAME='Priorita'
left join dbo.LIB_DomainValues on C7.Value=DMV_Cod and DMV_DM_ID='priorita'
where C.TipoDoc='RICHIESTA_HD' and C.deleted=0

GO
