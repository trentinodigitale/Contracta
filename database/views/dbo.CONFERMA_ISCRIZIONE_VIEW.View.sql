USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONFERMA_ISCRIZIONE_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[CONFERMA_ISCRIZIONE_VIEW] as 

	select d.*
		,i.Azienda as LegalPub
		,i.Protocollo as ProtocolloOfferta
		,bando.ResponsabileProcedimento 
		,i.tipodoc as colonnatecnica
		,bando.protocollo as ProtocolloCapostipite
		,ISNULL(CV.value,'') as Conferma_Parziale
		,ISNULL(n.value,'') as NumGiorni
		,ISNULL(c.value,'0') as Richiesta_Info
		, dbo.Get_Scelta_Classi_Libera_From_Albo(bando.id)  as Scelta_Classi_Libera
		--,A.Scelta 
		, 
			case 
				when bando.tipodoc = 'bando_sda' then bandosda2.value 
				else dettbando.ClasseIscriz 
			end as ClassiBando
		, bandosda.value as Elenco_Categorie_Merceologiche 
		, bandosda1.value as Livello_Categorie_Merceologiche
		, bando.id as IdDocBando

	from CTL_DOC  d												--conferma
		inner join CTL_DOC i on d.LinkedDoc = i.id				-- istanza
		left join CTL_DOC_VIEW bando ON bando.id = i.LinkedDoc  -- bando sda
		left join document_bando dettBando on dettBando.idheader = bando.id
		left join CTL_DOC_Value CV on CV.IdHeader=d.id and CV.DSE_ID='CLASSI' and CV.DZT_Name='Conferma_Parziale'		
		left join CTL_DOC_Value n on n.IdHeader=d.id and n.DSE_ID='ALLEGATO' and n.DZT_Name='NumGiorni'		
		left join CTL_DOC_Value c on c.IdHeader=bando.id and c.DSE_ID='TESTATA_PRODOTTI' and c.DZT_Name='Richiesta_Info'
		left join CTL_DOC_Value bandosda on bandosda.IdHeader=bando.id and bandosda.DSE_ID='TESTATA_PRODOTTI' and bandosda.DZT_Name='Elenco_Categorie_Merceologiche'
		left join CTL_DOC_Value bandosda1 on bandosda1.IdHeader=bando.id and bandosda1.DSE_ID='TESTATA_PRODOTTI' and bandosda1.DZT_Name='Livello_Categorie_Merceologiche'
		left join CTL_DOC_Value bandosda2 on bandosda2.IdHeader=bando.id and bandosda2.DSE_ID='TESTATA_PRODOTTI' and bandosda2.DZT_Name='Categorie_Merceologiche'

		
		
				
		--cross join ( select dbo.Get_Scelta_Classi_Libera_From_Albo(bando.id) as Scelta ) A 

GO
