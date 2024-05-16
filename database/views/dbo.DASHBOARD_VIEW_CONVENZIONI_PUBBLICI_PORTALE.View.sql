USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_CONVENZIONI_PUBBLICI_PORTALE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  view [dbo].[DASHBOARD_VIEW_CONVENZIONI_PUBBLICI_PORTALE] as
select
		ID, 
		DOC_Owner, 
		DOC_Name, 
		DataCreazione, 
		Protocol, 
		cast(DescrizioneEstesa as varchar(8000)) as DescrizioneEstesa, 
		cast(DescrizioneEstesa as varchar(8000)) as Oggetto,
		StatoConvenzione, 
		AZI, 
		Plant, 
		Deleted, 
		AZI_Dest, 
		NumOrd, 
		Imballo,
		Resa, 
		Spedizione, 
		Pagamento, 
		Valuta, 
		Total, 
		Completo, 
		Allegato, 
		Telefono, 
		Compilatore, 
		RuoloCompilatore, 
		TipoOrdine, 
		SendingDate, 
		ProtocolloBando, 
		DataInizio, 
		DataFine, 
		Merceologia, 
		TotaleOrdinato, 
		IVA, 
		NewTotal, 
		RicPropBozza, 
		ConvNoMail, 
		QtMinTot, 
		RicPreventivo, 
		TipoImporto, 
		TipoEstensione, 
		RichiediFirmaOrdine,
		'CONVENZIONE' as DOCUMENT ,
		DC.id as IDMSG,isnull( Total , 0 ) - isnull( TotaleOrdinato , 0 ) as BDG_TOT_Residuo,
		convert(varchar ,DataFine,126)  as expirydate ,
		convert(varchar ,DataFine,126) as expirydateal
		

from 	
		Document_Convenzione  DC
where 
	DC.Deleted = 0 --and DataFine > getdate() and statoconvenzione='Pubblicato'





GO
