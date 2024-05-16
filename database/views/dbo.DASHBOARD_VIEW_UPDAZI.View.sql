USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_UPDAZI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_UPDAZI]
AS
		SELECT     TOP 100 PERCENT LFN_CaptionML AS TIPO_AZI, 
					LFN_paramTarget AS PARAM, 
					LFN_GroupFunction ,
					profiliutente.idpfu , 
					idazi
		FROM         dbo.LIB_Functions , 
					 profiliutente ,
					 aziende , 
					 ctl_relations
					
		WHERE     (LFN_GroupFunction = 'UPD_AZI') and 
					rel_type = 'PERMESSO_MODIFICA_AZI' and 
					LFN_paramTarget = REL_ValueInput and
					( substring( pfufunzionalita , LFN_PosPermission , 1) = '1' or
					 LFN_PosPermission is null ) and
					substring( azifunzionalita , cast(REL_ValueOutput as int) , 1) = '1' and 
					LFN_paramTarget <> 'PROROGA_ALBO'
union
	
		SELECT     TOP 100 PERCENT LFN_CaptionML AS TIPO_AZI, 
					LFN_paramTarget AS PARAM, 
					LFN_GroupFunction ,
					profiliutente.idpfu , 
					idazi
		FROM         dbo.LIB_Functions , 
					 profiliutente ,
					 aziende , 
					 ctl_relations
					
		WHERE     (LFN_GroupFunction = 'UPD_AZI') and 
					rel_type = 'PERMESSO_MODIFICA_AZI' and 
					LFN_paramTarget = REL_ValueInput and
					( substring( pfufunzionalita , LFN_PosPermission , 1) = '1' or
					 LFN_PosPermission is null ) and
					substring( azifunzionalita , cast(REL_ValueOutput as int) , 1) = '1' and 
					LFN_paramTarget = 'PROROGA_ALBO' and( idazi in 
					(Select Azienda from CTL_DOC 			
					where tipodoc='SOSPENSIONE_ALBO' and StatoDoc='Sended' and Deleted=0
					union 
					select lnk from DM_ATTRIBUTI where dztnome='CancellatoDiUfficio' and vatvalore_Ft='2' )  )
						
		
GO
