using System.Security.Cryptography;
using Xunit;
using Assert = Xunit.Assert;

namespace eProcurementNext.CommonModule.Test
{
    public class CifraturaTest
    {
        [Fact]
        public void decifraTest()
        {
            string dir = "TestFiles";
            string chiaveFileName = Path.Combine(dir, "chiave_file_cifrato.txt");
            string cifratoFileName = Path.Combine(dir, "cifrato.pdf");
            string decifratoFileName = Path.Combine(dir, "decifrato.pdf");
            string ricifratoFileName = Path.Combine(dir, "ricifrato.pdf");

            Assert.True(File.Exists(chiaveFileName));
            Assert.True(File.Exists(cifratoFileName));

            string chiaveCifratura = File.ReadAllText(chiaveFileName);
            Assert.NotEmpty(chiaveCifratura);

            // crea directory

            if (!Directory.Exists(dir))
            {
                Directory.CreateDirectory(dir);
            }


            var cifratura = new Cifratura();

            string res = "";

            // decifra
            res = cifratura.CifraturaFile(cifratoFileName, decifratoFileName, chiaveCifratura, false, string.Empty);
            Assert.Empty(res);
            Assert.True(File.Exists(decifratoFileName));

            // cifra di nuovo
            cifratura.CifraturaFile(decifratoFileName, ricifratoFileName, chiaveCifratura, true, string.Empty);
            Assert.Empty(res);
            Assert.True(File.Exists(decifratoFileName));

            // verifica
            using (FileStream fs1 = File.Open(cifratoFileName, FileMode.Open, FileAccess.Read),
                    fs2 = File.Open(ricifratoFileName, FileMode.Open, FileAccess.Read))
            {
                byte[] hash1 = SHA256.Create().ComputeHash(fs1);
                byte[] hash2 = SHA256.Create().ComputeHash(fs2);
                Assert.Equal(hash1, hash2);
            }

            // cleaning

            if (File.Exists(cifratoFileName))
            {
                File.Delete(cifratoFileName);
            }

            if (File.Exists(ricifratoFileName))
            {
                File.Delete(ricifratoFileName);
            }
        }

        [Fact]
        public void cifraTest()
        {
            string dir = "TestFiles";
            string chiaveFileName = Path.Combine(dir, "chiave_file_cifrato2.txt");
            string dacifrareFileName = Path.Combine(dir, "dacifrare.zip");
            string cifratoFileName = Path.Combine(dir, "cifrato.zip");
            string decifratoFileName = Path.Combine(dir, "decifrato.zip");

            Assert.True(File.Exists(chiaveFileName));
            Assert.True(File.Exists(dacifrareFileName));

            string chiaveCifratura = File.ReadAllText(chiaveFileName);
            Assert.NotEmpty(chiaveCifratura);

            // crea directory

            if (!Directory.Exists(dir))
            {
                Directory.CreateDirectory(dir);
            }


            var cifratura = new Cifratura();

            string res = "";

            // cifra
            res = cifratura.CifraturaFile(dacifrareFileName, cifratoFileName, chiaveCifratura, true, string.Empty);
            Assert.Empty(res);
            Assert.True(File.Exists(cifratoFileName));

            // decifra
            cifratura.CifraturaFile(cifratoFileName, decifratoFileName, chiaveCifratura, false, string.Empty);
            Assert.Empty(res);
            Assert.True(File.Exists(decifratoFileName));

            // verifica
            using (FileStream fs1 = File.Open(dacifrareFileName, FileMode.Open, FileAccess.Read),
                    fs2 = File.Open(decifratoFileName, FileMode.Open, FileAccess.Read))
            {
                byte[] hash1 = SHA256.Create().ComputeHash(fs1);
                byte[] hash2 = SHA256.Create().ComputeHash(fs2);
                Assert.Equal(hash1, hash2);
            }

            // cleaning

            if (File.Exists(cifratoFileName))
            {
                File.Delete(cifratoFileName);
            }

            if (File.Exists(decifratoFileName))
            {
                File.Delete(decifratoFileName);
            }
        }
    }
}
