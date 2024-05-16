USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CHAT_ROOM_GET_MSGS]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE proc [dbo].[CHAT_ROOM_GET_MSGS]( @idPfu int , @Room int , @Time varchar(30) ) 
as 
begin
	set nocount on
	declare @DS datetime
	declare @AziAcquirente as int

	declare @LastUpd datetime

	-- definisco la data da cui estrarre i messaggi 
	if @Time <> ''
		set @DS = convert( datetime , @Time , 121 )
	else
		set @DS = convert( datetime , '1900-01-01 00:00:00' , 121 )

	--recupero aziacquirente utente colegato
	set @AziAcquirente = 0
	select @AziAcquirente = aziacquirente 
		from 
			profiliutente with (nolock)
				inner join aziende with (nolock) on pfuidazi = idazi 
		where idpfu = @idPfu 

	-- recupero la data di ultimo aggiornamento sulla chat per l'utente se è presente
	select @LastUpd = LastUpd from CTL_CHAT_LAST_UPD u with(nolock) where idPfu = @idPfu and idHeader = @Room
	

	declare @CurDate datetime
	set @CurDate = convert( varchar(19) , getdate( ) , 121 )
	
	declare @CurDateTxt varchar(19)
	set @CurDateTxt = convert( varchar(19) ,@CurDate , 121 )

	-- se l'utente non è presente vuol dire che non è iscritto ed il risultato deve essere nullo
	if @LastUpd is null 
	begin

		--insert into CTL_CHAT_LAST_UPD ( idHeader, idPfu, LastUpd  ) values ( @Room , @idPfu , getdate() )
		--set @LastUpd  = @CurDate
		set @DS = convert( datetime , '2100-01-01 00:00:00' , 121 )

		select 
				-1 as id,  
				0 as idPfu, 
				Convert( varchar(19) , getdate() , 105 ) + ' ' + Convert( varchar(8) , getdate() , 114 ) as DataIns ,  
				'Non autorizzato alla lettura' as Message , 
				'' as pfuNome , 
				'NON RICONOSCIUTO' as aziRagioneSociale , 
				'AF_CHAT_MSG_NOT_READ' as  NotRead ,  
				--@CurDate as LastTime , 
				@CurDateTxt as LastTime , 
				'AF_CHAT_MSG_PA'  as Profilo
				

	end
	else
	begin


		-- aggiorno la data dell'ultimo recupero messaggi
		update CTL_CHAT_LAST_UPD set LastUpd = @CurDate where idPfu = @idPfu and idHeader = @Room 


		-- recupero tutti i messaggi dalla data indicata
		select 
				id,  
				m.idPfu, 
				Convert( varchar(19) , m.DataIns , 105 ) + ' ' + Convert( varchar(8) , m.DataIns , 114 ) as DataIns ,  
				replace( m.Message , '	' , ' ' ) as Message , -- sotituiamo il tab con lo spazio
				p.pfuNome , 
				a.aziRagioneSociale , 
				case when DataIns > @LastUpd then 'AF_CHAT_MSG_NOT_READ' else 'AF_CHAT_MSG_READED' end as  NotRead ,  
				--@CurDate as LastTime , 
				@CurDateTxt as LastTime , 
				case when isnull( m.Type  , 'MSG' ) in ( 'MSG' ,'IN','OUT')

						then 
							case 
								when @idpfu = m.idPfu and a.azivenditore > 0 then 'AF_CHAT_' + isnull( m.Type  , 'MSG' ) + '_USER_OE'  
								when @idpfu <> m.idPfu and a.azivenditore > 0 then 'AF_CHAT_' + isnull( m.Type  , 'MSG' ) + '_OE'  
								when @idpfu = m.idPfu and a.aziAcquirente > 0 then 'AF_CHAT_' + isnull( m.Type  , 'MSG' ) + '_USER_PA'  
								when @idpfu <> m.idPfu and a.aziAcquirente > 0 then 'AF_CHAT_' + isnull( m.Type  , 'MSG' ) + '_PA'  
							end 
					else
					
						'AF_CHAT_MSG_' + m.Type
					end
					as Profilo,

				isnull( m.Type  , 'MSG' ) as Type

			from CTL_CHAT_MESSAGES m with(nolock) 
				inner join ProfiliUtente p with(nolock) on m.idPfu = p.IdPfu
				inner join Aziende a with(nolock) on p.pfuIdAzi = a.IdAzi
			where 
				m.idHeader = @Room and m.DataIns > @DS
								
				and 
				(	--se sono io e sono utente OE vede i miei IN/OUT
					( a.azivenditore > 0 and isnull( m.Type  , 'MSG' ) in ('IN','OUT') and m.idPfu = @idpfu )
					or
					--gli altri tipi per tutti
					 isnull( m.Type  , 'MSG' )  NOT in ('IN','OUT') 
					or 
					--utente ente vede tutto 
					@AziAcquirente > 0
				)

			order by m.DataIns

	end

end





GO
