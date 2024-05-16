USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PUBBLICITA_LEGALE_WORKFLOW_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[OLD_PUBBLICITA_LEGALE_WORKFLOW_VIEW] as
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
			end	as [APS_IdPfu], 
		 [APS_IsOld], 
		 --case when isnull( CS.APS_IdPfu , '' ) <> '' then APS_Date else null end as 
		 APS_Date , 
		 [APS_APC_Cod_Node], 
		 [APS_NextApprover],

		 AC.APC_Doc_State as Statofunzionale


	from CTL_ApprovalSteps CS with(nolock)
		inner join CTL_DOC D with(nolock) on D.id = CS.APS_ID_DOC
		inner join Document_RicPrevPubblic R with(nolock) on R.idHeader = D.id
		inner join CTL_ApprovalCycle AC with(nolock) on cs.APS_Doc_Type  +'_'+ D.JumpCheck= ac.APC_Doc_Type and AC.APC_Cod_Node = CS.APS_APC_Cod_Node
		
		left join  CTL_DOC_SIGN cds with(nolock) on cds.idHeader=d.id
		--left join Document_Bando DB with(nolock) on DB.idHeader=CS.APS_ID_DOC			
		--left join GESTIONE_DOMINIO_DIREZIONE  DOM with(nolock) on DOM.DMV_Cod=DB.EnteProponente
		left outer join CTL_DOC_Value v2 with(nolock) on D.id = v2.idheader and v2.dzt_name = 'UserRUP' and v2.value <> '' and v2.DSE_ID = 'CRITERI_ECO' --'InfoTec_comune'			

		-- recupero gli utenti con i ruoli per associarli ai passi del workflow
		left join
			( select 
					U.pfuIdAzi,U.IdPfu,P.attValue
						from  ProfiliUtente U 
							inner join ProfiliUtenteAttrib P with(nolock) on  P.dztNome='UserRole' and U.IdPfu=P.IdPfu 									
			) P on  
					(
						(	
							-- se la tipologia è 'ALTRO' non vanno presi  i ruoli per la SUA
							( 
								isnull(R.Tipologia,'') <> '4' 
								or 
								(   isnull(R.Tipologia,'') = '4' and CS.APS_UserProfile <> 'UFFICIO_APPALTI' )
							)

							and CS.APS_UserProfile not in( 'PI', 'Richiedente' )  
							and CS.APS_UserProfile=P.attValue 
							and CS.APS_UserProfile <> 'RUP_PREGARA' 
							and CS.APS_IdPfu = '' 

						)-- i nodi non associati
						or 
						( CS.APS_UserProfile in ( 'PI' , 'Richiedente' ) and CS.APS_UserProfile=P.attValue and P.idpfu = D.IdPfu )
					)
					and CS.APS_IdPfu = '' 
						
	
	where 
		APS_Doc_Type='PUBBLICITA_LEGALE'
		and
		(
			APS_IsOld=0 
			or
			(
				APS_IsOld=1 and [APS_State] in ( 'Approved' , 'Denied' , 'Sent')
			)
		)



GO
