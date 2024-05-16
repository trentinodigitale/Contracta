USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_OFFERTA_LISTA_BUSTE_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[OLD_OFFERTA_LISTA_BUSTE_VIEW] AS

	select lo.*,
		case when  isnull( v1.Value , CriterioAggiudicazioneGara ) = '15532' or isnull( v1.Value , CriterioAggiudicazioneGara ) = '25532'  or isnull( v2.Value , Conformita ) <> 'No'  
			 then 
				case	
					when ( lo.EsitoRiga = '<img src="../images/Domain/State_OK.gif">'  or SUBSTRING(lo.EsitoRiga,0,51)  = '<br><img src="../images/Domain/State_Warning.gif">' )  and C.RichiestaFirma = 'si'  and ISNULL(DF.F2_SIGN_HASH,'') = ''
						then 'da_generare'
					when ( lo.EsitoRiga = '<img src="../images/Domain/State_OK.gif">'  or SUBSTRING(lo.EsitoRiga,0,51)  = '<br><img src="../images/Domain/State_Warning.gif">' )  and C.RichiestaFirma = 'si'  and ISNULL(DF.F2_SIGN_ATTACH,'') = '' and ISNULL(DF.F2_SIGN_HASH,'') <> ''
						then 'da_firmare'
					when ( ( lo.EsitoRiga <> '<img src="../images/Domain/State_OK.gif">'  and  SUBSTRING(lo.EsitoRiga,0,51)  <> '<br><img src="../images/Domain/State_Warning.gif">' ) or signBT.statoFirma = 'SIGN_NOT_MATCH' ) and C.RichiestaFirma = 'si' 
						then 'errori'
					when C.RichiestaFirma = 'si' and ISNULL(DF.F2_SIGN_ATTACH,'') <> '' and signBT.id is null and cobust.value='no' and signBTP.id is not null
						then 'pdf_allegato'
					when C.RichiestaFirma = 'si' and ISNULL(DF.F2_SIGN_ATTACH,'') <> '' and signBT.id is null
						then 'firmato'
					when ( lo.EsitoRiga = '<img src="../images/Domain/State_OK.gif">'  or SUBSTRING(lo.EsitoRiga,0,51)  = '<br><img src="../images/Domain/State_Warning.gif">' )  and C.RichiestaFirma = 'no' 
						then 'pronto'
					when ( lo.EsitoRiga = '<img src="../images/Domain/State_OK.gif">'  or SUBSTRING(lo.EsitoRiga,0,51)  = '<br><img src="../images/Domain/State_Warning.gif">' )  and C.RichiestaFirma = 'si' and ISNULL(DF.F2_SIGN_ATTACH,'') <> '' and signBT.statoFirma = 'SIGN_PENDING'
						then 'pending'
					else
						'errori'
				end 
			else
			''
		end				
				as Esito_Busta_Tec, 
			
		case
   
			when ( lo.EsitoRiga = '<img src="../images/Domain/State_OK.gif">'  or SUBSTRING(lo.EsitoRiga,0,51)  = '<br><img src="../images/Domain/State_Warning.gif">' )  and C.RichiestaFirma = 'si' and ISNULL(DF.F1_SIGN_HASH,'') = ''
				then 'da_generare'
			when ( lo.EsitoRiga = '<img src="../images/Domain/State_OK.gif">'  or SUBSTRING(lo.EsitoRiga,0,51)  = '<br><img src="../images/Domain/State_Warning.gif">' )  and C.RichiestaFirma = 'si' and ISNULL(DF.F1_SIGN_ATTACH,'') = ''  and ISNULL(DF.F1_SIGN_HASH,'') <> ''
				then 'da_firmare'
			when ( ( lo.EsitoRiga <> '<img src="../images/Domain/State_OK.gif">'  and  SUBSTRING(lo.EsitoRiga,0,51)  <> '<br><img src="../images/Domain/State_Warning.gif">' ) or signBE.statoFirma = 'SIGN_NOT_MATCH' ) and C.RichiestaFirma = 'si' 
				then 'errori'
			when C.RichiestaFirma = 'si' and ISNULL(DF.F1_SIGN_ATTACH,'') <> '' and signBE.id is null  and cobust.value='no' and signBEP.id is not null
				then 'pdf_allegato'
			when ( lo.EsitoRiga = '<img src="../images/Domain/State_OK.gif">'  or SUBSTRING(lo.EsitoRiga,0,51)  = '<br><img src="../images/Domain/State_Warning.gif">' )  and C.RichiestaFirma = 'si' and ISNULL(DF.F1_SIGN_ATTACH,'') <> '' and signBE.id is null
				then 'firmato'
			when ( lo.EsitoRiga = '<img src="../images/Domain/State_OK.gif">'  or SUBSTRING(lo.EsitoRiga,0,51)  = '<br><img src="../images/Domain/State_Warning.gif">' )  and C.RichiestaFirma = 'no' 
				then 'pronto'
			when ( lo.EsitoRiga = '<img src="../images/Domain/State_OK.gif">'  or SUBSTRING(lo.EsitoRiga,0,51)  = '<br><img src="../images/Domain/State_Warning.gif">' )  and C.RichiestaFirma = 'si' and ISNULL(DF.F1_SIGN_ATTACH,'') <> '' and signBE.statoFirma = 'SIGN_PENDING'
				then 'pending'
			else
				'errori'
		end as Esito_Busta_Eco ,

		C.RichiestaFirma

	from CTL_DOC C with (nolock) -- offerta 

			inner join ctl_doc b with (nolock) on b.id = C.linkeddoc -- BANDO
			inner join document_bando ba with (nolock) on  ba.idheader = b.id
			inner join document_microlotti_dettagli lb with (nolock) on b.id = lb.idheader and lb.tipodoc = b.Tipodoc 
			inner join document_microlotti_dettagli lo with (nolock) on C.id = lo.idheader and lo.tipodoc = 'OFFERTA' and lb.Voce = lo.Voce and lb.NumeroLotto = lo.NumeroLotto 
			inner join Document_Microlotto_Firme DF with (nolock) ON lo.id = DF.idheader 

			left join CTL_SIGN_ATTACH_INFO signBE with(nolock) on signBE.ATT_Hash = dbo.GetColumnValue( DF.F1_SIGN_ATTACH ,'*','4') and signBE.statoFirma IN ( 'SIGN_PENDING', 'SIGN_NOT_MATCH' ) -- gli stati di pending e not match non possono avere record multipli nella tabella CTL_SIGN_ATTACH_INFO
			left join CTL_SIGN_ATTACH_INFO signBT with(nolock) on signBT.ATT_Hash = dbo.GetColumnValue( DF.F2_SIGN_ATTACH ,'*','4') and signBT.statoFirma IN ( 'SIGN_PENDING', 'SIGN_NOT_MATCH' )
			
			left outer join Document_Microlotti_DOC_Value v1 with (nolock) on v1.idheader = lb.id and v1.DZT_Name = 'CriterioAggiudicazioneGara'  and v1.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
			left outer join Document_Microlotti_DOC_Value v2 with (nolock) on v2.idheader = lb.id and v2.DZT_Name = 'Conformita'  and v2.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
			left join ctl_doc_value cobust with(nolock) on cobust.idheader = ba.idheader and cobust.DSE_ID = 'PARAMETRI' and cobust.DZT_Name = 'ControlloFirmaBuste'
			left join CTL_SIGN_ATTACH_INFO signBEP with(nolock) on signBEP.ATT_Hash = dbo.GetColumnValue( DF.F1_SIGN_ATTACH ,'*','4') and signBEP.statoFirma IN (  'SIGN_NOT_OK' )
			left join CTL_SIGN_ATTACH_INFO signBTP with(nolock) on signBTP.ATT_Hash = dbo.GetColumnValue( DF.F2_SIGN_ATTACH ,'*','4') and signBTP.statoFirma IN ( 'SIGN_NOT_OK' )

		where C.TipoDoc = 'OFFERTA' 
					--( isnull( v1.Value , CriterioAggiudicazioneGara ) = '15532'  or isnull( v2.Value , Conformita ) <> 'No' ) --= "Ex-Ante"  










GO
