USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_CONVENZIONE_QUOTA_LOTTI_FROMADD]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_CONVENZIONE_QUOTA_LOTTI_FROMADD] AS
select 
	indRow,
	C.Importo_Q_Lotto,
	--(C.Importo_Q_Lotto - ISNULL(S.totQL,0)) as Residuo,
	idRow,
	idHeader,
	C.NumeroLotto,
	Descrizione,
	Residuo
from CONVENZIONE_CAPIENZA_LOTTI_VIEW C
	--left join ( select  
	--				ctl_doc.linkeddoc, 
	--				NUmeroLotto,
	--				isnull(sum(Importo),0) as totQL
	--			from Document_Convenzione_Quota_Lotti with(nolock)
	--				inner join ctl_doc with(nolock) on tipodoc='QUOTA' and  idheader=id and statodoc='Sended'						
	--				group by linkeddoc,NumeroLotto
	--			) S	
	--on S.linkeddoc=C.idHeader and C.NumeroLotto=S.NumeroLotto
GO
