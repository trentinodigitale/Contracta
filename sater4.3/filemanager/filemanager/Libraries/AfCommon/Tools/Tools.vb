Imports System.Collections.Specialized
Imports System.IO
Imports System.Runtime.InteropServices
Imports System.Security.Cryptography
Imports HumanBytes
Imports MongoDB.Bson


Public Class Tools
    Public Enum SHA_Algorithm
        MD5 = 10
        SHA1 = 20
        SHA256 = 30
        SHA384 = 40
        SHA512 = 50
        'PDF = 100
    End Enum
    ''' <summary>
    ''' Restituisce una stringa Casuale formata da un codice casuale di 17 cifre seguita da un _ e  poi dal timestamp attuale
    ''' </summary>
    ''' <param name="uppercase">Specificare True se si desidera la stringa maiuscola</param>
    ''' <returns></returns>
    Public shared function getrandomid(optional uppercase As Boolean = False) As String
        dim ret As String = Guid.NewGuid.ToString.Replace("-","").ToLower
        If uppercase
            ret =  ret.ToUpper
        Else
            If IsNumeric(ret.Substring(0,1))
                ret = "r" & ret.Substring(1)
            End If
        End If
        With Date.Now.ToUniversalTime
            Return ret.Substring(0,17) & "_" & Format(.Year,"0000") & Format(.Month,"00")  & Format(.Day,"00")  & Format(.Hour,"00")  & Format(.Minute,"00")  & Format(.Second,"00")  & Format(.Millisecond,"000")
        End With        
    End function
    ''' <summary>
    ''' Ricava la data da una stringa create con la funzione getrandomid
    ''' </summary>
    ''' <param name="id"></param>
    ''' <returns></returns>
    Public shared function randomid_to_date(id As String) As DateTime?
        Dim inputid As String = id.Clone
        If inputid.Contains("_")
            inputid = inputid.Trim.Split("_").Last
        End If
        If inputid.Length = 17 AndAlso IsNumeric(inputid)
            Return New DateTime(inputid.Substring(0,4),inputid.Substring(4,2),inputid.Substring(6,2),inputid.Substring(8,2),inputid.Substring(10,2),inputid.Substring(12,2),inputid.Substring(14,3), DateTimeKind.Local)
        End If
        Return Nothing
    End function


    Public class FormattingTools
        ''' <summary>
        ''' converte i bytes in una versione leggibile (umana)
        ''' </summary>
        ''' <param name="bytes"></param>
        ''' <returns></returns>
        Public Shared function bytestoHuman(bytes As Long) As String
            dim formatter As New ByteSizeFormatter()  With{.Convention = ByteSizeConvention.Binary,.DecimalPlaces = 2,.NumberFormat = "#,##0.###",.MinUnit = ByteSizeUnit.Byte,.MaxUnit = ByteSizeUnit.Gigabyte,.RoundingRule = ByteSizeRounding.Closest,.UseFullWordForBytes = True}
            Return formatter.Format(bytes)
        End function
    End Class

    Public Class Generic
        ''' <summary>
        ''' Converte una stringa in booleano considerando TRUE i valori (true,yes e 1)
        ''' </summary>
        ''' <param name="input"></param>
        ''' <param name="defaultvalue"></param>
        ''' <returns></returns>
        Public shared function Getboolean(input As Object,defaultvalue As Boolean) As Boolean
            If IsNothing(input)
                Return defaultvalue
            else
                Select Case input.GetType.FullName
                    Case GetType(Boolean).FullName
                        Return CBool(input)
                    Case GetType(String).FullName
                        Select Case input.ToString.ToLower
                            Case "1","true","yes"
                                Return True
                            Case Else
                                Return False
                        End Select
                End Select
            End If
            Return defaultvalue
        End function
    End Class

    Public Class HashTools
        ''' <summary>
        ''' Calcola l'hash di un array di bytes
        ''' </summary>
        ''' <param name="input"></param>
        ''' <param name="Algorithm">Algoritmo desiderato</param>
        ''' <returns>Hash Bytes</returns>
        Public shared function GetHASHBytes(input As Byte(),Algorithm As Tools.SHA_Algorithm) As Byte()
            Select Case Algorithm
                Case SHA_Algorithm.MD5
                    Return New System.Security.Cryptography.MD5CryptoServiceProvider().ComputeHash(input)
                Case SHA_Algorithm.SHA1
                    Return New System.Security.Cryptography.SHA1CryptoServiceProvider().ComputeHash(input)
                Case SHA_Algorithm.SHA256
                    Return New System.Security.Cryptography.SHA256CryptoServiceProvider().ComputeHash(input)
                Case SHA_Algorithm.SHA384
                    Return New System.Security.Cryptography.SHA384CryptoServiceProvider().ComputeHash(input)
                Case SHA_Algorithm.SHA512
                    Return New System.Security.Cryptography.SHA512CryptoServiceProvider().ComputeHash(input)
                Case Else
                    Throw New Exception("Invalid Hashing Algorithm for " & Algorithm.ToString)
            End Select
        End function
        ''' <summary>
        ''' Calcola l'hash di un array di bytes
        ''' </summary>
        ''' <param name="input"></param>
        ''' <param name="Algorithm">Algoritmo desiderato</param>
        ''' <returns>Hash del file in formato stringa</returns>
        Public shared function GetHASHBytesToString(input As Byte(),Algorithm As Tools.SHA_Algorithm) As String
            Dim HashBytes As Byte() = Nothing
            Select Case Algorithm
                Case SHA_Algorithm.MD5
                    HashBytes = New System.Security.Cryptography.MD5CryptoServiceProvider().ComputeHash(input)
                Case SHA_Algorithm.SHA1
                    HashBytes = New System.Security.Cryptography.SHA1CryptoServiceProvider().ComputeHash(input)
                Case SHA_Algorithm.SHA256
                    HashBytes = New System.Security.Cryptography.SHA256CryptoServiceProvider().ComputeHash(input)
                Case SHA_Algorithm.SHA384
                    HashBytes = New System.Security.Cryptography.SHA384CryptoServiceProvider().ComputeHash(input)
                Case SHA_Algorithm.SHA512
                    HashBytes = New System.Security.Cryptography.SHA512CryptoServiceProvider().ComputeHash(input)
                Case Else
                    Throw New Exception("Invalid Hashing Algorithm for " & Algorithm.ToString)
            End Select
            Return Algorithm.ToString & ":" & BitConverter.ToString(HashBytes).Replace("-","")
        End function
        ''' <summary>
        ''' Calcola l'hash da uno stream
        ''' </summary>
        ''' <param name="stream">Memory o File Stream</param>
        ''' <param name="Algorithm">Algoritmo desiderato</param>
        ''' <returns>Hash del file in formato stringa</returns>
        Public shared Function GetHASHBytesToString(stream As System.IO.Stream,Algorithm As Tools.SHA_Algorithm) As String
            Dim HashBytes As Byte() = Nothing
            Select Case Algorithm
                Case SHA_Algorithm.MD5
                    HashBytes = New System.Security.Cryptography.MD5CryptoServiceProvider().ComputeHash(stream)
                Case SHA_Algorithm.SHA1
                    HashBytes = New System.Security.Cryptography.SHA1CryptoServiceProvider().ComputeHash(stream)
                Case SHA_Algorithm.SHA256
                    HashBytes = New System.Security.Cryptography.SHA256CryptoServiceProvider().ComputeHash(stream)
                Case SHA_Algorithm.SHA384
                    HashBytes = New System.Security.Cryptography.SHA384CryptoServiceProvider().ComputeHash(stream)
                Case SHA_Algorithm.SHA512
                    HashBytes = New System.Security.Cryptography.SHA512CryptoServiceProvider().ComputeHash(stream)
                Case Else
                    Throw New Exception("Invalid Hashing Algorithm for " & Algorithm.ToString)
            End Select
            Return Algorithm.ToString & ":" & BitConverter.ToString(HashBytes).Replace("-","")
        End Function

        Public Shared Function GetHASHBytesToString(pathFile As String, Algorithm As Tools.SHA_Algorithm) As String


            Using fs = New System.IO.FileStream(pathFile, FileMode.Open)
                Return GetHASHBytesToString(fs, Algorithm)
            End Using

        End Function

        ''' <summary>
        ''' Calcola l'hash SHA256 di un array di bytes
        ''' </summary>
        ''' <param name="input"></param>
        ''' <returns></returns>
        Public shared function ComputeHashBytes(input As Byte()) As Byte()
            Return SHA256.Create().ComputeHash(input)
        End function

        Public Shared Function GetStringsHash(ParamArray inputs As String()) As String
            Return getSHA1Hash(String.join(":",inputs),True)
        End Function


        ''' <summary>
        ''' Calcola l'hash SHA1 di una stringa ASCII
        ''' </summary>
        ''' <param name="strToHash"></param>
        ''' <param name="skipprefix"></param>
        ''' <returns></returns>
        Public Shared Function getSHA1Hash(ByVal strToHash As String, skipprefix As Boolean) As String

            'Dim strResult As String = ""
            'Dim bytesToHash() as Byte = GetHASHBytes(System.Text.Encoding.ASCII.GetBytes(strToHash), SHA_Algorithm.SHA1)
            'For Each b As Byte In bytesToHash
            'strResult += b.ToString("x2")
            'Next

            Dim sha1Obj As New System.Security.Cryptography.SHA1CryptoServiceProvider
            Dim bytesToHash() As Byte = System.Text.Encoding.ASCII.GetBytes(strToHash)

            bytesToHash = sha1Obj.ComputeHash(bytesToHash)

            Dim strResult As String = ""

            For Each b As Byte In bytesToHash
                strResult += b.ToString("x2")
            Next

            If Not skipprefix Then
                Return "SHA1:" & strResult
            Else
                Return strResult
            End If
        End Function


    End Class

    ''' <summary>
    ''' Funzioni di Codifica HTML e JS
    ''' </summary>
    Public class EncodeTools
        Public shared function HTMLencode(input As String) As String
            Return System.Web.HttpUtility.HtmlEncode(input)
        End function
        Public shared function URLencode(input As String) As String
            Return System.Web.HttpUtility.UrlEncode(input)
        End function
        Public shared function JAVASCRIPTEncode(input As String) As String
            Return System.Web.HttpUtility.JavaScriptStringEncode(input)
        End function
        Public shared function HTMLDecode(input As String) As String
            Return System.Web.HttpUtility.HtmlDecode(input)
        End function
        Public shared function URLDecode(input As String) As String
            Return System.Web.HttpUtility.UrlDecode(input)
        End function
    End Class

    Public Class EncryptionTools
        ''' <summary>
        ''' Classe per la gestione della crittografia dei files
        ''' </summary>
        Public Class EncryptionManager
            ''' <summary>
            ''' Chiave di Encrypt/Decrypt
            ''' </summary>
            ''' <returns></returns>
            Private readonly property encryptionkey As String
            Public sub New(encryptionkey As String)
                Me.encryptionkey = encryptionkey
            End sub

            ''' <summary>
            ''' Encrypt di un file
            ''' </summary>
            ''' <param name="sourcepath">percorso di origine</param>
            ''' <param name="targetpath">percorso di destinazione</param>
            Public sub EncryptFile(sourcepath As String,targetpath As String)
                My.Computer.FileSystem.WriteAllBytes(targetpath,Me.EncryptBytes(My.Computer.FileSystem.ReadAllBytes(sourcepath)),False)
            End sub
            ''' <summary>
            ''' Decrypt di un file
            ''' </summary>
            ''' <param name="sourcepath">percorso di origine</param>
            ''' <param name="targetpath">percorso di destinazione</param>
            Public sub Decrypt(sourcepath As String,targetpath As String)
                My.Computer.FileSystem.WriteAllBytes(targetpath,Me.DecryptBytes(My.Computer.FileSystem.ReadAllBytes(sourcepath)),False)
            End sub
            ''' <summary>
            ''' Encrypt di una stringa
            ''' </summary>
            ''' <param name="input"></param>
            ''' <returns></returns>
            Public Function EncryptString(input As String) As String
                Return System.Text.Encoding.UTF8.GetString(Me.EncryptBytes(System.Text.Encoding.UTF8.GetBytes(input)))
            End Function
            ''' <summary>
            ''' Decrypt di una string
            ''' </summary>
            ''' <param name="input"></param>
            ''' <returns></returns>
            Public Function DecryptString(input As String) As String
                Return System.Text.Encoding.UTF8.GetString(Me.DecryptBytes(System.Text.Encoding.UTF8.GetBytes(input)))
            End Function

            ''' <summary>
            ''' Encrypt di un array di bytes
            ''' </summary>
            ''' <param name="inputbytes"></param>
            ''' <returns></returns>
            Public Function EncryptBytes(inputbytes As Byte()) As Byte()
                Dim saltBytes As Byte() = New Byte(){19, 86, 19, 88, 90, 60, 90, 3}
                dim keyByte  As Byte() = System.Text.Encoding.UTF8.GetBytes(Me.encryptionkey)
                keyByte = SHA256.Create().ComputeHash(keyByte)
                Using myAes As Aes = Aes.Create()
                    myAes.KeySize = 256
                    myAes.BlockSize = 128
                    Dim key As New Rfc2898DeriveBytes(keyByte, saltBytes, 1000)
                    myAes.Key = key.GetBytes(myAes.KeySize / 8)
                    myAes.IV = key.GetBytes(myAes.BlockSize / 8)
                    Return  AES_Encrypt(inputbytes, myAes.Key, myAes.IV)                
                End Using
            End Function

            ''' <summary>
            ''' Decrypt di un array di bytes
            ''' </summary>
            ''' <param name="inputbytes"></param>
            ''' <returns></returns>
            Public Function DecryptBytes(inputbytes As Byte()) As Byte()
                Dim saltBytes As Byte() = New Byte(){19, 86, 19, 88, 90, 60, 90, 3}
                dim keyByte  As Byte() = System.Text.Encoding.UTF8.GetBytes(Me.encryptionkey)
                keyByte = SHA256.Create().ComputeHash(keyByte)
                Using myAes As Aes = Aes.Create()
                    myAes.KeySize = 256
                    myAes.BlockSize = 128
                    Dim key As New Rfc2898DeriveBytes(keyByte, saltBytes, 1000)
                    myAes.Key = key.GetBytes(myAes.KeySize / 8)
                    myAes.IV = key.GetBytes(myAes.BlockSize / 8)
                    Return  AES_Decrypt(inputbytes, myAes.Key, myAes.IV)                
                End Using              
            End Function
            Private Function AES_Decrypt(bytesToBeDecrypted As Byte(), ByVal Key() As Byte, ByVal IV() As Byte) As Byte()
                Dim decryptedBytes As Byte() = Nothing
                Using aes As Aes = aes.Create()
                    aes.Key = Key
                    aes.IV = IV
                    aes.Mode = CipherMode.CBC 'Cipher Block Chaining
                    Dim decryptor As ICryptoTransform = aes.CreateDecryptor(aes.Key, aes.IV)
                    Using msDecrypt As New MemoryStream()
                        Using cs As New CryptoStream(msDecrypt, decryptor, CryptoStreamMode.Write)
                            cs.Write(bytesToBeDecrypted, 0, bytesToBeDecrypted.Length)
                        End Using
                        decryptedBytes = msDecrypt.ToArray()
                    End Using
                End Using
                Return decryptedBytes
            End Function
            Private Function AES_Encrypt(bytesToBeEncrypted As Byte(), ByVal Key() As Byte, ByVal IV() As Byte) As Byte()
                Dim encryptedBytes As Byte() = Nothing
                Using aes As Aes = aes.Create()
                    aes.Key = Key
                    aes.IV = IV
                    aes.Mode = CipherMode.CBC 'Cipher Block Chaining
                    Dim encryptor As ICryptoTransform = aes.CreateEncryptor(aes.Key, aes.IV)
                    Using msDecrypt As New MemoryStream()
                        Using cs As New CryptoStream(msDecrypt, encryptor, CryptoStreamMode.Write)
                            cs.Write(bytesToBeEncrypted, 0, bytesToBeEncrypted.Length)
                        End Using
                        encryptedBytes = msDecrypt.ToArray()
                    End Using
                End Using
                Return encryptedBytes
            End Function
        End Class
    End Class

    ''' <summary>
    ''' Utility di Conversione da e vero base 64
    ''' </summary>
    Public Class ConversionTools
        Public shared Function ToBase64(Input as Byte()) as string
            Return Convert.ToBase64String(Input)
        End Function
        Public shared function FromBase64(b64string As String) As Byte()
            Return Convert.FromBase64String(b64string)
        End function
    End Class


    Public Class Serialization
        ''' <summary>
        ''' Serializza un ogetto di tipo (T) in una stringa json
        ''' </summary>
        ''' <typeparam name="T"></typeparam>
        ''' <param name="input"></param>
        ''' <returns></returns>
        Public shared function JsonSerialize(Of T)(input As T) As String
            If Not IsNothing(input)
                Return input.ToJson(New IO.JsonWriterSettings() With {.Indent = True,.OutputMode = IO.JsonOutputMode.Strict})
            Else
                Return Nothing                               
            End If            
        End function

        ''' <summary>
        ''' Deserializza una stringa JSON in un Oggetto di tipo (T)
        ''' </summary>
        ''' <typeparam name="T"></typeparam>
        ''' <param name="json"></param>
        ''' <returns></returns>
          
        Public shared function JsonDeserialize(Of T)(json As String) As T
            If Not String.IsNullOrWhiteSpace(json)
                Return MongoDB.Bson.Serialization.BsonSerializer.Deserialize(BsonDocument.Parse(json), GetType(T))
            End If
            Return Nothing
        End function
    End Class

    Public class ConsoleTools
#Region "Console TRICK"
        Private Const MF_BYCOMMAND As Integer = &H0
        Public Const SC_CLOSE As Integer = &HF060
        Public Const SC_MINIMIZE As Integer = &HF020
        Public Const SC_MAXIMIZE As Integer = &HF030
        Public Const SC_SIZE As Integer = &HF000

        Friend Declare Function DeleteMenu Lib "user32.dll" (ByVal hMenu As IntPtr, ByVal nPosition As Integer, ByVal wFlags As Integer) As Integer
        Friend Declare Function GetSystemMenu Lib "user32.dll" (hWnd As IntPtr, bRevert As Boolean) As IntPtr

        Const ENABLE_QUICK_EDIT As UInteger = &H40
        Const STD_INPUT_HANDLE As Integer = -10
        <DllImport("kernel32.dll", SetLastError:=True)>
        Private Shared Function GetStdHandle(ByVal nStdHandle As Integer) As IntPtr

        End Function
        <DllImport("kernel32.dll")>
        Private Shared Function GetConsoleMode(ByVal hConsoleHandle As IntPtr, <Out> ByRef lpMode As UInteger) As Boolean

        End Function
        <DllImport("kernel32.dll")>
        Private Shared Function SetConsoleMode(ByVal hConsoleHandle As IntPtr, ByVal dwMode As UInteger) As Boolean

        End Function

        Private Shared Function DisableQuickEdit() As Boolean
            Dim consoleHandle As IntPtr = GetStdHandle(STD_INPUT_HANDLE)
            Dim consoleMode As UInteger

            If Not GetConsoleMode(consoleHandle, consoleMode) Then
                Return False
            End If

            consoleMode = consoleMode And Not ENABLE_QUICK_EDIT

            If Not SetConsoleMode(consoleHandle, consoleMode) Then
                Return False
            End If

            Return True
        End Function
#End Region
        ''' <summary>
        ''' Disattiva la X di chiusura sulla console e disattiva il waiting del mouse in caso di click nella finestra della console
        ''' </summary>
        Public shared Sub ApplyConsoleTricks
            Dim handle As IntPtr = Process.GetCurrentProcess.MainWindowHandle ' Get the handle to the console window
            Dim sysMenu As IntPtr = GetSystemMenu(handle, False) ' Get the handle to the system menu of the console window
            If handle <> IntPtr.Zero Then
                DeleteMenu(sysMenu, SC_CLOSE, MF_BYCOMMAND) ' To prevent user from closing console window
                'DeleteMenu(sysMenu, SC_MINIMIZE, MF_BYCOMMAND) 'To prevent user from minimizing console window
                'DeleteMenu(sysMenu, SC_MAXIMIZE, MF_BYCOMMAND) 'To prevent user from maximizing console window
                'DeleteMenu(sysMenu, SC_SIZE, MF_BYCOMMAND) 'To prevent the use from re-sizing console window
                DisableQuickEdit()
            End If
        End Sub
    End Class
End Class
