using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace EduNest.App_Code
{
    /// <summary>
    /// Central ADO.NET data-access helper. All pages route their SQL Server
    /// calls through here so connection handling and parameterization
    /// (SQL-injection protection) is done in exactly one place.
    /// </summary>
    public static class DBHelper
    {
        private static readonly object LearningPathSchemaLock = new object();
        private static bool learningPathResourceColumnsReady;

        private static string ConnStr
        {
            get
            {
                ConnectionStringSettings settings = ConfigurationManager.ConnectionStrings["EduNestDB"];
                if (settings == null || String.IsNullOrWhiteSpace(settings.ConnectionString))
                {
                    throw new ConfigurationErrorsException(
                        "The 'EduNestDB' connection string is missing or empty. Add it to Web.ConnectionStrings.config.");
                }
                return settings.ConnectionString;
            }
        }

        /// <summary>
        /// Adds optional learning-resource columns to older LocalDB databases.
        /// This small additive migration lets existing installations keep using
        /// the learning path without first recreating their database.
        /// </summary>
        public static void EnsureLearningPathResourceColumns()
        {
            if (learningPathResourceColumnsReady) return;
            lock (LearningPathSchemaLock)
            {
                if (learningPathResourceColumnsReady) return;
                ExecuteNonQuery(@"IF OBJECT_ID(N'dbo.LearningPathTopics', N'U') IS NOT NULL
                BEGIN
                    IF COL_LENGTH(N'dbo.LearningPathTopics', N'ResourceTitle') IS NULL
                        ALTER TABLE dbo.LearningPathTopics ADD ResourceTitle NVARCHAR(200) NULL;
                    IF COL_LENGTH(N'dbo.LearningPathTopics', N'ResourceUrl') IS NULL
                        ALTER TABLE dbo.LearningPathTopics ADD ResourceUrl NVARCHAR(500) NULL;
                END");
                learningPathResourceColumnsReady = true;
            }
        }

        public static DataTable ExecuteQuery(string sql, params SqlParameter[] parameters)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                if (parameters != null) cmd.Parameters.AddRange(parameters);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
            return dt;
        }

        public static int ExecuteNonQuery(string sql, params SqlParameter[] parameters)
        {
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                if (parameters != null) cmd.Parameters.AddRange(parameters);
                conn.Open();
                return cmd.ExecuteNonQuery();
            }
        }

        public static object ExecuteScalar(string sql, params SqlParameter[] parameters)
        {
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                if (parameters != null) cmd.Parameters.AddRange(parameters);
                conn.Open();
                return cmd.ExecuteScalar();
            }
        }

        /// <summary>Returns the auto-increment ID of the row just inserted.</summary>
        public static long ExecuteInsertAndGetId(string sql, params SqlParameter[] parameters)
        {
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                if (parameters != null) cmd.Parameters.AddRange(parameters);
                conn.Open();
                cmd.CommandText += "; SELECT CAST(SCOPE_IDENTITY() AS BIGINT);";
                return Convert.ToInt64(cmd.ExecuteScalar());
            }
        }
    }
}
