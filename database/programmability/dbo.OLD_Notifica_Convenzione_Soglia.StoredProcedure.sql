USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_Notifica_Convenzione_Soglia]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[OLD_Notifica_Convenzione_Soglia] (@IdOrdinativo int ,@IdConv int )
AS
BEGIN 

	SET NOCOUNT ON

	declare @IdConvenzione as int
	declare @SogliaTemp as float
	declare @Impegnato as float
	declare @Importo as float
	declare @SogliaSuperata as float
	declare @IdRow as int
	declare @NuovaSogliaSuperata as int
	declare @IdPfu as int
	

	--se non ci sono soglie definite sulle convenzioni esco
	if not exists (select * from document_convenzione_parametri_soglie where deleted=0)
		return;
	
	--recupero id della convenzione
	if @IdConv is null
		select @IdConvenzione=linkeddoc from ctl_doc where id=@IdOrdinativo --and jumpcheck=''
	else
		set @IdConvenzione=@IdConv

	--recupero proprietario della convenzione
	select @IdPfu=idpfu from ctl_doc where id=@IdConvenzione

	--recupero i lotti della convenzione
	DECLARE crslotti CURSOR STATIC FOR 
	select idRow,Impegnato,Importo,isnull(SogliaSuperata,0) from document_convenzione_lotti where idheader=@IdConvenzione and isnull(Importo,0)>0			
	OPEN crslotti

	FETCH NEXT FROM crslotti INTO @IdRow,@Impegnato,@Importo,@SogliaSuperata
	WHILE @@FETCH_STATUS = 0
	BEGIN
			
		set @SogliaTemp = @Impegnato*100/@Importo

		--recupero la prima soglia superata	
		select @NuovaSogliaSuperata=isnull(min(soglia),0) from document_convenzione_parametri_soglie where deleted=0 and @SogliaTemp > soglia
			
			
		if @SogliaTemp > @SogliaSuperata
		begin
			
			--se la nuova soglia supera quella memorizzata
			--controllo se devo aggiornare la precedente soglia superata
			
			if @NuovaSogliaSuperata > @SogliaSuperata
			begin
				--memorizzo la nuova soglia
				update document_convenzione_lotti set SogliaSuperata=@NuovaSogliaSuperata, DataAlertSoglia = getdate() where idrow=@IdRow
				
				--metto a elaborate eventuali mail relative allo stesso lotto
				update CTL_Mail set state=1 where iddoc=@IdRow and typedoc in ('MAIL_CONVENZIONE_SOGLIA_SUPERATA','MAIL_CONVENZIONE_SOGLIA_REGREDITA')
				
				--inserisco una entrata per una nuova notifica di nuova soglia superata
				insert into CTL_Mail
				(IdDoc, IdUser, TypeDoc, State)
				values
				(@IdRow, @IdPfu, 'MAIL_CONVENZIONE_SOGLIA_SUPERATA', '0')	
			end

		end
		
		if @SogliaTemp < @SogliaSuperata
		begin
			
			--se la nuova soglia è inferiore a quella memorizzata
			--controllo se devo aggiornare la soglia superata con una più piccola
			
			if @NuovaSogliaSuperata < @SogliaSuperata
			begin
				
				--memorizzo la nuova soglia
				update document_convenzione_lotti set SogliaSuperata=@NuovaSogliaSuperata, DataAlertSoglia = getdate() where idrow=@IdRow
				
				--metto a elaborate eventuali mail relative allo stesso lotto
				update CTL_Mail set state=1 where iddoc=@IdRow and typedoc in ('MAIL_CONVENZIONE_SOGLIA_SUPERATA','MAIL_CONVENZIONE_SOGLIA_REGREDITA')
				
				--inserisco una entrata per una nuova notifica di nuova soglia regredita
				insert into CTL_Mail
				(IdDoc, IdUser, TypeDoc, State)
				values
				(@IdRow, @IdPfu, 'MAIL_CONVENZIONE_SOGLIA_REGREDITA', '0')	

			end

		end

		FETCH NEXT FROM crslotti INTO @IdRow,@Impegnato,@Importo,@SogliaSuperata
	END

	CLOSE crslotti 
	DEALLOCATE crslotti 	

	
	
END




GO
