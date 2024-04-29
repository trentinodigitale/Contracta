using System.Security.Cryptography;
using System.Text.Json;
using System.Text.Json.Nodes;
using eProcurementNext.CommonModule.Exceptions;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;

namespace eProcurementNext.CommonModule
{

	public class Cifratura
	{

		public string CifraturaFile(string pathInputFile, string pathOutputFile, string chiaveDiCifratura, bool cifra,
			string connectionString = "")
		{
			var strCause = "";

			try
			{

				// -- controllo parametri
				if (string.IsNullOrEmpty(pathInputFile) || !File.Exists(pathInputFile))
				{
					return "Parametro pathInputFile non corretto";
				}

				if (string.IsNullOrEmpty(pathOutputFile))
				{
					return "Parametro pathInputFile non corretto";
				}

				if (string.IsNullOrEmpty(chiaveDiCifratura))
				{
					return "Chiave di cifratura non passata";
				}

				if (File.Exists(pathOutputFile)) // -- se esiste gia un file con lo stesso nome lo cancello
				{
					strCause = "Provo a cancellare un precedente file decifrato con lo stesso nome";
					File.Delete(pathOutputFile);
				}

				// Dim chiave As String = "144A2640-1DD3-4F6A-A7C6-90CD39C36D89"
				strCause = "Genero i byte a partire dalla chiave di cifratura";
				var keyByte = System.Text.Encoding.UTF8.GetBytes(chiaveDiCifratura);

				strCause = "Invocazione getSalt";
				var saltBytes = GetSalt();

				strCause = "Genero l'hash della chiave";

				// Hash della password con SHA256
				keyByte = SHA256.Create().ComputeHash(keyByte);

				strCause = "Leggo il file di input";
				var fileOriginale = File.ReadAllBytes(pathInputFile);

				strCause = "Invocazione encryptByteArray";
				var outputByte = EncryptByteArray(cifra, fileOriginale, keyByte, saltBytes);

				strCause = "Scrivo su disco il file di output";
				File.WriteAllBytes(pathOutputFile, outputByte);
			}

			catch (Exception e)
			{
				return strCause + " - " + e;
			}

			return string.Empty; //tutto ok
		}

		private static byte[] GetSalt()
		{
			return new[] { (byte)19, (byte)86, (byte)19, (byte)88, (byte)90, (byte)60, (byte)90, (byte)3 };
		}

		private static byte[] EncryptByteArray(bool cifra, byte[] sourceByte, byte[] keyByte, byte[] saltBytes)
		{
			byte[] outputByte;
			var strCause = string.Empty;

			try
			{
				using var myAes = Aes.Create();
				myAes.KeySize = 256;
				myAes.BlockSize = 128;
				strCause = "Creazione oggetto key";
				var key = new Rfc2898DeriveBytes(keyByte, saltBytes, 1000);

				strCause = "Settaggio key";
                //myAes.Key = key.GetBytes((int)Math.Round(myAes.KeySize / 8d));
                myAes.Key = key.GetBytes(myAes.KeySize / 8);

                strCause = "Settaggio IV";
                //myAes.IV = key.GetBytes((int)Math.Round(myAes.BlockSize / 8d));
                myAes.IV = key.GetBytes(myAes.BlockSize / 8);

                if (cifra)
				{
					strCause = "Invoco il metodo di cifratura";
					outputByte = AES_Encrypt(sourceByte, myAes.Key, myAes.IV);
				}
				else
				{
                    try
                    {
                        strCause = "Invoco il metodo di decifratura senza forceClose";
                        outputByte = AES_Decrypt(sourceByte, myAes.Key, myAes.IV);
                    }
                    catch (DataBlockCryptographicException e)
                    {
						//Per massimizzare la retrocompatibilità metto in "resume next" la .close() solo per le decrypt in eccezione
                        strCause = $"Invoco il metodo di decifratura con forceClose dopo l'eccezione {e.Message}";
                        outputByte = AES_Decrypt(sourceByte, myAes.Key, myAes.IV, true);
                    }
				}
			}
			catch (Exception ex)
			{
				throw new DataEncryptionException($"{strCause} - {ex.Message}", ex);
			}

			return outputByte;
		}

