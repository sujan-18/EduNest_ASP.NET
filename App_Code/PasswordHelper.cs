using System;
using System.Security.Cryptography;
using System.Text;

namespace EduNest.App_Code
{
    /// <summary>
    /// Handles salted password hashing so plain-text passwords are never
    /// stored in the Users table.
    /// </summary>
    public static class PasswordHelper
    {
        private const int Iterations = 120000;

        public static string GenerateSalt()
        {
            byte[] saltBytes = new byte[16];
            using (RandomNumberGenerator rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(saltBytes);
            }
            return Convert.ToBase64String(saltBytes);
        }

        public static string HashPassword(string password, string salt)
        {
            byte[] saltBytes = Convert.FromBase64String(salt);
            using (var derive = new Rfc2898DeriveBytes(password, saltBytes, Iterations))
                return "pbkdf2$" + Iterations + "$" + Convert.ToBase64String(derive.GetBytes(32));
        }

        public static bool VerifyPassword(string password, string salt, string storedHash)
        {
            if (storedHash.StartsWith("pbkdf2$", StringComparison.Ordinal))
            {
                string[] parts = storedHash.Split('$');
                int iterations;
                if (parts.Length != 3 || !int.TryParse(parts[1], out iterations) || iterations < 1) return false;
                byte[] expected;
                try { expected = Convert.FromBase64String(parts[2]); }
                catch (FormatException) { return false; }
                using (var derive = new Rfc2898DeriveBytes(password, Convert.FromBase64String(salt), iterations))
                    return FixedTimeEquals(expected, derive.GetBytes(expected.Length));
            }

            // One-time compatibility for the demo accounts / existing installs
            // that were created with the original salted SHA-256 format.
            using (SHA256 sha = SHA256.Create())
            {
                byte[] legacy = sha.ComputeHash(Encoding.UTF8.GetBytes(password + salt));
                byte[] expected;
                try { expected = Convert.FromBase64String(storedHash); }
                catch (FormatException) { return false; }
                return FixedTimeEquals(expected, legacy);
            }
        }

        private static bool FixedTimeEquals(byte[] left, byte[] right)
        {
            if (left == null || right == null || left.Length != right.Length) return false;
            int difference = 0;
            for (int i = 0; i < left.Length; i++) difference |= left[i] ^ right[i];
            return difference == 0;
        }
    }
}
