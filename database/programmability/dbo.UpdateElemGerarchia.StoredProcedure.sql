USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[UpdateElemGerarchia]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--===============================
--	CODICE STRUTTURA	=
--===============================
CREATE PROCEDURE [dbo].[UpdateElemGerarchia]
  @IdTid int = 0,
  @CodiceInterno varchar(20) = null,
  @CodiceEsterno varchar(20) = null,
  @strLingue varchar(100) = null,
  @strDescs nvarchar(4000) = null
as
  SET NOCOUNT ON
  begin tran 
  declare @dgPath varchar(100)
  declare @dgLivello smallint
  declare @dgFoglia bit
  declare @dgLenPathPadre smallint
  declare @dgDeleted bit
  declare @NewdgIdDsc int
  declare @var_new_descsi nvarchar(1000)
  declare @var_new_descsE nvarchar(1000)
  declare @var_new_descsUK nvarchar(1000)
  declare @var_new_descsFRA nvarchar(1000)
  declare @var_new_descsLng1 nvarchar(1000)
  declare @var_new_descsLng2 nvarchar(1000)
  declare @var_new_descsLng3 nvarchar(1000)
  declare @var_new_descsLng4 nvarchar(1000)
  declare @Var_Scomp_I nvarchar(1000)  
  declare @Var_Scomp_E nvarchar(1000)  
  declare @Var_Scomp_UK nvarchar(1000)  
  declare @Var_Scomp_FRA nvarchar(1000) 
  declare @Var_Scomp_Lng1 nvarchar(1000)  
  declare @Var_Scomp_Lng2 nvarchar(1000)  
  declare @Var_Scomp_Lng3 nvarchar(1000)  
  declare @Var_Scomp_Lng4 nvarchar(1000)  
 	
  declare @var_descsx int
   --Dichiarazioni Variabili scompattamento
   declare @pos int
   declare @pos2 int
   declare @substrDescs varchar(400)
   declare @substrLingue varchar(20)
   declare @TempstrLingue varchar(100)
   declare @TempstrDescs nvarchar(4000)
   set @TempstrLingue = @strLingue
   set @TempstrDescs = @strDescs
   --Controllo Parametri Passati alla SP
   if (@idTid = 0) or (@CodiceInterno is null) or 
      (@CodiceEsterno is null) or (@strLingue is null) or 
      (@strDescs is null) 
		   		begin
					Raiserror ('Errore nella procedura "UpdateElemGerarchia" Verifica passaggio parametri',16,1)  
					rollback tran 
					return (99)
		                end 		
				
   --Controllo Esistenza Nodo con parametri passati 
   if not exists (select * 
		  from dominigerarchici 
		  where dgCodiceInterno = @CodiceInterno and 
			dgTipoGerarchia = @idTid and dgdeleted = 0 			
		 )
   							begin
								raiserror ('Errore nella procedura "UpdateElemGerarchia" Verifica esistenza nodo',16,1) 
								rollback tran
								return (99)
							end 
   --Scompattamento stringa
      	
   while @strLingue <> '' and @strDescs<>''   begin
      set @Pos = PATINDEX('%#~%', @strDescs)
      set @substrDescs = left (@strDescs, @Pos - 1) -- Estrazione della funzionalita
      set @strDescs = substring(@strDescs, @Pos + 2, len(@strDescs)- @Pos)  --riduzione della string delle funzionalita
      set @Pos2 = PATINDEX('%#~%', @strLingue)
      set @substrLingue = left (@strLingue, @Pos2 - 1) -- Estrazione della funzionalita
      set @strLingue = substring(@strLingue, @Pos2 + 2, len(@strLingue)- @Pos2)  --riduzione della string delle funzionalita
      if @substrLingue='I'	begin
					    set @Var_Scomp_I  = @substrDescs
					    
				end
      if @substrLingue='UK'
				begin
					    set @var_Scomp_UK = @substrDescs	
				end
      if @substrLingue='E'
				begin
					    set @var_Scomp_E = @substrDescs	
				end	 
      if @substrLingue='FRA'
				begin
					    set @var_Scomp_FRA = @substrDescs	
				end
      if @substrLingue='Lng1'
				begin
					    set @var_Scomp_Lng1 = @substrDescs	
				end
      if @substrLingue='Lng2'
				begin
					    set @var_Scomp_Lng2 = @substrDescs	
				end
      if @substrLingue='Lng3'
				begin
					    set @var_Scomp_Lng3 = @substrDescs	
				end
      if @substrLingue='Lng4'
				begin
					    set @var_Scomp_Lng4 = @substrDescs	
				end
     end --while
     if @strLingue<>'' or @strDescs<>''	
				begin --errore formattazione stringhe
                  					raiserror ('Errore UpdateElemGerarchia ', 16, 1) 
                  					rollback tran
                  					return 99
				end  
   --Resetta le variabili utilizzate nello scompattamento 
   set @pos  = 0
   set @pos2 = 0
   set @substrDescs = ''
   set @substrLingue = ''
   set @strLingue=@TempstrLingue
   set @strDescs=@TempstrDescs
   
   --Verifica esistenza Nodo
   if not exists (select * from dominigerarchici dom 
		  where dgCodiceInterno = @CodiceInterno and dgTipoGerarchia = @idTid and dgdeleted = 0) 			
					begin
					  raiserror ('Errore procedura "UpdateElemGerarchia" Nodo Inesistente',16,1) 
					  rollback tran 
					  return(99)
					end	
   
   select @var_descsx=iddsc
   from descsi, DominiGerarchici
   where dgIdDsc = IdDsc 
     and dgDeleted = 0
     and dgCodiceInterno = @CodiceInterno 
     and dgTipoGerarchia = @idTid
   
				begin
					  update dominigerarchici 
					  set dgCodiceEsterno = @CodiceEsterno,
					        dgultimamod = getdate()	
					  where dgCodiceInterno = @CodiceInterno and 
					        dgTipoGerarchia = @idTid and dgdeleted = 0 							
					  if @@error <> 0
   							begin
								raiserror ('Errore procedura "UpdateElemGerarchia" Update su Nodo con descrittiva esistente',16,1) 
								rollback tran
								return (99)
							end 
                                          -- Aggiornamento lingua italiana
					update descsi
 					set dsctesto = @var_scomp_i
					where iddsc = @var_descsx
				        if @@error <> 0	
							begin
							   raiserror ('Errore procedura "UpdateElemGerarchia" Update su Descsi',16,1) 
							   rollback tran
							   return 99
							end
                          
					  --Aggiornamento su diverse descrittive se esistenti e diverse 
					  	
					  --DescsUK
					  select @var_new_descsUK = duk.dsctesto
					  from descsuk duk
					  where iddsc = @var_descsx 
					  --Controllo Esistenza in DescsUK	 	
	 			          if (@@rowcount = 0)
										begin
										  raiserror ('Errore procedura "UpdateElemGerarchia" DescsUk Inesistente',16,1) 
										  rollback tran 
										  return(99)
										end	
					
					  
					  if cast(@var_new_descsUK as binary) <> cast (cast(@var_scomp_uk as nvarchar(100)) as binary) 	   	
											begin
												update descsuk
												set dsctesto = @var_scomp_uk
												where iddsc = @var_descsx
											        if @@error <> 0	
														begin
														   raiserror ('Errore procedura "UpdateElemGerarchia" Update su Descsuk',16,1) 
														   rollback tran
														   return 99
														end
											end		
					  --DescsE
					  	 							
					  select @var_new_descsE = de.dsctesto
					  from descse de 
					  where iddsc = @var_descsx
					  if (@@rowcount = 0)
										begin
										  raiserror ('Errore procedura "UpdateElemGerarchia" DescsE Inesistente',16,1) 
										  rollback tran 
										  return(99)
										end							  	
					  if cast(@var_new_descsE as binary) <> cast (cast(@var_scomp_E as nvarchar(100)) as binary) 	   	
											begin
												update descsE
												set dsctesto = @var_scomp_E
												where iddsc = @var_descsx
											        if @@error <> 0	
														begin
														   raiserror ('Errore procedura "UpdateElemGerarchia" Update su DescsE',16,1) 
														   rollback tran
														   return 99
														end
											end				
					  --DescsFRA
					  
  					  select @var_new_descsFRA = dfra.dsctesto
					  from descsfra dfra
					  where iddsc = @var_descsx
					  if (@@rowcount = 0)
										begin
										  raiserror ('Errore procedura "UpdateElemGerarchia" DescsFRA Inesistente',16,1) 
										  rollback tran 
										  return(99)
										end		
					  if cast(@var_new_descsFRA as binary) <> cast (cast(@var_scomp_FRA as nvarchar(100)) as binary) 	   	
											begin
												update descsFRA
												set dsctesto = @var_scomp_FRA
												where iddsc = @var_descsx
											        if @@error <> 0	
														begin
														   raiserror ('Errore procedure "UpdateElemGerarchia" Update su descsFRA',16,1) 
														   rollback tran
														   return 99
														end
											end					
					  --DescsLng1
					  if exists (select * from lingue where lngsuffisso = 'Lng1' and lngdeleted = 0)	
							begin
							  select @var_new_descsLng1 = duk.dsctesto
							  from descslng1 duk
							  where iddsc = @var_descsx 
							  --Controllo Esistenza in DescsLng1	 	
			 			          if (@@rowcount = 0)
										begin
										  raiserror ('Errore procedura "UpdateElemGerarchia" DescsLng1 Inesistente',16,1) 
										  rollback tran 
										  return(99)
										end	
					
					  
							  if cast(@var_new_descsLng1 as binary) <> cast (cast(@var_scomp_Lng1 as nvarchar(100)) as binary) 	   	
											begin
												update descsLng1
												set dsctesto = @var_scomp_Lng1
												where iddsc = @var_descsx
											        if @@error <> 0	
														begin
														   raiserror ('Errore procedura "UpdateElemGerarchia" Update su DescsLng1',16,1) 
														   rollback tran
														   return 99
																	end
											end
							end
					  --DescsLng2
					  if exists (select * from lingue where lngsuffisso = 'Lng2' and lngdeleted = 0)		
						begin
							  select @var_new_descsLng2 = duk.dsctesto
							  from descsLng2 duk
							  where iddsc = @var_descsx 
							  --Controllo Esistenza in DescsLng2	 	
	 					          if (@@rowcount = 0)
										begin
										  raiserror ('Errore procedura "UpdateElemGerarchia" DescsLng2 Inesistente',16,1) 
										  rollback tran 
										  return(99)
										end	
					
					  
							  if cast(@var_new_descsLng2 as binary) <> cast (cast(@var_scomp_Lng2 as nvarchar(100)) as binary) 	   	
											begin
												update descsLng2
												set dsctesto = @var_scomp_Lng2
												where iddsc = @var_descsx
											        if @@error <> 0	
														begin
														   raiserror ('Errore procedura "UpdateElemGerarchia" Update su DescsLng2',16,1) 
														   rollback tran
														   return 99
														end
											end
						end
					  --DescsLng3
					  if exists (select * from lingue where lngsuffisso = 'Lng3' and lngdeleted = 0)		
							begin
								  select @var_new_descsLng3 = duk.dsctesto
								  from descsLng3 duk
								  where iddsc = @var_descsx 
								  --Controllo Esistenza in DescsLng3	 	
				 			          if (@@rowcount = 0)
										begin
										  raiserror ('Errore procedura "UpdateElemGerarchia" DescsLng3 Inesistente',16,1) 
										  rollback tran 
										  return(99)
										end	
					
					  
					  if cast(@var_new_descsLng3 as binary) <> cast (cast(@var_scomp_Lng3 as nvarchar(100)) as binary) 	   	
											begin
												update descsLng3
												set dsctesto = @var_scomp_Lng3
												where iddsc = @var_descsx
											        if @@error <> 0	
														begin
														   raiserror ('Errore procedura "UpdateElemGerarchia" Update su DescsLng3',16,1) 
														   rollback tran
														   return 99
														end
											end
							end
					  --DescsLng4
					  if exists (select * from lingue where lngsuffisso = 'Lng4' and lngdeleted = 0)		
							begin
								  select @var_new_descsLng4 = duk.dsctesto
								  from descsLng4 duk
								  where iddsc = @var_descsx 
								  --Controllo Esistenza in DescsLng4	 	
				 			          if (@@rowcount = 0)
										begin
										  raiserror ('Errore procedura "UpdateElemGerarchia" DescsLng4 Inesistente',16,1) 
										  rollback tran 
										  return(99)
										end	
					
					  
								  if cast(@var_new_descsLng4 as binary) <> cast (cast(@var_scomp_Lng4 as nvarchar(100)) as binary) 	   	
											begin
												update descsLng4
												set dsctesto = @var_scomp_Lng4
												where iddsc = @var_descsx
											        if @@error <> 0	
														begin
														   raiserror ('Errore procedura "UpdateElemGerarchia" Update su DescsLng4',16,1) 
														   rollback tran
														   return 99
														end
											end	
						end
				end
commit tran
GO
