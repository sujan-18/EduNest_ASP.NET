using System;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient;

namespace EduNest.App_Code
{
    /// <summary>
    /// Central ADO.NET data-access helper. All pages route their MySQL
    /// calls through here so connection handling and parameterization
    /// (SQL-injection protection) is done in exactly one place.
    /// </summary>
    public static class DBHelper
    {
        private static string ConnStr
        {
            get
            {
                ConnectionStringSettings settings = ConfigurationManager.ConnectionStrings["EduNestDB"];
                if (settings == null || String.IsNullOrWhiteSpace(settings.ConnectionString))
                {
                    throw new ConfigurationErrorsException(
                        "The 'EduNestDB' connection string is missing or empty. Add it to Web.ConnectionStrings.config and set the MySQL server, database, user, and password.");
                }
                return settings.ConnectionString;
            }
        }

        public static DataTable ExecuteQuery(string sql, params MySqlParameter[] parameters)
        {
            DataTable dt = new DataTable();
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parameters != null) cmd.Parameters.AddRange(parameters);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
            return dt;
        }

        public static int ExecuteNonQuery(string sql, params MySqlParameter[] parameters)
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parameters != null) cmd.Parameters.AddRange(parameters);
                conn.Open();
                return cmd.ExecuteNonQuery();
            }
        }

        public static object ExecuteScalar(string sql, params MySqlParameter[] parameters)
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parameters != null) cmd.Parameters.AddRange(parameters);
                conn.Open();
                return cmd.ExecuteScalar();
            }
        }

        /// <summary>Returns the auto-increment ID of the row just inserted.</summary>
        public static long ExecuteInsertAndGetId(string sql, params MySqlParameter[] parameters)
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parameters != null) cmd.Parameters.AddRange(parameters);
                conn.Open();
                cmd.ExecuteNonQuery();
                return cmd.LastInsertedId;
            }
        }
    }
}
