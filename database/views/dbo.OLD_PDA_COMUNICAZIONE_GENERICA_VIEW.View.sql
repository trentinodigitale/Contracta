USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PDA_COMUNICAZIONE_GENERICA_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_PDA_COMUNICAZIONE_GENERICA_VIEW] AS
select
	C.*,
	case when ISNULL(v.num,0) = 0 and C.JumpCheck='1-VERIFICA_REQUISITI' then '1' else '0' end as CAN_SORT
from ctl_doc C
	left join (  select count(*) as num ,linkeddoc from VIEW_PDA_COMUNICAZIONE_DETTAGLI  group by linkeddoc ) V on V.LinkedDoc=C.id and C.TipoDoc='PDA_COMUNICAZIONE_GENERICA' 

GO
