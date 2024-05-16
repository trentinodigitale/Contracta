USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_VIEW_DOCGEN]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[MAIL_VIEW_DOCGEN] as
select T.*, lngsuffisso as LNG ,
	case lngsuffisso when 'I' then
		case when isdate(ReceivedDataMsg) = 1
			then convert(varchar(10),cast(ReceivedDataMsg as datetime),103) 
				+ ' ' + convert(varchar(8),cast(ReceivedDataMsg as datetime),108) 
			else ''
	    end
	else
		case when isdate(ReceivedDataMsg) = 1
			then convert(varchar(10),cast(ReceivedDataMsg as datetime),101) 
				+ ' ' + convert(varchar(8),cast(ReceivedDataMsg as datetime),108) 
			else ''
	    end
	end as DataRicezione
from 
tab_messaggi_fields T ,lingue

GO
