USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_View_Modelli_Lotti]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD_View_Modelli_Lotti] as

	select 
		D.codice , 
		ISNULL(D.Complex,0) as Complex,
		--C1.value as Conformita, 
		--C2.value as CriterioAggiudicazioneGara,
		--C4.Value as TipoProcedureApplicate,
		VCM.Conformita,
		VCM.CriterioAggiudicazioneGara,
		VCM.TipoProcedureApplicate,
		CriterioFormulazioneOfferte,
		--isnull(  C3.Value , '5' ) as Ambito, 
		isnull(  VCM.MacroAreaMerc , '5' ) as Ambito, 
		case when right( D.codice , 10 ) = '_MONOLOTTO' then 1 else 0 end as Monolotto
		from 
			ctl_doc C  with (nolock) 

			--inner join ctl_doc_value C1 with (nolock) on C1.idheader=C.id AND C1.DSE_ID='CRITERI' and C1.dzt_name='conformita' 
			--inner join ctl_doc_value C2 with (nolock)  on C2.idheader=C.id AND C2.DSE_ID='CRITERI' and C2.dzt_name='CriterioAggiudicazioneGara' 
			--left join ctl_doc_value C4 with (nolock) on C4.idheader=C.id AND C4.DSE_ID='CRITERI' and C4.dzt_name='TipoProcedureApplicate' 
			--left outer join ctl_doc_value C3  with (nolock) on C3.idheader=C.id AND C3.DSE_ID='AMBITO' and C3.dzt_name='MacroAreaMerc' 

			left outer join View_Criteri_Modelli  VCM on VCM.idheader = C.id

			inner join Document_Modelli_MicroLotti D  with (nolock)  on  ( C.titolo=D.codice   or C.titolo+'_COMPLEX'=D.codice or C.titolo+'_MONOLOTTO'=D.codice ) and ISNULL(Base,0)=1
			inner join Document_Modelli_MicroLotti_Formula M  with (nolock)  on  ( D.codice=M.codice ) /*or C.titolo+'_COMPLEX'=M.codice  or C.titolo+'_MONOLOTTO'=M.codice )*/ and M.deleted=0
		where 
			C.tipodoc='CONFIG_MODELLI_LOTTI'
			and C.deleted=0 and isnull( c.linkeddoc  , 0 ) = 0 



GO
