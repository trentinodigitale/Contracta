USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_ProfiliUtente_GeneraLogin]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE proc [dbo].[OLD2_ProfiliUtente_GeneraLogin] ( @idPfu as int )
as
begin
	declare @PrevUser int
	declare @PfuLogin varchar(255) 
	declare @Progr int
	declare @idAzi int
	declare @pfunomeutente varchar(500)  
	declare @pfuCognome varchar(500)  
	
	declare @Prefisso varchar(10)

	select  @pfunomeutente = pfunomeutente , @pfuCognome = pfuCognome   from profiliutente with (nolock) where idpfu = @idPfu
	set @pfunomeutente = dbo.NormStringExt( @pfunomeutente , 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789' )
	set @pfuCognome = dbo.NormStringExt( @pfuCognome , 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789' )


	select 	
		@Prefisso = case when aziAcquirente <> 0 then 'E_' else 'F_' end 
		from profiliutente as a with (nolock)
			inner join aziende z with (nolock) on a.pfuidazi = z.idazi
		where a.idpfu = @idPfu 

	set  @PfuLogin  = replace( isnull( @Prefisso , 'E_' ) + @pfunomeutente + '_' + @pfuCognome   , ' ' , '_' )
	
	set @PrevUser  = 0
	select @PrevUser = b.idpfu 
		from profiliutente as a with (nolock)
			
			inner join profiliutente  as b with (nolock) on @PfuLogin = b.PfuLogin or b.PfuLogin like @PfuLogin + '[_]%'
			
		--inner join profiliutente  as b on @pfuCognome = dbo.NormStringExt( b.pfuCognome , 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789' )
		--							and @pfunomeutente = dbo.NormStringExt( b.pfunomeutente , 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789' ) 
		----inner join profiliutente  as b on a.pfuCognome = b.pfuCognome and a.pfunomeutente = b.pfunomeutente --and a.pfuCodiceFiscale = b.pfuCodiceFiscale
		----inner join profiliutente  as b on a.pfuCodiceFiscale = b.pfuCodiceFiscale
		----inner join aziende z on a.pfuidazi = z.idazi
		where a.idpfu = @idPfu and b.idPfu <> @idPfu

	--print @PrevUser

	
	
	--non ci sono utenti omonimi		
	if isnull( @PrevUser  , 0 ) = 0
	begin
		
		----select  @PfuLogin  = replace( @Prefisso + pfunomeutente + '_' + pfuCognome   , ' ' , '_' ) from profiliutente where idpfu = @idPfu
		--set  @PfuLogin  = replace( @Prefisso + @pfunomeutente + '_' + @pfuCognome   , ' ' , '_' )
		update profiliutente set pfuLogin =@PfuLogin where idpfu = @idPfu 
	
	end		
	else
	begin

		-- verifichiamo se l'utente con stesso nominativo ha lo stesso codice fiscale, in questo caso si riferisce alla stessa persona e gli diamo la stessa login
		set @PrevUser  = 0
		select top 1 @PrevUser = b.idpfu
			from profiliutente as a with (nolock)

			inner join profiliutente  as b with (nolock) 
								on ( @PfuLogin = b.PfuLogin or b.PfuLogin like @PfuLogin + '[_]%' )
									and a.pfuCodiceFiscale = b.pfuCodiceFiscale
			where a.idpfu = @idPfu and b.idPfu <> @idPfu		
	
		--print @PrevUser
		
		if isnull( @PrevUser  , 0 ) > 0
		begin
			select  @PfuLogin  = pfuLogin from profiliutente with (nolock) where idpfu = @PrevUser
			update profiliutente set pfuLogin =@PfuLogin where idpfu = @idPfu 
		end
		else
		begin
			
			-- altrimenti l'utente che sto registrando ha un nuovo codice fiscale ma è un omonimo e quindi determino un progressivo
			select @Progr = count(*) from (
				select  b.pfuCodiceFiscale
					from profiliutente as a with (nolock)
----					inner join profiliutente  as b on a.pfuCognome = b.pfuCognome and a.pfunomeutente = b.pfunomeutente and a.pfuCodiceFiscale <> b.pfuCodiceFiscale
					--inner join profiliutente  as b on @pfuCognome = dbo.NormStringExt( b.pfuCognome , 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789' )
					--						and @pfunomeutente = dbo.NormStringExt( b.pfunomeutente , 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789' ) 
					inner join profiliutente  as b with (nolock) 
										on ( @PfuLogin = b.PfuLogin or b.PfuLogin like @PfuLogin + '[_]%' )
											and a.pfuCodiceFiscale <> b.pfuCodiceFiscale
					
					where a.idpfu = @idPfu and b.idPfu <> @idPfu
					group by b.pfuCodiceFiscale
			) as a
			
			set @Progr = @Progr + 1

			--select  @PfuLogin  = replace( @Prefisso + pfunomeutente + '_' + pfuCognome  , ' ' , '_' ) + '_' + cast( @Progr as varchar(10)) from profiliutente where idpfu = @idPfu
			set  @PfuLogin  = replace( isnull( @Prefisso , 'E_' ) + @pfunomeutente + '_' + @pfuCognome   , ' ' , '_' )  + '_' + cast( @Progr as varchar(10))

			update profiliutente set pfuLogin =@PfuLogin where idpfu = @idPfu 
		
		
		
		end
	end
	
end








GO
