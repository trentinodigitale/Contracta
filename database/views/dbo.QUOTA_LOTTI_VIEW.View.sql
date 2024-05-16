USE [AFLink_TND]
GO
/****** Object:  View [dbo].[QUOTA_LOTTI_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QUOTA_LOTTI_VIEW] AS
SELECT    

	DQL.*,
	--(DQL.Importo_Q_Lotto - ISNULL(S.totQL,0)) as Residuo 
	(l.Importo- ISNULL(S.totQL,0)) as Residuo --aggiornata condizione residuo perchè la colonna sul documento non è aggiornata
	--CC.Residuo
FROM  Document_Convenzione_Quota_Lotti DQL with(nolock) 
	inner join CTL_DOC C with(nolock)  on C.id=DQL.IDHEADER
	--inner join CONVENZIONE_CAPIENZA_LOTTI_VIEW CC on CC.idHeader=C.LinkedDoc and  CC.NumeroLotto=DQL.NumeroLotto 	
	inner join Document_Convenzione_Lotti l with (nolock) on l.idHeader=C.LinkedDoc and l.NumeroLotto=DQL.NumeroLotto 
	left join ( select  
					ctl_doc.linkeddoc, 
					NUmeroLotto,
					isnull(sum(Importo),0) as totQL
				from Document_Convenzione_Quota_Lotti with(nolock)
					inner join ctl_doc with(nolock) on tipodoc='QUOTA' and  idheader=id and statodoc='Sended'						
					group by linkeddoc,NumeroLotto
				) S	
				on S.linkeddoc=C.LinkedDoc and DQL.NumeroLotto=S.NumeroLotto

--where TipoDoc='QUOTA'
GO
