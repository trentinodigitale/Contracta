USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CTL_GetNewProtocol]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE proc [dbo].[CTL_GetNewProtocol] ( @DOC varchar(30) , @Plant VARCHAR(200)  , @Prot as varchar(50) output )
--RETURNS VARCHAR(200)
AS
BEGIN 
 	set nocount on

	declare @max varchar(20)
	declare @last int
	declare @id int
	declare @CAR_Plant varchar(20)
	declare @BaseProt varchar(20)

	declare @SQL varchar(2000)
	declare @ambito as varchar(10)
	declare @PrefissoCodifica as varchar(10)

	--recupero la plant
	set @max = ''

	---PER LA CODIFCA DEI PRODOTTI

	if  left(@DOC,16) = 'PRODOTTO_AMBITO_'  
	BEGIN
		

		set @ambito=right(@DOC,1)
		set @id = -1
		
		select @id = id from CTL_Counters where idAzi = 0 and Plant = '' and Name = @DOC and Altro = ''
			
		if @id = -1 
		begin
			insert into CTL_Counters  ( idAzi , Plant , Name , Period , Altro , Counter ) 
								values( 0     , '' , @DOC, right( cast( year(getdate()) as varchar ) , 2 ) , '' , 1 )
			set @max =  '000000001'
		end
		else
		begin		
			--print 'ENTRO2'
			update CTL_Counters set Counter = Counter  + 1
				where id = @id
				
			select @last = counter from CTL_Counters where id = @id
				
			set @max =  right( '000000000' + cast( @last as varchar(9) ) , 9)			

		end

		--if @ambito='1'   ---FARMACI
		--BEGIN	
				
		--	set @max = @max 
		--END
		if @ambito='2'  --CND
		BEGIN
			set @max='D' + right( @max , 8 ) 
		END
		if @ambito='3'  --ALTRI BENI
		BEGIN			
			set @max='B' + right( @max	,8 )
		END
		if @ambito='4'  --SERVIZI
		BEGIN
			set @max='S' + right( @max , 8 ) 
		END

		set @Prot = @max
		

	END
	else	if ( left(@DOC,17) = 'CODIFICA_PRODOTTI' )
	BEGIN
		--print 'ENTRO1'

		set @ambito=substring(@DOC,21,len(@DOC))
		set @id = -1
		
		select @id = id from CTL_Counters where idAzi = 0 and Plant = '' and Name = @DOC and Altro = ''
			
		if @id = -1 
		begin
			insert into CTL_Counters  ( idAzi , Plant , Name , Period , Altro , Counter ) 
								values( 0     , '' , @DOC, right( cast( year(getdate()) as varchar ) , 2 ) , '' , 1 )
			set @max =  '0000001'
		end
		else
		begin		
			--print 'ENTRO2'
			update CTL_Counters set Counter = Counter  + 1
				where id = @id
				
			select @last = counter from CTL_Counters where id = @id
				
			set @max =  right( '0000000' + cast( @last as varchar(7) ) , 7 )			

		end

		--ricavo il prefisso da utilizzare da una relazione
		--se non presente uso i default
		set @PrefissoCodifica = ''
		select 
			@PrefissoCodifica = isnull(REL_ValueOutput,'') 
			from
				CTL_Relations with (nolock)
			where
				rel_type='PREFIX_FOR_CODIFICA_PRODOTTI' and REL_ValueInput = @ambito


		if @ambito='1'   ---FARMACI
		BEGIN	
			--print 'ENTRO3'	
			if @PrefissoCodifica = ''
				set @PrefissoCodifica = 'BF'
			--set @max='BF' + @max
		END
		if @ambito='2'  --CND
		BEGIN
			--set @max='BD' + @max
			if @PrefissoCodifica = ''
				set @PrefissoCodifica = 'BD'
		END
		if @ambito='3'  --ALTRI BENI
		BEGIN			
			--set @max='BB' + @max		
			if @PrefissoCodifica = ''
				set @PrefissoCodifica = 'BB'
		END
		if @ambito='4'  --SERVIZI
		BEGIN
			--set @max='BS' + @max
			if @PrefissoCodifica = ''
				set @PrefissoCodifica = 'BS'
		END

		set @max= @PrefissoCodifica + @max

		set @Prot = @max

		return

	END
	else

	if @DOC = 'CONVENZIONE' 
		begin

			set @id = -1
			select @id = id
					from CTL_Counters 
					where idAzi = 0 and 
							Plant = '' and
							CTL_Counters.Name = @DOC and
							--Period = right( cast( year(getdate()) as varchar ) , 2 ) and 
							Altro = ''

			if @id = -1 
			begin
				insert into CTL_Counters  ( idAzi , Plant , Name , Period , Altro , Counter ) 
									values( 0     , '' , @DOC, right( cast( year(getdate()) as varchar ) , 2 ) , '' , 1 )
				set @max =  '00000001'
			end
			else
			begin		

				update CTL_Counters set Counter = Counter  + 1
					where id = @id
				
				select @last = counter from CTL_Counters where id = @id
				
				set @max =  right( '00000000' + cast( @last as varchar(8) ) , 8 )
				

			end

		end
	else

	if @DOC in (  'NumOrd' )-- BOLLA
		begin

			set @id = -1
			select @id = id
					from CTL_Counters 
					where idAzi = 0 and 
							Plant = '' and
							CTL_Counters.Name = @DOC and
							Period = right( cast( year(getdate()) as varchar ) , 2 ) and 
							Altro = ''

			if @id = -1 
			begin
				insert into CTL_Counters  ( idAzi , Plant , Name , Period , Altro , Counter ) 
									values( 0     , '' , @DOC, right( cast( year(getdate()) as varchar ) , 2 ) , '' , 1 )
				set @max =  right( cast( year(getdate()) as varchar ) , 2 ) + '000001'
			end
			else
			begin		

				update CTL_Counters set Counter = Counter  + 1
					where id = @id
				
				select @last = counter from CTL_Counters where id = @id
				set @max =  right( cast( year(getdate()) as varchar ) , 2 ) + right( '000000' + cast( @last as varchar(6) ) , 6 )

			end

		end
	else
	if @DOC in ( 'ODA' )
		begin

			set @id = -1
			select @id = id
					from CTL_Counters 
					where idAzi = 0 and 
							Plant = '' and
							CTL_Counters.Name = @DOC and
							Period = right( cast( year(getdate()) as varchar ) , 2 ) and 
							Altro = ''

			if @id = -1 
			begin
				insert into CTL_Counters  ( idAzi , Plant , Name , Period , Altro , Counter ) 
									values( 0     , '' , @DOC, right( cast( year(getdate()) as varchar ) , 2 ) , '' , 1 )
				set @max = '000001' + '-' + right( cast( year(getdate()) as varchar ) , 2 )
				-- set @max = right( cast( year(getdate()) as varchar ) , 2 ) + '000001'
			end
			else
			begin		

				update CTL_Counters set Counter = Counter + 1
					where id = @id
				
				select @last = counter from CTL_Counters where id = @id
				set @max = right( '000000' + cast( @last as varchar(6)),6) + '-' +  right( cast( year(getdate()) as varchar ) , 2 ) 
				--set @max = right( cast( year(getdate()) as varchar ) , 2 ) + '-' + right( '000000' + cast( @last as varchar(2) ) , 2 )

			end

		end
	else
	if @DOC = 'GEM' -- BOLLA
		begin

			set @id = -1
			select @id = id
					from CTL_Counters 
					where idAzi = 0 and 
							Plant = '' and
							CTL_Counters.Name = @DOC and
							Period = right( cast( year(getdate()) as varchar ) , 2 ) and 
							Altro = ''

			if @id = -1 
			begin
				insert into CTL_Counters  ( idAzi , Plant , Name , Period , Altro , Counter ) 
									values( 0     , '' , @DOC, right( cast( year(getdate()) as varchar ) , 2 ) , '' , 1 )
				set @max = 'C' + right( cast( year(getdate()) as varchar ) , 2 ) + '000001'
			end
			else
			begin		

				update CTL_Counters set Counter = Counter  + 1
					where id = @id
				
				select @last = counter from CTL_Counters where id = @id
				set @max = 'C' + right( cast( year(getdate()) as varchar ) , 2 ) + right( '000000' + cast( @last as varchar(6) ) , 6 )

			end

		end
	else
	if @DOC = 'GEM_ROW' -- Riga BOLLA
		begin

			set @id = -1
			select @id = id
					from CTL_Counters 
					where idAzi = 0 and 
							Plant = '' and
							CTL_Counters.Name = @DOC and
							Period = '' and 
							Altro = ''

			if @id = -1 
			begin
				insert into CTL_Counters  ( idAzi , Plant , Name , Period , Altro , Counter ) 
									values( 0     , '' , @DOC, '' , '' , 1 )
				set @max = 'C' +  '00000001'
			end
			else
			begin		

				update CTL_Counters set Counter = Counter  + 1
					where id = @id
				
				select @last = counter from CTL_Counters where id = @id
				set @max = 'C' +  right( '00000000' + cast( @last as varchar(8) ) , 8 )

			end

		end
	else
	if @DOC in (  'PREGARA' )
		begin

			set @id = -1
			select @id = id
					from CTL_Counters 
					where idAzi = 0 and 
							Plant = '' and
							CTL_Counters.Name = @DOC and
							Period = cast( year(getdate()) as varchar )  and 
							Altro = ''

			if @id = -1 
			begin
				insert into CTL_Counters  ( idAzi , Plant , Name , Period , Altro , Counter ) 
									values( 0     , '' , @DOC,  cast( year(getdate()) as varchar )   , '' , 1 )
				set @max = @Plant +  '001-' + cast( year(getdate()) as varchar )
			end
			else
			begin		

				update CTL_Counters set Counter = Counter  + 1
					where id = @id
				
				select @last = counter from CTL_Counters where id = @id
				set @max = @Plant +  right( '00000000' + cast( @last as varchar(3) ) ,3 ) + '-' +  cast( year(getdate()) as varchar )

			end

		end

	else if @DOC='PRATICA'
	begin
		set @id = -1
		select @id = id
			from CTL_Counters 
			where idAzi = 0 and 
				Plant = '' and
				CTL_Counters.Name = @DOC and
				Period = cast( year(getdate()) as varchar )  and 
				Altro = ''

		if @id = -1 
		begin
			insert into CTL_Counters  ( idAzi , Plant , Name , Period , Altro , Counter ) 
								values( 0     , '' , @DOC,  cast( year(getdate()) as varchar )   , '' , 1 )
			set @max = '001-' + cast( year(getdate()) as varchar )
		end
		else
		begin		

			update CTL_Counters set Counter = Counter  + 1
				where id = @id
				
			select @last = counter from CTL_Counters where id = @id
			set @max =   right( '00000000' + cast( @last as varchar(3) ) ,3 ) + '-' +  cast( year(getdate()) as varchar )

		end
	end 
	else
		begin

			set @CAR_Plant = ''	
			select @CAR_Plant = left( rel_valueoutput ,2 ) from ctl_relations where rel_type = 'SediDest_Plant' and rel_valueinput = @Plant
			if @CAR_Plant = ''
			begin 
				set @CAR_Plant = 'CA'
			end

			set @BaseProt = @DOC + @CAR_Plant + right( cast( year(getdate()) as varchar ) , 2 )


			set @id = -1
			select @id = id
					from CTL_Counters 
					where idAzi = 0 and 
							Plant = @Plant and
							CTL_Counters.Name = @DOC and
							Period = right( cast( year(getdate()) as varchar ) , 2 ) and 
							Altro = ''

			if @id = -1 
			begin
				insert into CTL_Counters  ( idAzi , Plant , Name , Period , Altro , Counter ) 
									values( 0     , @Plant , @DOC, right( cast( year(getdate()) as varchar ) , 2 ) , '' , 1 )
				set @max = @BaseProt + '000001'
			end
			else
			begin		

				update CTL_Counters set Counter = Counter  + 1
					where id = @id
				
				select @last = counter from CTL_Counters where id = @id
				set @max = @BaseProt + right( '000000' + cast( @last as varchar(6) ) , 6 )

			end
		end

	-- Modulo Iniziative
	if @DOC = 'INIZIATIVE'
		begin

			set @id = -1
			select @id = id
					from CTL_Counters 
					where idAzi = 0 and 
							Plant = '' and
							CTL_Counters.Name = @DOC and
							--Period = right( cast( year(getdate()) as varchar ) , 2 ) and 
							Altro = ''
			
			if @id = -1 
			begin
				insert into CTL_Counters  ( idAzi , Plant , Name , Period , Altro , Counter ) 
									values( 0     , '' , @DOC, right( cast( year(getdate()) as varchar ) , 2 ) , '' , 1 )
				set @max =  'I0001'
			end
			else
			begin		

				update CTL_Counters set Counter = Counter  + 1
					where id = @id
				
				select @last = counter from CTL_Counters where id = @id
				
				set @max =  'I' + (right( '0000' + cast( @last as varchar(4) ) , 4 ))
				

			end

		end

	-- Risposta Concorso
	--if @DOC = 'RISPOSTA_CONCORSO'
	--	begin

	--		set @id = -1
	--		select @id = id
	--				from CTL_Counters 
	--				where idAzi = 0 and
	--						Plant = '' and
	--						CTL_Counters.Name = @DOC and
	--						--Period = right( cast( year(getdate()) as varchar ) , 2 ) and 
	--						Altro = ''
			
	--		if @id = -1 
	--		begin
	--			insert into CTL_Counters  ( idAzi , Plant , Name , Period , Altro , Counter ) 
	--								values( 0     , '' , @DOC, right( cast( year(getdate()) as varchar ) , 2 ) , '' , 1 )
	--			set @max =  'R0001'
	--		end
	--		else
	--		begin		

	--			update CTL_Counters set Counter = Counter  + 1
	--				where id = @id
				
	--			select @last = counter from CTL_Counters where id = @id
				
	--			set @max =  'R' + (right( '0000' + cast( @last as varchar(4) ) , 4 ))
				

	--		end

	--	end


	set nocount off
	
	--print @max
	set @Prot = @max

END




GO
