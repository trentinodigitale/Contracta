USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_MONITORAGGIO_ISTANZE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  proc [dbo].[DASHBOARD_SP_MONITORAGGIO_ISTANZE]
(@IdPfu							int,
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output
)
as
begin

	declare @Param varchar(8000)

	declare @DI datetime
	declare @DF datetime

	
	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp

	-- recupero il periodo di filtro	
	if dbo.GetParam( 'DataInizio' , @Param ,1) <> ''
		set @DI			= convert( datetime , left( dbo.GetParam( 'DataInizio' , @Param ,1),10 ) + ' 00:00:00', 121 )
	else
		set @DI = cast( ( year( getdate())  )  as varchar(4)) + '-01-01 00:00:00' -- inizio anno in corso

	if dbo.GetParam( 'DataFine' , @Param ,1) <> '' 
		set @DF			= convert( datetime , left( dbo.GetParam( 'DataFine' , @Param ,1), 10 ) + ' 23:59:59' , 121 )
	else
		set @DF = cast( ( year( getdate()) )  as varchar(4)) + '-12-31 23:59:59' -- fine anno in corso

	
	

	-- preparo la base dei dati per fare il report
	select 
			c.tipodoc as TipodocAzione, i.tipodoc , i.datainvio as dataInvio ,c.datainvio as DataRisposta ,  c.id as r 
			, case 
				when b.tipodoc = 'BANDO_SDA' then 'SDA - ' + b.Titolo
				when b.tipodoc = 'BANDO' and isnull( b.JumpCheck , '' ) = '' then 'ME'
				else replace( b.JumpCheck ,'_' , ' ' )
			end as TipoBando
			, b.Titolo
			, b.id
		into #T2 

		from ctl_doc i with(nolock) 
			inner join ctl_doc b with(nolock) on b.id = i.LinkedDoc
			inner join ctl_doc c with(nolock) on c.tipodoc in ( 'CONFERMA_ISCRIZIONE' , 'CONFERMA_ISCRIZIONE_SDA' , 'SCARTO_ISCRIZIONE', 'SCARTO_ISCRIZIONE_SDA' ) and c.linkeddoc = i.id 
												and c.statofunzionale in ('Notificato') 
												and cast( c.body as nvarchar(max)) not in ( 'Conferma automatica del documento iscrizione Albo' , 'Conferma automatica del documento iscrizione SDA' )
		where i.tipodoc like 'istanza%' -- and i.statofunzionale in ('Confermato','Variato') 
			and c.datainvio >= @DI	
			and c.datainvio <= @DF




	select  
			id ,
			TipoBando as Descrizione, 
			count(*)  as NumIstLav , 
			sum( case when TipodocAzione in ( 'CONFERMA_ISCRIZIONE' , 'CONFERMA_ISCRIZIONE_SDA' ) then 1 else 0 end )  AS NumIstAcc ,
			sum( case when TipodocAzione in ( 'SCARTO_ISCRIZIONE' , 'SCARTO_ISCRIZIONE_SDA' ) then 1 else 0 end )  AS NumIstSca , 

			dbo.AFS_ROUND( avg( cast( datediff( day ,
						convert( varchar(10) , datainvio , 121 ) 
						,
						convert( varchar(10) ,datarisposta , 121 ) 
						) as float) ), 0 ) as NumGiorni

		from #T2
		group by TipoBando , id
		order by TipoBando

	--print @SQLCmd
	--exec (@SQLCmd)

	--select @cnt = count(*) from #temp
	--set @cnt = @@rowcount

end







GO
