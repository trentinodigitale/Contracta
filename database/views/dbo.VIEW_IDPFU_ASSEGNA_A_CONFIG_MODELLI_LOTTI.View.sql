USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_IDPFU_ASSEGNA_A_CONFIG_MODELLI_LOTTI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VIEW_IDPFU_ASSEGNA_A_CONFIG_MODELLI_LOTTI] as
--UTENTI con profilo Referente Tecnico TRA I riferimenti (Inviti) del bando 
	select
		   R.ID_FROM  as idPfu,
		   C.id
	from
	ctl_doc C with(nolock) 					
		inner join Document_Bando_Riferimenti  DR   with(nolock) on C.LinkedDoc=DR.idHeader and DR.RuoloRiferimenti='ReferenteTecnico'	
	    inner join USER_DOC_PROFILI_FROM_UTENTI R with(nolock) on  R.profilo ='Referente_Tecnico' AND R.ID_FROM=DR.idPfu
	where C.tipodoc in ( 'CONFIG_MODELLI_LOTTI')  and C.Deleted=0 

union

--utente compilatore della gara
	select
		  C.COMPILATORE_GARA as idPfu,
		  C.id
	from
	config_modelli_lotti_view C with(nolock) 	

union

--utente rup della gara
	select
		  Cv.VALUE as idPfu,
		  C.id
    FROM ctl_doc C with(nolock) 			
		INNER JOIN CTL_DOC_VALUE   cv with(nolock)  ON CV.IDHEADER=c.LINKEDdOC AND cv.DSE_ID='InfoTec_comune' AND cv.DZT_Name='UserRUP'
	where C.tipodoc in ( 'CONFIG_MODELLI_LOTTI')  and C.Deleted=0 
GO
