USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_AF_REFRESH_OWNERS_LIST]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[OLD_AF_REFRESH_OWNERS_LIST]
as
BEGIN

	SET NOCOUNT ON

	-- Cancello tutti i record che vengono estratti in automatico (quelli custom sono origine = 'js')
	DELETE FROM ctl_sqlobj_owner where origine = 'db'
	
	-- Estratto in automatico gli oggetti sql soggetti a owner dalla lib_functions
	-- escludendo quelli già presenti nella tabella ctl_sqlobj_owner con la colonna 'opzionale' a 1
	INSERT INTO CTL_sqlobj_owner 
		select distinct * from (
			select 	dbo.GetKeyMLfrom(SUBSTRING(lfn_paramtarget, CHARINDEX('owner=', lfn_paramtarget + space(209) ) + 6, 200)) AS campoOwner,
					dbo.GetKeyMLfrom(SUBSTRING(lfn_paramtarget, CHARINDEX('table=', lfn_paramtarget + space(209) ) + 6, 200)) AS oggettosql,
					0 as bDeleted,
					'db' as origine,
					0 as opzionale
				from lib_functions with(nolock) 
				where  ( lfn_paramtarget like '%&amp;owner=%' or lfn_paramtarget like '%&owner=%' or  lfn_paramtarget like '%[%]26owner[%]3D%' ) 
								and		
					   ( lfn_paramtarget NOT like '%&amp;owner=&amp;%' or lfn_paramtarget NOT like '%&owner=&%' or lfn_paramtarget NOT like '%[%]26owner[%]3D[%]26%' )
	
			) as tab where oggettosql not in ( select oggettosql from CTL_sqlobj_owner with(nolock) where origine = 'js' ) and campoOwner <> ''

END


GO
