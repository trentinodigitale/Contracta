USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CHAT_ROOMS_USER]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[OLD_CHAT_ROOMS_USER]( @idPfu int , @Time varchar(30) ) 
as 
begin
	set nocount on

	declare @DS datetime


	-- definisco la data da cui estrarre i messaggi 
	if @Time <> ''
		set @DS = convert( datetime , @Time , 121 )
	else
		set @DS = convert( datetime , '1900-01-01 00:00:00' , 121 )



	-- se esiste almeno una chat di interesse che ha subito una modifica allora recupero tutte le chat di interesse
	if exists ( 	select Title  
						from CTL_CHAT_LAST_UPD u with(nolock) 
							inner join CTL_CHAT_ROOMS r with(nolock)  on u.idheader = r.idheader and r.Chat_Stato <> 'OLD'
						where 
							u.idpfu = @idpfu and r.LastUpd > @DS
			  )
	begin



		select Title  , r.idHeader , u.LastUpd  , r.Chat_Stato , r.LastUpd as LUR into #T
			from CTL_CHAT_LAST_UPD u with(nolock) 
				inner join CTL_CHAT_ROOMS r with(nolock)  on u.idheader = r.idheader and r.Chat_Stato <> 'OLD'
			where 
				u.idpfu = @idpfu 

		-- tutti i messaggi non letti di quelle chat
		select  r.idHeader  , count(*) as NumNotRead into #M
			from #T r
				inner join CTL_CHAT_MESSAGES m with(nolock) on m.idheader = r.idheader and m.DataIns > r.LastUpd 
			group by  r.idHeader 
		

		-- output
		select  r.idHeader , r.Title , r.Chat_Stato , isnull(  m.NumNotRead , 0 ) as NumNotRead , convert( varchar(19) , getdate( ) , 121 ) as LastTime
			from #T r
				left outer join #M as m on r.idHeader = m.idHeader
			order by  r.LUR desc
	
	end
	else
	begin
		
		select  top 0 0 as idHeader , '' as Title , '' as Chat_Stato , '' as NumNotRead , '' as LastTime

	end
end

GO
