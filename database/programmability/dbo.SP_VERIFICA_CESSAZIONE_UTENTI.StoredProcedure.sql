USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_VERIFICA_CESSAZIONE_UTENTI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SP_VERIFICA_CESSAZIONE_UTENTI]  (  @IdUser int , @idDoc int )
AS
BEGIN

	SET NOCOUNT ON;

	declare @DataUltimoCollegamento as datetime
	declare @jumpcheck as varchar(10)

	select @jumpcheck=JumpCheck from CTL_DOC with(nolock) where Id=@idDoc
	
	Select @DataUltimoCollegamento=value  
		from CTL_DOC_Value with(nolock) where idheader=@IdDoc 
			and DSE_ID='PARAMETRI' and dzt_name='DataUltimoCollegamento'	
	
	--SE SONO PRESENTI RIMUOVE NELLA CTL_DOC_VALUE I RECORD di una precedente verifica
	delete from CTL_DOC_VALUE where idHeader= @idDoc and DSE_ID in ( 'ESITI' ,'NUMERI')
	
	
	if @jumpcheck = 'OE'
	BEGIN
		insert into CTL_DOC_Value ( IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @idDoc,'ESITI',ROW_NUMBER() over (order by a.idpfu)-1,'IdPfu',a.idpfu
				from ProfiliUtente a with(nolock)
					inner join Aziende with(nolock) on IdAzi=pfuIdAzi and aziDeleted=0 and aziIdDscFormaSoc <> 845326  --RTI NO					
					where a.pfuDeleted=0 and ISNULL(a.pfuLastLogin,a.pfuDataCreazione) < @DataUltimoCollegamento	
						and a.pfuVenditore=1 and aziVenditore>0 and ISNULL(aziDataCreazione,'1900-01-01') <  @DataUltimoCollegamento
						--escludo utenti con profili di servizio
						and a.IdPfu > 0 
						and SUBSTRING(pfuFunzionalita,400,1)='0'

		insert into CTL_DOC_Value ( IdHeader,DSE_ID,Row,DZT_Name,Value )
			select @idDoc,'NUMERI',0,'NumRighe',COUNT(*)
				from ProfiliUtente with(nolock)
					inner join Aziende with(nolock) on IdAzi=pfuIdAzi and aziDeleted=0 and aziIdDscFormaSoc <> 845326  --RTI NO
					where pfuDeleted=0 and pfuVenditore=1 and aziVenditore>0

		
		insert into CTL_DOC_Value ( IdHeader,DSE_ID,Row,DZT_Name,Value )
			select @idDoc,'NUMERI',0,'NumRigheCessare',COUNT(*)
				from ProfiliUtente a with(nolock)
					inner join Aziende with(nolock) on IdAzi=pfuIdAzi and aziDeleted=0 and aziIdDscFormaSoc <> 845326  --RTI NO
					where pfuDeleted=0  and ISNULL(pfuLastLogin,a.pfuDataCreazione) < @DataUltimoCollegamento	
						and pfuVenditore=1 and aziVenditore>0 and ISNULL(aziDataCreazione,'1900-01-01') <  @DataUltimoCollegamento
						--escludo utenti con profili di servizio
						and a.IdPfu > 0 
						and SUBSTRING(pfuFunzionalita,400,1)='0'
		--PER UTENTI UNICI PER AZIENDA, AGGIUNGO UN CONTROLLO "per l'azienda 
		--non ci sono convenzione con stato diverso da chiuso"
		select value into #tmp
			from CTL_DOC_Value with(nolock)
				inner join ProfiliUtente a with(nolock) on a.idpfu=value
				left  join profiliutente  b with(nolock) on a.pfuidazi = b.pfuidazi and b.pfuDeleted = 0 and a.idpfu <> b.idpfu 
				inner join Document_Convenzione DC with(nolock) on DC.AZI_Dest=a.pfuIdAzi
				inner join ctl_doc C on C.id=DC.id and C.TipoDoc='CONVENZIONE' and c.StatoFunzionale = 'Pubblicato' and c.deleted = 0 and c.JumpCheck <> 'INTEGRAZIONE'
			where IdHeader=@idDoc and DSE_ID='ESITI' and DZT_Name='IdPfu'
				and b.IdPfu is null

		IF EXISTS ( select * from #tmp )
		BEGIN
			delete from CTL_DOC_Value where Value=(select Value from #tmp) and DSE_ID='ESITI' and IdHeader=@idDoc
			update CTL_DOC_Value set Value=cast(Value as int) - (select COUNT(*) from #tmp) where IdHeader=@idDoc and DSE_ID='NUMERI' and DZT_Name='NumRighe'
			update CTL_DOC_Value set Value=cast(Value as int) - (select COUNT(*) from #tmp) where IdHeader=@idDoc and DSE_ID='NUMERI' and DZT_Name='NumRigheCessare'
		END

		drop table #tmp 






		insert into CTL_DOC_Value ( IdHeader,DSE_ID,Row,DZT_Name,Value )
			select @idDoc,'NUMERI',0,'NumRigheCollegati',0
				


	END
	if @jumpcheck = 'ENTI'
	BEGIN
		insert into CTL_DOC_Value ( IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @idDoc,'ESITI',ROW_NUMBER() over (order by a.idpfu)-1,'IdPfu',a.idpfu
				from ProfiliUtente a with(nolock)
					inner join Aziende with(nolock) on IdAzi=pfuIdAzi and aziDeleted=0 and aziIdDscFormaSoc <> 845326  --RTI NO
					where pfuDeleted=0 and ISNULL(pfuLastLogin,a.pfuDataCreazione) < @DataUltimoCollegamento	
					and aziacquirente=3 and ISNULL(aziDataCreazione,'1900-01-01') <  @DataUltimoCollegamento
					--escludo utenti con profili di servizio
					and a.IdPfu > 0 
					and SUBSTRING(pfuFunzionalita,400,1)='0'
					

		 insert into CTL_DOC_Value ( IdHeader,DSE_ID,Row,DZT_Name,Value )
			select @idDoc,'NUMERI',0,'NumRighe',COUNT(*)
				from ProfiliUtente with(nolock)
					inner join Aziende with(nolock) on IdAzi=pfuIdAzi and aziDeleted=0 and aziIdDscFormaSoc <> 845326  --RTI NO
					where pfuDeleted=0 and aziacquirente=3 

		
		insert into CTL_DOC_Value ( IdHeader,DSE_ID,Row,DZT_Name,Value )
			select @idDoc,'NUMERI',0,'NumRigheCessare',COUNT(*)
				from ProfiliUtente a with(nolock)
					inner join Aziende with(nolock) on IdAzi=pfuIdAzi and aziDeleted=0 and aziIdDscFormaSoc <> 845326  --RTI NO
					where pfuDeleted=0 and ISNULL(pfuLastLogin,a.pfuDataCreazione) < @DataUltimoCollegamento	
					and aziacquirente=3 and ISNULL(aziDataCreazione,'1900-01-01') <  @DataUltimoCollegamento
					--escludo utenti con profili di servizio
					and a.IdPfu > 0 
					and SUBSTRING(pfuFunzionalita,400,1)='0'

		insert into CTL_DOC_Value ( IdHeader,DSE_ID,Row,DZT_Name,Value )
			select @idDoc,'NUMERI',0,'NumRigheCollegati',0
	END
END











				

GO
