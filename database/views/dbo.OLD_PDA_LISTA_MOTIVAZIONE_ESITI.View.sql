USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PDA_LISTA_MOTIVAZIONE_ESITI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD_PDA_LISTA_MOTIVAZIONE_ESITI] as

/*---------------------------------------------------------------------------------
--ENRICO commentata la query unica e fatta la union per ottimizzare le prestazioni
--perchè analizzando con profiler di SQL faceva un table scan su document_pda_offerte
--legata al fatto che la colonna linkeddoc ritornata era ottenuta dal case
---------------------------------------------------------------------------------*/

--select 
--		d.id,
--		case 
--			when d.tipodoc in ('ESITO_ESCLUSA' , 'ESITO_VERIFICA' , 'ESITO_ANNULLA' , 'ESITO_AMMESSA' , 'ESITO_AMMESSA_CON_RISERVA') then linkeddoc
--			when d.tipodoc in ('ESCLUDI_LOTTI','ANNULLA_ESCLUDI_LOTTI','RICEZIONE_CAMPIONI','ANNULLA_RICEZIONE_CAMPIONI') then idrow
				
--		end as linkeddoc,

--		d.tipodoc,
--		d.idpfu,
--		protocollo,
--		datainvio,
--		body,
--		statofunzionale,
--		d.tipodoc + '.800.600' as OPEN_DOC_NAME
		
--		from CTL_Doc d
--				inner join document_pda_offerte on 
--						( ( idrow=d.linkeddoc and d.tipodoc in ( 'ESITO_ESCLUSA' , 'ESITO_VERIFICA' , 'ESITO_ANNULLA' , 'ESITO_AMMESSA' , 'ESITO_AMMESSA_CON_RISERVA' ) ) 
--							or
--						  ( idmsg=d.linkeddoc and iddoc=idheader and d.tipodoc in ( 'ESCLUDI_LOTTI','ANNULLA_ESCLUDI_LOTTI','RICEZIONE_CAMPIONI','ANNULLA_RICEZIONE_CAMPIONI') ) 
--						)
--			inner join profiliutente p on d.IdPfu = p.IdPfu 
--		where 
--			--tipodoc in ( 'ESITO_ESCLUSA' , 'ESITO_VERIFICA' , 'ESITO_ANNULLA' , 'ESITO_AMMESSA' ,'ESCLUDI_LOTTI') 
--			StatoDoc = 'Sended'


select 
		d.id,
		--case 
		--	when d.tipodoc in ('ESITO_ESCLUSA' , 'ESITO_VERIFICA' , 'ESITO_ANNULLA' , 'ESITO_AMMESSA' , 'ESITO_AMMESSA_CON_RISERVA') then linkeddoc
		--	when d.tipodoc in ('ESCLUDI_LOTTI','ANNULLA_ESCLUDI_LOTTI','RICEZIONE_CAMPIONI','ANNULLA_RICEZIONE_CAMPIONI') then idrow
				
		--end as linkeddoc,

		d.linkeddoc,

		d.tipodoc,
		d.idpfu,
		protocollo,
		datainvio,
		body,
		statofunzionale,
		d.tipodoc + '.800.600' as OPEN_DOC_NAME
		
		from CTL_Doc d with (nolock)
				inner join document_pda_offerte with (nolock) on 
						( ( idrow=d.linkeddoc and d.tipodoc in ( 'ESITO_ESCLUSA' , 'ESITO_VERIFICA' , 'ESITO_ANNULLA' , 'ESITO_AMMESSA' , 'ESITO_AMMESSA_CON_RISERVA','ESITO_RIAMMISSIONE' ) ) 
							--or
						  --( idmsg=d.linkeddoc and iddoc=idheader and d.tipodoc in ( 'ESCLUDI_LOTTI','ANNULLA_ESCLUDI_LOTTI','RICEZIONE_CAMPIONI','ANNULLA_RICEZIONE_CAMPIONI') ) 
						)
			inner join profiliutente p with (nolock) on d.IdPfu = p.IdPfu 
		where 
			--tipodoc in ( 'ESITO_ESCLUSA' , 'ESITO_VERIFICA' , 'ESITO_ANNULLA' , 'ESITO_AMMESSA' ,'ESCLUDI_LOTTI') 
			StatoDoc = 'Sended'
			
union all

select 
		d.id,
		--case 
		--	when d.tipodoc in ('ESITO_ESCLUSA' , 'ESITO_VERIFICA' , 'ESITO_ANNULLA' , 'ESITO_AMMESSA' , 'ESITO_AMMESSA_CON_RISERVA') then linkeddoc
		--	when d.tipodoc in ('ESCLUDI_LOTTI','ANNULLA_ESCLUDI_LOTTI','RICEZIONE_CAMPIONI','ANNULLA_RICEZIONE_CAMPIONI') then idrow
				
		--end as linkeddoc,
		idrow as linkeddoc,

		d.tipodoc,
		d.idpfu,
		protocollo,
		datainvio,
		body,
		statofunzionale,
		d.tipodoc + '.800.600' as OPEN_DOC_NAME
		
		from CTL_Doc d with (nolock)
				inner join document_pda_offerte with (nolock) on 
						( --( idrow=d.linkeddoc and d.tipodoc in ( 'ESITO_ESCLUSA' , 'ESITO_VERIFICA' , 'ESITO_ANNULLA' , 'ESITO_AMMESSA' , 'ESITO_AMMESSA_CON_RISERVA' ) ) 
							--or
						  ( idmsg=d.linkeddoc and iddoc=idheader and d.tipodoc in ( 'ESCLUDI_LOTTI','ANNULLA_ESCLUDI_LOTTI','RICEZIONE_CAMPIONI','ANNULLA_RICEZIONE_CAMPIONI') ) 

						)
			inner join profiliutente p with (nolock) on d.IdPfu = p.IdPfu 
		where 
			--tipodoc in ( 'ESITO_ESCLUSA' , 'ESITO_VERIFICA' , 'ESITO_ANNULLA' , 'ESITO_AMMESSA' ,'ESCLUDI_LOTTI') 
			(
				(d.TipoDoc <> 'ESCLUDI_LOTTI' and StatoDoc = 'Sended')
				or 
				(d.TipoDoc = 'ESCLUDI_LOTTI' and (StatoDoc = 'Sended' or StatoDoc='Saved') )
			)


GO
