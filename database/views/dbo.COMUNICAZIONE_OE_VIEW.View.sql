USE [AFLink_TND]
GO
/****** Object:  View [dbo].[COMUNICAZIONE_OE_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[COMUNICAZIONE_OE_VIEW] AS
select 
	d.*
	, rup.Value as UserRUP
	from  CTL_DOC d with(nolock)
		left outer join ctl_doc_value rup with (nolock) on d.LinkedDoc = rup.idHeader and  rup.dzt_name = 'UserRup' and rup.dse_id = 'InfoTec_comune'
	WHere d.TipoDoc='COMUNICAZIONE_OE'
GO
