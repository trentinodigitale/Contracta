USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_SDA_SITUAZIONE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_DASHBOARD_VIEW_SDA_SITUAZIONE] as

select b.id , Protocollo,titolo,body,sda.importoBando,s.NumSemp , s.ImportoBaseAsta ,i.NumIst ,
	 i.NumIstAcc , i.NumIstSca , i.NumIstLav,
	 b.StatoFunzionale,b.DataInvio,b.DataScadenza,
	 RUP.idPfu
	from ctl_doc b
	inner join document_bando sda on sda.idheader = b.id
	left join Document_Bando_Commissione RUP with(nolock) on sda.idHeader=RUP.idHeader and RUP.RuoloCommissione='15550'
	left outer join ( select linkedDoc , count(*) as NumSemp , sum(ImportoBaseAsta) as ImportoBaseAsta from ctl_doc  inner join document_bando on id = idheader where deleted = 0 and  StatoDoc = 'sended' and tipodoc = 'BANDO_SEMPLIFICATO' group by Linkeddoc ) as s on b.id = s.LinkedDoc 
	left outer join ( select linkedDoc , count(*) as NumIst 
							, sum( case when StatoFunzionale = 'Confermato' then 1 else 0 end ) as NumIstAcc 
							, sum( case when StatoFunzionale = 'Scartato' then 1 else 0 end ) as NumIstSca   
							, sum( case when StatoFunzionale NOT IN ( 'Scartato','Confermato' ) then 1 else 0 end ) as NumIstLav  
						from ctl_doc s where deleted = 0 and StatoDoc = 'sended' and left( tipodoc , 11 ) = 'ISTANZA_SDA' group by Linkeddoc 
					) as i on b.id = i.LinkedDoc 

	where b.tipodoc = 'BANDO_SDA'
		and b.StatoDoc = 'sended'
		and b.deleted = 0

GO
