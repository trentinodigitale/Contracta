USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_COPERTINA_SDA_FROM_USER]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD_BANDO_COPERTINA_SDA_FROM_USER] as 
select 
	U.idpfu as ID_FROM , 
	U.pfuidazi as Azienda,
	p.NumGiorniDomandaPartecipazione,
	ISNULL(L.DZT_ValueDef,2) as  versione,
	case
		when SUBSTRING(isnull( L2.DZT_ValueDef , '' ) ,115,1)='1' then 'si' -- è attivo il modulo DGUE
		else 'no'
	end as DGUEAttivo

from profiliutente U with(nolock)
	left join ctl_doc c with(nolock) on c.TipoDoc='PARAMETRI_SDA' and c.Deleted=0 and c.StatoFunzionale='Confermato'
	left outer join Document_Parametri_SDA p  with(nolock)  on  c.id=p.idheader  and p.deleted = 0
	left join LIB_Dictionary L with(nolock) on dzt_name='SYS_VERSIONE_BANDO_SDA'
	left outer join LIB_Dictionary L2  with (nolock) on l2.DZT_Name='SYS_MODULI_RESULT' 
GO
