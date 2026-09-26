namespace EduNest.App_Code
{
    /// <summary>Maps course subjects to bundled, local course artwork.</summary>
    public static class CourseVisualHelper
    {
        public static string GetImagePath(string category)
        {
            switch (category ?? string.Empty)
            {
                case "AI & Machine Learning": return "~/Images/Courses/course-ai.svg";
                case "Networking & Infrastructure": return "~/Images/Courses/course-network.svg";
                case "Data & Analytics": return "~/Images/Courses/course-data.svg";
                case "Cloud & DevOps": return "~/Images/Courses/course-cloud.svg";
                case "Cybersecurity": return "~/Images/Courses/course-security.svg";
                case "Mobile Development": return "~/Images/Courses/course-mobile.svg";
                case "Product Design": return "~/Images/Courses/course-design.svg";
                case "Web3 & Blockchain": return "~/Images/Courses/course-blockchain.svg";
                default: return "~/Images/Courses/course-web.svg";
            }
        }
    }
}
