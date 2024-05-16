USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[UpdateMpModAttr]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--===============================
--	CODICE STRUTTURA	=
--===============================
/*
Autore: Alfano Antonio
Scopo: Aggiornamento MpModelliAttributi
Data: 05/09/2001
*/
CREATE PROCEDURE [dbo].[UpdateMpModAttr] (@IdDoc int,@IdMp int, @IdMdlAtt int,  @mpmaRegObblig bit, @mpmaValoreDef varchar(50) , @mpmaPesoDef int, @mpmaIdFva int, @mpmaIdUmsDef int, @mpmaLocked bit, @mpmaShadow bit,@mpmaOpzioni varchar(20),@mpmaOper varchar(20),@strMpacIddzt varchar(500), @strMpacValue varchar(500),@idMpModNew  int OUTPUT,@IdDocNew int OUTPUT) AS
begin
declare @mpmaIdMpModNew int -- IdMpMod  temporaneo nel caso di copia
declare @mpmaIdMpMod int  -- IdMpMod
declare @DocIdMpMod int -- IdMpMod del documento
declare @mpmaIdDzt int -- IdDzt
declare @IdMpCorr1 int -- IdMp vecchio
--var per il cursore
declare @IdMpMod int --id del modello
declare @mpmaIdMpMod_c int
declare @mpmaIdDzt_c int
declare @mpmaRegObblig_c bit
declare @mpmaOrdine_c int
declare @mpmaValoreDef_c varchar(50)
declare @mpmaPesoDef_c int
declare @mpmaIdFva_c int
declare @mpmaIdUmsDef_c int
declare @mpmaLocked_c bit
declare @mpmaShadow_c bit
declare @mpmaOpzioni_c varchar(50)
declare @IdMdlAttOld int
declare @IdMdlAttNew int
declare @mpmaOper_c varchar(20)
--per MpacIddzt 
declare @pos int
declare @MpacIddzt int
declare @subMpacIddzt varchar(10)
--per MpacValue 
declare @pos2 int
declare @MpacValue varchar(30)
begin tran
set nocount on
set @IdDocNew=@IdDoc
 -- not (entrambe vuote o entrambe piene)
if not ((@strMpacIddzt<>'' and  @strMpacValue  <>'') or ( @strMpacIddzt='' and  @strMpacValue=''))	begin
	            		raiserror ('Errore formattazione stringhe  (UpdateMpModAttr) ', 16, 1) 
                  		rollback tran
                  		return 99
													end 
--selezione idMpMod del modello del documento
select @DocIdMpMod=DocIdMpMod from Mpdocumenti
where IdDoc=@IdDoc and docDeleted=0
if @DocIdMpMod is Null 		begin
				raiserror ('Errore record inesistente(UpdateMpModAttr) ', 16, 1) 
                  		rollback tran
                  		return 99
				end
--Seleziona IdMpMod MPModelliAttributi 
select @mpmaIdMpMod=mpmaIdMpMod, @mpmaIdDzt=mpmaIdDzt from MPModelliAttributi
where IdMdlAtt=@IdMdlAtt and mpmaDeleted=0
set @idMpModNew=@mpmaIdMpMod
set @IdMpMod=@mpmaIdMpMod
if @mpmaIdMpMod is Null 	begin
				raiserror ('Errore record inesistente(UpdateMpModAttr) ', 16, 1) 
                  		rollback tran
                  		return 99
				end
--consistenza del modello
if @DocIdMpMod<>@mpmaIdMpMod	begin
				raiserror ('Errore modello inconsistente(UpdateMpModAttr) ', 16, 1) 
                  		rollback tran
                  		return 99
				end
--IdMp da MPModelli
select @IdMpCorr1=mpmIdMp from MPModelli
where IdMpMod=@mpmaIdMpMod and mpmDeleted=0
if @IdMpCorr1 is Null	 	begin
				raiserror ('Errore record modello inesistente(UpdateMpModAttr) ', 16, 1) 
                  		rollback tran
                  		return 99
				end
--Assiomi
if @IdMp=0		begin
			if @IdMpCorr1<>0	begin
						raiserror ('Errore MP  incosistenti  (UpdateMpModAttr) ', 16, 1) 
                	  			rollback tran
                  				return 99
						end
			end
			else	begin
			if @IdMp<>@IdMpCorr1 and not @IdMpCorr1=0	begin
									raiserror ('Errore MP  incosistenti  (UpdateMpModAttr) ', 16, 1) 
	                  						rollback tran
                	  						return 99			
									end
			end