		public static byte[]? EncryptGenericData<T>(T original, string chiaveDiCifratura)
		{
			if (original is null)
				return null;

			var strCause = string.Empty;

			try
			{
				strCause = "Data Incapsulation";
				var container = new DataStore<T>(original);

				strCause = "call container.ToBson";
				//var bSonDoc = container.ToBsonDocument();
				var arrayByteBson = container.ToBson();

				//strCause = "call bSonDoc.AsByteArray";
				//var arrabyByteBson = bSonDoc.AsByteArray;
				//var arrayByteBson = bSonDoc.ToBson();

				strCause = "get byte of key";
				var keyByte = System.Text.Encoding.UTF8.GetBytes(chiaveDiCifratura);

				strCause = "get salt";
				var saltBytes = GetSalt();

				strCause = "call ComputeHash";
				// Hash della password con SHA256
				keyByte = SHA256.Create().ComputeHash(keyByte);

				strCause = "call EncryptByteArray";
				var encryptedByte = EncryptByteArray(true, arrayByteBson, keyByte, saltBytes);

				//var serial = JsonSerializer.Serialize<T>(original);
				//var cryptJson = EncryptString(serial,chiaveDiCifratura);
				return encryptedByte;
			}
			catch (Exception ex)
			{
				throw new DataEncryptionException($"{strCause} - {ex.Message}", ex);
			}
		}

		public static T? DecryptGenericData<T>(byte[]? encrypted, string chiaveDiCifratura)
		{
			if (encrypted is null)
				return default;

			var keyByte = System.Text.Encoding.UTF8.GetBytes(chiaveDiCifratura);
			var saltBytes = GetSalt();
			keyByte = SHA256.Create().ComputeHash(keyByte);

			var decryptedByte = EncryptByteArray(false, encrypted, keyByte, saltBytes);

			DataStore<T> container = BsonSerializer.Deserialize<DataStore<T>>(decryptedByte);
			return container._data;

			//var decryptJson = EncryptString(encrypted, chiaveDiCifratura, false);
			//return JsonSerializer.Deserialize<T>(decryptJson);
		}

		public static string EncryptString(string stringa, string chiaveDiCifratura, bool cifra = true)
		{

			// -- controllo parametri
			if (string.IsNullOrEmpty(stringa))
			{
				throw new DataEncryptionException("string to encrypt null");
			}

			if (string.IsNullOrEmpty(chiaveDiCifratura))
			{
				throw new DataEncryptionException("the crypto key is null");
			}

			// Dim chiave As String = "144A2640-1DD3-4F6A-A7C6-90CD39C36D89"
			var keyByte = System.Text.Encoding.UTF8.GetBytes(chiaveDiCifratura);

			var saltBytes = GetSalt();

			// Hash della password con SHA256
			keyByte = SHA256.Create().ComputeHash(keyByte);

			using var myAes = Aes.Create();
			myAes.KeySize = 256;
			myAes.BlockSize = 128;
			var key = new Rfc2898DeriveBytes(keyByte, saltBytes, 1000);

			myAes.Key = key.GetBytes((int)Math.Round(myAes.KeySize / 8d));
			myAes.IV = key.GetBytes((int)Math.Round(myAes.BlockSize / 8d));

			return cifra
				? System.Text.Encoding.Default.GetString(EncryptStringToBytes_Aes(stringa, myAes.Key, myAes.IV))
				: DecryptStringFromBytes_Aes(System.Text.Encoding.UTF8.GetBytes(stringa), myAes.Key, myAes.IV);
		}

		private static byte[] EncryptStringToBytes_Aes(string plainText, byte[] key, byte[] IV)
		{

			if (plainText is null || plainText.Length <= 0)
			{
				throw new ArgumentNullException(nameof(plainText));
			}

			if (key is null || key.Length <= 0)
			{
				throw new ArgumentNullException(nameof(key));
			}

			if (IV is null || IV.Length <= 0)
			{
				throw new ArgumentNullException(nameof(key));
			}

			using var aesAlg = Aes.Create();
			aesAlg.Key = key;
			aesAlg.IV = IV;
			aesAlg.Mode = CipherMode.CBC; // Cipher Block Chaining


			var encryptor = aesAlg.CreateEncryptor(aesAlg.Key, aesAlg.IV);

			using var msEncrypt = new MemoryStream();
			using var csEncrypt = new CryptoStream(msEncrypt, encryptor, CryptoStreamMode.Write);
			using (var swEncrypt = new StreamWriter(csEncrypt))
			{
				swEncrypt.Write(plainText);
			}

			var encrypted = msEncrypt.ToArray();

			return encrypted;

		}

