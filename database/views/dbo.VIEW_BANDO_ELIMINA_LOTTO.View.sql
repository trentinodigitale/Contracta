USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_BANDO_ELIMINA_LOTTO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create VIEW [dbo].[VIEW_BANDO_ELIMINA_LOTTO]
as
select 
	C.*
	,Divisione_Lotti

	from 
		ctl_doc C	inner join document_bando on idheader=linkeddoc
		where tipodoc='BANDO_ELIMINA_LOTTO'
GO
