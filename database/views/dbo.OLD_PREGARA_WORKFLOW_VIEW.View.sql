USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PREGARA_WORKFLOW_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD_PREGARA_WORKFLOW_VIEW] as
select 
		 [APS_ID_ROW], 
		 [APS_Doc_Type], 
		 [APS_ID_DOC], 
		 [APS_State], 
		 [APS_Note], 
		 [APS_Allegato], 
		 [APS_UserProfile], 
		 case
			when CS.APS_IdPfu <> ''  then CS.APS_IdPfu
			when CS.APS_UserProfile = 'RUP_PREGARA'  then v2.value -- DB.RupProponente
			when CS.APS_UserProfile in ( 'PI' , 'Richiedente' ) then D.IdPfu -- il PI è sempre chi ha iniziato
				else P.IdPfu 
			end	as  [APS_IdPfu], 
		 [APS_IsOld], 
		 case when isnull( CS.APS_IdPfu , '' ) <> '' then APS_Date else null end as APS_Date , 
		 [APS_APC_Cod_Node], 
		 [APS_NextApprover],

		 AC.APC_Doc_State as Statofunzionale
	 
	from CTL_ApprovalSteps CS with(nolock)
		inner join CTL_DOC D with(nolock) on D.id = CS.APS_ID_DOC
		inner join CTL_ApprovalCycle AC with(nolock) on AC.APC_Doc_Type = CS.APS_Doc_Type and AC.APC_Cod_Node = CS.APS_APC_Cod_Node
		left join Document_Bando DB with(nolock) on DB.idHeader=CS.APS_ID_DOC			
		left join GESTIONE_DOMINIO_DIREZIONE  DOM with(nolock) on DOM.DMV_Cod=DB.EnteProponente
		left outer join CTL_DOC_Value v2 with(nolock) on db.idheader = v2.idheader and v2.dzt_name = 'UserRUP' and v2.value <> '' and v2.DSE_ID = 'CRITERI_ECO' --'InfoTec_comune'
		
		--PER VEDERE SE ESISTE LA RELAZIONE PREGARA_ENTE_APPALTANTE
		left join ( select  top 1 'OK' as EsisteRelazioneTipoAppaltoGara from CTL_Relations with(nolock) WHERE REL_Type = 'PREGARA_ENTE_APPALTANTE' ) AS s on EsisteRelazioneTipoAppaltoGara = 'OK'

		--VECCHIA VERSIONE recupero gli utenti con i ruoli per associarli ai passi del workflow
		--left join
		--	( select 
		--			U.pfuIdAzi,U.IdPfu,P.attValue
		--				from  ProfiliUtente U 
		--					inner join ProfiliUtenteAttrib P with(nolock) on  P.dztNome='UserRole' and U.IdPfu=P.IdPfu 									
		--	) P on  
					
		--			(
		--				( CS.APS_UserProfile not in ( 'PI', 'Richiedente' )  and CS.APS_UserProfile=P.attValue and CS.APS_UserProfile <> 'RUP_PREGARA' 
		--																										and CS.APS_IdPfu = '' )-- i nodi non associati
		--				or 
		--				( CS.APS_UserProfile in ( 'PI' , 'Richiedente' ) and CS.APS_UserProfile=P.attValue and P.idpfu = D.IdPfu )
		--			)
		--			and CS.APS_IdPfu = '' 

		cross join ( select [dbo].[PARAMETRI]( 'PREGARA_WORKFLOW_VIEW' , 'SOLO_STESSO_ENTE' , 'ATTIVA' , '0'  , -1 )  as  SOLO_STESSO_ENTE ) as so
		
		 --NUOVA VERSIONE recupero gli utenti con i ruoli per associarli ai passi del workflow
        left join
            ( select 
                    U.pfuIdAzi,U.IdPfu,P.attValue
                        from  ProfiliUtente U 
                            inner join ProfiliUtenteAttrib P with(nolock) on  P.dztNome='UserRole' and U.IdPfu=P.IdPfu                                     
            ) P on  
                    -- i nodi non associati
                    CS.APS_IdPfu = '' 
                    and 
                    (
                            -- questi ruoli non vengono definiti dinamicamente dal ruolo ma dalla scelta sul documento
                            ( 
								CS.APS_UserProfile not in ('PI', 'Richiedente' , 'RUP_PREGARA')  
								or
								( CS.APS_UserProfile in ( 'PI' , 'Richiedente' ) and P.idpfu = D.IdPfu )
							)
                            
                            -- dove l'utente ha il ruolo
                            and CS.APS_UserProfile=P.attValue  

                            -- PER tutti gli altri ruoli
                            -- se esiste la relazione allora dobbiamo prendere solo gli utenti che sono o sull'azienda proponente o espletante
                            -- altrimenti tutti
                            and 
                            ( 
                                (ISNULL( EsisteRelazioneTipoAppaltoGara , '' ) = 'OK' and ( pfuIdAzi = Azienda or EnteProponente like cast( pfuIdAzi as varchar(10)) + '%'))
                                or
                                ISNULL( EsisteRelazioneTipoAppaltoGara , '' ) = ''

                            )

   							and
							( -- Gli utenti dell'ufficio appalti possono essere ristretti ai soli utenti dell'ente espletante
								( CS.APS_UserProfile = 'UFFICIO_APPALTI' and p.pfuIdAzi = Azienda )
								or
								( CS.APS_UserProfile = 'UFFICIO_APPALTI' and SOLO_STESSO_ENTE = '0' )
								or 
								(  CS.APS_UserProfile <> 'UFFICIO_APPALTI' )
							)
                     
                    )
						
	
	where 
		APS_Doc_Type='PREGARA' 
		and
		(
			APS_IsOld=0 
			or
			(
				APS_IsOld=1 and [APS_State] in ( 'Approved' , 'Denied' , 'Sent')
			)
		)



GO
