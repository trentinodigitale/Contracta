USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DELTA_TED_AGGIUDICAZIONE_CREATE_FROM_LOTTI_DESERTI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[DELTA_TED_AGGIUDICAZIONE_CREATE_FROM_LOTTI_DESERTI] ( @idGara int , @IdUser int, @lotti varchar(max) = null )
AS
BEGIN 

	SET NOCOUNT ON

	-- questa stored viene chiamata da : 
	--	(chiusura amministrativa ) processo PDA_MICROLOTTI-VALUTAZIONE_LOTTI	step 190 ( Verifica e richiesta integrazione OCP - itero sui lotti deserti ed invoco la stored di istanzia documentazione con tipo 17 )
	-- verifica_chiusura_gare ( gare deserte )
	-- [PDA_GRADUATORIA_LOTTO] - lotti non giudicabili

	-- se sono necessari ragionamenti specifici per il giro 'DESERTI' applicarli qui e non nella stored generica


	-- Se la variabile @lotti è null vuol dire che si vogliono passare tutti i lotti, quindi li recuperiamo dalla microlotti dettagli
	IF @lotti is null
	BEGIN

		set @lotti = ''

		select @lotti =  @lotti + b.NumeroLotto + '@'
			from ctl_doc a with(nolock) 
					inner join Document_MicroLotti_Dettagli b with(nolock) on b.IdHeader = a.id and b.TipoDoc = a.TipoDoc and b.voce = 0
			where a.id = @idGara

	END

	declare @lotto varchar(10) = NULL

	DECLARE curs2 CURSOR FAST_FORWARD FOR
		select items from dbo.Split(@lotti, '@' )

	OPEN curs2
	FETCH NEXT FROM curs2 INTO @lotto

	WHILE @@FETCH_STATUS = 0   
	BEGIN  

		--Chiamiamo la stored base N volte, una per lotto. Questo per creare 1 documento per ogni lotto
		EXEC DELTA_TED_AGGIUDICAZIONE_CREATE_FROM_BANDO @idGara ,@IdUser , @lotto , 'DESERTI', 0 

		FETCH NEXT FROM curs2 INTO @lotto

	END  

	CLOSE curs2   
	DEALLOCATE curs2

END

GO
