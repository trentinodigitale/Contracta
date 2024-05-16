USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DOWNLOAD_ATTACH_LISTA_ALLEGATI_EXTRA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[OLD_DOWNLOAD_ATTACH_LISTA_ALLEGATI_EXTRA] AS

	-- AVVISI DI RETTIFICA BANDO_GARA,BANDO_SEMPLIFICATO
	Select c.TipoDoc, c.id as id, isnull(allegato,'') as allegato , 'RETTIFICA' as tipo
		from ctl_doc c with(nolock)
			inner join ctl_doc c2 with(nolock) on c2.linkedDoc=c.id and c2.tipodoc='RETTIFICA_GARA' and c2.StatoFunzionale='Inviato' and c2.jumpcheck='BANDO_GARA' 
			inner join ctl_doc_allegati with(nolock) on  idheader=c2.id
		where isnull(allegato,'') <> ''

	UNION

	-- AVVISI DI RETTIFICA BANDO_SDA
	Select  c.TipoDoc, c.id as id, isnull(allegato,'') as allegato , 'RETTIFICA' as tipo
		from ctl_doc c with(nolock)
			inner join ctl_doc c2 with(nolock) on c2.linkedDoc=c.id and c2.tipodoc='RETTIFICA_BANDO' and c2.StatoFunzionale='Approved' and c2.jumpcheck='BANDO_SDA' 
			inner join ctl_doc_allegati with(nolock) on  idheader=c2.id
		where isnull(allegato,'') <> ''
    
     UNION
	
	
	-- AVVISI DI PROROGA BANDO_SDA
	Select  c.TipoDoc, c.id as id, isnull(allegato,'') as allegato , 'PROROGA' as tipo
		from ctl_doc c with(nolock)
			inner join ctl_doc c2 with(nolock) on c2.linkedDoc=c.id and c2.tipodoc='PROROGA_BANDO' and c2.StatoFunzionale='Approved' and c2.jumpcheck='BANDO_SDA' 
			inner join ctl_doc_allegati with(nolock) on  idheader=c2.id
		where isnull(allegato,'') <> ''



     UNION
	
	-- AVVISI DI PROROGA BANDO GARA , BANDO_SEMPLIFCATO
	Select  c.TipoDoc, c.id as id, isnull(allegato,'') as allegato , 'PROROGA' as tipo
		from ctl_doc c with(nolock)
			inner join ctl_doc c2 with(nolock) on c2.linkedDoc=c.id and c2.tipodoc='PROROGA_GARA' and c2.StatoFunzionale='Inviato' and c2.jumpcheck='BANDO_GARA' 
			inner join ctl_doc_allegati with(nolock) on  idheader=c2.id
		where isnull(allegato,'') <> '' 


    
     UNION
	
	-- AVVISI DI REVOCA BANDO GARA,BANDO_SEMPLIFICATO,BANDO_SDA
	Select  c.TipoDoc, c.id as id, isnull(allegato,'') as allegato , 'REVOCA' as tipo
		from ctl_doc c with(nolock)
			inner join ctl_doc c2 with(nolock) on c2.linkedDoc=c.id and c2.tipodoc='PDA_COMUNICAZIONE_GENERICA' and c2.StatoFunzionale='Inviato' and c2.jumpcheck in  ('0-REVOCA_BANDO' )
			inner join ctl_doc_allegati with(nolock) on  idheader=c2.id
		where isnull(allegato,'') <> '' 
    

     UNION


	-- AVVISI GENERICI
	select c.TipoDoc, A.linkeddoc as id, isnull(A.sign_attach,'') as allegato , 'AVVISO' as tipo
			from AVVISI_GARA_LISTA_DOCUMENTI A
				inner join ctl_doc C with(nolock) on C.id = A.LinkedDoc
		where A.StatoFunzionale = 'Inviato' and isnull(A.sign_attach,'') <> ''

	UNION

	-- PUBBLICAZIONI / ESITI
	select Tipodoc_src as Tipodoc, leg as id, isnull(allegato,'') as allegato  , 'PUBBLICAZIONE' as tipo
		from DOCUMENT_RISULTATODIGARA_ROW_VIEW 
		where StatoFunzionale = 'Inviato' and isnull(allegato,'') <> ''
    

    UNION
	
	-- AVVISI DI PROROGA BANDO CONSULTAZIONE 
	Select  c.TipoDoc, c.id as id, isnull(allegato,'') as allegato , 'PROROGA' as tipo
		from ctl_doc c with(nolock)
			inner join ctl_doc c2 with(nolock) on c2.linkedDoc=c.id and c2.tipodoc='PROROGA_CONSULTAZIONE' and c2.StatoFunzionale='Inviato' and c2.jumpcheck='BANDO_CONSULTAZIONE' 
			inner join ctl_doc_allegati with(nolock) on  idheader=c2.id
		where isnull(allegato,'') <> '' 

	UNION
	-- AVVISI DI RETTIFICA BANDO CONSULTAZIONE 
	Select c.TipoDoc, c.id as id, isnull(allegato,'') as allegato , 'RETTIFICA' as tipo
		from ctl_doc c with(nolock)
			inner join ctl_doc c2 with(nolock) on c2.linkedDoc=c.id and c2.tipodoc='RETTIFICA_CONSULTAZIONE' and c2.StatoFunzionale='Inviato' and c2.jumpcheck='BANDO_CONSULTAZIONE' 
			inner join ctl_doc_allegati with(nolock) on  idheader=c2.id
		where isnull(allegato,'') <> ''
	
	UNION
	-- AVVISI DI SOSPENSIONE_GARA
	Select  c.TipoDoc, c.id as id, isnull(allegato,'') as allegato , 'SOSPENSIONE_GARA' as tipo
		from ctl_doc c with(nolock)
			inner join ctl_doc c2 with(nolock) on c2.linkedDoc=c.id and c2.tipodoc='PDA_COMUNICAZIONE_GENERICA' and c2.StatoFunzionale='Inviato' and c2.jumpcheck in  ('0-SOSPENSIONE_GARA' )
			inner join ctl_doc_allegati with(nolock) on  idheader=c2.id
		where isnull(allegato,'') <> '' 

	UNION
	-- AVVISI DI RIPRISTINO_GARA
	Select  c.TipoDoc, c.id as id, isnull(allegato,'') as allegato , 'RIPRISTINO_GARA' as tipo
		from ctl_doc c with(nolock)
			inner join ctl_doc c2 with(nolock) on c2.linkedDoc=c.id and c2.tipodoc='RIPRISTINO_GARA' and c2.StatoFunzionale='Inviato'-- and c2.jumpcheck='BANDO_GARA' 
			inner join ctl_doc_allegati with(nolock) on  idheader=c2.id
		where isnull(allegato,'') <> '' 


    UNION
	--PARAMETRI ALLEGATI CONTENUTI NEL MODULO QUESTIONARIO AMMINISTRATIVO COLLEGFATO
	SELECT 
		c.TipoDoc, c.id as id,isnull(value,'') as allegato,'MODULO_QUESTIONARIO_AMMINISTRATIVO' as tipo
		--MA.*
		FROM CTL_DOC c with (nolock)
			inner join ctl_doc M with(nolock) on M.linkedDoc=c.id and M.tipodoc='MODULO_QUESTIONARIO_AMMINISTRATIVO' and isnull(m.SIGN_ATTACH,'')<>''
			inner join CTL_DOC_SECTION_MODEL MO with(nolock) on MO.IdHeader = M.id  and MO.DSE_ID='MODULO'
			inner join CTL_ModelAttributes MOA with(nolock) on MOA.MA_MOD_ID = MO.MOD_Name and MOA.DZT_Type=18
			inner join ctl_doc_value MA with(nolock) on MA.IdHeader = M.id and ma.DZT_Name = MOA.MA_DZT_Name
	--where c.id=423759
	
			
GO
