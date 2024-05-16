USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_Document_Nuova_Procedura]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_Document_Nuova_Procedura] as
select 

D.*,

 case isnull(TipoSceltaContraente,'')
	when 'ACCORDOQUADRO_RUPAR'  then 'no' 
	when 'AQ_STRU_INFORMATICA'  then 'no' 
	else ''
 end AS DividiInLotti

, case isnull(TipoSceltaContraente,'')
	when 'ACCORDOQUADRO' then 	' ModalitadiPartecipazione  ProceduraGara  TipoBandoGara '
	when 'ACCORDOQUADRO_RUPAR' then ' ModalitadiPartecipazione  ProceduraGara  TipoBandoGara  Divisione_lotti  Conformita  CriterioFormulazioneOfferte  TipoAppaltoGara  Opzioni  DividiInLotti  '
	when 'AQ_STRU_INFORMATICA' then ' ModalitadiPartecipazione  ProceduraGara  TipoBandoGara  Divisione_lotti  Conformita  CriterioFormulazioneOfferte  TipoAppaltoGara  Opzioni  CriterioAggiudicazioneGara  DividiInLotti  '
	
	else ''
end as NotEditable
,
 case
	when W.items IS not null then '1'
	else '0'
 end AS AFFIDAMENTO_DIRETTO_DUE_FASI
,
case
	when N.items IS not null then '1'
	else '0'
 end AS MODULO_ACCORDO_QUADRO
,
case
	when R.items IS not null then '1'
	else '0'
 end AS GROUP_Procedura_RDO

 , CU.Cottimo_Gara_Unificato_Attivo

from Document_Bando D with (nolock)
		left join ( 
					select items from dbo.Split(
					(	select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI'),',') 
				) W on W.items ='AFFIDAMENTO_DIRETTO_DUE_FASI'
				left join ( 
					select items from dbo.Split(
					(	select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI'),',') 
				) N on N.items ='GROUP_Procedura_AccordoQuadro'
		left join ( 
			select items from dbo.Split(
			(	select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI'),',') 
		) R on R.items ='GROUP_Procedura_RDO'
		
		--vedo tramite parametro se il Cottimo è unificato alle Procedure di gara
		cross join (select dbo.PARAMETRI('GROUP_Procedura','Cottimo_Gara_Unificato','ATTIVO','NO',-1 ) as Cottimo_Gara_Unificato_Attivo ) CU  
		
GO
