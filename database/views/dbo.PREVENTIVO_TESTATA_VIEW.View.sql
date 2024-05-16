USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PREVENTIVO_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

-----------------------------------------------------------

CREATE  view [dbo].[PREVENTIVO_TESTATA_VIEW] as

select  isnull( p.id , 0 )  as Id_Preventivo  , d.*
from CTL_DOC d
		left outer join CTL_DOC p on p.LinkedDoc = d.id and p.StatoFunzionale in ('Approved' , 'InApprove' ) 


GO
