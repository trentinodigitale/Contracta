USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DOSSIER_FILTRO_DOCUMENTI_UTENTE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_DOSSIER_FILTRO_DOCUMENTI_UTENTE] as 
	select p.idpfu , IdDcm  
		from Document 
			cross join profiliutente p
			left join profiliutenteattrib a on p.IdPfu = a.idpfu and dztNome = 'Dossier_DocumentType' and attvalue = IdDcm
			left join ( select distinct idpfu from profiliutenteattrib where dztNome = 'Dossier_DocumentType' ) as R on R.idpfu = p.idpfu

		where 
			(
			   CHARINDEX ( substring( pfuProfili , 1 , 1 )  , dcmDetail ) > 0 
			or CHARINDEX ( substring( pfuProfili , 2 , 1 )  , dcmDetail ) > 0 
			or CHARINDEX ( substring( pfuProfili , 3 , 1 )  , dcmDetail ) > 0 
			or CHARINDEX ( substring( pfuProfili , 4 , 1 )  , dcmDetail ) > 0 
			)
			-- o l'utente non ha restrizioni sui documenti oppure prendiamo i documenti presenti 
			and ( R.idpfu is null or a.idpfu is not null )


GO