--verifica MP e copia
if @IdMpCorr1<>@IdMp and @IdMpCorr1=0 	begin  --ifc
					--copia record MPModelli
					insert into MPModelli(mpmIdMp,mpmDesc,mpmTipo)
					select @IdMp,mpmDesc,mpmTipo from MPModelli
					where IdMpMod=@mpmaIdMpMod
					if @@error <> 0	begin
                  					raiserror ('Errore insert MPModelli (UpdateMpModAttr) ', 16, 1) 
                  					rollback tran
                  					return 99
             						end
					set @mpmaIdMpModNew=@@identity
					set @idMpModNew=@mpmaIdMpModNew
					--copia record MpDocumenti
					insert into MpDocumenti(docIdMp,docItype,docPath,docIdMpMod,docISubType,docIsReplicable)
					select @IdMp,docItype,docPath,@mpmaIdMpModNew,docISubType,docIsReplicable from MpDocumenti
					where IdDoc=@IdDoc --docIdMpMod=@mpmaIdMpMod and docDeleted=0 --and docIdMp=@IdMpCorr1 
					if @@error <> 0 begin
                  					raiserror ('Errore insert MpDocumenti  (UpdateMpModAttr) ', 16, 1) 
                  					rollback tran
                  					return 99
             						end
					set @IdDocNew=@@identity
					/********/
					--cursore per la copia degli attributicontrolli 
					--copia record MPModelliAttributi
					declare crsMpModAtt cursor static for 	select IdMdlAtt,mpmaIdMpMod,mpmaIdDzt,mpmaRegObblig,mpmaOrdine,mpmaValoreDef,mpmaPesoDef,mpmaIdFva,mpmaIdUmsDef,mpmaLocked,mpmaShadow,mpmaOpzioni,mpmaOper from MPModelliAttributi
									where mpmaIdMpMod=@IdMpMod and mpmaDeleted=0
           
					open crsMpModAtt
					fetch next from crsMpModAtt into @IdMdlAttOld,@mpmaIdMpMod_c,@mpmaIdDzt_c,@mpmaRegObblig_c,@mpmaOrdine_c,@mpmaValoreDef_c,@mpmaPesoDef_c,@mpmaIdFva_c,@mpmaIdUmsDef_c,@mpmaLocked_c,@mpmaShadow_c,@mpmaOpzioni_c,@mpmaOper_c
					while @@fetch_status = 0  --Whileb
						begin
						insert into MPModelliAttributi(mpmaIdMpMod,mpmaIdDzt,mpmaRegObblig,mpmaOrdine,mpmaValoreDef,mpmaPesoDef,mpmaIdFva,mpmaIdUmsDef,mpmaLocked,mpmaShadow,mpmaOpzioni,mpmaOper)
						values(@mpmaIdMpModNew,@mpmaIdDzt_c,@mpmaRegObblig_c,@mpmaOrdine_c,@mpmaValoreDef_c,@mpmaPesoDef_c,@mpmaIdFva_c,@mpmaIdUmsDef_c,@mpmaLocked_c,@mpmaShadow_c,@mpmaOpzioni_c,@mpmaOper_c)
						if @@error <> 0 begin
                  						raiserror ('Errore insert MPModelliAttributi  (InsertMpModAttr) ', 16, 1) 
                  						rollback tran
								close crsMpModAtt
								deallocate crsMpModAtt
                  						return 99
             							end
						set  @IdMdlAttNew=@@identity
						--MpAttributiControlli
						insert into MpAttributiControlli(mpacIdMdlAtt,mpacIddzt,mpacValue) 
						select @IdMdlAttNew,mpacIddzt,mpacValue from MpAttributiControlli 
						where mpacIdMdlAtt=@IdMdlAttOld and mpacDeleted=0
						if @@error <> 0 begin
                  						raiserror ('Errore insert MpAttributiControlli (UpdateMpModAttr) ', 16, 1) 
                  						rollback tran
								close crsMpModAtt
								deallocate crsMpModAtt
                  						return 99
             							end
						fetch next from crsMpModAtt into @IdMdlAttOld,@mpmaIdMpMod_c,@mpmaIdDzt_c,@mpmaRegObblig_c,@mpmaOrdine_c,@mpmaValoreDef_c,@mpmaPesoDef_c,@mpmaIdFva_c,@mpmaIdUmsDef_c,@mpmaLocked_c,@mpmaShadow_c,@mpmaOpzioni_c,@mpmaOper_c
					end--Whileb
					close crsMpModAtt
					deallocate crsMpModAtt
					/*******/
					--cambio IdMpMod con l'ultimo generato
					set @mpmaIdMpMod=@mpmaIdMpModNew
					--selezione del nuovo @IdMdlAtt
					select @IdMdlAtt=IdMdlAtt from MPModelliAttributi
					where mpmaIdDzt=@mpmaIdDzt and mpmaIdMpMod=@mpmaIdMpMod
end     --ifc
declare @a varchar(51)
set  @a=@mpmaValoreDef+'.'
if len(@a)=1
   begin
          set  @mpmaValoreDef=Null
  end
