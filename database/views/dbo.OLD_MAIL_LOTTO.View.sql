USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_LOTTO]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[OLD_MAIL_LOTTO] as
select
	l.id as iddoc
	,lngSuffisso as LNG

	, convert( varchar , getdate() , 103 ) as DataOperazione
	,[GUID]
	, b.ProtocolloBando
	, l.NumeroLotto

	, dbo.GetCodDom2DescML( 'StatoRiga' , l.StatoRiga  , lngSuffisso ) as StatoRiga
from 
	Document_MicroLotti_Dettagli l
	inner join CTL_DOC d on l.idheader = d.id
	inner join Document_Bando b on d.LinkedDoc = b.idheader
	cross join Lingue
GO
