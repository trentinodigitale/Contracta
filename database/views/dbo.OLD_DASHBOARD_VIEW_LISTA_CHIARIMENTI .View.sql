USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_LISTA_CHIARIMENTI ]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_LISTA_CHIARIMENTI ]  AS

	-- Prende gli utenti definiti nei riferimenti per i quesiti
	SELECT  c.* 
			, 'DETAIL_CHIARIMENTI_BANDO' as ELENCOGrid_OPEN_DOC_NAME
			, c.id as ELENCOGrid_ID_DOC 
			,case isnull(chiarimentoevaso,0)
				WHEN 0 THEN ''
				else ' ChiarimentoEvaso '
				END AS Not_Editable
			, TipoDoc
			, Titolo
			, cast( Body as nvarchar(4000)) as Body
			, d.Protocollo as ProtocolloRiferimento
			, r.idPfu as Owner
			, CIG
			, convert( varchar(10) , c.DataCreazione , 121 ) as DataA
			, convert( varchar(10) , c.DataCreazione , 121 ) as DataI
			, isnull(TipoProceduraCaratteristica,'') as TipoProceduraCaratteristica
			,isnull(JumpCheck,'') as JumpCheck
			,d.id as ListaAlbi
			,TipoSceltaContraente
			, CU.Cottimo_Gara_Unificato
		from 
			document_chiarimenti c with(nolock) 
			inner join CTL_DOC d with(nolock) on d.id = id_origin
			inner join Document_bando b with(nolock) on b.idheader = id_origin
			inner join Document_Bando_Riferimenti r with(nolock) on r.idheader = id_origin and RuoloRiferimenti = 'Quesiti'
			
			--vedo tramite parametro se il Cottimo è unificato alle Procedure di gara
			cross join (select dbo.PARAMETRI('GROUP_Procedura','Cottimo_Gara_Unificato','ATTIVO','NO',-1 ) as Cottimo_Gara_Unificato ) CU  

		where isnull( protocol , '' ) <> '' and ISNULL(Document,'')<>''

-- Prende i responsabili del procedimento per ALBO e SDA
union 

	SELECT  c.* 
			, 'DETAIL_CHIARIMENTI_BANDO' as ELENCOGrid_OPEN_DOC_NAME
			, c.id as ELENCOGrid_ID_DOC 
			,case isnull(chiarimentoevaso,0)
				WHEN 0 THEN ''
				else ' ChiarimentoEvaso '
				END AS Not_Editable
			, TipoDoc
			, Titolo
			, cast( Body as nvarchar(4000)) as Body
			, d.Protocollo as ProtocolloRiferimento
			, r.idPfu as Owner
			, CIG
			, convert( varchar(10) , c.DataCreazione , 121 ) as DataA
			, convert( varchar(10) , c.DataCreazione , 121 ) as DataI
			, isnull(TipoProceduraCaratteristica,'') as TipoProceduraCaratteristica
			,isnull(JumpCheck,'') as JumpCheck
			,d.id as ListaAlbi
			,TipoSceltaContraente
			, CU.Cottimo_Gara_Unificato
		from 
			document_chiarimenti c with(nolock) 
			inner join CTL_DOC d with(nolock) on d.id = id_origin
			inner join Document_bando b with(nolock) on b.idheader = id_origin
			inner join Document_Bando_Commissione r with(nolock) on r.idheader = id_origin and RuoloCommissione = '15550'
			--vedo tramite parametro se il Cottimo è unificato alle Procedure di gara
			cross join (select dbo.PARAMETRI('GROUP_Procedura','Cottimo_Gara_Unificato','ATTIVO','NO',-1 ) as Cottimo_Gara_Unificato ) CU  

		where isnull( protocol , '' ) <> '' and ISNULL(Document,'')<>''


-- Prende il rup per le gare Semplificato , bando ed RDO
union 

	SELECT  c.* 
			, 'DETAIL_CHIARIMENTI_BANDO' as ELENCOGrid_OPEN_DOC_NAME
			, c.id as ELENCOGrid_ID_DOC 
			,case isnull(chiarimentoevaso,0)
				WHEN 0 THEN ''
				else ' ChiarimentoEvaso '
				END AS Not_Editable
			, TipoDoc
			, Titolo
			, cast( Body as nvarchar(4000)) as Body
			, d.Protocollo as ProtocolloRiferimento
			, r.Value  as Owner
			, CIG
			, convert( varchar(10) , c.DataCreazione , 121 ) as DataA
			, convert( varchar(10) , c.DataCreazione , 121 ) as DataI
			, isnull(TipoProceduraCaratteristica,'') as TipoProceduraCaratteristica
			,isnull(JumpCheck,'') as JumpCheck
			,d.id as ListaAlbi
			,TipoSceltaContraente
			, CU.Cottimo_Gara_Unificato
		from 
			document_chiarimenti c with(nolock) 
			inner join CTL_DOC d with(nolock) on d.id = id_origin
			inner join Document_bando b with(nolock) on b.idheader = id_origin
			inner join CTL_DOC_VALUE  r with(nolock) on r.idheader = id_origin and DZT_Name = 'UserRUP' and DSE_ID = 'InfoTec_comune' and isnull( r.Value , '' ) <> ''

			--vedo tramite parametro se il Cottimo è unificato alle Procedure di gara
			cross join (select dbo.PARAMETRI('GROUP_Procedura','Cottimo_Gara_Unificato','ATTIVO','NO',-1 ) as Cottimo_Gara_Unificato ) CU  

		where isnull( protocol , '' ) <> '' and ISNULL(Document,'')<>''






GO