--aggiornamento MPModelliAttributi
update MPModelliAttributi
set 		mpmaRegObblig=@mpmaRegObblig,
		mpmaValoreDef=@mpmaValoreDef , 
		mpmaPesoDef= NULLIF(@mpmaPesoDef ,-1),
		mpmaIdFva=NULLIF(@mpmaIdFva,-1), 
		mpmaIdUmsDef=NULLIF(@mpmaIdUmsDef ,-1), 
		mpmaLocked=@mpmaLocked, 
		mpmaShadow=@mpmaShadow,
		mpmaOpzioni=@mpmaOpzioni,
		mpmaOper=NULLIF(@mpmaOper,-1)
where IdMdlAtt=@IdMdlAtt
if @@error <> 0 	begin
                  	raiserror ('Errore update MPModelliAttributi  (UpdateMpModAttr) ', 16, 1) 
                  	rollback tran
                  	return 99
             		end
--cancellati tutti logicamente!!!!!!
/*update MPAttributiControlli
set mpacDeleted=1 
where mpacIdMdlAtt=@IdMdlAtt
if @@error <> 0		begin
                  	raiserror ('Errore update MPAttributiControlli  (UpdateMpModAttr) ', 16, 1) 
                  	rollback tran
                  	return 99
	             	end
*/
/* bisogna cancellare logicamenta??? o semplicemente fare un update*/
if @strMpacIddzt<>'' and @strMpacValue<>'' 	begin  --ifce
						while @strMpacIddzt <> ''   
							begin
      							set @Pos = PATINDEX('%#~%', @strMpacIddzt)
						      	set @subMpacIddzt = left (@strMpacIddzt, @Pos - 1) -- Estrazione della funzionalita
      							set @strMpacIddzt = substring(@strMpacIddzt, @Pos + 2, len(@strMpacIddzt)- @Pos)  --riduzione della string delle funzionalita
						        set @Pos2 = PATINDEX('%#~%', @strMpacValue)
      							set @MpacValue = left (@strMpacValue, @Pos2 - 1) -- Estrazione della funzionalita
      							set @strMpacValue = substring(@strMpacValue, @Pos2 + 2, len(@strMpacValue)- @Pos2)  --riduzione della string delle funzionalita
							--Controllo valore numerico, mentre "else" segnala l'errore  
  							if isnumeric(@subMpacIddzt)=1	begin --ifi  
   											set @MpacIddzt = cast (@subMpacIddzt as int)
											--esistenza idDzt nel DizionarioAttributi
											if exists(select * from DizionarioAttributi where  Iddzt=@MpacIddzt )	begin--ife
											if not exists(select * from MpAttributiControlli where mpacIdMdlAtt=@IdMdlAtt and mpacIddzt=@MpacIddzt )	begin --ifne
																									--Inserimento in MpAttributiControlli
																									 insert into MpAttributiControlli(mpacIdMdlAtt,mpacIddzt,mpacValue) values(@IdMdlAtt,@mpacIddzt,@mpacValue)
																									 if @@error <> 0	begin
																				                  					raiserror ('Errore insert MpAttributiControlli  (UpdateMpModAttr) ', 16, 1) 
                  																									rollback tran
                  																									return 99
             					 																					end
																									end --ifne
																									else --ifne
																									begin --ifne
																									--Update in MpAttributiControlli 
																									 update MPAttributiControlli
																									 set 	mpacDeleted=0,
																									 mpacValue=@mpacValue 
																									 where mpacIdMdlAtt=@IdMdlAtt and mpacIddzt=@mpacIddzt
																									 if @@error <> 0	begin
																						                  		 		raiserror ('Errore update MPAttributiControlli  (UpdateMpModAttr) ', 16, 1) 
                  																										rollback tran
                  																										return 99
	             				     																						end
																									end --ifne
																					
																				/* Valori da cancellare!!!*/		
																				update MPAttributiControlli
																				   set mpacDeleted=1,
																				       mpacValue='' 
																				 where mpacIdMdlAtt=@IdMdlAtt and mpacIddzt=@mpacIddzt and mpacValue='?$?'
																				if @@error <> 0		begin
                  																					raiserror ('Errore update MPAttributiControlli  (UpdateMpModAttr) ', 16, 1) 
                  																					rollback tran
                  																					return 99
	             																					end
																				end--ife
																				else--ife
																				begin--ife
                  																		raiserror ('Errore valore mpacIdDzt non presente nel DizionarioAttributi  (UpdateMpModAttr) ', 16, 1) 
                  																		rollback tran
                  																		return 99
																				end--ife
   
     											end --ifi
      											else --ifi   
					             					begin --ifi
                  									raiserror ('Errore valore mpacIdDzt non numerico  (UpdateMpModAttr) ', 16, 1) 
                  									rollback tran
                  									return 99
             					 					end --ifi
							end --while
							if @strMpacIddzt<>'' or  @strMpacValue  <>''	begin
                  											raiserror ('Errore formattazione stringhe  (UpdateMpModAttr) ', 16, 1) 
                  											rollback tran
                  											return 99
													end
							end--ifce
commit tran
set nocount off
end


GO
