USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Bando_Copertina]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[Document_Bando_Copertina] as
select 
	CTL_DOC .* ,
	Document_Bando .* ,
	CT.value as TipoBandoScelta,
	CT2.value as id_modello,
	CT3.Value as ClasseIscriz_Sospese,
	CT4.Value as ClasseIscriz_Revocate,
	CT5.Value as Categorie_Merceologiche,
	CT6.Value as Elenco_Categorie_Merceologiche,
	CT7.Value as Livello_Categorie_Merceologiche,
	CT8.Value as NumGiorniDomandaPartecipazione,
	CT9.Value as Richiesta_Info,
	CT10.Value as NoteScheda,
	az1.aziRagioneSociale as aziRagioneSociale,
	az1.idazi as StazioneAppaltante,
	case when W.LinkedDoc IS NULL then 1 else 0 end as FLAG_NUOVA_ESTRAZIONE_OE
	,GARE_IN_MODIFICA_O_RETTIFICA
from CTL_DOC
left join aziende az1 ON az1.idazi = azienda
left outer  join Document_Bando  on idheader = id
left outer join CTL_DOC_Value CT on CT.idHeader=id and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='TipoBandoScelta'
left outer join CTL_DOC_Value CT2 on CT2.idHeader=id and CT2.DSE_ID='TESTATA_PRODOTTI' and CT2.DZT_Name='id_modello'
left outer join CTL_DOC_Value CT3 on CT3.idHeader=id and CT3.DSE_ID='CLASSI' and CT3.DZT_Name='ClasseIscriz_Sospese'
left outer join CTL_DOC_Value CT4 on CT4.idHeader=id and CT4.DSE_ID='CLASSI' and CT4.DZT_Name='ClasseIscriz_Revocate'
left outer join CTL_DOC_Value CT10 on CT10.idHeader=id and CT10.DSE_ID='CLASSI' and CT10.DZT_Name='NoteScheda'
left outer join CTL_DOC_Value CT5 on CT5.idHeader=id and CT5.DSE_ID='TESTATA_PRODOTTI' and CT5.DZT_Name='Categorie_Merceologiche'
left outer join CTL_DOC_Value CT6 on CT6.idHeader=id and CT6.DSE_ID='TESTATA_PRODOTTI' and CT6.DZT_Name='Elenco_Categorie_Merceologiche'
left outer join CTL_DOC_Value CT7 on CT7.idHeader=id and CT7.DSE_ID='TESTATA_PRODOTTI' and CT7.DZT_Name='Livello_Categorie_Merceologiche'
left outer join CTL_DOC_Value CT8 on CT8.idHeader=id and CT8.DSE_ID='TESTATA_PRODOTTI' and CT8.DZT_Name='NumGiorniDomandaPartecipazione'
left outer join CTL_DOC_Value CT9 on CT9.idHeader=id and CT9.DSE_ID='TESTATA_PRODOTTI' and CT9.DZT_Name='Richiesta_Info'
left outer join (select linkeddoc from CTL_DOC with(nolock) where TipoDoc='OE_DA_CONTROLLARE' and StatoFunzionale='InLavorazione' and deleted=0 group by LinkedDoc ) W on W.LinkedDoc=id
cross join ( select dbo.GetBandiInRettificaOModifica( ) as GARE_IN_MODIFICA_O_RETTIFICA ) as girm


GO
