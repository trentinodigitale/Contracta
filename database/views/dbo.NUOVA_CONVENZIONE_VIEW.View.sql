USE [AFLink_TND]
GO
/****** Object:  View [dbo].[NUOVA_CONVENZIONE_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[NUOVA_CONVENZIONE_VIEW]
as

select 
	NC.*,
	DNC.Ambito 

	from 
		CTL_DOC NC with (nolock)
		inner join Document_Convenzione DNC with (nolock) on DNC.ID=NC.id
	--where tipodoc = 'NUOVA_CONVENZIONE'

GO