		private static string DecryptStringFromBytes_Aes(byte[] cipherText, byte[] key, byte[] IV)
		{

			if (cipherText is null || cipherText.Length <= 0)
			{
				throw new ArgumentNullException(nameof(cipherText));
			}

			if (key is null || key.Length <= 0)
			{
				throw new ArgumentNullException(nameof(key));
			}

			if (IV is null || IV.Length <= 0)
			{
				throw new ArgumentNullException(nameof(key));
			}

			string? plaintext = null;

			using var aesAlg = Aes.Create();
			aesAlg.Key = key;
			aesAlg.IV = IV;
			aesAlg.Mode = CipherMode.CBC; // Cipher Block Chaining

			var decryptor = aesAlg.CreateDecryptor(aesAlg.Key, aesAlg.IV);

			using var msDecrypt = new MemoryStream(cipherText);

			using var csDecrypt = new CryptoStream(msDecrypt, decryptor, CryptoStreamMode.Read);

			using var srDecrypt = new StreamReader(csDecrypt);
			plaintext = srDecrypt.ReadToEnd();

			return plaintext;

		}

		private static byte[] AES_Encrypt(byte[] bytesToBeEncrypted, byte[] key, byte[] IV)
		{
			using var aes = Aes.Create();
			aes.Key = key;
			aes.IV = IV;
			aes.Mode = CipherMode.CBC; // Cipher Block Chaining

			var encryptor = aes.CreateEncryptor(aes.Key, aes.IV);

			using var msDecrypt = new MemoryStream();

			using (var cs = new CryptoStream(msDecrypt, encryptor, CryptoStreamMode.Write))
			{

				cs.Write(bytesToBeEncrypted, 0, bytesToBeEncrypted.Length);
				cs.Close();
			}

			return msDecrypt.ToArray();

		}

		private static byte[] AES_Decrypt(byte[] bytesToBeDecrypted, byte[] key, byte[] IV, bool forceClose = false)
		{

			byte[] decryptedBytes;
			var strCause = "";

            try
            {
                using var aes = Aes.Create();

                aes.Key = key;
                aes.IV = IV;
                aes.Mode = CipherMode.CBC; // Cipher Block Chaining

                //aes.Padding = PaddingMode.PKCS7; --> NON FUNZIONA! non aggiunge l'ultimo blocco! come invece dovrebbe...

                using var decryptor = aes.CreateDecryptor(aes.Key, aes.IV);

                using var msDecrypt = new MemoryStream();

                using (var cs = new CryptoStream(msDecrypt, decryptor, CryptoStreamMode.Write))
                {
                    strCause = "Invoco la write sul CryptoStream";
                    cs.Write(bytesToBeDecrypted, 0, bytesToBeDecrypted.Length);

                    //strCause = "Mandiamo in flush l'eventuale ultimo block non scritto dalla write";
                    //cs.FlushFinalBlock(); <--- se abbiamo l'errore 'The input data is not a complete block.' sulla Close(), chiamando questa flush anticipiamo il problema e comunque non risolviamo

                    try
                    {
                        strCause = "Effettuo la close del cryptStream";
                        cs.Close();
                    }
                    catch (CryptographicException e)
                    {
                        strCause += $" - CryptographicException - {e.Message}";
                        //skippiamo l'eccezione System.Security.Cryptography.CryptographicException: The input data is not a complete block.
                        //abbiamo verificato che la close in eccezione blocca il processo di decodifica ma il file era stato comunque decifrato correttamente.
                        //tra l'altro comunque la using di questo stream effettua una dispose, cioè una close

                        if (!forceClose)
                        {
                            throw new DataBlockCryptographicException(e.Message, e);
                        }

                    }

                }

                strCause = "invoco la ToArray sul MemoryStream";
                decryptedBytes = msDecrypt.ToArray();

            }
            catch (DataBlockCryptographicException ex)
            {
				//l'eccezione lanciata per l'errore sulla close() la lascio risalire per poterla gestire in modo specifico
                throw;
            }
			catch (Exception ex)
			{
				throw new DataEncryptionException("Eccezione nel metodo AES_Decrypt, " + strCause, ex);
			}

			return decryptedBytes;

		}

		/// <summary>
		/// Classe utile a risolvere il problema : System.InvalidOperationException: 'An Array value cannot be written to the root level of a BSON document.'
		/// </summary>
		/// <typeparam name="T"></typeparam>
		private class DataStore<T>
		{
			public T _data; //Non cambiare questo dato, se si metteva private o readonly il bson produceva sempre null

			public DataStore(T data)
			{
				this._data = data;
			}
		}

	}
}

