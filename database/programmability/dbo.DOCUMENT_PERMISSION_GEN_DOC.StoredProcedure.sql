USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_PERMISSION_GEN_DOC]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO


---------------------------------------------------------------
--stored che controlla l'accessibilita ai documenti generici 
---------------------------------------------------------------

CREATE proc [dbo].[DOCUMENT_PERMISSION_GEN_DOC]( @idPfu   as int  , @idMsg as int  )
as
begin

	declare @msgiSubType	int
	declare @idAzi			int

	select @msgiSubType = msgiSubType  from TAB_MESSAGGI with(nolock)	where IdMsg = @idMsg
	select @idAzi = pfuIdAzi  from profiliutente with(nolock)	where idPfu = @idPfu

	-- il documento di gara è visibile anche dal portale
	if 	@msgiSubType = 167
	begin

        if exists(select * from ctl_approvalsteps inner join profiliutenteattrib 
				on idpfu=@idPfu and attvalue=aps_userprofile 
				and dztnome='UserRole' where APS_Doc_Type='APPROVAZIONE' and aps_id_doc=@idMsg)

			select 1 as bP_Read , 0 as bP_Write

		else

			select top 1  1 as bP_Read , case when tum.umIdPfu = @idPfu then 1 else 0 end as bP_Write
			from TAB_UTENTI_MESSAGGI tum with(nolock) 
				inner join tab_messaggi_fields TMF with(nolock)  on tum.umIdMsg = TMF.IdMsg
				inner join profiliutente p1 with(nolock)  on p1.idpfu = umIdPfu
			where   tum.umIdMsg = @idMsg
					and 
					(
						tum.umIdPfu = @idPfu 
						or  
						( p1.pfuidAzi = @idAzi and TMF.Stato = 2 )
						or 
						( TMF.TipoBando='3' and TMF.Stato = 2 )
					)
			order by bP_Write desc
		

	end
	else
	begin

		-- per i documenti che sono visibili solo da gli utenti della stessa azienda
		if @msgiSubType in ( 168 , 169 )
		begin

			select  top 1 1 as bP_Read , case when tum.umIdPfu = @idPfu then 1 else 0 end as bP_Write
				from TAB_UTENTI_MESSAGGI tum  with(nolock)
				where tum.umIdMsg = @idMsg
					and ( umIdPfu = -10 or umIdPfu = @idPfu )
				order by bP_Write desc

		end
		else
		begin
			
			-- per i documenti visibili dagli utenti della stessa azienda 
			-- oppure è un documento pubblicato
			-- oppure il proprietrio del documento
			select  top 1 1 as bP_Read , case when tum.umIdPfu = @idPfu then 1 else 0 end as bP_Write
				from TAB_UTENTI_MESSAGGI tum  with(nolock)
					inner join profiliutente p1 with(nolock)  on p1.idpfu = umIdPfu
				where tum.umIdMsg = @idMsg
					and ( umIdPfu = -10 or umIdPfu = @idPfu or p1.pfuidAzi = @idAzi )
				order by bP_Write desc

		end
	end

end

GO
