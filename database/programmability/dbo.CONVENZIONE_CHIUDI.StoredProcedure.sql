USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CONVENZIONE_CHIUDI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc [dbo].[CONVENZIONE_CHIUDI]( @id int , @Motivazione nvarchar(max)  , @Owner  int = -10   , @Profilo varchar(200) = '' ) as 
begin

	--declare  @id int
	--set @id = 62475--<ID_DOC>


	update Document_Convenzione set StatoConvenzione = 'Chiuso' where id = @id
	update ctl_doc set StatoFunzionale='Chiuso' where id = @id

	insert into CTL_ApprovalSteps 
				( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
		values ('CONVENZIONE' , @id , 'Chiusura' , @Motivazione , @Owner    , @Profilo       , 1         , getdate() )


	-- CHIUDE LE INTEGRAZIONI COLLEGATE
	update Document_Convenzione 
		set StatoConvenzione = 'Chiuso' 
		where id IN ( SELECT ID FROM ctl_doc with(nolock) where tipoDoc = 'CONVENZIONE' and deleted = 0 and JumpCheck = 'INTEGRAZIONE' and linkeddoc = @id and statofunzionale = 'Pubblicato' )

	update ctl_doc 
		set StatoFunzionale='Chiuso' 
		where id IN ( SELECT ID FROM ctl_doc with(nolock) where tipoDoc = 'CONVENZIONE' and deleted = 0 and JumpCheck = 'INTEGRAZIONE' and linkeddoc = @id and statofunzionale = 'Pubblicato' )

	insert into CTL_ApprovalSteps 
				( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
		select 'CONVENZIONE' , id , 'Chiusura' , @Motivazione , @Owner    ,  @Profilo       , 1         , getdate() 
			FROM ctl_doc with(nolock) where tipoDoc = 'CONVENZIONE' and deleted = 0 and JumpCheck = 'INTEGRAZIONE' and linkeddoc = @id and statofunzionale = 'Pubblicato'

end
GO
