USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_DOCUMENTI_DA_PERFEZIONARE_INCHARGE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_DOCUMENTI_DA_PERFEZIONARE_INCHARGE] as

	select	
			C.*,
			C.TipoDoc as OPEN_DOC_NAME,
			C.idPfuInCharge as owner,
			A.aziRagioneSociale,
			convert( varchar(10) , c.DataInvio , 121 )   as DataDA ,
			convert( varchar(10) , c.DataInvio , 121 )   as DataA ,
			CO.datascadenza as DataScadenzaOfferta

		from  ctl_doc C with (nolock)
				--inner join ProfiliUtente P on P.pfuIdAzi=C.Destinatario_Azi
				inner join aziende A with (nolock) on A.IdAzi=C.Azienda
				inner join ctl_doc CO with (nolock) on CO.id=C.LinkedDoc
		where C.tipodoc='RICHIESTA_COMPILAZIONE_DGUE' and c.Deleted=0

GO
