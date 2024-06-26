USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_ELENCO_FUNZIONI_PERMESSI_ASP]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD_DASHBOARD_VIEW_ELENCO_FUNZIONI_PERMESSI_ASP] as 	

	select distinct a.*, CASE WHEN ( isnull(dict.DZT_ValueDef,'') = '' OR substring( dict.DZT_ValueDef, a.LFN_PosPermission, 1) = '1' ) THEN 1
								ELSE 0
							END as Attivo

	from 
	(	
		select * from 
		(
	
			-- estrae tutti i gruppi funzioni
			select G.LFN_GroupFunction , 'gruppi' as Title , F.LFN_PosPermission , G.LFN_GroupFunction + '-' + dbo.ZeriInTesta( G.LFN_Order , 5 )  + '-' + dbo.ZeriInTesta( F.LFN_Order ,5 ) as Path, G.LFN_Target
				from LIB_Functions G  with(nolock)
					inner join LIB_Functions F  with(nolock)  ON G.LFN_Target = f.LFN_GroupFunction

				--where G.LFN_GroupFunction in (  'dashboardmain', 'main_group' )
			
			

			union all
	
			-- per ogni funzione prendo la relativa toolbar
			select G.LFN_GroupFunction , 'toolbar' , T.LFN_PosPermission , G.LFN_GroupFunction + '-' + dbo.ZeriInTesta( G.LFN_Order , 5 )  + '-' + dbo.ZeriInTesta( F.LFN_Order ,5 ) + '-' + dbo.ZeriInTesta( T.LFN_Order ,5 ) as Path, G.LFN_Target
				from LIB_Functions G  with(nolock)
					inner join LIB_Functions F  with(nolock) on G.LFN_Target = f.LFN_GroupFunction
					inner join LIB_Functions T  with(nolock) on T.LFN_GroupFunction = dbo.GetValue ( 'TOOLBAR' , replace( F.LFN_paramTarget , '&amp;' , '&' )) and  isnull( T.LFN_PosPermission  , 0 ) <> 0 

				--where G.LFN_GroupFunction in (  'dashboardmain', 'main_group' )
		
		
			union all

			-- per ogni funzione prendo i documenti eventualmente collegati
			select G.LFN_GroupFunction , 'documenti_collegati'  , D.DOC_PosPermission  , G.LFN_GroupFunction + '-' + dbo.ZeriInTesta( G.LFN_Order , 5 )  + '-' + dbo.ZeriInTesta( F.LFN_Order ,5 ) + '-' + 'DOC' as Path, G.LFN_Target
				from LIB_Functions G  with(nolock)
					inner join LIB_Functions F  with(nolock) on G.LFN_Target = f.LFN_GroupFunction
					left join CTL_Relations  with(nolock) on REL_Type = 'DOC_X_VIEWER' and REL_ValueInput = F.LFN_GroupFunction + '-' + F.LFN_id
					inner join dbo.LIB_Documents D  with(nolock) on ( REL_ValueOutput = D.DOC_ID  or D.DOC_ID = dbo.GetValue ( 'DOCUMENT' , replace( F.LFN_paramTarget , '&amp;' , '&' )) )  and  isnull( D.DOC_PosPermission , 0 ) <> 0 

				--where G.LFN_GroupFunction in (  'dashboardmain', 'main_group' )
			
	
			union all

			-- per ogni funzione e per ogni documento collegato prendo la toolbar 
			select G.LFN_GroupFunction ,'toolbar_doc_collegati' , T.LFN_PosPermission , G.LFN_GroupFunction + '-' + dbo.ZeriInTesta( G.LFN_Order , 5 )  + '-' + dbo.ZeriInTesta( F.LFN_Order ,5 ) + '-' + 'DOC' +   dbo.ZeriInTesta( T.LFN_Order ,5 ) as Path, G.LFN_Target
				from LIB_Functions G  with(nolock)
					inner join LIB_Functions F with(nolock) on G.LFN_Target = f.LFN_GroupFunction
					left join CTL_Relations with(nolock) on REL_Type = 'DOC_X_VIEWER' and REL_ValueInput = F.LFN_GroupFunction + '-' + F.LFN_id
					inner join dbo.LIB_Documents D with(nolock) on ( REL_ValueOutput = D.DOC_ID )
					inner join LIB_Functions T with(nolock) on T.LFN_GroupFunction = D.DOC_LFN_GroupFunction and  isnull( T.LFN_PosPermission  , 0 ) <> 0 
			
			UNION ALL

				select G.LFN_GroupFunction ,'toolbar_doc_collegati' , T.LFN_PosPermission , G.LFN_GroupFunction + '-' + dbo.ZeriInTesta( G.LFN_Order , 5 )  + '-' + dbo.ZeriInTesta( F.LFN_Order ,5 ) + '-' + 'DOC' +   dbo.ZeriInTesta( T.LFN_Order ,5 ) as Path, G.LFN_Target
					from LIB_Functions G  with(nolock)
						inner join LIB_Functions F with(nolock) on G.LFN_Target = f.LFN_GroupFunction
						--left join CTL_Relations with(nolock) on REL_Type = 'DOC_X_VIEWER' and REL_ValueInput = F.LFN_GroupFunction + '-' + F.LFN_id
						inner join dbo.LIB_Documents D with(nolock) on ( D.DOC_ID = dbo.GetValue ( 'DOCUMENT' , replace( F.LFN_paramTarget , '&amp;' , '&' )) )  
						inner join LIB_Functions T with(nolock) on T.LFN_GroupFunction = D.DOC_LFN_GroupFunction and  isnull( T.LFN_PosPermission  , 0 ) <> 0 

				--where G.LFN_GroupFunction in (  'dashboardmain', 'main_group' )
				

			union all
		
			-- per ogni funzione e per ogni documento collegato prendo la toolbar delle sezioni
			select G.LFN_GroupFunction , 'toolbar_doc_sec_collegati', T.LFN_PosPermission , G.LFN_GroupFunction + '-' + dbo.ZeriInTesta( G.LFN_Order , 5 )  + '-' + dbo.ZeriInTesta( F.LFN_Order ,5 ) + '-' + 'SEC' +   dbo.ZeriInTesta( S.DES_Order ,5 ) + ' - ' +  dbo.ZeriInTesta( T.LFN_Order ,5 ) as Path, G.LFN_Target
				from LIB_Functions G  with(nolock)
					inner join LIB_Functions F  with(nolock) on G.LFN_Target = f.LFN_GroupFunction
					left join CTL_Relations  with(nolock) on REL_Type = 'DOC_X_VIEWER' and REL_ValueInput = F.LFN_GroupFunction + '-' + F.LFN_id
					inner join dbo.LIB_Documents D  with(nolock) on ( REL_ValueOutput = D.DOC_ID )
					--inner join dbo.LIB_Documents D on D.DOC_ID = dbo.GetValue ( 'DOCUMENT' , replace( F.LFN_paramTarget , '&amp;' , '&' )) 
					inner join dbo.LIB_DocumentSections S with(nolock) on S.DSE_DOC_ID = D.DOC_ID
					inner join LIB_Functions T  with(nolock) on T.LFN_GroupFunction = S.DES_LFN_GroupFunction and  isnull( T.LFN_PosPermission  , 0 ) <> 0 
				--where G.LFN_GroupFunction in (  'dashboardmain', 'main_group' )
			
				UNION  ALL
			
			select G.LFN_GroupFunction , 'toolbar_doc_sec_collegati', T.LFN_PosPermission , G.LFN_GroupFunction + '-' + dbo.ZeriInTesta( G.LFN_Order , 5 )  + '-' + dbo.ZeriInTesta( F.LFN_Order ,5 ) + '-' + 'SEC' +   dbo.ZeriInTesta( S.DES_Order ,5 ) + ' - ' +  dbo.ZeriInTesta( T.LFN_Order ,5 ) as Path, G.LFN_Target
				from LIB_Functions G  with(nolock)
					inner join LIB_Functions F  with(nolock) on G.LFN_Target = f.LFN_GroupFunction
					
					inner join dbo.LIB_Documents D  with(nolock) on (  D.DOC_ID = dbo.GetValue ( 'DOCUMENT' , replace( F.LFN_paramTarget , '&amp;' , '&' )) )  
					--inner join dbo.LIB_Documents D on D.DOC_ID = dbo.GetValue ( 'DOCUMENT' , replace( F.LFN_paramTarget , '&amp;' , '&' )) 
					inner join dbo.LIB_DocumentSections S with(nolock) on S.DSE_DOC_ID = D.DOC_ID
					inner join LIB_Functions T  with(nolock) on T.LFN_GroupFunction = S.DES_LFN_GroupFunction and  isnull( T.LFN_PosPermission  , 0 ) <> 0 
				--where G.LFN_GroupFunction in (  'dashboardmain', 'main_group' )


							
		) as v
			where V.LFN_GroupFunction in
								
									(
										select 'dashboardmain' + case when mplog = 'PA' then '' else '_' + mplog end
											from marketplace with(nolock)

											union all

										select 'main_group' + case when mplog = 'PA' then '' else '_' + mplog end
											from marketplace with(nolock)
							
								
								) 
		union all

		select LFN_GroupFunction , [LFN_CaptionML] as Title , LFN_PosPermission  , [LFN_paramTarget] as Path, 'PERMESSI_AGGIUNTIVI' as LFN_Target
				from LIB_Functions  with(nolock) 
			where LFN_GroupFunction = 'PERMESSI_AGGIUNTIVI'

	) as a			

		LEFT JOIN LIB_Dictionary dict  with(nolock)  ON dict.DZT_Name = 'SYS_MODULI_RESULT'





GO
