USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AFV_Elenco_Lotti]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[AFV_Elenco_Lotti] as

	SELECT  
			d.id as idBando 
			,d.Protocollo as RegistroBando 
			,d.Body as DescrizioneBando

			, d.StatoFunzionale as StatoBando
			, coalesce( [ML_Description] , dd1.DMV_DescML , d.statofunzionale ) as StatoBandoDescrizione

			, case when db.divisione_lotti = '0' then db.CIG else lt1.CIG end as CIG
		
			, isnull( lt1.Descrizione , '' ) as DescrizioneCIG
			, case when db.divisione_lotti = '0' then '1' else lt1.numeroLotto end as Lotto
			--, dbo.GetDescTipoProcedura ( d.Tipodoc , TipoProceduraCaratteristica , ProceduraGara )  as TipoProcedura
			, TipoAppaltoGara as TipoAppalto

			--, case
			--	when lt2.statoriga IS NULL 
			--		then 
			--			case when d.StatoFunzionale = 'Chiuso' and RecivedIstanze = 0 
			--				then 'Deserta'
			--				else d.StatoFunzionale 
			--			end
			--		else lt2.StatoRiga
			--	end	  as [StatoLotto]  

			, isnull( lt2.StatoRiga , '' ) as [StatoLotto]  

			--, case
			--	when isnull( desc3.DMV_DescML , '' ) = '' 
			--		then 
			--			case when d.StatoFunzionale = 'Chiuso' and RecivedIstanze = 0 
			--				then 'Deserta'
			--				else desc1.DMV_DescML
			--			end
			--		else desc3.DMV_DescML 
			--	end	  
			
			, isnull( desc3.DMV_DescML , '' ) as [StatoLottoDescrizione]  


			, v2.Value as idRUP
			, idazi as idEnte
			, aziLog as EnteCodice			
		FROM CTL_Doc d WITH (NOLOCK)
	  
			-- BANDO
			inner join Document_Bando db WITH (NOLOCK) on d.id = db.idheader

			--LOTTI
			inner join  document_microlotti_dettagli lt1 WITH (NOLOCK) on  lt1.IdHeader = d.Id and lt1.Voce = 0 and lt1.TipoDoc = d.tipodoc	

			-- PDA
			LEFT join CTL_Doc pda WITH (NOLOCK) on  pda.LinkedDoc = d.Id and pda.TipoDoc = 'PDA_MICROLOTTI' and pda.Deleted = 0

			-- LOTTI della PDA
			left join  document_microlotti_dettagli lt2 WITH (NOLOCK) on  lt2.IdHeader = pda.Id and lt1.NumeroLotto = lt2.NumeroLotto 
																				and lt2.Voce = 0 and lt2.TipoDoc = 'PDA_MICROLOTTI'

			-- Domini
			left join LIB_DomainValues dd1 with (nolock) on dd1.DMV_DM_ID = 'statoFunzionale' 
															and dd1.DMV_Cod = d.statofunzionale
			left join lib_multilinguismo m with(nolock) on m.[ML_KEY] = dd1.[DMV_DescML] and m.[ML_LNG] = 'I' and m.[ML_Context] = 0


			left outer join LIB_DomainValues desc3 WITH (NOLOCK) on desc3.DMV_DM_ID = 'statoriga' and desc3.DMV_Cod = isnull( lt2.StatoRiga , lt1.StatoRiga ) 

			-- RUP
			left outer join CTL_DOC_Value v2 with(nolock) on db.idheader = v2.idheader and v2.dzt_name = 'UserRUP' and v2.DSE_ID = 'InfoTec_comune'		

			inner join aziende a with(nolock) on a.idazi = d.azienda

		 WHERE d.tipodoc in ( 'BANDO_GARA' ,'BANDO_SEMPLIFICATO')   
					AND d.deleted = 0
					--AND d.statodoc = 'sended'
					and d.StatoFunzionale <> 'InLavorazione'

				





GO
