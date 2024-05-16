USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_View_FascicoloGara_Documenti_GeneraPDF]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[OLD2_View_FascicoloGara_Documenti_GeneraPDF] as
	select 

		F.idrow as ID_DOC,
		F.idrow as ID ,
		F.IdDoc as ID_DOC_PDF,
		F.IDHEADER,
		F.TIPODOC,
		
		--case
		--	when F.TipoDoc ='VERIFICA_ANOMALIA' then F.TipoDoc + ' Lotto ' + isnull(PDA_DETT.NumeroLotto,'')
		--	else F.TITOLO
		--end as TITOLO

		F.TipoDoc + case
						when PDA_DETT.NumeroLotto is not null then ' Lotto ' + PDA_DETT.NumeroLotto
						else ''
					end as TITOLO

		,
		--case
		--	when F.TipoDoc ='VERIFICA_ANOMALIA' then 'Lotto ' + isnull(PDA_DETT.NumeroLotto,'')
		--	else ''
		--end as AREADIAPPARTENENZA
		 case
			when PDA_DETT.NumeroLotto is not null then 'Lotto ' + PDA_DETT.NumeroLotto
			else ''
		end as AREADIAPPARTENENZA

	from 
	
		Document_Fascicolo_Gara_Documenti F with(nolock)
			left join ctl_doc D with(nolock) on d.id=F.IdDoc and d.tipodoc=F.tipodoc
			left join document_microlotti_dettagli PDA_DETT with(nolock)  on PDA_DETT.id=D.LinkedDoc 
	--where 
	--	generapdf=1

		--F.TipoDOc in (select 
		--						REL_ValueOutput  
		--					from 
		--						ctl_relations with (nolock) 
		--					where 
		--						rel_type='FASCICOLO_GARA' and REL_ValueInput ='DOCUMENTI_GENERA_PDF')
GO
