Imports System.Data
Imports System.Data.SqlClient
Imports System.Reflection

Public Class DbUtil

    Public sqlConn As SqlConnection
    Dim connectionString As String = ConfigurationSettings.AppSettings("db.conn")
    Dim attivaTrace As String = ConfigurationSettings.AppSettings("app.log")

    Public dbError As String = ""

    Sub New()

        On Error Resume Next

        If connectionString Is Nothing Or CStr(connectionString) = "" Then

            Dim path As String = (New System.Uri(Assembly.GetExecutingAssembly().CodeBase)).AbsolutePath
            Dim array As String()
            Dim nomeFile As String

            array = Split(path, "/")
            nomeFile = array(UBound(array))

            path = path.Replace(nomeFile, "")
            path = System.Web.HttpUtility.UrlDecode(path)

            connectionString = IniRead(path & "../application.ini", "Stringa di Connessione", "ConnectionString")

            connectionString = connectionString.Replace("Provider=SQLOLEDB;", "")
            connectionString = connectionString.Replace("Provider=SQLOLEDB.1;", "")

        End If

    End Sub

    Protected Overrides Sub Finalize()
        'If (Not sqlConn Is Nothing) Then 'Or sqlConn.State <> ConnectionState.Open) Then
        close()
        'End If
    End Sub

    Public Function init() As Boolean
        On Error GoTo err

        '-- Se la connessione non è attiva la attiviamo
        If (sqlConn Is Nothing) Then 'Or sqlConn.State <> ConnectionState.Open) Then

            sqlConn = Nothing
            sqlConn = New SqlConnection(connectionString)
            sqlConn.Open()

        Else

            If (sqlConn.State <> ConnectionState.Open) Then

                sqlConn.Close()
                sqlConn = Nothing
                sqlConn = New SqlConnection(connectionString)
                sqlConn.Open()

            End If

        End If

        Return True

        Exit Function
err:
        dbError = Err.Description
        'Console.WriteLine("ERRORE NELLA INIT SUL DB : " & Err.Description)
        Return False

    End Function

    Public Sub close()
        On Error Resume Next
        sqlConn.Close()
    End Sub

    Public Function checkAlgoritmoFirma(alg As String, dataFirma As String) As Boolean

        Dim ret As Boolean = True

        If init() Then

            Dim strSql As String = "select * FROM CTL_RelationsTime "
            strSql = strSql & " where REL_Type = 'VERIFICA_ALGORITMO_FIRMA' and REL_ValueInput = '" & Replace(alg, "'", "''") & "' "
            strSql = strSql & " and '" & dataFirma & "' >= REL_Data_I and '" & dataFirma & "' <= REL_Data_F "

            Dim sqlComm As New SqlCommand(strSql, sqlConn)
            Dim r As SqlDataReader = sqlComm.ExecuteReader()

            ret = r.Read

            r.Close()

            Return ret


        Else

            Return False

        End If


    End Function


    Public Sub trace(messaggio As String, chiamante As String)

        If init() Then

            Dim strSql As String = ""

            Try

                strSql = "INSERT INTO CTL_LOG_UTENTE" &
                    "(ip " &
                    ",idpfu " &
                    " ,datalog " &
                    " ,paginaDiArrivo " &
                    " ,paginaDiPartenza " &
                    " ,querystring " &
                    " ,form " &
                    " ,browserUsato) " &
                    " VALUES " &
                    " ('' " &
                    " ,-20" &
                    " ,getDate()  " &
                    " ,'' " &
                    " ,'' " &
                    " ,'" & Replace(chiamante, "'", "''") & "' " &
                    " ,'" & Replace(messaggio, "'", "''") & "' " &
                    " ,'PDF-P7M')"

                Dim sqlComm = New SqlCommand(strSql, sqlConn)
                sqlComm.ExecuteNonQuery()

                sqlComm = Nothing

            Catch ex As Exception

            End Try

        End If


    End Sub

    Public Function getConnection() As SqlConnection
        Return Me.sqlConn
    End Function


End Class
