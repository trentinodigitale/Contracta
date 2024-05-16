USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_PREGARA_ESPLETARE]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_PREGARA_ESPLETARE] as

	--VISIBILITA' AI RUP
	select 
			C.id,
			C.Titolo, 
			C.IdPfu, 
			Cast(C.Body as nvarchar(max)) as Body, 
			C.Protocollo, 
			C.DataInvio,
			C.StatoFunzionale, 
			--D.RupProponente as OWNER,
			v2.value as OWNER,
			D.TipoProceduraCaratteristica,
			D.TipoAppaltoGara
			,ProtocolloBando
			,
			 case 
				when RIC_CIG.Id IS not null  and GarePreGara.id is null then 'si'
				else 'no'
			 end as SelezionePregara

		from CTL_DOC C with(nolock)
			inner join Document_Bando D with(nolock) on idHeader=id
			inner join CTL_DOC_Value v2 with(nolock) on d.idheader = v2.idheader and v2.dzt_name = 'UserRUP' and v2.DSE_ID = 'CRITERI_ECO' --'InfoTec_comune'
			
			--vedo se hanno una richiesta cig collegata
			left join CTL_DOC RIC_CIG with (nolock) on  RIC_CIG.LinkedDoc = C.Id and RIC_CIG.tipodoc in ('RICHIESTA_CIG','RICHIESTA_SMART_CIG') and RIC_CIG.StatoFunzionale ='inviato' and  RIC_CIG.Deleted =0
			
			----salgo sull dettaglio dove sta numero gara autorità  per le multilotto
			--left join Document_SIMOG_GARA DS with (nolock) on DS.idHeader =  RIC_CIG.Id 

			----salgo sul dettaglio dove sta cig per le monolotto 
			--left join  Document_SIMOG_LOTTI DSL with (nolock) on DSL.idHeader =  RIC_CIG.Id and DSL.NumeroLotto = 1

			--salgo sul dettaglio dello smart cig
			--left join Document_SIMOG_SMART_CIG DSC with (nolock) on DSC.idHeader =  RIC_CIG.Id 

			-----sottovista delle gare con una richiesta cig inviata
			--left join
			--	(
			--		--se smart cig il cig della gara corrisponde al cig presente sulla tabella Document_SIMOG_SMART_CIG
			--		--se richiesta cig 
			--		--se la gara non a lotti allora il cig della gara corrisponde al cig presente sulla tabella Document_SIMOG_LOTTI
			--		--se la gara è alotti allora il cig della gara corrisponde al numero gara presente sulla tabella Document_SIMOG_GARA
			--		select 
			--				RIC_CIG.TipoDoc,
			--				G.Id,
			--				case
			--					when DS.idHeader is not null then DS.id_gara
			--					when RIC_CIG.TipoDoc ='RICHIESTA_SMART_CIG' and DSC.idHeader is not null then DSC.smart_cig
			--				end as cig

			--				, divisione_lotti
			--			from
			--				CTL_DOC G with (nolock)
			--					inner join Document_Bando with (nolock) on idHeader = G.id
			--					inner join CTL_DOC RIC_CIG with (nolock) on  RIC_CIG.LinkedDoc = G.Id and RIC_CIG.tipodoc in ('RICHIESTA_CIG','RICHIESTA_SMART_CIG') and RIC_CIG.StatoFunzionale ='inviato' and  RIC_CIG.Deleted =0
			--					left join Document_SIMOG_GARA DS with (nolock) on DS.idHeader =  RIC_CIG.Id
			--					left join Document_SIMOG_SMART_CIG DSC with (nolock) on DSC.idHeader =  RIC_CIG.Id 
			--			where 
			--				G.TipoDoc in ('bando_gara','bando_semplificato') and G.Deleted = 0 

			--	) gare on   ( smart_cig= gare.CIG )    or  DS.id_gara = gare.CIG 
			
			-- sottovista delle gare con un pregara associato
			left join
				(
					select 
						G.Id, value as IdDocPreGara
						from 
							CTL_DOC G with (nolock) 
								inner join CTL_DOC_Value with (nolock) on IdHeader = G.Id and DSE_ID='InfoTec_comune' and DZT_Name = 'IdDocPreGara' and Value<>''
						where 
							G.TipoDoc in ('bando_gara','bando_semplificato') and G.Deleted = 0 
							
				) GarePreGara on C.Id = IdDocPreGara


		where C.TipoDoc='PREGARA' and C.Deleted=0 and C.StatoFunzionale in ( 'completo')--, 'concluso')

	UNION all 

	--VISIBILITA' AI PI dei RUP
	select 
			C.id,
			C.Titolo, 
			C.IdPfu, 
			Cast(C.Body as nvarchar(max)) as Body, 
			C.Protocollo, 
			C.DataInvio, 
			C.StatoFunzionale,
			P.idpfu as OWNER,
			D.TipoProceduraCaratteristica,
			D.TipoAppaltoGara
			,ProtocolloBando
			
			 ,
			 case 
				when RIC_CIG.Id IS not null  and GarePreGara.id is null then 'si'
				else 'no'
			 end as SelezionePregara

		from CTL_DOC C with(nolock)
			inner join Document_Bando D with(nolock) on idHeader=id
			inner join CTL_DOC_Value v2 with(nolock) on d.idheader = v2.idheader and v2.dzt_name = 'UserRUP' and v2.DSE_ID = 'CRITERI_ECO' --'InfoTec_comune'
			inner join Elenco_PI_collegati P on P.idpfu <> P.Responsabile and P.Responsabile=v2.value --D.RupProponente 

			--vedo se hanno una richiesta cig collegata
			left join CTL_DOC RIC_CIG with (nolock) on  RIC_CIG.LinkedDoc = C.Id and RIC_CIG.tipodoc in ('RICHIESTA_CIG','RICHIESTA_SMART_CIG') and RIC_CIG.StatoFunzionale ='inviato' and  RIC_CIG.Deleted =0
			--salgo sull dettaglio dove sta numero gara autorità  per le multilotto
			left join Document_SIMOG_GARA DS with (nolock) on DS.idHeader =  RIC_CIG.Id 
			--salgo sul dettaglio dove sta cig per le monolotto 
			--left join  Document_SIMOG_LOTTI DSL with (nolock) on DSL.idHeader =  RIC_CIG.Id and DSL.NumeroLotto = 1

			--salgo sul dettaglio dello smart cig
			left join Document_SIMOG_SMART_CIG DSC with (nolock) on DSC.idHeader =  RIC_CIG.Id

			-------sottovista delle gare con una richiesta cig inviata
			--left join
			--	(
			--		select 
			--				G.Id,
			--				case
			--					when DS.idHeader is not null then DS.id_gara
			--					when DSC.idHeader is not null then DSC.smart_cig
			--				end as cig
			--				, divisione_lotti
			--			from
			--				CTL_DOC G with (nolock)
			--					inner join Document_Bando with (nolock) on idHeader = G.id
			--					inner join CTL_DOC RIC_CIG with (nolock) on  RIC_CIG.LinkedDoc = G.Id and RIC_CIG.tipodoc in ('RICHIESTA_CIG','RICHIESTA_SMART_CIG') and RIC_CIG.StatoFunzionale ='inviato' and  RIC_CIG.Deleted =0
			--					left join Document_SIMOG_GARA DS with (nolock) on DS.idHeader =  RIC_CIG.Id
			--					left join Document_SIMOG_SMART_CIG DSC with (nolock) on DSC.idHeader =  RIC_CIG.Id 
			--			where 
			--				G.TipoDoc in ('bando_gara','bando_semplificato') and G.Deleted = 0 

			--	) gare on   smart_cig= gare.CIG   or  DS.id_gara = gare.CIG 
						-- sottovista delle gare con un pregara associato
			left join
				(
					select 
						G.Id, value as IdDocPreGara
						from 
							CTL_DOC G with (nolock) 
								inner join CTL_DOC_Value with (nolock) on IdHeader = G.Id and DSE_ID='InfoTec_comune' and DZT_Name = 'IdDocPreGara' and Value<>''
						where 
							G.TipoDoc in ('bando_gara','bando_semplificato') and G.Deleted = 0 
							
				) GarePreGara on C.Id = IdDocPreGara



		where C .TipoDoc='PREGARA' and C.Deleted=0 and C.StatoFunzionale in ( 'completo')--, 'concluso')


GO
