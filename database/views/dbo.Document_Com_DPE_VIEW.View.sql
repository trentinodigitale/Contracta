USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Com_DPE_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Document_Com_DPE_VIEW] as 
select 
		D.*,
		case 
			when P.idcom is null then 'NO' 
				else 'SI' 
			end as HIDE_RICHIAMA_COM
	from Document_Com_DPE D with(nolock)
		left join document_inipec P with(nolock) on P.IdCom=D.IdCom
GO
