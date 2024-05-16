USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_FABBISOGNI_DOMINI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[DASHBOARD_VIEW_FABBISOGNI_DOMINI] as 

	select 
		D.ID,
		case when N.id is null then D.titolo else '<b>( In Modifica )</b> ' + D.titolo end as Titolo,
		D.idpfu ,
		D.Protocollo,
		d.DataInvio,
		d.StatoFunzionale
		
	
	 
		from CTL_DOC D with(nolock)
			left outer join CTL_DOC N with(nolock) on N.tipodoc = 'QUESTIONARIO_DOMINIO' and N.statofunzionale in ( 'InLavorazione'  ) and N.PrevDoc = D.id and N.deleted = 0 
		where D.tipodoc = 'QUESTIONARIO_DOMINIO' and D.Deleted = 0 and
				( D.statofunzionale in (  'Pubblicato' ) 
				 or ( D.statofunzionale in ( 'InLavorazione' )  and isnull( D.PrevDoc , 0 ) = 0)
				 )



	



GO
