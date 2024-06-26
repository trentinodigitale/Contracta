USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_ELENCO_FUNZIONI_PERMESSI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  view [dbo].[OLD2_DASHBOARD_VIEW_ELENCO_FUNZIONI_PERMESSI] as 	

select distinct a.*, CASE WHEN ( isnull(dict.DZT_ValueDef,'') = '' OR substring( dict.DZT_ValueDef, a.LFN_PosPermission, 1) = '1' ) THEN 1
							ELSE 0
						END as Attivo

from 
(	
	
	-- estrae tutti i gruppi funzioni
	--select G.LFN_GroupFunction , dbo.CNV( G.LFN_CaptionML ,'I' ) + ' - ' + dbo.CNV( rtrim( F.LFN_CaptionML ) , 'I' )as Title , F.LFN_PosPermission , G.LFN_GroupFunction + '-' + dbo.ZeriInTesta( G.LFN_Order , 5 )  + '-' + dbo.ZeriInTesta( F.LFN_Order ,5 ) as Path, G.LFN_Target
	select G.LFN_GroupFunction , CAST( ISNULL( mlg1.ML_Description,G.LFN_CaptionML) AS NVARCHAR(MAX)) + ' - ' + CAST( ISNULL(mlg2.ML_Description , rtrim( F.LFN_CaptionML ) ) AS NVARCHAR(MAX)) as Title , F.LFN_PosPermission , G.LFN_GroupFunction + '-' + dbo.ZeriInTesta( G.LFN_Order , 5 )  + '-' + dbo.ZeriInTesta( F.LFN_Order ,5 ) as Path, G.LFN_Target
		from LIB_Functions G
			inner join LIB_Functions F   ON G.LFN_Target = f.LFN_GroupFunction

			LEFT JOIN LIB_Multilinguismo mlg1 ON mlg1.ML_KEY = G.LFN_CaptionML and mlg1.ML_LNG = 'I' and mlg1.ML_Context = 0
			LEFT JOIN LIB_Multilinguismo mlg2 ON mlg2.ML_KEY = rtrim( F.LFN_CaptionML ) and mlg2.ML_LNG = 'I' and mlg2.ML_Context = 0

		where G.LFN_GroupFunction in (  'dashboardmain', 'main_group' )
		
	union all
	
	-- per ogni funzione prendo la relativa toolbar
	--select G.LFN_GroupFunction ,dbo.CNV( G.LFN_CaptionML ,'I' ) + ' - ' + dbo.CNV( rtrim( F.LFN_CaptionML ) , 'I' )+ ' - TOOLBAR - ' + dbo.CNV( T.LFN_CaptionML , 'I' ) , T.LFN_PosPermission , G.LFN_GroupFunction + '-' + dbo.ZeriInTesta( G.LFN_Order , 5 )  + '-' + dbo.ZeriInTesta( F.LFN_Order ,5 ) + '-' + dbo.ZeriInTesta( T.LFN_Order ,5 ) as Path, G.LFN_Target
	select G.LFN_GroupFunction , CAST( ISNULL(mlg1.ML_Description,G.LFN_CaptionML) AS NVARCHAR(MAX)) + ' - ' + CAST( ISNULL(mlg2.ML_Description , rtrim( F.LFN_CaptionML ) ) AS NVARCHAR(MAX)) + ' - TOOLBAR - ' + CAST( ISNULL(mlg3.ML_Description ,T.LFN_CaptionML) AS NVARCHAR(MAX)) , T.LFN_PosPermission , G.LFN_GroupFunction + '-' + dbo.ZeriInTesta( G.LFN_Order , 5 )  + '-' + dbo.ZeriInTesta( F.LFN_Order ,5 ) + '-' + dbo.ZeriInTesta( T.LFN_Order ,5 ) as Path, G.LFN_Target
		from LIB_Functions G
			inner join LIB_Functions F on G.LFN_Target = f.LFN_GroupFunction
			inner join LIB_Functions T on T.LFN_GroupFunction = dbo.GetValue ( 'TOOLBAR' , replace( F.LFN_paramTarget , '&amp;' , '&' )) and  isnull( T.LFN_PosPermission  , 0 ) <> 0 

			LEFT JOIN LIB_Multilinguismo mlg1 ON mlg1.ML_KEY = G.LFN_CaptionML and mlg1.ML_LNG = 'I' and mlg1.ML_Context = 0
			LEFT JOIN LIB_Multilinguismo mlg2 ON mlg2.ML_KEY = rtrim( F.LFN_CaptionML ) and mlg2.ML_LNG = 'I' and mlg2.ML_Context = 0
			LEFT JOIN LIB_Multilinguismo mlg3 ON mlg3.ML_KEY = rtrim( T.LFN_CaptionML ) and mlg3.ML_LNG = 'I' and mlg3.ML_Context = 0

		where G.LFN_GroupFunction in (  'dashboardmain', 'main_group' )
		
	union all

	-- per ogni funzione prendo i documenti eventualmente collegati
	--select G.LFN_GroupFunction , dbo.CNV( G.LFN_CaptionML ,'I' ) + ' - ' + dbo.CNV( rtrim( F.LFN_CaptionML ) , 'I' ) + ' - DOC - ' + dbo.CNV( D.DOC_DescML , 'I' )  , D.DOC_PosPermission  , G.LFN_GroupFunction + '-' + dbo.ZeriInTesta( G.LFN_Order , 5 )  + '-' + dbo.ZeriInTesta( F.LFN_Order ,5 ) + '-' + 'DOC' as Path, G.LFN_Target
	select G.LFN_GroupFunction , CAST( ISNULL(mlg1.ML_Description,G.LFN_CaptionML) AS NVARCHAR(MAX)) + ' - ' + CAST( ISNULL(mlg2.ML_Description , rtrim( F.LFN_CaptionML ) ) AS NVARCHAR(MAX)) + ' - DOC - ' + CAST( ISNULL( mlg3.ML_Description,D.DOC_DescML) AS NVARCHAR(MAX))  , D.DOC_PosPermission  , G.LFN_GroupFunction + '-' + dbo.ZeriInTesta( G.LFN_Order , 5 )  + '-' + dbo.ZeriInTesta( F.LFN_Order ,5 ) + '-' + 'DOC' as Path, G.LFN_Target
		from LIB_Functions G
			inner join LIB_Functions F on G.LFN_Target = f.LFN_GroupFunction
			left join CTL_Relations on REL_Type = 'DOC_X_VIEWER' and REL_ValueInput = F.LFN_GroupFunction + '-' + F.LFN_id
			inner join dbo.LIB_Documents D on ( REL_ValueOutput = D.DOC_ID  or D.DOC_ID = dbo.GetValue ( 'DOCUMENT' , replace( F.LFN_paramTarget , '&amp;' , '&' )) )  and  isnull( D.DOC_PosPermission , 0 ) <> 0 

			LEFT JOIN LIB_Multilinguismo mlg1 ON mlg1.ML_KEY = G.LFN_CaptionML and mlg1.ML_LNG = 'I' and mlg1.ML_Context = 0
			LEFT JOIN LIB_Multilinguismo mlg2 ON mlg2.ML_KEY = rtrim( F.LFN_CaptionML ) and mlg2.ML_LNG = 'I' and mlg2.ML_Context = 0
			LEFT JOIN LIB_Multilinguismo mlg3 ON mlg3.ML_KEY =  D.DOC_DescML and mlg3.ML_LNG = 'I' and mlg3.ML_Context = 0

		where G.LFN_GroupFunction in (  'dashboardmain', 'main_group' )
	
	union all

	-- per ogni funzione e per ogni documento collegato prendo la toolbar 
	--select G.LFN_GroupFunction , dbo.CNV( G.LFN_CaptionML ,'I' ) + ' - ' + dbo.CNV( rtrim( F.LFN_CaptionML ) , 'I' ) + ' - DOC - ' +  dbo.CNV(  D.DOC_DescML , 'I' ) + ' - TOOLBAR - ' + dbo.CNV( T.LFN_CaptionML , 'I' ) , T.LFN_PosPermission , G.LFN_GroupFunction + '-' + dbo.ZeriInTesta( G.LFN_Order , 5 )  + '-' + dbo.ZeriInTesta( F.LFN_Order ,5 ) + '-' + 'DOC' +   dbo.ZeriInTesta( T.LFN_Order ,5 ) as Path, G.LFN_Target
	select G.LFN_GroupFunction , CAST( ISNULL(mlg1.ML_Description,G.LFN_CaptionML) as NVARCHAR(MAX)) + ' - ' + CAST( ISNULL(mlg2.ML_Description , rtrim( F.LFN_CaptionML ) ) AS NVARCHAR(MAX)) + ' - DOC - ' + CAST( ISNULL( mlg3.ML_Description,D.DOC_DescML) AS NVARCHAR(MAX)) + ' - TOOLBAR - ' + CAST( ISNULL(mlg4.ML_Description,T.LFN_CaptionML) AS NVARCHAR(MAX)) , T.LFN_PosPermission , G.LFN_GroupFunction + '-' + dbo.ZeriInTesta( G.LFN_Order , 5 )  + '-' + dbo.ZeriInTesta( F.LFN_Order ,5 ) + '-' + 'DOC' +   dbo.ZeriInTesta( T.LFN_Order ,5 ) as Path, G.LFN_Target
		from LIB_Functions G
			inner join LIB_Functions F on G.LFN_Target = f.LFN_GroupFunction
			left join CTL_Relations on REL_Type = 'DOC_X_VIEWER' and REL_ValueInput = F.LFN_GroupFunction + '-' + F.LFN_id
			inner join dbo.LIB_Documents D on ( REL_ValueOutput = D.DOC_ID  or D.DOC_ID = dbo.GetValue ( 'DOCUMENT' , replace( F.LFN_paramTarget , '&amp;' , '&' )) )  
			--inner join dbo.LIB_Documents D on D.DOC_ID = dbo.GetValue ( 'DOCUMENT' , replace( F.LFN_paramTarget , '&amp;' , '&' )) 
			inner join LIB_Functions T on T.LFN_GroupFunction = D.DOC_LFN_GroupFunction and  isnull( T.LFN_PosPermission  , 0 ) <> 0 

			LEFT JOIN LIB_Multilinguismo mlg1 ON mlg1.ML_KEY = G.LFN_CaptionML and mlg1.ML_LNG = 'I' and mlg1.ML_Context = 0
			LEFT JOIN LIB_Multilinguismo mlg2 ON mlg2.ML_KEY = rtrim( F.LFN_CaptionML ) and mlg2.ML_LNG = 'I' and mlg2.ML_Context = 0
			LEFT JOIN LIB_Multilinguismo mlg3 ON mlg3.ML_KEY =  D.DOC_DescML and mlg3.ML_LNG = 'I' and mlg3.ML_Context = 0
			LEFT JOIN LIB_Multilinguismo mlg4 ON mlg4.ML_KEY = rtrim( T.LFN_CaptionML ) and mlg4.ML_LNG = 'I' and mlg4.ML_Context = 0

		where G.LFN_GroupFunction in (  'dashboardmain', 'main_group' )

	union all
		
	-- per ogni funzione e per ogni documento collegato prendo la toolbar delle sezioni
	--select G.LFN_GroupFunction , dbo.CNV( G.LFN_CaptionML , 'I' ) + ' - ' + dbo.CNV( rtrim( F.LFN_CaptionML ) , 'I' ) + ' - DOC - ' + dbo.CNV( D.DOC_DescML , 'I' ) + ' - SEC - ' + dbo.CNV( S.DSE_DescML , 'I' ) + ' - TOOLBAR - ' + T.LFN_CaptionML, T.LFN_PosPermission , G.LFN_GroupFunction + '-' + dbo.ZeriInTesta( G.LFN_Order , 5 )  + '-' + dbo.ZeriInTesta( F.LFN_Order ,5 ) + '-' + 'SEC' +   dbo.ZeriInTesta( S.DES_Order ,5 ) + ' - ' +  dbo.ZeriInTesta( T.LFN_Order ,5 ) as Path, G.LFN_Target
	select G.LFN_GroupFunction , CAST( ISNULL(mlg1.ML_Description,G.LFN_CaptionML) AS NVARCHAR(MAX)) + ' - ' + CAST(ISNULL(mlg2.ML_Description , rtrim( F.LFN_CaptionML ) ) AS NVARCHAR(MAX)) + ' - DOC - ' + CAST( ISNULL( mlg3.ML_Description,D.DOC_DescML) AS NVARCHAR(MAX)) + ' - SEC - ' + CAST( ISNULL(mlg5.ML_Description,S.DSE_DescML) AS NVARCHAR(MAX)) + ' - TOOLBAR - ' + CAST( ISNULL(mlg4.ML_Description,T.LFN_CaptionML) AS NVARCHAR(MAX)), T.LFN_PosPermission , G.LFN_GroupFunction + '-' + dbo.ZeriInTesta( G.LFN_Order , 5 )  + '-' + dbo.ZeriInTesta( F.LFN_Order ,5 ) + '-' + 'SEC' +   dbo.ZeriInTesta( S.DES_Order ,5 ) + ' - ' +  dbo.ZeriInTesta( T.LFN_Order ,5 ) as Path, G.LFN_Target
		from LIB_Functions G
			inner join LIB_Functions F on G.LFN_Target = f.LFN_GroupFunction
			left join CTL_Relations on REL_Type = 'DOC_X_VIEWER' and REL_ValueInput = F.LFN_GroupFunction + '-' + F.LFN_id
			inner join dbo.LIB_Documents D on ( REL_ValueOutput = D.DOC_ID  or D.DOC_ID = dbo.GetValue ( 'DOCUMENT' , replace( F.LFN_paramTarget , '&amp;' , '&' )) )  
			--inner join dbo.LIB_Documents D on D.DOC_ID = dbo.GetValue ( 'DOCUMENT' , replace( F.LFN_paramTarget , '&amp;' , '&' )) 
			inner join dbo.LIB_DocumentSections S on S.DSE_DOC_ID = D.DOC_ID
			inner join LIB_Functions T on T.LFN_GroupFunction = S.DES_LFN_GroupFunction and  isnull( T.LFN_PosPermission  , 0 ) <> 0 

			LEFT JOIN LIB_Multilinguismo mlg1 ON mlg1.ML_KEY = G.LFN_CaptionML and mlg1.ML_LNG = 'I' and mlg1.ML_Context = 0
			LEFT JOIN LIB_Multilinguismo mlg2 ON mlg2.ML_KEY = rtrim( F.LFN_CaptionML ) and mlg2.ML_LNG = 'I' and mlg2.ML_Context = 0
			LEFT JOIN LIB_Multilinguismo mlg3 ON mlg3.ML_KEY =  D.DOC_DescML and mlg3.ML_LNG = 'I' and mlg3.ML_Context = 0
			LEFT JOIN LIB_Multilinguismo mlg4 ON mlg4.ML_KEY = rtrim( T.LFN_CaptionML ) and mlg4.ML_LNG = 'I' and mlg4.ML_Context = 0
			LEFT JOIN LIB_Multilinguismo mlg5 ON mlg5.ML_KEY = rtrim( S.DSE_DescML ) and mlg5.ML_LNG = 'I' and mlg5.ML_Context = 0

		where G.LFN_GroupFunction in (  'dashboardmain', 'main_group' )

	union all

	select LFN_GroupFunction , [LFN_CaptionML] as Title , LFN_PosPermission  , [LFN_paramTarget] as Path, 'PERMESSI_AGGIUNTIVI' as LFN_Target
		from LIB_Functions where LFN_GroupFunction = 'PERMESSI_AGGIUNTIVI'

) as a			

	LEFT JOIN LIB_Dictionary dict ON dict.DZT_Name = 'SYS_MODULI_RESULT'




GO
