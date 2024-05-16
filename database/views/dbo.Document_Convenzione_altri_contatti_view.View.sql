USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Convenzione_altri_contatti_view]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[Document_Convenzione_altri_contatti_view] as
select 
		

		c.Id as idheader 
		, Mandataria
		, P.IdPfu as idrow
		, P.IdPfu
		, pfuTel 
		, pfuCell
		, pfuE_Mail
		,
			case 
				when p.IdPfu = ReferenteFornitore then 'Referente convenzione'
				else 'Altro contatto'
			end as ruoloUtente
from CTL_DOC c
	
	inner join  Document_Convenzione D with (nolock) on D.id=C.id
	inner join ProfiliUtente P  with (nolock) on P.pfuIdAzi= Mandataria
where c.deleted=0 and c.tipodoc='CONVENZIONE' and StatoFunzionale <>'inlavorazione'


GO
