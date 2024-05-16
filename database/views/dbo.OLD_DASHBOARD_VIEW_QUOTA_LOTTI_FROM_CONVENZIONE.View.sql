USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_QUOTA_LOTTI_FROM_CONVENZIONE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--use AFLink_NA_New
CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_QUOTA_LOTTI_FROM_CONVENZIONE] AS
select 
		--SE CI SONO QUOTE CHE NON SONO PER LOTTI ALLORA RITORNA ID NEGATIVO
		--IN QUESTO MODO NON HO LA GRIGLIA PER I LOTTI NON SAPENDOLA GESTIRE CONTINUO A 
		--FAR LAVORARE PER COMPLESSIVO NON PER LOTTO				
		case when S.linkeddoc is null and QUOTA='PRESENTE' then -DC.id else DC.ID end as ID_FROM,
		DCL.NumeroLotto, 
		DCL.Descrizione,
		DCL.Importo as Importo_Q_Lotto, 
		--(DCL.Importo - ISNULL(S.totQLOTTO,0)) as Residuo
		DCL.Residuo
	 from Document_Convenzione DC with(nolock)
		inner join Document_Convenzione_Lotti DCL with(NOLOCK) on DC.id=DCL.idheader
		 left join  (
						select  ctl_doc.linkeddoc,case when linkeddoc > 0 then 'PRESENTE' else 'NO' end as QUOTA
						from Document_Convenzione_Quote with(nolock) ,ctl_doc with(nolock)
						where tipodoc='QUOTA' and idheader=id and statodoc='Sended'
						group by linkeddoc
					  ) Q on DC.id=Q.linkeddoc		
		left join  (
						select  C.linkeddoc, isnull(sum(Importo),0) as totQLOTTO -- ,NumeroLotto
							from  ctl_doc C with(nolock) 
								left join Document_Convenzione_Quota_Lotti DQL with(nolock) on DQL.idHeader=C.id
								where  TipoDoc='QUOTA' and statodoc='Sended'
						group by linkeddoc -- ,NumeroLotto
					 ) S on DC.id=S.linkeddoc --and DCL.NumeroLotto=S.NumeroLotto
	
	where DC.Deleted = 0
GO
