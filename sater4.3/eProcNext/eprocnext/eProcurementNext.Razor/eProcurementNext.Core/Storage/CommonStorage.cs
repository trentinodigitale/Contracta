using System.IO.Enumeration;
using Microsoft.AspNetCore.Http;

namespace eProcurementNext.Core.Storage
{
    public class CommonStorage
    {
        public static IList<string> ListObjects(string fullName, string searchPattern = "*", SearchOption searchOption = SearchOption.AllDirectories)
        {
            return Directory.GetFiles(fullName, searchPattern, searchOption);
        }
        public static IList<string> ListDirectories(string fullName)
        {
            return Directory.GetDirectories(fullName);
        }

        public static bool FileExists(string fullName)
        {
            return File.Exists(fullName);
        }
        public static bool DirectoryExists(string fullName)
        {
            return Directory.Exists(fullName);
        }

        public static bool ExistsDirectory(string path)
        {
            return DirectoryExists(path);
        }

        public static bool ExistsFile(string path)
        {
            return FileExists(path);
        }

        public static string PathCombine(string pathBase, string fileName)
        {
            return System.IO.Path.Combine(pathBase, fileName);
        }

        public static Stream Get(string fullName)
        {
            if (!File.Exists(fullName))
            {
                throw new FileNotFoundException("file non esiste");
            }

            Stream stream = File.Open(fullName, FileMode.Open, FileAccess.Read);
            return stream;
        }
        public static string ReadAllText(string fullName)
        {
            return File.ReadAllText(fullName);
        }

        public static void Write(string fullName, string row)
        {
            try
            {
                using StreamWriter sw = File.AppendText(fullName);
                sw.WriteLine(row);
            }
            catch (Exception ex)
            {
                throw new Exception("Impossibile scrivere il file " + fullName, ex);
            }
        }

        public static void Save(string fullName, Stream stream)
        {
            using Stream fs = File.OpenWrite(fullName);
            stream.CopyTo(fs);
        }
        public static void Save(string fullName, IFormFile stream)
        {
            using Stream fs = File.OpenWrite(fullName);
            stream.CopyTo(fs);
        }

        public static void DeleteObject(string fullName, bool force = false)
        {
            try
            {
                try
                {
                    if (force)
                    {
                        File.SetAttributes(fullName, FileAttributes.Normal);
                    }
                }
                catch (Exception)
                {
                }

                File.Delete(fullName);
            }
            catch (Exception ex)
            {
                throw new Exception("Impossibile cancellare il file " + fullName, ex);
            }
        }

        /// <summary>
        /// Deletes the directory indicated in the fullName
        /// </summary>
        /// <param name="fullName"></param>
        /// <param name="checkIfExists"></param>
        /// <param name="throwEx"></param>
        public static void DeleteDirectory(string fullName, bool checkIfExists = false, bool throwEx = true)
        {
            try
            {
                if (!checkIfExists)
                {
                    if (DirectoryExists(fullName))
                    {
                        Directory.Delete(fullName, true);
                    }
                }
                else
                {
                    Directory.Delete(fullName, true);

                }
            }
            catch
            {
                if (throwEx)
                {
                    throw;
                }
            }
        }
        public static DirectoryInfo CreateFolder(string path)
        {
            return Directory.CreateDirectory(path);
        }

        public static DirectoryInfo CreateDirectory(string path)
        {
            return CreateFolder(path);
        }

        public static void DeleteFile(string fullName, bool force = false)
        {
            DeleteObject(fullName, force);
        }

        public static string GetTempName(string ext = "")
        {
            //string tempName = DateTime.Now.Ticks.ToString("X");
            string tempName = $"{Guid.NewGuid()}".Replace("-", "");
            if (!string.IsNullOrEmpty(ext))
            {
                tempName += "." + ext;
            }
            return tempName;
        }

        public static void CheckExistsAndDelete(string fullName, bool force = false, bool throwEx = true)
        {
            try
            {
                if (FileExists(fullName))
                    DeleteFile(fullName, force);
            }
            catch
            {
                if (throwEx)
                    throw;
            }

        }

        public static string GetNormalizedFileExtension(string fileName, bool toUpper = true)
        {
            string ext = System.IO.Path.GetExtension(fileName);

            if (!string.IsNullOrEmpty(ext))
            {
                ext = ext.Replace(".", "");

                if (toUpper)
                    ext = ext.ToUpper();
            }

            return ext;
        }

    }
}
