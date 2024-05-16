USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PREGARA_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE VIEW [dbo].[OLD_PREGARA_TESTATA_VIEW] AS


	select 
			C.*,
			DB.EnteProponente,
			DB.RupProponente,
			CV.Value 
				+
				case
					when c.idpfuincharge <> c.idpfu or c.StatoFunzionale not in ('InLavorazione','VerificaAttiNonApp') then ' RichiestaCigPreGara '
					else + '' 
				end 
				+
				case 
					when v3.Value <> 'no' or c.StatoFunzionale not in ('AttiDefinitivi') then ' CIG '
					else + ''
				end

				+ 
				case when SIMOG_RCig.EntiAbilitati <> '' AND CHARINDEX (',' + dbo.GetPos ( EnteProponente ,'#',1) + ',', ',' + SIMOG_RCig.EntiAbilitati + ',') = 0 then ' RichiestaCigPreGara '
					else ''
				 end

			as Not_Editable

			, v2.Value as UserRUP
			, isnull( r.rel_valueoutput , ',VerificaAtti,' ) as AT_Rifiuta
			, dbo.GetElenco_PI (v2.Value  ,'RUP,RUP_PDG' ) as IdPfuCreaGara
			, DB.FuoriPiattaforma
			, DB.ProtocolloBando
			, DB.RupProponente as RupProponente_OLD
			, v3.Value as RichiestaCigPreGara
			, DB.CIG 
			, P.Tipo_Rup
			 , case when rCig.id is null then '0' else '1' end as cigInviato
			 , v4.value as UserDirigente
			 --, SIMOG_RCig.EntiAbilitati
		from CTL_DOC C with(nolock)
			left join CTL_DOC_Value CV with(nolock) on CV.IdHeader=C.Id and CV.DSE_ID='NOT_EDITABLE' and CV.DZT_Name='Not_Editable'
			left join Document_Bando DB with(nolock)  on DB.idHeader=C.id
			left outer join CTL_DOC_Value v2 with(nolock) on db.idheader = v2.idheader and v2.dzt_name = 'UserRUP' and v2.DSE_ID = 'CRITERI_ECO' --'InfoTec_comune'
			left outer join CTL_DOC_Value v3 with(nolock) on db.idheader = v3.idheader and v3.dzt_name = 'RichiestaCigPreGara' and v3.DSE_ID = 'CRITERI_ECO' --'InfoTec_comune'
			left join  CTL_Relations r with(nolock) on r.REL_Type='DOCUMENT_PREGARA_ATTIVA_TOOLBAR_For_Stato'  and r.REL_ValueInput = 'RIFIUTA' 
			inner join ( select dbo.PARAMETRI ('SIMOG','TIPO_RUP','DefaultValue','UserRUP',-1) as Tipo_Rup) P on 1=1
			left join ctl_doc rCig with(nolock) on rCig.LinkedDoc = c.Id and rCig.TipoDoc in ( 'RICHIESTA_CIG', 'RICHIESTA_SMART_CIG' ) and rCig.Deleted = 0 and rCig.StatoFunzionale in ( 'Inviato' , 'Invio_con_errori' )
			left outer join CTL_DOC_Value v4 with(nolock) on db.idheader = v4.idheader and v4.dzt_name = 'UserDirigente' and v4.DSE_ID = 'CRITERI_ECO' --'InfoTec_comune'
			
			cross join ( select  dbo.PARAMETRI('GROUP_SIMOG','ENTI_ABILITATI','DefaultValue','',-1) as EntiAbilitati ) as SIMOG_RCig 

		where c.TipoDoc='PREGARA'
GO
