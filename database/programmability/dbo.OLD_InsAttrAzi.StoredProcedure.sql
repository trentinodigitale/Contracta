USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_InsAttrAzi]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[OLD_InsAttrAzi] (@IdAzi int, @dztNome varchar(50), @valore varchar(8000))
as

set nocount on

declare @tipomem          int
declare @dztmultivalue    int
declare @valtemp          varchar(8000)
declare @valtemp1         varchar(8000)
declare @idvat            int
declare @iddzt            int
declare @idums            int
declare @iddscs           int
declare @iddscn           int
declare @idtid            int
declare @iddsc            int
declare @tipodom          char(1)


select @tipomem = tidTipoMem, @iddzt = iddzt, @idums = dztIdUmsDefault, @idtid = dztidtid, @tipodom = tidtipodom, @dztmultivalue = dztmultivalue
  from tipidati, dizionarioattributi
 where dztidtid = idtid
   and dztnome = @dztnome

if @iddzt is null
begin
        raiserror('Attributo %s non trovato', 16, 1, @dztnome)
        return 99
end

if @idums is not null 
   select @iddscs = umsIdDscSimbolo,  @iddscn = umsIdDscNome
     from unitamisura
    where idums = @idums
        

if left (@valore, 3) = '###'
        set @valtemp = substring(@valore, 4, 8000)
else
        set @valtemp = @valore

