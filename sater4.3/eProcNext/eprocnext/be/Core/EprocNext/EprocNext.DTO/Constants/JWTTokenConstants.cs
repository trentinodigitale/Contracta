using System.Text;

namespace Core.Common.Constants.Authentication
{
    public static class JWTTokenConstants
    {
        public static byte[] IssuerSigningKey => Encoding.ASCII.GetBytes("superSecretKey@345");
    }
}
