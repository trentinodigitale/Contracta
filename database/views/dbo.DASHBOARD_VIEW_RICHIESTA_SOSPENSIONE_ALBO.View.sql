USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_RICHIESTA_SOSPENSIONE_ALBO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_RICHIESTA_SOSPENSIONE_ALBO] as 
select  C.ID,
C.Azienda,
aziRagioneSociale,
aziIdDscFormaSoc,
aziPartitaIVA,
aziIndirizzoLeg,
aziCAPLeg,
aziProvinciaLeg,
aziStatoLeg,
aziLocalitaLeg,
aziTelefono1 as aziTelefono,
aziTelefono1 ,
aziFAX,
aziE_Mail,
C.Data,
C.StatoDoc,
C.DataInvio as DataCreazione,
C.StatoFunzionale,
a.vatValore_FT as codicefiscale,
b.vatValore_FT as EmailRapLeg


from CTL_DOC C
inner join aziende on idazi=C.Azienda
inner join DM_ATTRIBUTI a on a.lnk = idazi and a.dztNome='codicefiscale'
inner join DM_ATTRIBUTI b on b.lnk = idazi and b.dztNome='EmailRapLeg'
where C.tipodoc='SOSPENSIONE_ALBO'




GO