while @valtemp <> '' and @valtemp <> '###'
begin

        if charindex('###', @valtemp) <> 0
        begin
                set @valtemp1 = substring (@valtemp, 1, charindex('###', @valtemp) -1)
                set @valtemp = substring (@valtemp, charindex('###', @valtemp) + 3, 8000)
        end
        else 
        begin
                set @valtemp1 = @valtemp
                set @valtemp = ''
        end
        
        insert into valoriattributi(vatiddzt, vattipomem) values (@iddzt, @tipomem)

        if @@error <> 0
        begin
                raiserror ('Errore "INSERT" ValoriAttributi', 16, 1)
                return 99
        end

        set @idvat = @@identity

        insert into dfvatazi (idazi, idvat) values (@idazi, @idvat)

        if @@error <> 0
        begin
                raiserror ('Errore "INSERT" ValoriAttributi', 16, 1)
                return 99
        end

        if @tipomem = 1
        begin
                insert into valoriattributi_int (idvat, vatvalore) values (@idvat, @valtemp1)

                if @@error <> 0
                begin
                        raiserror ('Errore "INSERT" ValoriAttributi_int', 16, 1)
                        return 99
                end      

                insert into dm_attributi (idapp, lnk, idvat, vatiddzt, vatidums, vatidumsdscnome, vatidumsdscsimbolo,
                                          dztnome, dztmultivalue, dztidtid, vatvalore_ft, vatvalore_fv, isdsccsx, vattipomem)
                     values (1, @idazi, @idvat, @iddzt, @idums, isnull(@iddscn,'0'), isnull(@iddscs,'0'),
                                   @dztnome, @dztmultivalue, @idtid, @valtemp1, @valtemp1, 0, 1)


                if @@error <> 0
                begin
                        raiserror ('Errore "INSERT" dm_attributi', 16, 1)
                        return 99
                end      
        end
        else
        if @tipomem = 2
        begin
                insert into valoriattributi_money (idvat, vatvalore) values (@idvat, cast(@valtemp1 as money))

                if @@error <> 0
                begin
                        raiserror ('Errore "INSERT" ValoriAttributi_Money', 16, 1)
                        return 99
                end      

                insert into dm_attributi (idapp, lnk, idvat, vatiddzt, vatidums, vatidumsdscnome, vatidumsdscsimbolo,
                                          dztnome, dztmultivalue, dztidtid, vatvalore_ft, vatvalore_fv, isdsccsx, vattipomem)
                     values (1, @idazi, @idvat, @iddzt, @idums, isnull(@iddscn,'0'), isnull(@iddscs,'0'),
                                   @dztnome, @dztmultivalue, @idtid, ltrim(str(@valtemp1, 20, 3)), ltrim(str(@valtemp1, 20, 3)), 0, 2)


                if @@error <> 0
                begin
                        raiserror ('Errore "INSERT" dm_attributi', 16, 1)
                        return 99
                end      
        end
        if @tipomem = 3
        begin
                insert into valoriattributi_float (idvat, vatvalore) values (@idvat, @valtemp1)

                if @@error <> 0
                begin
                        raiserror ('Errore "INSERT" dm_attributi', 16, 1)
                        return 99
                end      

                insert into dm_attributi (idapp, lnk, idvat, vatiddzt, vatidums, vatidumsdscnome, vatidumsdscsimbolo,
                                          dztnome, dztmultivalue, dztidtid, vatvalore_ft, vatvalore_fv, isdsccsx, vattipomem)
                     values (1, @idazi, @idvat, @iddzt, @idums, isnull(@iddscn,'0'), isnull(@iddscs,'0'),
                                   @dztnome, @dztmultivalue, @idtid, ltrim(str(@valtemp1, 20, 3)), ltrim(str(@valtemp1, 20, 3)), 0, 3)


                if @@error <> 0
                begin
                        raiserror ('Errore "INSERT" dm_attributi', 16, 1)
                        return 99
                end      
        end
        if @tipomem = 4
        begin
                if @tipodom = 'A'
                begin
                        insert into valoriattributi_nvarchar (idvat, vatvalore) values (@idvat, @valtemp1)
        
                        if @@error <> 0
                        begin
                                raiserror ('Errore "INSERT" ValoriAttributi_NVarchar', 16, 1)
                                return 99
                        end      
        
                        insert into dm_attributi (idapp, lnk, idvat, vatiddzt, vatidums, vatidumsdscnome, vatidumsdscsimbolo,
                                                  dztnome, dztmultivalue, dztidtid, vatvalore_ft, vatvalore_fv, isdsccsx, vattipomem)
                             values (1, @idazi, @idvat, @iddzt, @idums, isnull(@iddscn,'0'), isnull(@iddscs,'0'),
                                           @dztnome, @dztmultivalue, @idtid, @valtemp1, @valtemp1, 0, 4)
        
        
                        if @@error <> 0
                        begin
                                raiserror ('Errore "INSERT" dm_attributi', 16, 1)
                                return 99
                        end      
                end
                else
                if @tipodom = 'G'
                begin
                        select @iddsc = dgiddsc
                          from dominigerarchici 
                         where dgtipogerarchia = @idtid
                           and dgcodiceinterno = @valtemp1
                           and dgdeleted = 0
						
						--commentato perchè classifizioneSOA sebbene ancora censito nel vecchio dizionario
						--punta al dominio GERARCHICOSOA definito nelle nuove tabelle LIB_DOMAIN_VALUES
						--e quindi per un determinato codice potrebbe non trovare il corrispondente iddsc
                        --if @iddsc is null
                        --begin
                        --        raiserror ('Codice %s non trovato per l''attributo %s', 16, 1, @valtemp1, @dztnome)
                        --        return 99
                        --end
        
                        insert into valoriattributi_nvarchar (idvat, vatvalore) values (@idvat, @valtemp1)
        
                        if @@error <> 0
                        begin
                                raiserror ('Errore "INSERT" ValoriAttributi_NVarchar', 16, 1)
                                return 99
                        end      
        
                        insert into dm_attributi (idapp, lnk, idvat, vatiddzt, vatidums, vatidumsdscnome, vatidumsdscsimbolo,
                                                  dztnome, dztmultivalue, dztidtid, vatvalore_ft, vatvalore_fv, isdsccsx, vattipomem)
                             values (1, @idazi, @idvat, @iddzt, @idums, isnull(@iddscn,'0'), isnull(@iddscs,'0'),
                                           @dztnome, @dztmultivalue, @idtid, @valtemp1, @iddsc, 1, 4)
        
        
                        if @@error <> 0
                        begin
                                raiserror ('Errore "INSERT" dm_attributi', 16, 1)
                                return 99
                        end      
                end
                else
                if @tipodom = 'C'
                begin
                        select @iddsc = tdriddsc
                          from tipidatirange
                         where tdridtid = @idtid
                           and tdrcodice = @valtemp1
                           and tdrdeleted = 0

                        if @iddsc is null
                        begin
                                raiserror ('Codice %s non trovato per l''attributo %s', 16, 1, @valtemp1, @dztnome)
                                return 99
                        end
                
                        insert into valoriattributi_nvarchar (idvat, vatvalore) values (@idvat, @valtemp1)
        
                        if @@error <> 0
                        begin
                                raiserror ('Errore "INSERT" ValoriAttributi_NVarchar', 16, 1)
                                return 99
                        end      
        
                        insert into dm_attributi (idapp, lnk, idvat, vatiddzt, vatidums, vatidumsdscnome, vatidumsdscsimbolo,
                                                  dztnome, dztmultivalue, dztidtid, vatvalore_ft, vatvalore_fv, isdsccsx, vattipomem)
                             values (1, @idazi, @idvat, @iddzt, @idums, isnull(@iddscn,'0'), isnull(@iddscs,'0'),
                                           @dztnome, @dztmultivalue, @idtid, @valtemp1, @iddsc, 1, 4)
        
        
                        if @@error <> 0
                        begin
                                raiserror ('Errore "INSERT" dm_attributi', 16, 1)
                                return 99
                        end      
                end
        end
        if @tipomem = 5
        begin
                insert into valoriattributi_datetime (idvat, vatvalore) values (@idvat, @valtemp1)

                if @@error <> 0
                begin
                        raiserror ('Errore "INSERT" ValoriAttributi_Datetime', 16, 1)
                        return 99
                end      

                insert into dm_attributi (idapp, lnk, idvat, vatiddzt, vatidums, vatidumsdscnome, vatidumsdscsimbolo,
                                          dztnome, dztmultivalue, dztidtid, vatvalore_ft, vatvalore_fv, isdsccsx, vattipomem)
                     values (1, @idazi, @idvat, @iddzt, @idums, isnull(@iddscn,'0'), isnull(@iddscs,'0'),
                                   @dztnome, @dztmultivalue, @idtid, @valtemp1, @valtemp1, 0, 5)


                if @@error <> 0
                begin
                        raiserror ('Errore "INSERT" dm_attributi', 16, 1)
                        return 99
                end      
        end
        if @tipomem = 6
        begin
                select @iddsc = tdriddsc
                  from tipidatirange
                 where tdridtid = @idtid
                   and tdrcodice = @valtemp1
                   and tdrdeleted = 0

                if @iddsc is null
                begin
                        raiserror ('Codice %s non trovato per l''attributo %s', 16, 1, @valtemp1, @dztnome)
                        return 99
                end
                
                insert into valoriattributi_descrizioni (idvat, vatiddsc) values (@idvat, @valtemp1)

                if @@error <> 0
                begin
                        raiserror ('Errore "INSERT" ValoriAttributi_Descrizioni', 16, 1)
                        return 99
                end      

                insert into dm_attributi (idapp, lnk, idvat, vatiddzt, vatidums, vatidumsdscnome, vatidumsdscsimbolo,
                                          dztnome, dztmultivalue, dztidtid, vatvalore_ft, vatvalore_fv, isdsccsx, vattipomem)
                     values (1, @idazi, @idvat, @iddzt, @idums, isnull(@iddscn,'0'), isnull(@iddscs,'0'),
                                   @dztnome, @dztmultivalue, @idtid, @valtemp1, @iddsc, 1, 6)


                if @@error <> 0
                begin
                        raiserror ('Errore "INSERT" dm_attributi', 16, 1)
                        return 99
                end      
        end
        if @tipomem = 7
        begin
                select @iddsc = dgiddsc
                  from dominigerarchici 
                 where dgtipogerarchia = @idtid
                   and dgcodiceinterno = @valtemp1
                   and dgdeleted = 0

                if @iddsc is null
                begin
                        raiserror ('Codice %s non trovato per l''attributo %s', 16, 1, @valtemp1, @dztnome)
                        return 99
                end
                
                insert into valoriattributi_keys (idvat, vatvalore) values (@idvat, @valtemp1)

                if @@error <> 0
                begin
                        raiserror ('Errore "INSERT" ValoriAttributi_Descrizioni', 16, 1)
                        return 99
                end      

                insert into dm_attributi (idapp, lnk, idvat, vatiddzt, vatidums, vatidumsdscnome, vatidumsdscsimbolo,
                                          dztnome, dztmultivalue, dztidtid, vatvalore_ft, vatvalore_fv, isdsccsx, vattipomem)
                     values (1, @idazi, @idvat, @iddzt, @idums, isnull(@iddscn,'0'), isnull(@iddscs,'0'),
                                   @dztnome, @dztmultivalue, @idtid, @valtemp1, @iddsc, 1, 7)


                if @@error <> 0
                begin
                        raiserror ('Errore "INSERT" dm_attributi', 16, 1)
                        return 99
                end      
        end
       
end 


set nocount off


GO
