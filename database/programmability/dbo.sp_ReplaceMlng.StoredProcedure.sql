USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[sp_ReplaceMlng]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[sp_ReplaceMlng] (@strIn NVARCHAR (1000), @strOut NVARCHAR (1000), @Lng VARCHAR(5)) AS
set transaction isolation level serializable
DECLARE @strTemp AS VARCHAR (1000)
set @strTemp = '%' + @strIn + '%'
begin tran
alter table multilinguismo disable trigger MultiLinguismo_UltimaMod
IF  @Lng = 'I'
    begin
           update Multilinguismo 
              set mlngDesc_I = replace (cast (mlngDesc_I AS NVARCHAR(4000)), @strIn, @strOut),
              mlngUltimaMod=GETDATE()
            WHERE mlngDesc_I like @strTemp
    
           IF @@error <> 0
              begin
               alter table multilinguismo enable trigger MultiLinguismo_UltimaMod
                   raiserror ('Errore "Update" Multilinguismo', 16, 1)
                   rollback tran
                   return
              end
    end
ELSE
IF  @Lng = 'UK'
    begin
           update Multilinguismo 
              set mlngDesc_UK = replace (cast (mlngDesc_UK AS NVARCHAR(4000)), @strIn, @strOut),
              mlngUltimaMod=GETDATE()
            WHERE mlngDesc_UK like @strTemp
    
           IF @@error <> 0
              begin
               alter table multilinguismo enable trigger MultiLinguismo_UltimaMod
                   raiserror ('Errore "Update" Multilinguismo', 16, 1)
                   rollback tran
                   return
              end
    end
ELSE
IF  @Lng = 'E'
    begin
           update Multilinguismo 
              set mlngDesc_E = replace (cast (mlngDesc_E AS NVARCHAR(4000)), @strIn, @strOut),
              mlngUltimaMod=GETDATE()
            WHERE mlngDesc_E like @strTemp
    
           IF @@error <> 0
              begin
               alter table multilinguismo enable trigger MultiLinguismo_UltimaMod
                   raiserror ('Errore "Update" Multilinguismo', 16, 1)
                   rollback tran
                   return
              end
    end
ELSE
IF  @Lng = 'FRA'
    begin
           update Multilinguismo 
              set mlngDesc_FRA = replace (cast (mlngDesc_FRA AS NVARCHAR(4000)), @strIn, @strOut),
              mlngUltimaMod=GETDATE()
            WHERE mlngDesc_FRA like @strTemp
    
           IF @@error <> 0
              begin
               alter table multilinguismo enable trigger MultiLinguismo_UltimaMod
                   raiserror ('Errore "Update" Multilinguismo', 16, 1)
                   rollback tran
                   return
              end
    end
ELSE
IF  @Lng = 'Lng1'
    begin
           update Multilinguismo 
              set mlngDesc_Lng1 = replace (cast (mlngDesc_Lng1 AS NVARCHAR(4000)), @strIn, @strOut),
              mlngUltimaMod=GETDATE()
            WHERE mlngDesc_Lng1 like @strTemp
    
           IF @@error <> 0
              begin
               alter table multilinguismo enable trigger MultiLinguismo_UltimaMod
                   raiserror ('Errore "Update" Multilinguismo', 16, 1)
                   rollback tran
                   return
              end
    end
ELSE
IF  @Lng = 'Lng2'
    begin
           update Multilinguismo 
              set mlngDesc_Lng2 = replace (cast (mlngDesc_Lng2 AS NVARCHAR(4000)), @strIn, @strOut),
              mlngUltimaMod=GETDATE()
            WHERE mlngDesc_Lng2 like @strTemp
    
           IF @@error <> 0
              begin
               alter table multilinguismo enable trigger MultiLinguismo_UltimaMod
                   raiserror ('Errore "Update" Multilinguismo', 16, 1)
                   rollback tran
                   return
              end
    end
ELSE
IF  @Lng = 'Lng3'
    begin
           update Multilinguismo 
              set mlngDesc_Lng3 = replace (cast (mlngDesc_Lng3 AS NVARCHAR(4000)), @strIn, @strOut),
              mlngUltimaMod=GETDATE()
            WHERE mlngDesc_Lng3 like @strTemp
    
           IF @@error <> 0
              begin
               alter table multilinguismo enable trigger MultiLinguismo_UltimaMod
                   raiserror ('Errore "Update" Multilinguismo', 16, 1)
                   rollback tran
                   return
              end
    end
ELSE
IF  @Lng = 'Lng4'
    begin
           update Multilinguismo 
              set mlngDesc_Lng4 = replace (cast (mlngDesc_Lng4 AS NVARCHAR(4000)), @strIn, @strOut),
              mlngUltimaMod=GETDATE()
            WHERE mlngDesc_Lng4 like @strTemp
    
           IF @@error <> 0
              begin
               alter table multilinguismo enable trigger MultiLinguismo_UltimaMod
                   raiserror ('Errore "Update" Multilinguismo', 16, 1)
                   rollback tran
                   return
              end
    end
ELSE
    begin
       alter table multilinguismo enable trigger MultiLinguismo_UltimaMod
         raiserror ('Lingua [%s] non valida', 16, 1, @Lng)
         rollback tran
         return 99
    end
alter table multilinguismo enable trigger MultiLinguismo_UltimaMod
commit tran
GO
