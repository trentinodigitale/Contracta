USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_ESTRAZIONE_AUSILIARIE_PDA_VERIFICA_AMM_XLSX]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_VIEW_ESTRAZIONE_AUSILIARIE_PDA_VERIFICA_AMM_XLSX] as
select 
	[Document_PDA_OFFERTE_VIEW].[IdRow], 
	[Document_PDA_OFFERTE_VIEW].[IdHeader],
	[Document_PDA_OFFERTE_VIEW].[IdHeader] as IDDOC, 
	[NumRiga], 
	[Document_PDA_OFFERTE_VIEW].[aziRagioneSociale], 
	[ProtocolloOfferta], 
	[ReceivedDataMsg], 
	[IdMsg], 
	[IdMittente], 
	[idAziPartecipante], 
	[StatoPDA], 
	[TipoDoc], 
	[bReadEconomica], 
	[bReadDocumentazione], 
	[Motivazione], 
	[VerificaCampionatura], 
	[warning], 
	[EsclusioneLotti], 
	[id_ritira_offerta], 
	[Avvalimento],
	DM.vatValore_FT as codicefiscale,
	A.aziPartitaIVA as PartitaIva,
	ISNULL(DO.RagSocRiferimento,'') as RagSocRiferimento,
	ISNULL(DO.CodiceFiscale,'') as CodiceFiscaleReferente,
	ISNULL(DO.RagSoc,'') as RagSoc,
	ISNULL(DO.IndirizzoLeg,'') as INDIRIZZOLEG,
	ISNULL(DO.LocalitaLeg,'') as LOCALITALEG,
	ISNULL(DO.ProvinciaLeg,'') as PROVINCIALEG
from [dbo].[Document_PDA_OFFERTE_VIEW]
	inner join Aziende A with(nolock) on A.IdAzi=idAziPartecipante 
	left join DM_Attributi DM with(nolock) on DM.lnk=idAziPartecipante and DM.dztNome='codicefiscale'
	left join Document_Offerta_Partecipanti DO with(nolock) on Avvalimento='S' and DO.IdHeader=IdMsg and DO.TipoRiferimento='AUSILIARIE'
	--NON MOSTRA LE RITIRATE E LE INVALIDATE
	where StatoPDA not in ('99','999')
GO
