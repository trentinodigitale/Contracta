USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Messaggi_di_sistema_attivi]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[Messaggi_di_sistema_attivi] as


	select 

		case when Fermo_Avviso = 'avviso' then DataAvvisoDal else DataSysMsgDA end as DI ,
		case when Fermo_Avviso= 'avviso' then DataAvvisoAl else DataInizio end as DF ,
		Body ,
		Fermo_Avviso
	
		from	ctl_doc with(nolock) 
			inner join Document_FermoSistema with(nolock) on idHeader = id 
	
		where tipodoc = 'FERMOSISTEMA' and deleted = 0 and StatoFunzionale = 'Confermato' 
			and ( 
					( getdate() >= DataSysMsgDA and getdate() < DataInizio ) 
					or 
					( getdate() >= DataAvvisoDal and getdate() < DataAvvisoAl ) 
				)
			and case when Fermo_Avviso = 'avviso' then DataAvvisoDal else DataSysMsgDA end is not null

GO
